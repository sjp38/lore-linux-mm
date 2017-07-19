Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A87666B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 16:08:32 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g28so10500587wrg.3
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 13:08:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h131si447673wme.218.2017.07.19.13.08.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 13:08:31 -0700 (PDT)
Date: Wed, 19 Jul 2017 21:08:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: TLB batching breaks MADV_DONTNEED
Message-ID: <20170719200829.7gfon5xkb3pnglgf@suse.de>
References: <B672524C-1D52-4215-89CB-9FF3477600C9@gmail.com>
 <20170719082316.ceuzf3wt34e6jy3s@suse.de>
 <196BA5A2-A4EA-43A0-8961-B5CF262CA745@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <196BA5A2-A4EA-43A0-8961-B5CF262CA745@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

On Wed, Jul 19, 2017 at 11:14:17AM -0700, Nadav Amit wrote:
> > 
> > Technically, DONTNEED is not required to zero-fill the data but in the
> > case of Linux, it actually does matter because the stale entry is
> > pointing to page that will be freed shortly. If a caller returns and
> > uses a stale TLB entry to "reinitialise" the region then the writes may
> > be lost.
> 
> And although I didn???t check, it may have some implications on userfaultfd
> which is often used with MADV_DONTNEED.
> 

Potentially although I also consider it unlikely that a user of
userfaultfd would be racing two madvises while copying out data. Then
again, I do not know the userspace implementation of anything that uses
userfaultfd.

> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 9976852f1e1c..78bbe09e549e 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -497,6 +497,18 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
> > 					unsigned long start, unsigned long end)
> > {
> > 	zap_page_range(vma, start, end - start);
> > +
> > +	/*
> > +	 * A parallel madvise operation could have unmapped PTEs and deferred
> > +	 * a flush before this madvise returns. Guarantee the TLB is flushed
> > +	 * so that an immediate read after madvise will return zero's for
> > +	 * private anonymous mappings. File-backed shared mappings do not
> > +	 * matter as they will either use a stale TLB entry or refault the
> > +	 * data in the event of a race.
> > +	 */
> > +	if (vma_is_anonymous(vma))
> > +		flush_tlb_range(vma, start, end);
> > +	
> > 	return 0;
> > }
> 
> It will work but would in this case but would very often result in a
> redundant TLB flush.

It's one additional flush per anonymous VMA that is unmapped.  Unfortunate
but not excessive except maybe in the worst case of unmapping single-page
VMAs. The larger the VMA, the less the relative cost.

> I also think that we still don???t understand the extent
> of the problem, based on the issues that keep coming out. In this case it
> may be better to be defensive and not to try to avoid flushes too
> aggressively (e.g., on non-anonymous VMAs).
> 

Well, for file-backed or shared mappings, the data will either be clean
(which means it's write-protected because of how dirty page tracking works)
and can be discarded and retrived from disk and read safely from a stale
TLB as long as it's flushed before the page is freed or it will be dirty
in which case the TLB will be flushed before any IO starts.  That's why
I only checked for the anonymous case.

> Here is what I have in mind (not tested). Based on whether mmap_sem is
> acquired for write, exclusiveness is determined. If exclusiveness is not
> maintained, a TLB flush is required. If I could use the owner field of rwsem
> (when available), this can simplify the check whether the code is run
> exclusively.
> 
> Having said that, I still think that the whole batching scheme need to be
> unified and rethought of.
> 

This is a bit more overkill on the basis it covers file-backed or shared
mappings but if you quantify it and see that it's not a problem, then I
have no objection to the patch either. You may receive feedback that
altering the API universally is undesirable and modify it to only update
the madvise() caller that is directly affected due to two madvise calls
beiing able to race and have one return to userspace with stale TLB
entries pointing to anonymous memory that is about to be freed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
