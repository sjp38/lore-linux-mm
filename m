Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E661D6B04D3
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 17:09:22 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u30so982594wrc.9
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:09:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p128si352333wmb.40.2017.07.11.14.09.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 14:09:21 -0700 (PDT)
Date: Tue, 11 Jul 2017 22:09:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170711210919.y4odiqtfeb4e3ulz@suse.de>
References: <20170711064149.bg63nvi54ycynxw4@suse.de>
 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <3373F577-F289-4028-B6F6-777D029A7B07@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <3373F577-F289-4028-B6F6-777D029A7B07@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 01:06:48PM -0700, Nadav Amit wrote:
> > +/*
> > + * Reclaim batches unmaps pages under the PTL but does not flush the TLB
> > + * TLB prior to releasing the PTL. It's possible a parallel mprotect or
> > + * munmap can race between reclaim unmapping the page and flushing the
> > + * page. If this race occurs, it potentially allows access to data via
> > + * a stale TLB entry. Tracking all mm's that have TLB batching pending
> > + * would be expensive during reclaim so instead track whether TLB batching
> > + * occured in the past and if so then do a full mm flush here. This will
> > + * cost one additional flush per reclaim cycle paid by the first munmap or
> > + * mprotect. This assumes it's called under the PTL to synchronise access
> > + * to mm->tlb_flush_batched.
> > + */
> > +void flush_tlb_batched_pending(struct mm_struct *mm)
> > +{
> > +	if (mm->tlb_flush_batched) {
> > +		flush_tlb_mm(mm);
> > +		mm->tlb_flush_batched = false;
> > +	}
> > +}
> > #else
> > static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
> > {
> 
> I don???t know what is exactly the invariant that is kept, so it is hard for
> me to figure out all sort of questions:
> 
> Should pte_accessible return true if mm->tlb_flush_batch==true ?
> 

It shouldn't be necessary. The contexts where we hit the path are

uprobes: elevated page count so no parallel reclaim
dax: PTEs are not mapping that would be reclaimed
hugetlbfs: Not reclaimed
ksm: holds page lock and elevates count so cannot race with reclaim
cow: at the time of the flush, the page count is elevated so cannot race with reclaim
page_mkclean: only concerned with marking existing ptes clean but in any
	case, the batching flushes the TLB before issueing any IO so there
	isn't space for a stable TLB entry to be used for something bad.

> Does madvise_free_pte_range need to be modified as well?
> 

Yes, I noticed that out shortly after sending the first version and
commented upon it.

> How will future code not break anything?
> 

I can't really answer that without a crystal ball. Code dealing with page
table updates would need to take some care if it can race with parallel
reclaim.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
