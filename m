Date: Thu, 5 Sep 2002 00:07:11 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: statm_pgd_range() sucks!
Message-ID: <20020905070711.GB888@holomorphy.com>
References: <20020830015814.GN18114@holomorphy.com> <3D6EDDC0.F9ADC015@zip.com.au> <20020905032035.GY888@holomorphy.com> <3D76E207.1FA08024@zip.com.au> <20020905060534.GZ888@holomorphy.com> <3D76FE71.E6633D03@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D76FE71.E6633D03@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> I don't know of anything actually meant to report mapping occupancy
>> (except full RSS) before or after this patch. Or have I blundered?

On Wed, Sep 04, 2002 at 11:49:21PM -0700, Andrew Morton wrote:
> statm_pgd_range(pgd, vma->vm_start, vma->vm_end, &pages, &shared, &dirty, &total);
>                                                   ^^^^^
> `pages' there is the number of actually resident pages, yes?
> And it gets fed into trs, drs and lrs.
> But converting it to this:
+               int pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
...
+               if (vma->vm_flags & VM_SHARED)
+                       shared += pages;
> Will mean that `shared' can be vastly overestimated.   I think??


Shared as wildly guessing from the implementation can only be accurately
estimated in one of two ways"

(1) maintaining RSS counters in the mm's updated on PG_direct split/coalesce
(2) walking the pagetables and adding up things with PG_direct clear

... both are too computationally expensive, so I deliberately changed
the semantics to "amount of mem mapped as MAP_SHARED".

Prior to this it was pure garbage because it checked page->count > 1.


William Lee Irwin III wrote:
>> Hmm, that could get hairy depending on how we want them grouped. It
>> might be better just to maintain RSS counters for the kinds of mappings
>> we're interested in. Doing pagetable walks to make splitvma() do that
>> right could perform poorly. Otherwise we'd have to find another
>> instance of the same kind of thing to "donate" our RSS to on unmap.

On Wed, Sep 04, 2002 at 11:49:21PM -0700, Andrew Morton wrote:
> A walk in split_vma would be unpopular..  Could we separate mm->rss
> up into text, stack and library or something?
> Or do we just not care?  I guess it's conceivably useful to know
> the residency of each mapping, but there doesn't seem to be an
> existing proc interface for that anyway.  And having them all
> rolled up into an mm-wide number is a lot of information loss.

drs and lrs both have problems.

drs basically requires either the pagetable walk here or a pte_chain
walk in a hotpath (set_page_dirty()/ClearPageDirty(), maybe pte_mkdirty()).
So I dropped its reporting entirely.

lrs is not semantically meaningful except to a.out, the existing code
uses hardcoded i386 values for it, and requires chasing down executable
format stuff to "get right".

trs is counting up memory that's mapped as VM_EXECUTABLE, which isn't
a big deal. RSS-style counters work for that just fine.

At any rate, while this may very well benefit small systems, it looks
like this isn't likely to make system monitoring feasible for larger
boxen, since I ran with it tonight and vmstat(1) and top(1) required 2
minutes or (much) longer to refresh during the big bad tiobench run. In
all likelihood I'll have to write a chardev to monitor the system.


Cheers,
Bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
