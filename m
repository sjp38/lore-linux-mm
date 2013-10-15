Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4B38F6B003B
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:34:17 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so8979614pde.37
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:34:16 -0700 (PDT)
Date: Tue, 15 Oct 2013 16:34:07 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: fix BUG in __split_huge_page_pmd
Message-ID: <20131015143407.GE3479@redhat.com>
References: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Tue, Oct 15, 2013 at 04:08:28AM -0700, Hugh Dickins wrote:
> Occasionally we hit the BUG_ON(pmd_trans_huge(*pmd)) at the end of
> __split_huge_page_pmd(): seen when doing madvise(,,MADV_DONTNEED).
> 
> It's invalid: we don't always have down_write of mmap_sem there:
> a racing do_huge_pmd_wp_page() might have copied-on-write to another
> huge page before our split_huge_page() got the anon_vma lock.
> 

I don't get exactly the scenario with do_huge_pmd_wp_page(), could you
elaborate?

My scenario is that in the below line another madvise(MADV_DONTNEED)
runs:

	spin_unlock(&mm->page_table_lock);
	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);

	------ madvise(MADV_DONTNEED) from another thread zapping the
               entire 2m and clearing the pmd

	split_huge_page(page);

then split_huge_page does nothing because the page has been freed. And
then just before the BUG_ON (after split_huge_page returns) a new page
fault fills in an anonymous page just before the BUG_ON.

And the crashing thread would always be a partial MADV_DONTNEED with a
misaligned end address (so requiring a split_huge_page to zap 4k
subpages).

So the testcase required would be: 2 concurrent MADV_DONTNEED, where
the first has a misaligned "end" address (the one that triggers the
BUG_ON), the second MADV_DONTNEED has a end address that covers the
whole hugepmd, and a trans huge page fault happening just before the
false positive triggers.

Maybe your scenario with do_huge_pmd_wp_page() is simpler?

> Forget the BUG_ON, just go back and try again if this happens.
>     
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org
> ---
> 
>  mm/huge_memory.c |   10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> --- 3.12-rc5/mm/huge_memory.c	2013-09-16 17:37:56.811072270 -0700
> +++ linux/mm/huge_memory.c	2013-10-15 03:40:02.044138488 -0700
> @@ -2697,6 +2697,7 @@ void __split_huge_page_pmd(struct vm_are
>  
>  	mmun_start = haddr;
>  	mmun_end   = haddr + HPAGE_PMD_SIZE;
> +again:
>  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>  	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_trans_huge(*pmd))) {
> @@ -2719,7 +2720,14 @@ void __split_huge_page_pmd(struct vm_are
>  	split_huge_page(page);
>  
>  	put_page(page);
> -	BUG_ON(pmd_trans_huge(*pmd));
> +
> +	/*
> +	 * We don't always have down_write of mmap_sem here: a racing
> +	 * do_huge_pmd_wp_page() might have copied-on-write to another
> +	 * huge page before our split_huge_page() got the anon_vma lock.
> +	 */
> +	if (unlikely(pmd_trans_huge(*pmd)))
> +		goto again;
>  }
>  
>  void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,

While it is correct, the looping is misleading. We should document
simply that any caller of split_huge_page_pmd with the mmap_sem for
reading, should use pmd_none_or_trans_huge_or_clear_bad or
pmd_trans_unstable before making any assumption on the pmd being
"stable" after split_huge_page returns.

This is what zap_pmd_range of course does already so it's perfectly
safe if split_huge_page_pmd returns with pmd_trans_huge(*pmd) == true.

Even with the loop, if the concurrent page faults that maps a
trans_huge_pmd (replacing the pmd_none) triggers just after the 'goto
again', but before the 'ret' instruction, the function still returns
with a trans huge page mapped in the *pmd.

In short I think either we try the more strict but more tricky
approach from Hillf https://patchwork.kernel.org/patch/2178311/ and we
also take into account the mapcount > 0 in the __split_huge_page loop
to make Hillf patch safe (I think currently it isn't), or we just nuke
the BUG_ON completely. And we should document in the source what
happens with mmap_sem hold for reading in MADV_DONTNEED.

Yet another approach would be to add something like down_write_trylock
in front of the check after converting it to a VM_BUG_ON.

The patch in patchwork, despite trying to be more strict, it doesn't
look safe to me because I tend to think we should also change
__split_huge_page to return the "mapcount", so that split_huge_page
will fail also if the mapcount was 0 in __split_huge_page.

I believe split_huge_page_to_list may obtain the anon_vma lock (so the
page was mapped) but then zap_huge_pmd obtains the page_table_lock
before __split_huge_page runs __split_huge_page_splitting and freezes
any attempt zap_huge_pmd or any other attempt of MADV_DONTNEED with
truncation of the pmd (waiting in another split_huge_page). So I
believe it is possible (and safe) for it to run with mapcount 0 (doing
nothing). But it doesn't return failure in that case, but if mapcount
is 0, the pmd may not have been converted to stable state. This is why
that change would be needed to use the patchwork patch.

The only place where we depend on split_huge_page retval so far is
add_to_swap. But regular anon pages can also be zapped there. So it
should be able to cope and the swapcache will free itself when all
refcounts are dropped. So we don't need to worry about the above I
think in add_to_swap.

Could you also post the stack trace so we compare to the one in
patchwork? Ideally this happened for you also in the context of a
MADV_DONTNEED, the other places walking pagetables with only the
mmap_sem for reading usually don't mangle pagetables.

Also note the workload I described with two MADV_DONTNEED running
concurrently and a page fault too, on the very same transhugepage
looks a non deterministic workload, but still we need to avoid false
positives in those non deterministic cases.

The two stack traces I have for this problem (patchwork above and
below bugzilla) all confirms it's happening only inside MADV_DONTNEED
confirming my theory above.

https://bugzilla.redhat.com/show_bug.cgi?id=949735

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
