Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id F2F776B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 19:52:01 -0400 (EDT)
Received: by padev16 with SMTP id ev16so22586556pad.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 16:52:01 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id da5si10901853pbc.20.2015.06.09.16.52.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 16:52:01 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so24506330pdb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 16:52:00 -0700 (PDT)
Date: Wed, 10 Jun 2015 08:52:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 3/6] mm: mark dirty bit on swapped-in page
Message-ID: <20150609235206.GB12689@bgram>
References: <1433312145-19386-1-git-send-email-minchan@kernel.org>
 <1433312145-19386-4-git-send-email-minchan@kernel.org>
 <20150609190737.GV13008@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150609190737.GV13008@uranus>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Yalin Wang <yalin.wang@sonymobile.com>

Hello Cyrill,

On Tue, Jun 09, 2015 at 10:07:37PM +0300, Cyrill Gorcunov wrote:
> On Wed, Jun 03, 2015 at 03:15:42PM +0900, Minchan Kim wrote:
> > Basically, MADV_FREE relys on the dirty bit in page table entry
> > to decide whether VM allows to discard the page or not.
> > IOW, if page table entry includes marked dirty bit, VM shouldn't
> > discard the page.
> > 
> > However, if swap-in by read fault happens, page table entry
> > point out the page doesn't have marked dirty bit so MADV_FREE
> > might discard the page wrongly.
> > 
> > To fix the problem, this patch marks page table entry of page
> > swapping-in as dirty so VM shouldn't discard the page suddenly
> > under us.
> > 
> > With MADV_FREE point of view, marking dirty unconditionally is
> > no problem because we dropped swapped page in MADV_FREE sycall
> > context(ie, Look at madvise_free_pte_range) so every swapping-in
> > pages are no MADV_FREE hinted pages.
> > 
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> > Cc: Pavel Emelyanov <xemul@parallels.com>
> > Reported-by: Yalin Wang <yalin.wang@sonymobile.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/memory.c | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 8a2fc9945b46..d1709f763152 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2557,9 +2557,11 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  
> >  	inc_mm_counter_fast(mm, MM_ANONPAGES);
> >  	dec_mm_counter_fast(mm, MM_SWAPENTS);
> > -	pte = mk_pte(page, vma->vm_page_prot);
> > +
> > +	/* Mark dirty bit of page table because MADV_FREE relies on it */
> > +	pte = pte_mkdirty(mk_pte(page, vma->vm_page_prot));
> >  	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
> > -		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> > +		pte = maybe_mkwrite(pte, vma);
> >  		flags &= ~FAULT_FLAG_WRITE;
> >  		ret |= VM_FAULT_WRITE;
> >  		exclusive = 1;
> 
> Hi Minchan! Really sorry for delay in reply. Look, I don't understand
> the moment -- if page has fault on read then before the patch the
> PTE won't carry the dirty flag but now we do set it up unconditionally
> and to me it looks somehow strange at least because this as well
> sets soft-dirty bit on pages which were not modified but only swapped
> out. Am I missing something obvious?

It's same one I sent a while ago and you said it's okay at that time. ;-)
Okay, It might be lack of description compared to one I sent long time ago
because I moved some part of description to another patch and I didn't Cc
you. Sorry. I hope below will remind you.

https://www.mail-archive.com/linux-kernel%40vger.kernel.org/msg857827.html

In summary, the problem is that in MADV_FREE point of view,
clean anonymous page(ie, no dirty) in  page table entry has a problem
about sudden discarding under us by reclaimer. Otherwise, VM cannot
discard MADV_FREE hinted pages by PageDirty flag of page descriptor.

This patchset aims for solving the problem.
Please feel free to ask if you have questions without wasting your time
unless you can remind after reading above URL

Thanks for looking!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
