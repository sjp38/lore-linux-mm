Date: Tue, 6 Feb 2007 03:25:49 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-ID: <20070206022549.GB31476@wotan.suse.de>
References: <20070204063833.23659.55105.sendpatchset@linux.site> <20070204014445.88e6c8c7.akpm@linux-foundation.org> <20070204101529.GA22004@wotan.suse.de> <20070204023055.2583fd65.akpm@linux-foundation.org> <20070204104609.GA29943@wotan.suse.de> <20070204025602.a5f8c53a.akpm@linux-foundation.org> <20070204110317.GA9034@wotan.suse.de> <20070204031549.203f7b47.akpm@linux-foundation.org> <20070204151051.GB12771@wotan.suse.de> <20070204103620.33c24cad.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070204103620.33c24cad.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 04, 2007 at 10:36:20AM -0800, Andrew Morton wrote:
> On Sun, 4 Feb 2007 16:10:51 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > They're not likely to hit the deadlocks, either. Probability gets more
> > likely after my patch to lock the page in the fault path. But practially,
> > we could live without that too, because the data corruption it fixes is
> > very rare as well. Which is exactly what we've been doing quite happily
> > for most of 2.6, including all distro kernels (I think).
> 
> Thing is, an application which is relying on the contents of that page is
> already unreliable (or really peculiar), because it can get indeterminate
> results anyway.

Not necessarily -- they could read from one part of a page and write to
another. I see this as the biggest data corruption problem.

But even in the case where they can get indeterminate results, they can
still determine what the results *won't* be. Eg. they might use a single
byte for a flag or something.

> > ...
> > 
> > On a P4 Xeon, SMP kernel, on a tmpfs filesystem, a 1GB dd if=/dev/zero write
> > had the following performance (higher is worse):
> > 
> > Orig kernel			New kernel
> > new file (no pagecache)
> > 4K  blocks 1.280s		1.287s (+0.5%)
> > 64K blocks 1.090s		1.105s (+1.4%)
> > notrunc (uptodate pagecache)
> > 4K  blocks 0.976s		1.001s (+0.5%)
> > 64K blocks 0.780s		0.792s (+1.5%)
> > 
> > [numbers are better than +/- 0.005]
> > 
> > So we lose somewhere between half and one and a half of one percent
> > performance in a pagecache write intensive workload.
> 
> That's not too bad - caches are fast.  Did you look at optimising the
> handling of that temp page, ensure that we always use the same page?  I
> guess the page allocator per-cpu-pages thing is being good here.

Yeah it should be doing a reasonable job.

> I'm not sure how, though.  Park a copy in the task_struct, just as an
> experiment.  But that'd de-optimise multiple-tasks-writing-on-the-same-cpu.
> Maybe a per-cpu thing?  Largely duplicates the page allocator's per-cpu-pages.

Putting a copy in the task_struct won't do much I figure, except saving
a copule of interrupt enable/disable, and being more wasteful of memory
and cache-hotness.

Per-cpu doesn't work because we can't hold preempt off over the usercopy
(well, we *could* do it in a loop together with fault_in_pages, but that
just adds to the icache bloat).

> 
> Of course, we're also increasing caceh footprint, which this test won't
> show.

We are indeed. At least we release the hot page back to the allocator
very quickly that it can be reused.

The upshot is that your writev performance will be improved :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
