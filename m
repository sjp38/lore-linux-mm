Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11278C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 21:48:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85FB820823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 21:48:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85FB820823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E766C8E005F; Mon,  4 Feb 2019 16:48:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFF168E001C; Mon,  4 Feb 2019 16:48:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9F338E005F; Mon,  4 Feb 2019 16:48:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D19B8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 16:48:00 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so783340pgt.11
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 13:48:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pvOR0ybWLbquYq9P4dkVnEQ/6DW4HDb2qClxVvzG6Ns=;
        b=WHyTks2Qt6CQghgt+U5nP7DedBXOZNQUMYv3/Z7dcxaROtkYDLSLcBXp2fOkO9te5I
         cZDGc6gONeIn/onRij0AjWDxTUMnONDQ3dOBw/o77ld5naZzC5ZsRoGkDkrrNy+QG8EB
         7nWTa8q79qKqlQzmGAMOkFjbtd3Tx+OApli2EfByOUENVBybh+A0h1Io1R2RJ6gGJtay
         YBGll8d9FvH7P328a6umWkBXp1ikIG0FX8bES92OPpLBW+ZhdxupcEv+3Ch4tN9JQ3Zs
         pv7KI7xDcgIeNN40mCErSamERSDQ0L72bKkkfOAbGZDibpilncxPrBol1IqRvPDL1eIn
         Qtng==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuZ000gkJcG5SxHJ0gjDfVoaWupng5gIR5xL4jA/yMd654VSJCkn
	niVeC7YY8RpNzQ6q4LdDbi3K6Urf5oDVHY28dLFTN87fAsesVshtQ8HsqKJAqIRsBe5gSrEmmlC
	I0NGHWiCUadYIi06dae+u3yqPLG3edkwATzEi/Fy0r6ufPg52gDOZSZgIkqptwkw=
X-Received: by 2002:a17:902:778b:: with SMTP id o11mr1586602pll.90.1549316879971;
        Mon, 04 Feb 2019 13:47:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYVMEkTgxM+U+y4ClCROMm9XE/BJ3t09AtGI8+h99cr/wdho+wYWSWu9Kn4HPSankSkQ8Z8
X-Received: by 2002:a17:902:778b:: with SMTP id o11mr1586519pll.90.1549316878339;
        Mon, 04 Feb 2019 13:47:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549316878; cv=none;
        d=google.com; s=arc-20160816;
        b=mmJ6iZ1fMMvFXqtvknaSlZRgHN6xLWZAXSAvVF7hE+iynI0d+h6RYUnf0GY6To07FB
         Vu+f6Lb7mzpkr/qOLL8P2G2s0RxEFKCuxP2p2WSoECK/p4DLsZOWpREVRf8bupP5Pop5
         LGGT2KIARHKTvZtI9tfaGILDBZTavTKOd9HL8pC0ocyaR92XFSsvmUmlpIMktTDP3Ewv
         dy3PAvEXgH0rBtKPYBQuEaZOysrVFlNTdGHbapbAfVBlC/C/+gP7SrEw8goKEUfVmj4F
         yIQNMThoZY9NbNkOpRILFDOipj5rWJexmE9r+kFy/FpxetR4WRSeU3wZIJHVk2Gk8pNf
         2njA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pvOR0ybWLbquYq9P4dkVnEQ/6DW4HDb2qClxVvzG6Ns=;
        b=ZOW17JKw2czO1JDCaHtPoIs27+aVTfjJeTJIA4tXx8+DtY5lFpnhHb7whV7ay6Cg5i
         aaR7/D7pnFR3ClJUwqXAvtzLYpAJVC6/3topIqJFdZY9nca+SpA4qJzPJc5Ok0yekop/
         0GZS/ooF2m5BEJyoYqmXn09m/PrClg8NQrdgEIR1T6AT+zbyqbstihowYWb16I6sea6L
         2ONWByTmBXkjyPMjHPFr+btV1bXihY1bg7N+a9z7OXaU4kJPpWrUrVf2F2vHYlLPEVfj
         iYx/dKn07aVO72Xh6e2RDEN1+89nJNR9pxNLoKIIC26Mi7fKZEviOtAxoS5tm/uMfMZh
         tryQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id f5si1107072pfn.259.2019.02.04.13.47.56
        for <linux-mm@kvack.org>;
        Mon, 04 Feb 2019 13:47:58 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.145;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl6.internode.on.net with ESMTP; 05 Feb 2019 08:17:55 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gqm5q-0000OY-G6; Tue, 05 Feb 2019 08:47:54 +1100
Date: Tue, 5 Feb 2019 08:47:54 +1100
From: Dave Chinner <david@fromorbit.com>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Chris Mason <clm@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Message-ID: <20190204214754.GA14116@dastard>
References: <20190130041707.27750-1-david@fromorbit.com>
 <20190130041707.27750-2-david@fromorbit.com>
 <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
 <20190131013403.GI4205@dastard>
 <20190131091011.GP18811@dhcp22.suse.cz>
 <20190131185704.GA8755@castle.DHCP.thefacebook.com>
 <20190131221904.GL4205@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131221904.GL4205@dastard>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 01, 2019 at 09:19:04AM +1100, Dave Chinner wrote:
> > So, assuming all this, can we, please, first check if Rik's patch is addressing
> > the regression?
> 
> Nope, it's broken and buggy, and reintroduces problems with racing
> deferred counts that were fixed years ago when I originally
> wrote the numa aware shrinker infrastructure.

So, the first thing to do here is fix the non-deterministic deferred
reclaim behaviour of the shrinker. Any deferred reclaim because of
things like GFP_NOFS contexts get landed on the the very next
shrinker instance that runs, be it kswapd, direct reclaim, or
whether it can even perform reclaim or not (e.g. it might be a
GFP_NOFS context itself).

As a result, there is no predicting when a shrinker instance might
get landed with a huge amount of work that isn't it's own. We can't
even guarantee that kswapd reclaim context sees this deferred work,
because if there is another reclaimer on that node running at the
same time, it will have scooped away the deferred work and kswapd
will only do a small amount of work.

How small? Well a node with 1.8m freeable items, reclaim priority
12 (i.e. lowest priority), and seeks = 2 will result in a scan count
of:

	delta = 1,800,000 >> 12 = 440
	delta *= 4 = 1600
	delta /= 2 = 800.

the shrinker will only scan 800 objects when there is light memory
pressure. That's only 0.04% of the cache, which is insignificant.
That's fine for direct reclaim, but for kswapd we need it to do more
work when there is deferred work.

So, say we have another 1m objects of deferred work (very common
on filesystem (and therefore GFP_NOFS) heavy workloads), we'll do:

	total_scan = deferred_objects;
	....
	total_scan += delta;

(ignoring clamping)

which means that we'll actually try to scan 1,000,800 objects from
the cache on the next pass. This may be clamped down to
(freeable_objects / 2), but that's still 900,000 objects in this
case.

IOWs, we just increased the reclaim work of this shrinker instance
by a factor of 1000x.  That's where all the long tail shrinker
reclaim latencies are coming from, and where a large amount of the
"XFS is doing inode IO from the shrinker" come from as they drive it
straight through all the clean inodes and into dirty reclaimable
inodes. With the additional "small cache" pressure being added and
then deferred since 4.18-rc5, this is much more likely to happen
with direct reclaim because the deferred count from GFP_NOFS
allocations are wound up faster.

So, if we want to prevent direct reclaim from this obvious long tail
latency problem, we have to stop direct reclaim from ever doing
deferred work. i.e. we need to move deferred work to kswapd and, for
XFS, we then have to ensure that kswapd will not block on dirty
inodes so it can do all this work as quickly as possible. And then
for kswapd, we need to limit the amount of deferred work so that it
doesn't spend all it's time emptying a single cache at low
priorities, but will attempt to perform all the deferred work if
reclaim priority winds up far enough.

This gives us a solid, predictable "deferred work" infrastructure
for the shrinkers. It gets rid of the nasty behaviour, and paves the
way for adding different sorts of deferred work (like Rik's "small
cache" pressure increase) to kswapd rather than in random reclaim
contexts. It also allows us to use a different "how much work should
we do" calculation for kswapd. i.e. one that is appropriate for
background, non-blocking scanning rather than being tailored to
limiting the work that any one direct reclaim context must do.

So, if I just set the XFS inode cache shrinker to skip inode
writeback (as everyone seems to want to do), fsmark is OOM-killed at
27M inodes, right when the log runs out of space, the tail-pushing
thread goes near to being CPU bound, and inode writeback from
reclaim is necessary to retire the dirty inode from the log before
it can be reclaimed. It's easily reproducable, and sometimes the
oom-killer chooses daemons rather than fsmark and it has killed the
system on occasion. Reverting the two patches in this thread makes
the OOM kill problem go away - it just turns it back into a
performance issue.

So, on top of the reverts, the patch below that reworks the deferred
shrinker work to kswapd is the first patch I've been able to get a
"XFs inode shrinker doesn't block kswapd" patch through my
benchmarks and memory stress workloads without triggering OOM-kills
randomly or seeing substantial performance regressions. Indeed, it
appears to behave better that the existing code (fsmark inode create
is marginally faster, simoops long tails have completely gone(*)).

This indicates to me that we really should be considering fixing the
deferred work problems before adding new types of deferred work into
the shrinker infrastructure (for whatever reason). Get the
infrastructure, reliable, predictable and somewhat deterministic,
then we can start trialling pressure/balance changes knowing exactly
where we are directing that extra work....

Cheers,

Dave.

(*) Chris, FYI, the last output before symoops died because "too
many open files" - p99 latency is nearly identical to p50 latency:

Run time: 10873 seconds
Read latency (p50: 3,084,288) (p95: 3,158,016) (p99: 3,256,320)
Write latency (p50: 7,479,296) (p95: 8,101,888) (p99: 8,437,760)
Allocation latency (p50: 479,744) (p95: 744,448) (p99: 1,016,832)
work rate = 8.63/sec (avg 9.05/sec) (p50: 9.19) (p95: 9.91) (p99: 11.42)
alloc stall rate = 0.02/sec (avg: 0.01) (p50: 0.01) (p95: 0.01) (p99: 0.01)

This is the same machine that I originally ran simoops on back in
~4.9 when you first proposed async kswapd behaviour for XFS. Typical
long tail latencies back then were:

[https://www.spinics.net/lists/linux-xfs/msg02235.html]

Run time: 1140 seconds
Read latency (p50: 3,035,136) (p95: 4,415,488) (p99: 6,119,424)
Write latency (p50: 27,557,888) (p95: 31,490,048) (p99: 45,285,376)
Allocation latency (p50: 247,552) (p95: 1,497,088) (p99: 19,496,960)
work rate = 3.68/sec (avg 3.71/sec) (p50: 3.71) (p95: 4.04) (p99: 4.04)
alloc stall rate = 1.65/sec (avg: 0.12) (p50: 0.00) (p95: 0.12) (p99: 0.12)

-- 
Dave Chinner
david@fromorbit.com

mm: shrinker deferral cleanup

From: Dave Chinner <dchinner@redhat.com>

Shrinker defers to random GFP_KERNEL reclaim context, which means so
poor direct reclaimer coul dbe loaded with huge amounts of work just
because it's the first reclaimer in a while.

This can be seen from the shrinker trace point output, where a
random reclaim contexts take all the deferred scan count and try to
run it, then put it all back in the global pool when they are done.
Racing shrinkers see none of that deferred work, to the point where
kswapd may never see any load on the shrinker at all because it's
always being held by a direct reclaimer.

SO, first things first: only do deferred work in kswapd context. We
know that this is GFP_KERNEL context, so work deferred from GFP_NOFS
contexts will always be able to run from kswapd.

This also gets rid of the need to specifically avoid windup because
we only have one thread that will process the deferred work, and it
will be capped in what it can do in a single by the reclaim priority
it operates under. i.e. reclaim priority prevents deferred work from
being done all at once under light memory pressure. If we have realy
heavy pressure, then we're aiming to kill as much cache as we can,
so at that point windup no longer matters.

Next, factor of the calculation of the amount of work to do from the
rest of the code. This makes it easier to see what is work
calculation and what are constraints, clamping and behavioural
restrictions. Rename the variables to be more meaningful, too,
and convert everything to uint64_t because all the hoops we jump
through to keep things in 32 bits for 32 bit systems makes this all
just a mess.

Next, allow the shrinker "freeable object count" callout tell the
shrinker it won't be able to do any work. e.g. GFP_NOFS context on a
filesystem shrinker. THis means it can simply calculate the work to
defer to kswapd and move on. Fast, and doesn't require calling into
the scan code to find out that we can't actually do any work.

Next, cleanup the tracing to be less ... obtuse. We care about the
work being done, the amount of work that was done, and how much we
still have deferred to do. The rest of it is mostly useless.

Finally, remove the blocking SYNC_WAIT from kswapd context in the
XFS inode shrinker. Still block direct reclaim, but allow kswapd to
scan primarily for clean, immediately reclaimable inodes without
regard to any other reclaim that is on-going. This means kswapd
won't get stuck behind blocked direct reclaim, nor will it issue IO
unless there

Further experiments:
- kick kswapd when deferred gets too big
- store deferred priority rather than a count? Windup always ends up
  with more deferred work than there is freeable items, so a
  do_div(freeable, deferred_priority) setup might make sense.
- get kswapd reclaim priority priority wound up if shrinker
  is not making enough progress on deferred work.
- factor out deferral code

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/super.c                    |   8 +++
 fs/xfs/xfs_icache.c           |   7 +-
 include/linux/shrinker.h      |   2 +
 include/trace/events/vmscan.h |  69 +++++++++----------
 mm/vmscan.c                   | 156 +++++++++++++++++++++++++-----------------
 5 files changed, 141 insertions(+), 101 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 48e25eba8465..59bfb285a856 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -139,6 +139,14 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 		return 0;
 	smp_rmb();
 
+	/*
+	 * If we know we can't reclaim, let the shrinker know so it can account
+	 * for deferred reclaim that kswapd must do, but doesn't have to call
+	 * super_cache_count to find this out.
+	 */
+	if (!(sc->gfp_mask & __GFP_FS))
+		sc->will_defer = true;
+
 	if (sb->s_op && sb->s_op->nr_cached_objects)
 		total_objects = sb->s_op->nr_cached_objects(sb, sc);
 
diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 245483cc282b..60723ae79ec2 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1373,11 +1373,16 @@ xfs_reclaim_inodes_nr(
 	struct xfs_mount	*mp,
 	int			nr_to_scan)
 {
+	int			flags = SYNC_TRYLOCK;
+
 	/* kick background reclaimer and push the AIL */
 	xfs_reclaim_work_queue(mp);
 	xfs_ail_push_all(mp->m_ail);
 
-	return xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan);
+	if (!current_is_kswapd())
+		flags |= SYNC_WAIT;
+
+	return xfs_reclaim_inodes_ag(mp, flags, &nr_to_scan);
 }
 
 /*
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 9443cafd1969..a4216dcdd59e 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -31,6 +31,8 @@ struct shrink_control {
 
 	/* current memcg being shrunk (for memcg aware shrinkers) */
 	struct mem_cgroup *memcg;
+
+	bool will_defer;
 };
 
 #define SHRINK_STOP (~0UL)
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a1cb91342231..a4f34cde779a 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -195,84 +195,81 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_re
 
 TRACE_EVENT(mm_shrink_slab_start,
 	TP_PROTO(struct shrinker *shr, struct shrink_control *sc,
-		long nr_objects_to_shrink, unsigned long cache_items,
-		unsigned long long delta, unsigned long total_scan,
-		int priority),
+		int64_t deferred_count, int64_t freeable_objects,
+		int64_t scan_count, int priority),
 
-	TP_ARGS(shr, sc, nr_objects_to_shrink, cache_items, delta, total_scan,
+	TP_ARGS(shr, sc, deferred_count, freeable_objects, scan_count,
 		priority),
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
 		__field(void *, shrink)
 		__field(int, nid)
-		__field(long, nr_objects_to_shrink)
-		__field(gfp_t, gfp_flags)
-		__field(unsigned long, cache_items)
-		__field(unsigned long long, delta)
-		__field(unsigned long, total_scan)
+		__field(int64_t, deferred_count)
+		__field(int64_t, freeable_objects)
+		__field(int64_t, scan_count)
 		__field(int, priority)
+		__field(gfp_t, gfp_flags)
 	),
 
 	TP_fast_assign(
 		__entry->shr = shr;
 		__entry->shrink = shr->scan_objects;
 		__entry->nid = sc->nid;
-		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
-		__entry->gfp_flags = sc->gfp_mask;
-		__entry->cache_items = cache_items;
-		__entry->delta = delta;
-		__entry->total_scan = total_scan;
+		__entry->deferred_count = deferred_count;
+		__entry->freeable_objects = freeable_objects;
+		__entry->scan_count = scan_count;
 		__entry->priority = priority;
+		__entry->gfp_flags = sc->gfp_mask;
 	),
 
-	TP_printk("%pF %p: nid: %d objects to shrink %ld gfp_flags %s cache items %ld delta %lld total_scan %ld priority %d",
+	TP_printk("%pF %p: nid: %d objects to scan %lld freeable items %lld deferred count %lld priority %d gfp_flags %s",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
-		__entry->nr_objects_to_shrink,
-		show_gfp_flags(__entry->gfp_flags),
-		__entry->cache_items,
-		__entry->delta,
-		__entry->total_scan,
-		__entry->priority)
+		__entry->scan_count,
+		__entry->freeable_objects,
+		__entry->deferred_count,
+		__entry->priority,
+		show_gfp_flags(__entry->gfp_flags))
 );
 
 TRACE_EVENT(mm_shrink_slab_end,
-	TP_PROTO(struct shrinker *shr, int nid, int shrinker_retval,
-		long unused_scan_cnt, long new_scan_cnt, long total_scan),
+	TP_PROTO(struct shrinker *shr, int nid, int64_t freed_objects,
+		int64_t unused_scan_cnt, int64_t new_deferred_count,
+		int64_t old_deferred_count),
 
-	TP_ARGS(shr, nid, shrinker_retval, unused_scan_cnt, new_scan_cnt,
-		total_scan),
+	TP_ARGS(shr, nid, freed_objects, unused_scan_cnt, new_deferred_count,
+		old_deferred_count),
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
 		__field(int, nid)
 		__field(void *, shrink)
-		__field(long, unused_scan)
-		__field(long, new_scan)
-		__field(int, retval)
-		__field(long, total_scan)
+		__field(long long, unused_scan)
+		__field(long long, new_deferred_count)
+		__field(long long, freed_objects)
+		__field(long long, old_deferred_count)
 	),
 
 	TP_fast_assign(
 		__entry->shr = shr;
 		__entry->nid = nid;
 		__entry->shrink = shr->scan_objects;
+		__entry->freed_objects = freed_objects;
 		__entry->unused_scan = unused_scan_cnt;
-		__entry->new_scan = new_scan_cnt;
-		__entry->retval = shrinker_retval;
-		__entry->total_scan = total_scan;
+		__entry->new_deferred_count = new_deferred_count;
+		__entry->old_deferred_count = old_deferred_count;
 	),
 
-	TP_printk("%pF %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("%pF %p: nid: %d freed objects %lld unused scan count %lld new deferred count %lld old deferred count %lld",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
+		__entry->freed_objects,
 		__entry->unused_scan,
-		__entry->new_scan,
-		__entry->total_scan,
-		__entry->retval)
+		__entry->new_deferred_count,
+		__entry->old_deferred_count)
 );
 
 TRACE_EVENT(mm_vmscan_lru_isolate,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e979705bbf32..7db6d8242613 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -447,37 +447,21 @@ void unregister_shrinker(struct shrinker *shrinker)
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
-#define SHRINK_BATCH 128
-
-static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
-				    struct shrinker *shrinker, int priority)
+/*
+ * calculate the number of new objects to scan this this time around
+ */
+static int64_t shrink_scan_count(struct shrink_control *shrinkctl,
+			    struct shrinker *shrinker, int priority,
+			    uint64_t *freeable_objects)
 {
-	unsigned long freed = 0;
-	unsigned long long delta;
-	long total_scan;
-	long freeable;
-	long nr;
-	long new_nr;
 	int nid = shrinkctl->nid;
-	long batch_size = shrinker->batch ? shrinker->batch
-					  : SHRINK_BATCH;
-	long scanned = 0, next_deferred;
-
-	if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
-		nid = 0;
+	uint64_t delta;
+	uint64_t freeable;
 
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
 	if (freeable == 0 || freeable == SHRINK_EMPTY)
 		return freeable;
 
-	/*
-	 * copy the current shrinker scan count into a local variable
-	 * and zero it so that other concurrent shrinker invocations
-	 * don't also do this scanning work.
-	 */
-	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
-
-	total_scan = nr;
 	if (shrinker->seeks) {
 		delta = freeable >> priority;
 		delta *= 4;
@@ -491,40 +475,81 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		delta = freeable / 2;
 	}
 
-	total_scan += delta;
-	if (total_scan < 0) {
-		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
-		       shrinker->scan_objects, total_scan);
-		total_scan = freeable;
-		next_deferred = nr;
-	} else
-		next_deferred = total_scan;
+	*freeable_objects = freeable;
+	return delta > 0 ? delta : 0;
+}
 
-	/*
-	 * We need to avoid excessive windup on filesystem shrinkers
-	 * due to large numbers of GFP_NOFS allocations causing the
-	 * shrinkers to return -1 all the time. This results in a large
-	 * nr being built up so when a shrink that can do some work
-	 * comes along it empties the entire cache due to nr >>>
-	 * freeable. This is bad for sustaining a working set in
-	 * memory.
-	 *
-	 * Hence only allow the shrinker to scan the entire cache when
-	 * a large delta change is calculated directly.
-	 */
-	if (delta < freeable / 4)
-		total_scan = min(total_scan, freeable / 2);
+#define SHRINK_BATCH 128
+
+static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
+				    struct shrinker *shrinker, int priority)
+{
+	int nid = shrinkctl->nid;
+	int batch_size = shrinker->batch ? shrinker->batch
+					  : SHRINK_BATCH;
+	int64_t scan_count;
+	int64_t freeable_objects = 0;
+	int64_t scanned_objects = 0;
+	int64_t next_deferred = 0;
+	int64_t new_dcount;
+	int64_t freed = 0;
+	int64_t deferred_count = 0;
+
+	if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
+		nid = 0;
+
+	shrinkctl->will_defer = false;
+	scan_count = shrink_scan_count(shrinkctl, shrinker, priority,
+					&freeable_objects);
+	if (scan_count == 0 || scan_count == SHRINK_EMPTY)
+		return scan_count;
+
+/*
+ * If kswapd, we take all the deferred work and do it here. We don't let direct
+ * reclaim do this, because then it means some poor sod is going to have to do
+ * somebody else's GFP_NOFS reclaim, and it hides the real amount of reclaim
+ * work from concurrent kswapd operations. hence we do the work in the wrong
+ * place, at the wrong time, and it's largely unpredictable.
+ *
+ * By doing the deferred work only in kswapd, we can schedule the work according
+ * the the reclaim priority - low priority reclaim will do less deferred work,
+ * hence we'll do more of the deferred work the more desperate we become for
+ * free memory. This avoids the need for needing to specifically avoid deferred
+ * work windup as low amount os memory pressure won't excessive trim caches
+ * anymore.
+ */
+	if (current_is_kswapd()) {
+		int64_t	deferred_scan;
+
+		deferred_count = atomic64_xchg(&shrinker->nr_deferred[nid], 0);
+
+		/* we want to scan 5-10% of the deferred work here at minimum */
+		deferred_scan = deferred_count;
+		if (priority)
+			do_div(deferred_scan, priority);
+
+		scan_count += deferred_scan;
+	}
 
 	/*
-	 * Avoid risking looping forever due to too large nr value:
+	 * Avoid risking looping forever due to too much deferred work:
 	 * never try to free more than twice the estimate number of
 	 * freeable entries.
 	 */
-	if (total_scan > freeable * 2)
-		total_scan = freeable * 2;
+	if (scan_count > freeable_objects * 2)
+		scan_count = freeable_objects * 2;
+
 
-	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
-				   freeable, delta, total_scan, priority);
+	trace_mm_shrink_slab_start(shrinker, shrinkctl, deferred_count,
+				   freeable_objects, scan_count, priority);
+
+	/*
+	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
+	 * defer the work to kswapd. kswapd runs under GFP_KERNEL, so should
+	 * never have shrinker defer wok in that context.
+	 */
+	if (shrinkctl->will_defer)
+		goto done;
 
 	/*
 	 * Normally, we should not scan less than batch_size objects in one
@@ -541,10 +566,10 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	 * scanning at high prio and therefore should try to reclaim as much as
 	 * possible.
 	 */
-	while (total_scan >= batch_size ||
-	       total_scan >= freeable) {
-		unsigned long ret;
-		unsigned long nr_to_scan = min(batch_size, total_scan);
+	while (scan_count >= batch_size ||
+	       scan_count >= freeable_objects) {
+		int64_t ret;
+		int64_t nr_to_scan = min_t(int64_t, batch_size, scan_count);
 
 		shrinkctl->nr_to_scan = nr_to_scan;
 		shrinkctl->nr_scanned = nr_to_scan;
@@ -554,28 +579,31 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		freed += ret;
 
 		count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
-		total_scan -= shrinkctl->nr_scanned;
-		scanned += shrinkctl->nr_scanned;
+		scan_count -= shrinkctl->nr_scanned;
+		scanned_objects += shrinkctl->nr_scanned;
 
 		cond_resched();
 	}
 
-	if (next_deferred >= scanned)
-		next_deferred -= scanned;
-	else
-		next_deferred = 0;
+done:
+	if (deferred_count)
+		next_deferred = deferred_count - scanned_objects;
+	else if (scan_count > 0)
+		next_deferred = scan_count;
+
 	/*
 	 * move the unused scan count back into the shrinker in a
 	 * manner that handles concurrent updates. If we exhausted the
 	 * scan, there is no need to do an update.
 	 */
 	if (next_deferred > 0)
-		new_nr = atomic_long_add_return(next_deferred,
+		new_dcount = atomic64_add_return(next_deferred,
 						&shrinker->nr_deferred[nid]);
 	else
-		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
+		new_dcount = atomic64_read(&shrinker->nr_deferred[nid]);
 
-	trace_mm_shrink_slab_end(shrinker, nid, freed, nr, new_nr, total_scan);
+	trace_mm_shrink_slab_end(shrinker, nid, freed, scan_count, deferred_count,
+				new_dcount);
 	return freed;
 }
 

