Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 032AF6003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 13:03:41 -0500 (EST)
Message-ID: <4B5F2E52.2080608@redhat.com>
Date: Tue, 26 Jan 2010 13:02:58 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 22 of 31] split_huge_page paging
References: <patchbomb.1264513915@v2.random> <3e6e5d853907eafd664a.1264513937@v2.random>
In-Reply-To: <3e6e5d853907eafd664a.1264513937@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 01/26/2010 08:52 AM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Paging logic that splits the page before it is unmapped and added to swap to
> ensure backwards compatibility with the legacy swap code. Eventually swap
> should natively pageout the hugepages to increase performance and decrease
> seeking and fragmentation of swap space. swapoff can just skip over huge pmd as
> they cannot be part of swap yet. In add_to_swap be careful to split the page
> only if we got a valid swap entry so we don't split hugepages with a full swap.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> ---
>
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -378,6 +378,8 @@ static void collect_procs_anon(struct pa
>   	struct task_struct *tsk;
>   	struct anon_vma *av;
>
> +	if (unlikely(split_huge_page(page)))
> +		return;
>   	read_lock(&tasklist_lock);
>   	av = page_lock_anon_vma(page);
>   	if (av == NULL)	/* Not actually mapped anymore */
> diff --git a/mm/rmap.c b/mm/rmap.c
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1174,6 +1174,7 @@ int try_to_unmap(struct page *page, enum
>   	int ret;
>
>   	BUG_ON(!PageLocked(page));
> +	BUG_ON(PageTransHuge(page));
>
>   	if (unlikely(PageKsm(page)))
>   		ret = try_to_unmap_ksm(page, flags);
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -156,6 +156,12 @@ int add_to_swap(struct page *page)
>   	if (!entry.val)
>   		return 0;
>
> +	if (unlikely(PageTransHuge(page)))
> +		if (unlikely(split_huge_page(page))) {
> +			swapcache_free(entry, NULL);
> +			return 0;
> +		}
> +
>   	/*
>   	 * Radix-tree node allocations from PF_MEMALLOC contexts could
>   	 * completely exhaust the page allocator. __GFP_NOMEMALLOC

Shouldn't we split up these pages in vmscan.c, before calling
add_to_swap() ?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
