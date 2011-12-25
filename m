Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 7D6486B004F
	for <linux-mm@kvack.org>; Sun, 25 Dec 2011 04:40:01 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so11039669vbb.14
        for <linux-mm@kvack.org>; Sun, 25 Dec 2011 01:40:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111223102810.GT3487@suse.de>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
	<1321960128-15191-6-git-send-email-gilad@benyossef.com>
	<20111223102810.GT3487@suse.de>
Date: Sun, 25 Dec 2011 11:39:59 +0200
Message-ID: <CAOtvUMd6+ZZVLp-FbbEwbq3UZLRvSRo+_MMYj1aCGT3gBhxMwg@mail.gmail.com>
Subject: Re: [PATCH v4 5/5] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

On Fri, Dec 23, 2011 at 12:28 PM, Mel Gorman <mgorman@suse.de> wrote:
>
> On Tue, Nov 22, 2011 at 01:08:48PM +0200, Gilad Ben-Yossef wrote:
> > Calculate a cpumask of CPUs with per-cpu pages in any zone and only sen=
d an IPI requesting CPUs to drain these pages to the buddy allocator if the=
y actually have pages when asked to flush.
> >
> > The code path of memory allocation failure for CPUMASK_OFFSTACK=3Dy con=
fig was tested using fault injection framework.
> >
> > Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> > Acked-by: Christoph Lameter <cl@linux.com>
> > CC: Chris Metcalf <cmetcalf@tilera.com>
> > CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > CC: Frederic Weisbecker <fweisbec@gmail.com>
> > CC: Russell King <linux@arm.linux.org.uk>
> > CC: linux-mm@kvack.org
> > CC: Pekka Enberg <penberg@kernel.org>
> > CC: Matt Mackall <mpm@selenic.com>
> > CC: Sasha Levin <levinsasha928@gmail.com>
> > CC: Rik van Riel <riel@redhat.com>
> > CC: Andi Kleen <andi@firstfloor.org>
> > ---
> > =A0mm/page_alloc.c | =A0 18 +++++++++++++++++-
> > =A01 files changed, 17 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9dd443d..a3efdf1 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1119,7 +1119,23 @@ void drain_local_pages(void *arg)
> > =A0 */
> > =A0void drain_all_pages(void)
> > =A0{
> > - =A0 =A0 on_each_cpu(drain_local_pages, NULL, 1);
> > + =A0 =A0 int cpu;
> > + =A0 =A0 struct zone *zone;
> > + =A0 =A0 cpumask_var_t cpus;
> > + =A0 =A0 struct per_cpu_pageset *pcp;
> > +
> > + =A0 =A0 if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_populated_zone(zone)=
 {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcp =3D per_c=
pu_ptr(zone->pageset, cpu);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pcp->pcp.=
count)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 cpumask_set_cpu(cpu, cpus);
> > + =A0 =A0 =A0 =A0 =A0 =A0 }
> > + =A0 =A0 }
> > + =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu_mask(cpus, drain_local_pages, NUL=
L, 1);
> > + =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(cpus);
>
First off, thank you for the review.

>
> The indenting there is very weird but easily fixed.


Hmm... I missed that. Sorry. I will fix it with the next iteration.
>
>
> A greater concern is that we are calling zalloc_cpumask_var() from the
> direct reclaim path when we are already under memory pressure. How often
> is this path hit and how often does the allocation fail?


Yes, this scenario worried me too. In fact, I worried that we might
end in an infinite
loop of direct reclaim =3D> cpumask var allocation =3D> direct reclaim.
Luckily this can't happen.
It did cause me to test the failure allocation case with the fault
injection frame work to make
sure it fails gracefully.

I'll try to explain why I believe we end up succeeding in most cases:

For=A0CONFIG_CPUMASK_OFFSTACK=3Dn - case there is no allocation, so there
is no problem.

For=A0CONFIG_CPUMASK_OFFSTACK=3Dy but when=A0we got to drain_all_pages from
the memory
hotplug or the memory failure code path (the code other code path that
call drain_all_pages),
there is =A0no inherent memory pressure, so we should be OK.

If we did get to drain_all_pages =A0from direct reclaim, but the cpumask
slab has an object in the
slab (or partial pages in the case =A0of slub), then we never hit the
page allocator so all is well, I believe.

So this leaves us with being called from the direct reclaim path, when
the cpumask slab has no
object or partial pages and it needs to hit the page allocator. =A0If we
hit direct page relcaim, the original
allocation was not atomic ,=A0otherwise we would not have =A0hit direct
page reclaim. =A0The cpumask allocation
however, =A0is atomic,=A0so we have broader allocation=A0options - =A0alloc=
ate
high, =A0allocate outside our cpuset
etc. and =A0there is a=A0reasonable=A0chance the cpumask=A0allocation can
succeed even if the original allocation
ended up in direct reclaim.

So we end up failing to allocate the cpumask var only if the memory
pressure is really a global system
memory shortage, as opposed to, for example, some user space failure
to page in some heap space
in a cpuset. Even then, we fail gracefully.


> Related to that, calling into the page allocator again for
> zalloc_cpumask_var is not cheap. =A0Does reducing the number of IPIs
> offset the cost of calling into the allocator again? How often does it
> offset the cost and how often does it end up costing more? I guess that
> would heavily depend on the number of CPUs and how many of them have
> pages in their per-cpu buffer. Basically, sometimes we *might* save but
> it comes at a definite cost of calling into the page allocator again.
>

Good point and I totally agree it depends on the number of CPUs.

The thing is, if you are at CPUMASK_OFFSTACK=3Dy, you are saying
that you optimize for the large number of CPU case, otherwise it doesn't
make sense - you can represent 32 CPU in the space it takes to
hold the pointer to the cpumask (on 32bit system) etc.

If you are at CPUMASK_OFFSTACK=3Dn you (almost) didn't pay anything.

The way I see it, the use cases where you end up profiting from the code
are the same places you also pay. Having lots of CPU is what=A0forced you
to use CPUMASK_OFFSTACK and pay that extra allocation but
then it is exactly when you have lots of CPUs that the code pays off.

>
> The patch looks ok functionally but I'm skeptical that it really helps
> performance.


Thanks! it is good to hear it is not=A0completely=A0off the wall :-)

I think of it more of as a CPU isolation feature then pure performance.
If you have a system with a couple of dozens of CPUs (Tilera, SGI, Cavium
or the various virtual NUMA folks) you tend to want to break up the system
into sets of CPUs that work of=A0separate=A0tasks.

It is very annoying when a memory allocation failure in a task allocated to=
 a
small set of 4 CPUs=A0yanks out all the rest of your 4,092 CPUs working on
something=A0completely=A0different out of their cache warm happy existence =
into
the cache cold=A0reality=A0of=A0an IPI, or worse=A0yet yanks all those CPUs=
 from the
nirvana of idle C-states saving power just to=A0discover that no, they don'=
t
actually have anything to do. :-)

I do believe the overhead for the cases without a lot of CPUs is quite mini=
mal.

Thanks again for taking your time tor review the patch and for reading
this long
response.

> + =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu(drain_local_pages, NULL, 1);
> =A0}
>
> =A0#ifdef CONFIG_HIBERNATION

I do have a new version of the patch with the logic of building the
cpumask abstracted away to a service
function but otherwise the same. I'll send that out if you figure the
general approach is worth while.

--
Mel Gorman
SUSE Labs



--
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
