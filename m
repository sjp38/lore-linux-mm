Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 12DF16B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 17:13:31 -0400 (EDT)
Date: Tue, 13 Aug 2013 14:13:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/2] mm: make lru_add_drain_all() selective
Message-Id: <20130813141329.c55deccf462f3ad49129bbca@linux-foundation.org>
In-Reply-To: <520A9E4A.2050203@tilera.com>
References: <5202CEAA.9040204@linux.vnet.ibm.com>
	<201308072335.r77NZZwl022494@farm-0012.internal.tilera.com>
	<20130812140520.c6a2255d2176a690fadf9ba7@linux-foundation.org>
	<52099187.80301@tilera.com>
	<20130813123512.3d6865d8bf4689c05d44738c@linux-foundation.org>
	<20130813201958.GA28996@mtj.dyndns.org>
	<20130813133135.3b580af557d1457e4ee8331a@linux-foundation.org>
	<520A9E4A.2050203@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

On Tue, 13 Aug 2013 16:59:54 -0400 Chris Metcalf <cmetcalf@tilera.com> wrote:

> >
> > Then again, why does this patchset exist?  It's a performance
> > optimisation so presumably someone cares.  But not enough to perform
> > actual measurements :(
> 
> The patchset exists because of the difference between zero overhead on
> cpus that don't have drainable lrus, and non-zero overhead.  This turns
> out to be important on workloads where nohz cores are handling 10 Gb
> traffic in userspace and really, really don't want to be interrupted,
> or they drop packets on the floor.

But what is the effect of the patchset?  Has it been tested against the
problematic workload(s)?

> >> the logical thing to do
> >> would be pre-allocating per-cpu buffers instead of depending on
> >> dynamic allocation.  Do the invocations need to be stackable?
> > schedule_on_each_cpu() calls should if course happen concurrently, and
> > there's the question of whether we wish to permit async
> > schedule_on_each_cpu().  Leaving the calling CPU twiddling thumbs until
> > everyone has finished is pretty sad if the caller doesn't want that.
> >
> >>> That being said, the `cpumask_var_t mask' which was added to
> >>> lru_add_drain_all() is unneeded - it's just a temporary storage which
> >>> can be eliminated by creating a schedule_on_each_cpu_cond() or whatever
> >>> which is passed a function pointer of type `bool (*call_needed)(int
> >>> cpu, void *data)'.
> >> I'd really like to avoid that.  Decision callbacks tend to get abused
> >> quite often and it's rather sad to do that because cpumask cannot be
> >> prepared and passed around.  Can't it just preallocate all necessary
> >> resources?
> > I don't recall seeing such abuse.  It's a very common and powerful
> > tool, and not implementing it because some dummy may abuse it weakens
> > the API for all non-dummies.  That allocation is simply unneeded.
> 
> The problem with a callback version is that it's not clear that
> it helps with Andrew's original concern about allocation.  In
> schedule_on_each_cpu() we need to track which cpus we scheduled work
> on so that we can flush_work() after all the work has been scheduled.
> Even with a callback approach, we'd still end up wanting to record
> the results of the callback in the first pass so that we could
> properly flush_work() on the second pass.  Given that, having the
> caller just create the cpumask in the first place makes more sense.

Nope.  schedule_on_each_cpu() can just continue to do

	for_each_cpu(cpu, mask)
		flush_work(per_cpu_ptr(works, cpu));

lru_add_drain_all() can do that as well.  An optimisation would be to
tag the unused works as not-needing-flush.  Set work.entry,next to
NULL, for example.

If we were to switch from alloc_per_cpu() to bunch-of-kmallocs then
they'd need to be assembled into a list which is pretty trivial. 

> As Andrew suggests, we could also just have an asynchronous version
> of schedule_on_each_cpu(), but I don't know if that's beneficial
> enough to the swap code to make it worthwhile, or if it's tricky
> enough on the workqueue side to make it not worthwhile; it does seem
> like we would need to rethink the work_struct allocation, and
> e.g. avoid re-issuing the flush to a cpu that hadn't finished the
> previous flush, etc.  Potentially tricky, particularly if
> lru_add_drain_all() doesn't care about performance in the first place.

lru_add_drain_all() wants synchronous behavior.  I don't know how much
call there would be for an async schedule_on_each_cpu_cond().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
