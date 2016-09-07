Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7101E6B0268
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 08:26:39 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vp2so30345097pab.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 05:26:39 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s70si41142287pfa.89.2016.09.07.05.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 05:26:36 -0700 (PDT)
Date: Wed, 7 Sep 2016 15:25:59 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: mm: use-after-free in collapse_huge_page
Message-ID: <20160907122559.GA6542@black.fi.intel.com>
References: <CACT4Y+Z3gigBvhca9kRJFcjX0G70V_nRhbwKBU+yGoESBDKi9Q@mail.gmail.com>
 <20160829124233.GA40092@black.fi.intel.com>
 <20160829153548.pmwcup4q74hafwmu@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160829153548.pmwcup4q74hafwmu@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <levinsasha928@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On Mon, Aug 29, 2016 at 05:35:48PM +0200, Andrea Arcangeli wrote:
> Hello Kirill,
> 
> On Mon, Aug 29, 2016 at 03:42:33PM +0300, Kirill A. Shutemov wrote:
> > @@ -898,13 +899,13 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
> >  		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
> >  		if (ret & VM_FAULT_RETRY) {
> >  			down_read(&mm->mmap_sem);
> > -			if (hugepage_vma_revalidate(mm, address)) {
> > +			if (hugepage_vma_revalidate(mm, address, &vma)) {
> >  				/* vma is no longer available, don't continue to swapin */
> >  				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
> >  				return false;
> >  			}
> >  			/* check if the pmd is still valid */
> > -			if (mm_find_pmd(mm, address) != pmd)
> > +			if (mm_find_pmd(mm, address) != pmd || vma != fe.vma)
> >  				return false;
> >  		}
> >  		if (ret & VM_FAULT_ERROR) {
> 
> You check if the vma changed if the mmap_sem was released by the
> VM_FAULT_RETRY case but not below:
> 
> 	/*
> 	 * Prevent all access to pagetables with the exception of
> 	 * gup_fast later handled by the ptep_clear_flush and the VM
> > @@ -994,7 +995,7 @@ static void collapse_huge_page(struct mm_struct *mm,
> >  	 * handled by the anon_vma lock + PG_lock.
> >  	 */
> >  	down_write(&mm->mmap_sem);
> > -	result = hugepage_vma_revalidate(mm, address);
> > +	result = hugepage_vma_revalidate(mm, address, &vma);
> >  	if (result)
> >  		goto out;
> >  	/* check if the pmd is still valid */
> 	if (mm_find_pmd(mm, address) != pmd)
> 		goto out;
> 
> Here you go ahead without care if the vma has changed as long as the
> "vma" pointer was updated to the new one, and the pmd is still present
> and stable (present and not huge) and all vma details matched as
> before.
> 
> Either we care that the vma changed in both places or we don't in
> either of the two places.
> 
> The idea was that even if the vma changed it doesn't matter because
> it's still good to proceed for a collapse if all revalidation check
> pass.
> 
> What we failed at, was in refreshing the pointer of the vma to the new
> one after the vma revalidation passed, so that the code that goes
> ahead uses the right vma pointer and not the stale one we got
> initially.
> 
> Now it may give a perception that it is safer to check fa.vma != vma
> but in reality it is not, because the vma may be freed and reallocated
> in exactly the same address...
> 
> So I think the vma != fe.vma check shall be removed because no matter
> what the safety of the vma revalidate cannot come from checking if the
> pointer has not changed and it must come from something else.

[ Finally back to this. ]

Here's updated version.
