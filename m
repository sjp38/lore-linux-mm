Message-ID: <3D76FE71.E6633D03@zip.com.au>
Date: Wed, 04 Sep 2002 23:49:21 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: statm_pgd_range() sucks!
References: <20020830015814.GN18114@holomorphy.com> <3D6EDDC0.F9ADC015@zip.com.au> <20020905032035.GY888@holomorphy.com> <3D76E207.1FA08024@zip.com.au> <20020905060534.GZ888@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> William Lee Irwin III wrote:
> >> I lost track of what the TODO's were but this is of relatively minor
> >> import, and I lagged long enough this is against 2.5.33-mm2:
> 
> On Wed, Sep 04, 2002 at 09:48:07PM -0700, Andrew Morton wrote:
> > Well the TODO was to worry about the (very) incorrect reporting of
> > mapping occupancy.  mmap(1G file), touch one byte of it (or none)
> > and the thing will report 1G?
> 
> I don't know of anything actually meant to report mapping occupancy
> (except full RSS) before or after this patch. Or have I blundered?

statm_pgd_range(pgd, vma->vm_start, vma->vm_end, &pages, &shared, &dirty, &total);
                                                  ^^^^^

`pages' there is the number of actually resident pages, yes?
And it gets fed into trs, drs and lrs.

But converting it to this:

+               int pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
...
+               if (vma->vm_flags & VM_SHARED)
+                       shared += pages;

Will mean that `shared' can be vastly overestimated.   I think??

> On Wed, Sep 04, 2002 at 09:48:07PM -0700, Andrew Morton wrote:
> > We figured that per-vma rss accounting would be easy and would fix
> > it, then we remembered that vma's can be split into two, which
> > screwed that plan most royally.
> > Maybe when a VMA is split, we set the new VMA to have an rss of zero,
> > and keep on doing the accounting.  That way, the sum-of-vmas is
> > still correct even though the individual ones are wildly wrong??
> 
> Hmm, that could get hairy depending on how we want them grouped. It
> might be better just to maintain RSS counters for the kinds of mappings
> we're interested in. Doing pagetable walks to make splitvma() do that
> right could perform poorly. Otherwise we'd have to find another
> instance of the same kind of thing to "donate" our RSS to on unmap.

A walk in split_vma would be unpopular..  Could we separate mm->rss
up into text, stack and library or something?

Or do we just not care?  I guess it's conceivably useful to know
the residency of each mapping, but there doesn't seem to be an
existing proc interface for that anyway.  And having them all
rolled up into an mm-wide number is a lot of information loss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
