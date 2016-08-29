Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6EDC83102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 11:35:54 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 30so88628647uab.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 08:35:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u13si23602561qtu.141.2016.08.29.08.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 08:35:52 -0700 (PDT)
Date: Mon, 29 Aug 2016 17:35:48 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: use-after-free in collapse_huge_page
Message-ID: <20160829153548.pmwcup4q74hafwmu@redhat.com>
References: <CACT4Y+Z3gigBvhca9kRJFcjX0G70V_nRhbwKBU+yGoESBDKi9Q@mail.gmail.com>
 <20160829124233.GA40092@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160829124233.GA40092@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <levinsasha928@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

Hello Kirill,

On Mon, Aug 29, 2016 at 03:42:33PM +0300, Kirill A. Shutemov wrote:
> @@ -898,13 +899,13 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
>  		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
>  		if (ret & VM_FAULT_RETRY) {
>  			down_read(&mm->mmap_sem);
> -			if (hugepage_vma_revalidate(mm, address)) {
> +			if (hugepage_vma_revalidate(mm, address, &vma)) {
>  				/* vma is no longer available, don't continue to swapin */
>  				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
>  				return false;
>  			}
>  			/* check if the pmd is still valid */
> -			if (mm_find_pmd(mm, address) != pmd)
> +			if (mm_find_pmd(mm, address) != pmd || vma != fe.vma)
>  				return false;
>  		}
>  		if (ret & VM_FAULT_ERROR) {

You check if the vma changed if the mmap_sem was released by the
VM_FAULT_RETRY case but not below:

	/*
	 * Prevent all access to pagetables with the exception of
	 * gup_fast later handled by the ptep_clear_flush and the VM
> @@ -994,7 +995,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	 * handled by the anon_vma lock + PG_lock.
>  	 */
>  	down_write(&mm->mmap_sem);
> -	result = hugepage_vma_revalidate(mm, address);
> +	result = hugepage_vma_revalidate(mm, address, &vma);
>  	if (result)
>  		goto out;
>  	/* check if the pmd is still valid */
	if (mm_find_pmd(mm, address) != pmd)
		goto out;

Here you go ahead without care if the vma has changed as long as the
"vma" pointer was updated to the new one, and the pmd is still present
and stable (present and not huge) and all vma details matched as
before.

Either we care that the vma changed in both places or we don't in
either of the two places.

The idea was that even if the vma changed it doesn't matter because
it's still good to proceed for a collapse if all revalidation check
pass.

What we failed at, was in refreshing the pointer of the vma to the new
one after the vma revalidation passed, so that the code that goes
ahead uses the right vma pointer and not the stale one we got
initially.

Now it may give a perception that it is safer to check fa.vma != vma
but in reality it is not, because the vma may be freed and reallocated
in exactly the same address...

So I think the vma != fe.vma check shall be removed because no matter
what the safety of the vma revalidate cannot come from checking if the
pointer has not changed and it must come from something else.

Now reading __collapse_huge_page_swapin I noticed some other unrelated
issues.

		if (referenced < HPAGE_PMD_NR/2) {
			trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
			return false;
		}

Referenced is not updated ever by __collapse_huge_page_swapin. In turn
the above check would better be moved out of the loop, before we start
to kmap the pte.

Bigger issue is that leaving it where it is right now, we don't seem
to unmap the pte as needed when the above "return false" above runs,
which means we're leaking kmap_atomic entries, and that will also get
fixed by moving the check before the loop starts and before the first
pte_offset_map.

swapped_in will showup zero instead of 1 in the tracing at all times
but I doubt it makes any difference so I would move it out of the loop
instead of adding a pte_unmap before returning, so it runs faster.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
