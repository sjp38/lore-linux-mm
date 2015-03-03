Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4836B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 22:26:05 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so13614995pdb.5
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 19:26:05 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id oi3si8284960pdb.209.2015.03.02.19.26.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 19:26:04 -0800 (PST)
Received: by pabli10 with SMTP id li10so19959279pab.13
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 19:26:03 -0800 (PST)
Date: Tue, 3 Mar 2015 12:25:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC V3] mm: change mm_advise_free to clear page dirty
Message-ID: <20150303032537.GA25015@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Michal Hocko' <mhocko@suse.cz>, 'Andrew Morton' <akpm@linux-foundation.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Rik van Riel' <riel@redhat.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Shaohua Li' <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>

Could you separte this patch in this patchset thread?
It's tackling differnt problem.

As well, I had a question to previous thread about why shared page
has a problem now but you didn't answer and send a new patchset.
It makes reviewers/maintainer time waste/confuse. Please, don't
hurry to send a code. Before that, resolve reviewers's comments.

On Tue, Mar 03, 2015 at 10:06:40AM +0800, Wang, Yalin wrote:
> This patch add ClearPageDirty() to clear AnonPage dirty flag,
> if not clear page dirty for this anon page, the page will never be
> treated as freeable. We also make sure the shared AnonPage is not
> freeable, we implement it by dirty all copyed AnonPage pte,
> so that make sure the Anonpage will not become freeable, unless
> all process which shared this page call madvise_free syscall.

Please, spend more time to make description clear. I really doubt
who understand this description without code inspection. :(
Of course, I'm not a person to write description clear like native
, either but just I'm sure I spend a more time to write description
rather than coding, at least. :)

> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  mm/madvise.c | 16 +++++++++-------
>  mm/memory.c  | 12 ++++++++++--
>  2 files changed, 19 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 6d0fcb8..b61070d 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -297,23 +297,25 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  			continue;
>  
>  		page = vm_normal_page(vma, addr, ptent);
> -		if (!page)
> +		if (!page || !trylock_page(page))
>  			continue;
>  
>  		if (PageSwapCache(page)) {
> -			if (!trylock_page(page))
> -				continue;
> -
>  			if (!try_to_free_swap(page)) {
>  				unlock_page(page);
>  				continue;
>  			}
> -
> -			ClearPageDirty(page);
> -			unlock_page(page);
>  		}
>  
>  		/*
> +		 * we clear page dirty flag for AnonPage, no matter if this
> +		 * page is in swapcahce or not, AnonPage not in swapcache also set
> +		 * dirty flag sometimes, this happened when a AnonPage is removed
> +		 * from swapcahce by try_to_free_swap()
> +		 */
> +		ClearPageDirty(page);
> +		unlock_page(page);
> +		/*

Parent:

ptrP = malloc();
*ptrP = 'a';
fork(); -> child process pte has dirty by your patch
..
memory pressure -> So, swapped out the page.
..
..
Child: var = *ptrP; assert(var =='a') -> So, swapin happens and child has pte_clean
parent: var = *ptrP; aasert(var == 'a') -> So, swapin happens and parent has pte_clean
..
..
Parent:
madvise_free -> remove PageDirty
So, both parent and child has pte_clean and !PageDirty, which
is target for VM to discard a page.
..
VM discard the page by memory pressure.
..
Child: var = *ptrP: assert(var == 'a'); <---- oops.

And blindly ClearPageDirty makes duplicates swap out.

>  		 * Some of architecture(ex, PPC) don't update TLB
>  		 * with set_pte_at and tlb_remove_tlb_entry so for
>  		 * the portability, remap the pte with old|clean
> diff --git a/mm/memory.c b/mm/memory.c
> index 8068893..3d949b3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -874,10 +874,18 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	if (page) {
>  		get_page(page);
>  		page_dup_rmap(page);
> -		if (PageAnon(page))
> +		if (PageAnon(page)) {
> +			/*
> +			 * we dirty the copyed pte for anon page,
> +			 * this is useful for madvise_free_pte_range(),
> +			 * this can prevent shared anon page freed by madvise_free
> +			 * syscall
> +			 */
> +			pte = pte_mkdirty(pte);

It made every MADV_FREE hinted page void. IOW, if a process called MADV_FREE
calls fork, VM cannot discard pages if child doesn't free pages or calls madvise_free.
Then, if parent calls madvise_free before fork, we couldn't free those pages.
IOW, you are ignoring below example.

parent:
ptr1 = malloc(len);
        -> allocator calls mmap(len);
memset(ptr1, 'a', len);
free(ptr1);
        -> allocator calls madvise_free(ptr1, len);
fork();
..
..
        -> VM discard hinted pages
child:

ptr2 = malloc(len)
        -> allocator reuses the chunk allocated from parent.
so, child will see zero pages from ptr2 but he doesn't write
anything so garbage|zero page anything is okay to him.

As well, you are adding new instructions in fork which is very frequent syscall
so I'd like to find another way to avoid adding instructions in such hot path.

I will send different patch. Please review it.

So, my suggestion is below. It always makes pte dirty so let's Cc
Cyrill to take care of softdirty and Hugh who is Mr.Swap.
