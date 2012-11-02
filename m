Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 543316B004D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 23:21:24 -0400 (EDT)
Message-ID: <50933CB6.6000909@redhat.com>
Date: Fri, 02 Nov 2012 11:23:34 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/31] numa/core patches
References: <20121025121617.617683848@chello.nl> <508A52E1.8020203@redhat.com> <1351242480.12171.48.camel@twins> <20121028175615.GC29827@cmpxchg.org> <508F73C5.7050409@redhat.com> <20121031004838.GA1657@cmpxchg.org> <alpine.LNX.2.00.1210302350140.5084@eggly.anvils> <50912478.2040403@redhat.com> <alpine.LNX.2.00.1210311005220.5685@eggly.anvils> <alpine.LNX.2.00.1211010636140.3648@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1211010636140.3648@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, CAI Qian <caiqian@redhat.com>

On 11/01/2012 09:41 PM, Hugh Dickins wrote:
> On Wed, 31 Oct 2012, Hugh Dickins wrote:
>> On Wed, 31 Oct 2012, Zhouping Liu wrote:
>>> On 10/31/2012 03:26 PM, Hugh Dickins wrote:
>>>> There's quite a few put_page()s in do_huge_pmd_numa_page(), and it
>>>> would help if we could focus on the one which is giving the trouble,
>>>> but I don't know which that is.  Zhouping, if you can, please would
>>>> you do an "objdump -ld vmlinux >bigfile" of your kernel, then extract
>>>> from bigfile just the lines from "<do_huge_pmd_numa_page>:" to whatever
>>>> is the next function, and post or mail privately just that disassembly.
>>>> That should be good to identify which of the put_page()s is involved.
>>> Hugh, I didn't find the next function, as I can't find any words that matched
>>> "do_huge_pmd_numa_page".
>>> is there any other methods?
>> Hmm, do_huge_pmd_numa_page does appear in your stacktrace,
>> unless I've made a typo but am blind to it.
>>
>> Were you applying objdump to the vmlinux which gave you the
>> BUG at mm/memcontrol.c:1134! ?
> Thanks for the further info you then sent privately: I have not made any
> more effort to reproduce the issue, but your objdump did tell me that the
> put_page hitting the problem is the one on line 872 of mm/huge_memory.c,
> "Drop the local reference", just before successful return after migration.
>
> I didn't really get the inspiration I'd hoped for out of knowing that,
> but it did make wonder whether you're suffering from one of the issues
> I already mentioned, and I can now see a way in which it might cause
> the mm/memcontrol.c:1134 BUG:-
>
> migrate_page_copy() does TestClearPageActive on the source page:
> so given the unsafe way in which do_huge_pmd_numa_page() was proceeding
> with a !PageLRU page, it's quite possible that the page was sitting in
> a pagevec, and added to the active lru (so added to the lru_size of the
> active lru), but our final put_page removes it from lru, active flag has
> been cleared, so we subtract it from the lru_size of the inactive lru -
> that could indeed make it go negative and trigger the BUG.
>
> Here's a patch fixing and tidying up that and a few other things there.
> But I'm not signing it off yet, partly because I've barely tested it
> (quite probably I didn't even have any numa pmd migration happening
> at all), and partly because just a moment ago I ran across this
> instructive comment in __collapse_huge_page_isolate():
> 	/* cannot use mapcount: can't collapse if there's a gup pin */
> 	if (page_count(page) != 1) {
>
> Hmm, yes, below I've added the page_mapcount() check I proposed to
> do_huge_pmd_numa_page(), but is even that safe enough?  Do we actually
> need a page_count() check (for 2?) to guard against get_user_pages()?
> I suspect we do, but then do we have enough locking to stabilize such
> a check?  Probably, but...
>
> This will take more time, and I doubt get_user_pages() is an issue in
> your testing, so please would you try the patch below, to see if it
> does fix the BUGs you are seeing?  Thanks a lot.

Hugh, I have tested the patch for 5 more hours, the issue can't be 
reproduced again,
so I think it has fixed the issue, thank you :)

Zhouping

>
> Not-Yet-Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>
>   mm/huge_memory.c |   24 +++++++++---------------
>   1 file changed, 9 insertions(+), 15 deletions(-)
>
> --- 3.7-rc2+schednuma+johannes/mm/huge_memory.c	2012-11-01 04:10:43.812155671 -0700
> +++ linux/mm/huge_memory.c	2012-11-01 05:52:19.512153771 -0700
> @@ -745,7 +745,7 @@ void do_huge_pmd_numa_page(struct mm_str
>   	struct mem_cgroup *memcg = NULL;
>   	struct page *new_page = NULL;
>   	struct page *page = NULL;
> -	int node, lru;
> +	int node = -1;
>   
>   	spin_lock(&mm->page_table_lock);
>   	if (unlikely(!pmd_same(*pmd, entry)))
> @@ -762,7 +762,8 @@ void do_huge_pmd_numa_page(struct mm_str
>   		VM_BUG_ON(!PageCompound(page) || !PageHead(page));
>   
>   		get_page(page);
> -		node = mpol_misplaced(page, vma, haddr);
> +		if (page_mapcount(page) == 1)	/* Only do exclusively mapped */
> +			node = mpol_misplaced(page, vma, haddr);
>   		if (node != -1)
>   			goto migrate;
>   	}
> @@ -801,13 +802,11 @@ migrate:
>   	if (!new_page)
>   		goto alloc_fail;
>   
> -	lru = PageLRU(page);
> -
> -	if (lru && isolate_lru_page(page)) /* does an implicit get_page() */
> +	if (isolate_lru_page(page))	/* Does an implicit get_page() */
>   		goto alloc_fail;
>   
> -	if (!trylock_page(new_page))
> -		BUG();
> +	__set_page_locked(new_page);
> +	SetPageSwapBacked(new_page);
>   
>   	/* anon mapping, we can simply copy page->mapping to the new page: */
>   	new_page->mapping = page->mapping;
> @@ -820,8 +819,6 @@ migrate:
>   	spin_lock(&mm->page_table_lock);
>   	if (unlikely(!pmd_same(*pmd, entry))) {
>   		spin_unlock(&mm->page_table_lock);
> -		if (lru)
> -			putback_lru_page(page);
>   
>   		unlock_page(new_page);
>   		ClearPageActive(new_page);	/* Set by migrate_page_copy() */
> @@ -829,6 +826,7 @@ migrate:
>   		put_page(new_page);		/* Free it */
>   
>   		unlock_page(page);
> +		putback_lru_page(page);
>   		put_page(page);			/* Drop the local reference */
>   
>   		return;
> @@ -859,16 +857,12 @@ migrate:
>   	mem_cgroup_end_migration(memcg, page, new_page, true);
>   	spin_unlock(&mm->page_table_lock);
>   
> -	put_page(page);			/* Drop the rmap reference */
> -
>   	task_numa_fault(node, HPAGE_PMD_NR);
>   
> -	if (lru)
> -		put_page(page);		/* drop the LRU isolation reference */
> -
>   	unlock_page(new_page);
> -
>   	unlock_page(page);
> +	put_page(page);			/* Drop the rmap reference */
> +	put_page(page);			/* Drop the LRU isolation reference */
>   	put_page(page);			/* Drop the local reference */
>   
>   	return;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
