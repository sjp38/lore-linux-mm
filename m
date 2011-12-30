Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D386D6B004D
	for <linux-mm@kvack.org>; Fri, 30 Dec 2011 10:04:27 -0500 (EST)
Date: Fri, 30 Dec 2011 15:04:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 5/5] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20111230150421.GE15729@suse.de>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
 <1321960128-15191-6-git-send-email-gilad@benyossef.com>
 <20111223102810.GT3487@suse.de>
 <CAOtvUMd6+ZZVLp-FbbEwbq3UZLRvSRo+_MMYj1aCGT3gBhxMwg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOtvUMd6+ZZVLp-FbbEwbq3UZLRvSRo+_MMYj1aCGT3gBhxMwg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

On Sun, Dec 25, 2011 at 11:39:59AM +0200, Gilad Ben-Yossef wrote:
> Hmm... I missed that. Sorry. I will fix it with the next iteration.
> >
> >
> > A greater concern is that we are calling zalloc_cpumask_var() from the
> > direct reclaim path when we are already under memory pressure. How often
> > is this path hit and how often does the allocation fail?
> 
> 
> Yes, this scenario worried me too. In fact, I worried that we might
> end in an infinite
> loop of direct reclaim => cpumask var allocation => direct reclaim.
> Luckily this can't happen.

Indeed.

> It did cause me to test the failure allocation case with the fault
> injection frame work to make
> sure it fails gracefully.
> 
> I'll try to explain why I believe we end up succeeding in most cases:
> 
> For CONFIG_CPUMASK_OFFSTACK=n - case there is no allocation, so there
> is no problem.
> 

CONFIG_CPUMASK_OFFSTACK is force enabled if CONFIG_MAXSMP on x86. This
may be the case for some server-orientated distributions. I know
SLES enables this option for x86-64 at least. Debian does not but
might in the future. I don't know about RHEL but it should be checked.
Either way, we cannot depend on CONFIG_CPUMASK_OFFSTACK being disabled
(it's enabled on my laptop for example due to the .config it is based
on). That said, breaking the link between MAXSMP and OFFSTACK may be
an option.

Stack usage may also be an issue. If NR_CPU is set to 4096 then
this will allocated 512 bytes on the stack within the page allocator
which can be called from some heavy stack usage paths. However, as
we have already used direct reclaim and that is a heavy stack user,
it probably is not as serious a problem.

> For CONFIG_CPUMASK_OFFSTACK=y but when we got to drain_all_pages from
> the memory
> hotplug or the memory failure code path (the code other code path that
> call drain_all_pages),
> there is  no inherent memory pressure, so we should be OK.
> 

It's the memory failure code path after direct reclaim failed. How
can you say there is no inherent memory pressure?

> If we did get to drain_all_pages  from direct reclaim, but the cpumask
> slab has an object in the
> slab (or partial pages in the case  of slub), then we never hit the
> page allocator so all is well, I believe.
> 

Unless the slab is empty or we are competing heavily with other
alloc_cpumask_var users. I would expect it is rare but that is not
the same as "never" hitting the page allocator. However, I accept
that it is likely to be rare.

> So this leaves us with being called from the direct reclaim path, when
> the cpumask slab has no
> object or partial pages and it needs to hit the page allocator.  If we
> hit direct page relcaim, the original
> allocation was not atomic , otherwise we would not have  hit direct
> page reclaim.  The cpumask allocation
> however,  is atomic, so we have broader allocation options -  allocate
> high,  allocate outside our cpuset
> etc. and  there is a reasonable chance the cpumask allocation can
> succeed even if the original allocation
> ended up in direct reclaim.
> 

Ok, the atomic allocation can dip further into the PFMEMALLOC reserves
meaning that it may succeed an allocation even when an ordinarily
allocation would fail. However, this is applying more memory pressure
at a time we are already under memory pressure. In an extreme case,
allocating for the cpumask will be causing other allocations to fail
and stalling processes for longer. Considering that the processes are
already stalled for direct reclaim and the resulting allocation will
end up as a slab page, the additional delay is likely insignificant.

> So we end up failing to allocate the cpumask var only if the memory
> pressure is really a global system
> memory shortage, as opposed to, for example, some user space failure
> to page in some heap space
> in a cpuset. Even then, we fail gracefully.
> 

Ok, I accept that it will fail gracefully.

> 
> > Related to that, calling into the page allocator again for
> > zalloc_cpumask_var is not cheap.  Does reducing the number of IPIs
> > offset the cost of calling into the allocator again? How often does it
> > offset the cost and how often does it end up costing more? I guess that
> > would heavily depend on the number of CPUs and how many of them have
> > pages in their per-cpu buffer. Basically, sometimes we *might* save but
> > it comes at a definite cost of calling into the page allocator again.
> >
> 
> Good point and I totally agree it depends on the number of CPUs.
> 
> The thing is, if you are at CPUMASK_OFFSTACK=y, you are saying
> that you optimize for the large number of CPU case, otherwise it doesn't
> make sense - you can represent 32 CPU in the space it takes to
> hold the pointer to the cpumask (on 32bit system) etc.
> 
> If you are at CPUMASK_OFFSTACK=n you (almost) didn't pay anything.
> 

It's the CPUMASK_OFFSTACK=y case I worry about as it is enabled on
at least one server-orientated distribution and probably more.

> The way I see it, the use cases where you end up profiting from the code
> are the same places you also pay. Having lots of CPU is what forced you
> to use CPUMASK_OFFSTACK and pay that extra allocation but
> then it is exactly when you have lots of CPUs that the code pays off.
> 
> >
> > The patch looks ok functionally but I'm skeptical that it really helps
> > performance.
> 
> 
> Thanks! it is good to hear it is not completely off the wall :-)
> 
> I think of it more of as a CPU isolation feature then pure performance.
> If you have a system with a couple of dozens of CPUs (Tilera, SGI, Cavium
> or the various virtual NUMA folks) you tend to want to break up the system
> into sets of CPUs that work of separate tasks.
> 

Even with the CPUs isolated, how often is it the case that many of
the CPUs have 0 pages on their per-cpu lists? I checked a bunch of
random machines just there and in every case all CPUs had at least
one page on their per-cpu list. In other words I believe that in
many cases the exact same number of IPIs will be used but with the
additional cost of allocating a cpumask.

> It is very annoying when a memory allocation failure in a task allocated to a
> small set of 4 CPUs yanks out all the rest of your 4,092 CPUs working on
> something completely different out of their cache warm happy existence into
> the cache cold reality of an IPI, or worse yet yanks all those CPUs from the
> nirvana of idle C-states saving power just to discover that no, they don't
> actually have anything to do. :-)
> 
> I do believe the overhead for the cases without a lot of CPUs is quite minimal.
> 

I'm still generally uncomfortable with the allocator allocating memory
while it is known memory is tight.

As a way of mitigating that, I would suggest this is done in two
passes. The first would check if at least 50% of the CPUs have no pages
on their per-cpu list. Then and only then allocate the per-cpu mask to
limit the IPIs. Use a separate patch that counts in /proc/vmstat how
many times the per-cpu mask was allocated as an approximate measure of
how often this logic really reduces the number of IPI calls in practice
and report that number with the patch - i.e. this patch reduces the
number of times IPIs are globally transmitted by X% for some workload.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
