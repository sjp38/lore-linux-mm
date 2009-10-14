Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E48996B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 11:40:27 -0400 (EDT)
Date: Wed, 14 Oct 2009 16:40:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091014154026.GC5027@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910132238.40867.elendil@planet.nl> <20091014103002.GA5027@csn.ul.ie> <200910141510.11059.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200910141510.11059.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 14, 2009 at 03:10:08PM +0200, Frans Pop wrote:
> On Wednesday 14 October 2009, Mel Gorman wrote:
> > I think this is very significant. Either that change needs to be backed
> > out or more likely, __GFP_NOWARN needs to be specified and warnings
> > *only* printed when the RX buffers are really low. My expectation would
> > be that some GFP_ATOMIC allocations fail during refill but the fact they
> > fail wakes kswapd to reclaim order-2 pages while the RX buffers in the
> > pool are consumed.
> 
> Sorry I did not actually mention this, but the SKB failures I get with .32 
> have loads of the "Failed to allocate SKB buffer with GFP_ATOMIC. Only 0 
> free buffers remaining." errors. That's why I don't think your patch will 
> help anything.
> 
> zgrep "Only 0 free buffers remaining" /var/log/kern.log* | wc -l
> 84
> 
> OK, they are all GPF_ATOMIC and not GPF_KERNEL, but they also almost all 
> have "0 free buffers"! Next to the 84 warnings for 0 remaining I only have 
> one with "3 free buffers" and one with "1 free buffers".
> 

This is fairly important. It shows that the refills are not keeping up
with the GFP_ATOMIC usage. I'm not sure what to do with this. As the
driver introduced GFP_ATOMIC usage at all, I'm tempted to say revert the
changes in the driver that makes use of GFP_ATOMIC but I'm not the
maintainer. They could also consider having a GFP_ATOMIC-optimistic,
GFP_KERNEL-if-no-buffers-free-and-directly-allocating with GFP_KERNEL
refills always happening in the tasklet.

However, it might be just avoiding the MM problem on my part. It's possible
that if I figure out what went wrong in mm and drivers use of GFP_ATOMIC
will be swept under the carpet.

> And that does not even count the rate limitting:
> Oct 12 20:15:07 aragorn kernel: __ratelimit: 45 callbacks suppressed
> Oct 12 20:25:19 aragorn kernel: __ratelimit: 27 callbacks suppressed
> Oct 12 20:25:20 aragorn kernel: __ratelimit: 2 callbacks suppressed
> 
> Attached the kernel log for one test I did with .32.
> 
> > > In both cases I no longer get SKB errors, but instead (?) I get
> > > firmware errors:
> > > iwlagn 0000:10:00.0: Microcode SW error detected.  Restarting
> > > 0x2000000.
> >
> > I am no wireless expert, but that looks like an separate problem to me.
> > I don't see how an allocation failure could trigger errors in the
> > microcode.
> 
> Yes, it is a separate problem, but it is still significant that reverting 
> that patch triggers them in the extreme swap situation.
> 

True.

> > > With your patch on .32-rc4 I still get the SKB errors, so it does not
> > > seem to help. The only change there may have been is that the desktop
> > > was frozen longer than without the patch, but that is an impression,
> > > not a hard fact.
> >
> > Actually, that's fairly interesting and I think justifies pushing the
> > patch. Direct reclaim can stall processes in a user-visible manner which
> > kswapd is meant to avoid in the majority of cases but is tricky to
> > quantify without instrumenting the kernel to measure direct reclaim
> > frequency and latency (I have WIP tracepoints for this but it's still a
> > WIP). If you notice shorter stalls with the patch applied, it means that
> > kswapd really did need to be informed of the problems.
> 
> No, I thought I saw _longer_ stalls with your patch applied...
> 

Sorry, I misinterpreted. If the stalls are longer, it likely means that
kswapd is doing more work and causing more IO when applied as it tries to
get order-2 pages free. You said you still got SKB errors. Were there any
significant change to the number of failures or can that be told?

> > There still has not been a mm-change identified that makes fragmentation
> > significantly worse.
> 
> My bisection shows a very clear point, even if not an individual commit, in 
> the 'akpm' merge where SKB errors suddenly become *much* more frequent and 
> easy to trigger.
> I'm sorry to say this, but the fact that nothing has been identified yet is 
> IMO the result of a lack of effort, not because there is no such change.
> 

I apologise if I've given that impression. I've been starting at the commits
but could not find an obvious candidate within the page allocator itself which
is why I've been looking at other areas. I put together a hack that allocated
order-2 atomics at a constant rate and order-5 atomics at a lower rate to
try replicate the problem without drivers. I ran some workloads but I wasn't
able to get reliable figures that would have allowed me to investigate further.

> > The majority of the wireless reports have been in 
> > this driver and I think we have the problem commit there. The only other
> > is a firmware loading problem in e100 after resume that fails to make an
> > atomic order-5 fail.
> 
> Not exactly true. Bartlomiej's report was about ipw2200, so there are at 
> least 3 different drivers involved, two wireless and one wired. Besides 
> that one report is related to heavy swap, one to resume and one to driver 
> reload.
> So it's much more likely that there is some common regression (in mm) that 
> affected all three than that there are three unrelated regressions.

Very very likely, I'm not denying this.

> And although both of the others did extremely high allocations, they both 
> started appearing in the same timeframe. And Bart's very first report 
> linked it to mm changes.
> 
> > It's possible that something has changed in resume 
> > in the 2.6.31 window there - maybe something like drivers now reload
> > during resume where they didn't previously or less memory being pushed
> > to swap during resume.
> 
> IMO you're sticking your head in the sand here. 

No. If I was sticking my head in the sand, I would have dismissed this
entirely as "GFP_ATOMIC allocations can fail boo hoo hoo deal with it".

What I'm trying to identify what changed that would affect fragmentation
but that is not within the page allocator itself - largely because with
the exception of the patch I gave you, I couldn't find obvious breakage.

You highlighted the first akpm merge so lets look closer at that as I don't
think there is anything more I can do with the wireless driver other than the
suggestions made already. I looked at this already but I felt fixing GFP_ATOMIC
in wireless was the more likely fix. 

Here is what you said about the merge.

====
For a good overview of the area, use 'gitk f83b1e61..517d0869'.

v2.6.30-5466-ga1dd268   mm: use alloc_pages_exact in alloc_large_system_hash
        2.3     +-
v2.6.30-5478-ge9bb35d   mm: setup_per_zone_inactive_ratio - fix comment and..
        2.5     +-
v2.6.30-5486-g35282a2   migration: only migrate_prep() once per move_pages()
        2.6     -|+|-   not quite conclusive...
v2.6.30-5492-gbce7394   page-allocator: reset wmark_min and inactive ratio..
        2.4     -|-
====

This is what I found. The following were the possible commits that might
be causing the problem.

d239171..72807a7 -- page allocator
	These are the bulk of the page-allocator changes that happened int
	the 2.6.30..2.6.31 cycle. It's also the location of the change to
	kswapd that I sent you a patch for. If there was a marked increase
	in the number of failures before and after this patchset, it means
	that I was wrong about the problem not being in the page allocator
	and I have to go back and keep looking. However, you report that

	commit e9bb35d   mm: setup_per_zone_inactive_ratio - fix comment

	had relatively good results - relatively being that it didn't fail
	on the first try. In my head, these patches have been struck off the
	list of possibilities and is why I've been looking in other subsystems.

56e49d2..f166777 -- reclaim
	I would have considered this strong candidates except again, the last
	good commit happened after this point. If other obvious candidates
	don't crop up, it might be worth double checking within this range, particularly
	commit 56e49d2 vmscan: evict use-once pages first
	as it is targeted at streaming-IO workloads which would include
	your music workload. This commit also will cleanly revert on
	mainline so is relatively easy to test

5c87ead..e9bb35d -- inactive ratio changes
	These patches should be harmless but just in case, please
	compare the output of
	# grep inactive_ratio /proc/zoneinfo
	on 2.6.30 and 2.6.31 and make sure the ratios are the same.

e9bb35d..bce7394 -- various changes
	According to your analysis, this is the most likely location of
	the problem commit.

	Commit b70d94e altered how zonelists were selected during
	allocation. This was tested fairly heavily but if the testing
	missed something, it would mean that some allocations are not
	using the zones they should be.  However, my expectation would
	be that mistakes here would have severe consequences affecting a
	large number of people. This does not revert cleanly but there is
	an untested patch below that should do the job. While it's hard to
	imagine this patch being the problem, it's the most likely commit
	with the range of commits your analysis identified.

	Commit bc75d33 is totally harmless but it mentions min_free_kbytes. I
	checked on my machine to make sure min_free_kbytes was the same on both
	2.6.30 and 2.6.31. Can you check that this is true for your machine? If
	min_free_kbytes decreased, it could explain GFP_ATOMIC failures.

	An extremely unlikely candidate is 75927af8. For this to be a problem,
	much of your userspace would have to be calling madvise() with
	stupid parameters and depending on it silently ignore the
	parameters

	A vague potential candidate for swapless systems is 69c85481 but
	your machine has swap so it can't be this.

	Commit bce7394 affects min_free_kbytes but only on hotplug so it
	can't be this either for your machine

After this point, your analysis indicates that things are already broken
but lets look at some of the candidates anyway.  Out of curiousity,
was CONFIG_UNEVICTABLE_LRU unset in your .config for 2.6.30? I could
only find your 2.6.31 .config. If it was, it might be worth reverting
6837765963f1723e80ca97b1fae660f3a60d77df and unsetting it in 2.6.31 and
seeing what happens.

Commit 8cab4754d24a0f2e05920170c845bd84472814c6 keeps pages on the active
lists for longer than 2.6.30 did. It's possible the fewer reclaim decisions
is delaying lumpy reclaim.

CONFIG_NUMA is not set in your config, so the zone_reclaim() changes
around 24cf72518c79cdcda486ed26074ff8151291cf65 can be discounted.

Commit ee993b135ec75a93bd5c45e636bb210d2975159b altered how lumpy
reclaim works but it should have been harmless. It does not cleanly
revert but it's easy to manually revert.

I didn't spot any other patches that might be potential problems in the
commits.

> I'm not saying that mm is the only issue here, but I'm convinced that there 
> _is_ an mm change that has contributed in a major way to these issues, 
> even if we've not yet been able to identify it.
> 
> > -			    net_ratelimit())
> > +			    net_ratelimit()) {
> >  				IWL_CRIT(priv, "Failed to allocate SKB buffer with %s. Only %u free
> > buffers remaining.\n", priority == GFP_ATOMIC ?  "GFP_ATOMIC" :
> > "GFP_KERNEL",
> 
> Haven't you broken the test 'priority == GFP_ATOMIC' here by setting 
> priority to GFP_ATOMIC|__GFP_NOWARN?
> 

Yes, I did, but as you say that this error message is showing up and buffers
are all depleted, it's not even close to being the right fix. It'd only
be relevant if that error message was showing up with buffers remaining in
the queue.


Revert commit b70d94ee

---

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 557bdad..3a94e4b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -21,8 +21,7 @@ struct vm_area_struct;
 #define __GFP_DMA	((__force gfp_t)0x01u)
 #define __GFP_HIGHMEM	((__force gfp_t)0x02u)
 #define __GFP_DMA32	((__force gfp_t)0x04u)
-#define __GFP_MOVABLE	((__force gfp_t)0x08u)  /* Page is movable */
-#define GFP_ZONEMASK	(__GFP_DMA|__GFP_HIGHMEM|__GFP_DMA32|__GFP_MOVABLE)
+
 /*
  * Action modifiers - doesn't change the zoning
  *
@@ -52,6 +51,7 @@ struct vm_area_struct;
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
+#define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
 
 #ifdef CONFIG_KMEMCHECK
 #define __GFP_NOTRACK	((__force gfp_t)0x200000u)  /* Don't track with kmemcheck */
@@ -128,105 +128,24 @@ static inline int allocflags_to_migratetype(gfp_t gfp_flags)
 		((gfp_flags & __GFP_RECLAIMABLE) != 0);
 }
 
-#ifdef CONFIG_HIGHMEM
-#define OPT_ZONE_HIGHMEM ZONE_HIGHMEM
-#else
-#define OPT_ZONE_HIGHMEM ZONE_NORMAL
-#endif
-
+static inline enum zone_type gfp_zone(gfp_t flags)
+{
 #ifdef CONFIG_ZONE_DMA
-#define OPT_ZONE_DMA ZONE_DMA
-#else
-#define OPT_ZONE_DMA ZONE_NORMAL
+	if (flags & __GFP_DMA)
+		return ZONE_DMA;
 #endif
-
 #ifdef CONFIG_ZONE_DMA32
-#define OPT_ZONE_DMA32 ZONE_DMA32
-#else
-#define OPT_ZONE_DMA32 ZONE_NORMAL
-#endif
-
-/*
- * GFP_ZONE_TABLE is a word size bitstring that is used for looking up the
- * zone to use given the lowest 4 bits of gfp_t. Entries are ZONE_SHIFT long
- * and there are 16 of them to cover all possible combinations of
- * __GFP_DMA, __GFP_DMA32, __GFP_MOVABLE and __GFP_HIGHMEM
- *
- * The zone fallback order is MOVABLE=>HIGHMEM=>NORMAL=>DMA32=>DMA.
- * But GFP_MOVABLE is not only a zone specifier but also an allocation
- * policy. Therefore __GFP_MOVABLE plus another zone selector is valid.
- * Only 1bit of the lowest 3 bit (DMA,DMA32,HIGHMEM) can be set to "1".
- *
- *       bit       result
- *       =================
- *       0x0    => NORMAL
- *       0x1    => DMA or NORMAL
- *       0x2    => HIGHMEM or NORMAL
- *       0x3    => BAD (DMA+HIGHMEM)
- *       0x4    => DMA32 or DMA or NORMAL
- *       0x5    => BAD (DMA+DMA32)
- *       0x6    => BAD (HIGHMEM+DMA32)
- *       0x7    => BAD (HIGHMEM+DMA32+DMA)
- *       0x8    => NORMAL (MOVABLE+0)
- *       0x9    => DMA or NORMAL (MOVABLE+DMA)
- *       0xa    => MOVABLE (Movable is valid only if HIGHMEM is set too)
- *       0xb    => BAD (MOVABLE+HIGHMEM+DMA)
- *       0xc    => DMA32 (MOVABLE+HIGHMEM+DMA32)
- *       0xd    => BAD (MOVABLE+DMA32+DMA)
- *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
- *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
- *
- * ZONES_SHIFT must be <= 2 on 32 bit platforms.
- */
-
-#if 16 * ZONES_SHIFT > BITS_PER_LONG
-#error ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
+	if (flags & __GFP_DMA32)
+		return ZONE_DMA32;
 #endif
-
-#define GFP_ZONE_TABLE ( \
-	(ZONE_NORMAL << 0 * ZONES_SHIFT)				\
-	| (OPT_ZONE_DMA << __GFP_DMA * ZONES_SHIFT) 			\
-	| (OPT_ZONE_HIGHMEM << __GFP_HIGHMEM * ZONES_SHIFT)		\
-	| (OPT_ZONE_DMA32 << __GFP_DMA32 * ZONES_SHIFT)			\
-	| (ZONE_NORMAL << __GFP_MOVABLE * ZONES_SHIFT)			\
-	| (OPT_ZONE_DMA << (__GFP_MOVABLE | __GFP_DMA) * ZONES_SHIFT)	\
-	| (ZONE_MOVABLE << (__GFP_MOVABLE | __GFP_HIGHMEM) * ZONES_SHIFT)\
-	| (OPT_ZONE_DMA32 << (__GFP_MOVABLE | __GFP_DMA32) * ZONES_SHIFT)\
-)
-
-/*
- * GFP_ZONE_BAD is a bitmap for all combination of __GFP_DMA, __GFP_DMA32
- * __GFP_HIGHMEM and __GFP_MOVABLE that are not permitted. One flag per
- * entry starting with bit 0. Bit is set if the combination is not
- * allowed.
- */
-#define GFP_ZONE_BAD ( \
-	1 << (__GFP_DMA | __GFP_HIGHMEM)				\
-	| 1 << (__GFP_DMA | __GFP_DMA32)				\
-	| 1 << (__GFP_DMA32 | __GFP_HIGHMEM)				\
-	| 1 << (__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM)		\
-	| 1 << (__GFP_MOVABLE | __GFP_HIGHMEM | __GFP_DMA)		\
-	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA)		\
-	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_HIGHMEM)		\
-	| 1 << (__GFP_MOVABLE | __GFP_DMA32 | __GFP_DMA | __GFP_HIGHMEM)\
-)
-
-static inline enum zone_type gfp_zone(gfp_t flags)
-{
-	enum zone_type z;
-	int bit = flags & GFP_ZONEMASK;
-
-	z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
-					 ((1 << ZONES_SHIFT) - 1);
-
-	if (__builtin_constant_p(bit))
-		MAYBE_BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
-	else {
-#ifdef CONFIG_DEBUG_VM
-		BUG_ON((GFP_ZONE_BAD >> bit) & 1);
+	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
+			(__GFP_HIGHMEM | __GFP_MOVABLE))
+		return ZONE_MOVABLE;
+#ifdef CONFIG_HIGHMEM
+	if (flags & __GFP_HIGHMEM)
+		return ZONE_HIGHMEM;
 #endif
-	}
-	return z;
+	return ZONE_NORMAL;
 }
 
 /*
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
