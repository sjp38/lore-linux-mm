Date: Sun, 4 Feb 2007 10:36:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-Id: <20070204103620.33c24cad.akpm@linux-foundation.org>
In-Reply-To: <20070204151051.GB12771@wotan.suse.de>
References: <20070204063707.23659.20741.sendpatchset@linux.site>
	<20070204063833.23659.55105.sendpatchset@linux.site>
	<20070204014445.88e6c8c7.akpm@linux-foundation.org>
	<20070204101529.GA22004@wotan.suse.de>
	<20070204023055.2583fd65.akpm@linux-foundation.org>
	<20070204104609.GA29943@wotan.suse.de>
	<20070204025602.a5f8c53a.akpm@linux-foundation.org>
	<20070204110317.GA9034@wotan.suse.de>
	<20070204031549.203f7b47.akpm@linux-foundation.org>
	<20070204151051.GB12771@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Feb 2007 16:10:51 +0100 Nick Piggin <npiggin@suse.de> wrote:

> On Sun, Feb 04, 2007 at 03:15:49AM -0800, Andrew Morton wrote:
> > On Sun, 4 Feb 2007 12:03:17 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > On Sun, Feb 04, 2007 at 02:56:02AM -0800, Andrew Morton wrote:
> > > > On Sun, 4 Feb 2007 11:46:09 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > > 
> > > > If that recollection is right, I think we could afford to reintroduce that
> > > > problem, frankly.  Especially as it only happens in the incredibly rare
> > > > case of that get_user()ed page getting unmapped under our feet.
> > > 
> > > Dang. I was hoping to fix it without introducing data corruption.
> > 
> > Well.  It's a compromise.  Being practical about it, I reeeealy doubt that
> > anyone will hit this combination of circumstances.
> 
> They're not likely to hit the deadlocks, either. Probability gets more
> likely after my patch to lock the page in the fault path. But practially,
> we could live without that too, because the data corruption it fixes is
> very rare as well. Which is exactly what we've been doing quite happily
> for most of 2.6, including all distro kernels (I think).

Thing is, an application which is relying on the contents of that page is
already unreliable (or really peculiar), because it can get indeterminate
results anyway.

> ...
> 
> On a P4 Xeon, SMP kernel, on a tmpfs filesystem, a 1GB dd if=/dev/zero write
> had the following performance (higher is worse):
> 
> Orig kernel			New kernel
> new file (no pagecache)
> 4K  blocks 1.280s		1.287s (+0.5%)
> 64K blocks 1.090s		1.105s (+1.4%)
> notrunc (uptodate pagecache)
> 4K  blocks 0.976s		1.001s (+0.5%)
> 64K blocks 0.780s		0.792s (+1.5%)
> 
> [numbers are better than +/- 0.005]
> 
> So we lose somewhere between half and one and a half of one percent
> performance in a pagecache write intensive workload.

That's not too bad - caches are fast.  Did you look at optimising the
handling of that temp page, ensure that we always use the same page?  I
guess the page allocator per-cpu-pages thing is being good here.

I'm not sure how, though.  Park a copy in the task_struct, just as an
experiment.  But that'd de-optimise multiple-tasks-writing-on-the-same-cpu.
Maybe a per-cpu thing?  Largely duplicates the page allocator's per-cpu-pages.

Of course, we're also increasing caceh footprint, which this test won't
show.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
