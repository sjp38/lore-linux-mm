Date: Tue, 1 Nov 2005 11:57:19 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
In-Reply-To: <4366D469.2010202@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0511011014060.14884@skynet>
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie><20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au>
 <20051030235440.6938a0e9.akpm@osdl.org> <27700000.1130769270@[10.10.2.4]>
 <4366A8D1.7020507@yahoo.com.au> <Pine.LNX.4.58.0510312333240.29390@skynet>
 <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet>
 <4366D469.2010202@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Nov 2005, Nick Piggin wrote:

> OK I'm starting to repeat myself a bit so after this I'll be
> quiet for a bit and let others speak :)
>
> Mel Gorman wrote:
> > On Tue, 1 Nov 2005, Nick Piggin wrote:
>
> > I accept that. We should not be encouraging subsystems to use high order
> > allocations but keeping the system in a fragmented state to force the
> > issue is hardly the correct thing to do either.
> >
>
> But you don't seem to actually "fix" anything. It is slightly improved,
> but for cases where higher order GFP_ATOMIC and GFP_KERNEL allocations
> fail (ie. anything other than memory hotplug or hugepages) you still
> seem to have all the same failure cases.
>

The set of patches do fix a lot and make a strong start at addressing the
fragmentation problem, just not 100% of the way. The stress tests I've
been running with kernel compiles show that relatively few kernel pages
fallback to undesirable areas. The failure cases I hit are dependant on
workload rather than almost guaranteed to happen as we have with the
current approach.

For example, this is the fallback statistics for the Normal zone after a
kernel compile stress-test (5 simultaneous -j2 kernel compiles);

KernNoRclm Allocs: 35461      Reserve: 24         Fallbacks: 2
EasyRclm   Allocs: 971798     Reserve: 152        Fallbacks: 1223
KernRclm   Allocs: 34816      Reserve: 16         Fallbacks: 0
Fallback   Allocs: 0          Reserve: 28         Fallbacks: 0

2 really awkward kernel pages out of 35,461 allocations ended up in the
wrong place. Reducing the fallbacks to 0 for all workloads would require
page reclaim that knew what the areas in the usemap meant. If a mechanism
like linear page reclaiming was built upon these patches, we would find
that at least 152 2^MAX_ORDER-1 pages could be allocated on demand if we
wanted to. We don't do anything like this today because it simply isn't
possible.

GFP_ATOMIC allocations still suffer. If the order size they need is not
available, they can't fix up the situation. Fixing that up would require
something like active defragmentation, kswapd to work on keeping high
order free pages or the reliable and reasonable "don't do high order
GFP_ATOMIC allocations".

So, with this set of patches, how fragmented you get is dependant on the
workload and it may still break down and high order allocations will fail.
But the current situation is that it will defiantly break down. The fact
is that it has been reported that memory hotplug remove works with these
patches and doesn't without them. Granted, this is just one feature on a
high-end machine, but it is one solid operation we can perform with the
patches and cannot without them. The second possibility is that this patch
may allow the preloading of per-cpu magazines which will improve some
workloads and make no different to others. Preloading in one allocation is
less work than loading with pcp->batch allocations.

> Transient higher order allocations mean we don't fragment much, you say?
> Well that is true, but it is true for how the system currently works.
> My desktop has been up for a day or two, and it has 4444K free, and it
> has 295 order-3 pages available - it can run a GigE and all its trasient
> allocations no problem.
>
> In the cases were we *do* actually get those failures from eg. networking,
> I'd say your patch probably will end up having problems too. The way to
> fix it is to not use higher order allocations.
>
> > > But complexity. More bugs, code harder to understand and maintain, more
> > > cache and memory footprint, more branches and instructions.
> > >
> >
> >
> > The patches have gone through a large number of revisions, have been
> > heavily tested and reviewed by a few people. The memory footprint of this
> > approach is smaller than introducing new zones. If the cache footprint,
> > increased branches and instructions were a problem, I would expect them to
> > show up in the aim9 benchmark or the benchmark that ran ghostscript
> > multiple times on a large file.
> >
>
> I appreciate that a lot of work has gone into them. You must appreciate
> that they add a reasonable amount of complexity and a non-zero perormance
> cost to the page allocator.
>

I do appreciate that there is a reasonable amount of complexity. Hence the
patches are fairly well commented and the introduction mail and changelog
is detailed to help explain the mechanism. If that is not good enough,
people googling may find the lwn.net article
(http://lwn.net/Articles/120960/) that explains the guts of the mechanism
complete with comment at the end on how hard it is to get high-order
allocation patches merged :). The complexity of this scheme was the main
reason why an early version was released long before it was ready so
people would have a chance to look through it.

The performance cost is something that has to be determined by benchmarks.
With each version of this patch, I released aim9 benchmarks of the clean
kernel and with my benchmarks. If there were performance regressions on my
test machine, it didn't get released until I had figured out what I was
doing wrong. Here is the difference between 2.6.14-rc5-mm1 and
2.6.14-rc5-mm1-mbuddy-v19

 1 creat-clo      16006.00   15889.41    -116.59 -0.73% File Creations and Closes/second
 2 page_test     117515.83  117082.15    -433.68 -0.37% System Allocations & Pages/second
 3 brk_test      440289.81  437887.37   -2402.44 -0.55% System Memory Allocations/second
 4 jmp_test     4179466.67 4179950.00     483.33  0.01% Non-local gotos/second
 5 signal_test    80803.20   85335.78    4532.58  5.61% Signal Traps/second
 6 exec_test         61.75      61.92       0.17  0.28% Program Loads/second
 7 fork_test       1327.01    1342.21      15.20  1.15% Task Creations/second
 8 link_test       5531.53    5555.55      24.02  0.43% Link/Unlink Pairs/second

I'll admit right now there is a 0.37% drop in raw page allocation
performance on this test run but these figures always vary by a few
percent. I could run this aim9 test a few more times until I got a figure
that showed the set of patches giving a performance gain. fork_test and
signal_test show a nice performance improvement.

A trip through the -mm tree would discover if the performance figures are
real, or are they just on my test machine.

> However I think something must be broken if the footprint of adding a new
> zone is higher?
>

Here are the sizeof() of struct zone in three kernels

2.6.14-rc5-mm1: 768
2.6.14-rc5-mm1-mbuddy-nostats: 1408
2.6.14-rc5-mm1-mbuddy-withallocstats: 1536

The main increases in the size is one additional list for per-cpu for
every CPU in the system and the addition of the new free lists. The usemap
is 2 bits per 2^(MAX_ORDER-1) pages in the system. On my system with
1.5GiB of RAM, that's 94 bytes. So the memory overhead is about 734 bytes
in all.

If a very small memory system was worried about this, they could get rid
of this whole scheme by defining __GFP_KERNRCLM and __GFP_EASYRCLM to 0
and change RCLM_TYPES from 4 to 1. Actually... Now that I think it, this
whole anti fragmentation scheme could be made configurable by doing
something like;

#ifdef CONFIG_ANTIDEFRAG
#define RCLM_NORCLM   0
#define RCLM_EASY     1
#define RCLM_KERN     2
#define RCLM_FALLBACK 3
#define RCLM_TYPES    4
#define __GFP_EASYRCLM   0x80000u  /* User and other easily reclaimed pages */
#define __GFP_KERNRCLM   0x100000u /* Kernel page that is reclaimable */
#else
#define RCLM_NORCLM   0
#define RCLM_EASY     0
#define RCLM_KERN     0
#define RCLM_FALLBACK 0
#define RCLM_TYPES    1
#define __GFP_EASYRCLM   0u
#define __GFP_KERNRCLM   0u
#endif

This would need more work obviously, but essentially, the above would make
anti-defragmentation a configurable option for small memory systems.
However, I would be wary of changing the behavior of the allocator as a
configurable option for anything other than debugging. Such an option
should only be provided if we really want those 734 bytes back.

We can't measure the difference in code complexity as we don't have a
zone-based approach to compare against. Ideally if it did exist, any loop
that depends on MAX_NR_ZONES would be increased by 1, maybe 2 depending on
how many of these easyrclm zones that would be created. This would impact
both the allocator and kswapd. It would at least add 768 or 1536 for two
zones in comparison to the 734 bytes my approach adds.

> > > The easy-to-reclaim stuff doesn't need higher order allocations anyway, so
> > > there is no point in being happy about large contiguous regions for these
> > > guys.
> > >
> >
> >
> > The will need high order allocations if we want to provide HugeTLB pages
> > to userspace on-demand rather than reserving at boot-time. This is a
> > future problem, but it's one that is not worth tackling until the
> > fragmentation problem is fixed first.
> >
>
> Sure. In what form, we haven't agreed. I vote zones! :)
>

We'll agree to disagree for the moment ;) . I would expect others to choke
on the idea of more zones been introduced. Some architectures like power
and sparc64 (I think) only use one zone ZONE_DMA. Hopefully some of the
architecture maintainers will express some opinion on the addition of new
zones.

> >
> > > The only thing that seems to need it is memory hot unplug, which should
> > > rather
> > > use another zone.
> > >
> >
> >
> > Work from 2004 in memory hotplug was trying to use additional zones. I am
> > hoping that someone more involved with memory hotplug will tell us what
> > problems they ran into. If they ran into no problems, they might explain
> > why it was never included in the mainline.
> >
>
> That would be good.
>
> > > OK, for hot unplug you may want that, or for hugepages. However, in those
> > > cases it should be done with zones AFAIKS.
> > >
> >
> >
> > And then we are back to what size to make the zones. This set of patches
> > will largely manage themselves without requiring a sysadmin to intervene.
> >
>
> Either you need to guarantee some hugepage allocation / hot unplug
> capability or you don't. Placing a bit of burden on admins of these
> huge servers or mainframes sounds like a fine idea to me.
>

I'd rather avoid hitting people with tunables if at all possible. I'd
rather my face didn't end up on the dart board of some NOC because their
high-end server failed at 4 in the morning because they misconfigured the
size of the kernel zone.

> Seriously nobody else will want this, no embedded, no desktops, no
> small servers.
>

Not yet anyway. My long-term plan is to have HugeTLB pages supplied on
demand for applications that wanted them. This would require fragmentation
to be addressed first. Desktop applications like openoffice or anything
using a sparse address space like Java applications should benefit if they
could use HugeTLB pages. Small database servers should see a benefit as
well. Of course, this would not happen today, because right now, we cannot
give HugeTLB pages on demand to anyone, userspace or kernel space and
there is no point even trying.

Solaris is able to supply large pages for applications on demand but it
eventually falls back to using small pages because they get fragmented. I
think Windows has an API for large pages as well, but it also hits
fragmentation problems.

> >
> > > > > IMO in order to make Linux bulletproof, just have fallbacks for
> > > > > anything
> > > > > greater than about order 2 allocations.
> > > > >
> > > >
> > > >
> > > > What sort of fallbacks? Private pools of pages of the larger order for
> > > > subsystems that need large pages is hardly desirable.
> > > >
> > >
> > > Mechanisms to continue to run without contiguous memory would be best.
> > > Small private pools aren't particularly undesirable - we do that
> > > everywhere
> > > anyway. Your fragmentation patches essentially do that.
> > >
> >
> >
> > The main difference been that when a subsystem has small private pools, it
> > is possible for anyone else to use them and shrinking mechanisms are
> > required. My fragmentation patches has subpools, but they are always
> > available.
> >
>
> True, but we're talking about the need to guarantee an allocation. In
> that case, mempools are required anyway and neither the current nor your
> modified page allocator will help.
>

The modified allocator will help when refilling the mempools as long as
the caller is not GFP_ATOMIC. If using GFP_KERNEL, kswapd will page out
enough pages to get the contiguous blocks. Teaching kswapd to be smarter
about freeing contiguous pages is future work.

> In the case were there is no need for a guarantee, there is presumably
> some other fallback.
>
> >
> > > > > From what I have seen, by far our biggest problems in the mm are due
> > > > > to
> > > > > page reclaim, and these patches will make our reclaim behaviour more
> > > > > complex I think.
> > > > >
> > > >
> > > >
> > > > This patchset does not touch reclaim at all. The lists that this patch
> > > > really affects is the zone freelists, not the LRU lists that page
> > > > reclaim
> > > > are dealing with. It is only later when we want to try and guarantee
> > > > large-order allocations that we will have to change page reclaim.
> > > >
> > >
> > > But it affects things in the allocation path which in turn affects the
> > > reclaim path.
> >
> >
> > Maybe it's because it's late, but I don't see how these patches currently
> > hit the reclaim path. The reclaim path deals with LRU lists, this set of
> > patches deals with the freelists.
> >
>
> You don't "hit" the reclaim path, but by making the allocation path
> more complex makes reclaim behaviour harder to analyse.
>

I still don't see why. With the normal allocator, free pages are on a list
that get allocated. With the modified allocator, free pages are on lists
that get allocated.

> >
> > > You're doing various balancing and fallbacks and it is
> > > simply complicated behaviour in terms of trying to analyse a working
> > > system.
> > >
> >
> >
> > Someone performing such an analysis of the system will only hit problems
> > with these patches if they are performing a deep analysis of the page
> > allocator. Other analysis such as the page reclaim should not even notice
> > that the page allocator has changed.
> >
>
> Let me think what a nasty one we had was? Oh yeah, the reclaim
> priority would "wind up" because concurrent allocations were keeping
> free pages below watermarks.
>

That sounds like kswapd could not free pages fast enough for the storm of
allocators coming in. In that case, they would all enter direct reclaim
leading to a storm of kswapd-like processes.

I still cannot see any impact these patches would have on reclaim but
maybe that is a lack of imagination. I'll accept that, potentially, these
patches affect reclaim in some-currently-undefined-fashion. If that is the
case, I would assert that any zone-based approach would also have an
impact because kswapd has a new zone to manage the watermarks for.

> I don't know, that's just an example but there are others. The two
> are fundamentally tied together.
>
>

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
