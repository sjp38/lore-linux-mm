Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id B893A6B0069
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 21:03:00 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2] mm: Warn about costly page allocation
Date: Tue, 10 Jul 2012 10:02:59 +0900
Message-Id: <1341882179-16648-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>

Since lumpy reclaim was introduced at 2.6.23, it helped higher
order allocation.
Recently, we removed it at 3.4 and we didn't enable compaction
forcingly[1]. The reason makes sense that compaction.o + migration.o
isn't trivial for system doesn't use higher order allocation.
But the problem is that we have to enable compaction explicitly
while lumpy reclaim enabled unconditionally.

Normally, admin doesn't know his system have used higher order
allocation and even lumpy reclaim have helped it.
Admin in embdded system have a tendency to minimise code size so that
they can disable compaction. In this case, we can see page allocation
failure we can never see in the past. It's critical on embedded side
because...

Let's think this scenario.

There is QA team in embedded company and they have tested their product.
In test scenario, they can allocate 100 high order allocation.
(they don't matter how many high order allocations in kernel are needed
during test. their concern is just only working well or fail of their
middleware/application) High order allocation will be serviced well
by natural buddy allocation without lumpy's help. So they released
the product and sold out all over the world.
Unfortunately, in real practice, sometime, 105 high order allocation was
needed rarely and fortunately, lumpy reclaim could help it so the product
doesn't have a problem until now.

If they use latest kernel, they will see the new config CONFIG_COMPACTION
which is very poor documentation, and they can't know it's replacement of
lumpy reclaim(even, they don't know lumpy reclaim) so they simply disable
that option for size optimization. Of course, QA team still test it but they
can't find the problem if they don't do test stronger than old.
It ends up release the product and sold out all over the world, again.
But in this time, we don't have both lumpy and compaction so the problem
would happen in real practice. A poor enginner from Korea have to flight
to the USA for the fix a ton of products. Otherwise, should recall products
from all over the world. Maybe he can lose a job. :(

This patch adds warning for notice. If the system try to allocate
PAGE_ALLOC_COSTLY_ORDER above page and system enters reclaim path,
it emits the warning. At least, it gives a chance to look into their
system before the relase.

Please keep in mind. It's not a good idea to depend lumpy/compaction
for regular high-order allocations. Both depends on being able to move
MIGRATE_MOVABLE allocations to satisfy the high-order allocation. If used
reregularly for high-order kernel allocations and tehy are long-lived,
the system will eventually be unable to grant these allocations, with or
without compaction or lumpy reclaim. Hatchet jobs that work around this problem
include forcing MIGRATE_RESERVE to be only used for high-order allocations
and tuning its size. It's a major hack though and is unlikely to be merged
to mainline but might suit an embedded product.

This patch avoids false positive by alloc_large_system_hash which
allocates with GFP_ATOMIC and a fallback mechanism so it can make
this warning useless.

[1] c53919ad(mm: vmscan: remove lumpy reclaim)

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
Changelog

* from v1
 - add more description about warning failure of high-order allocation
 - use printk_ratelimited/pr_warn and dump stack - [Mel, Andrew]
 - noinline/__always_inline optimization - Andrew
 - modify warning message - Andrew

 mm/page_alloc.c |   37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a4d3a19..a8f60d0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2276,6 +2276,41 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	return alloc_flags;
 }
 
+#if defined(CONFIG_DEBUG_VM) && !defined(CONFIG_COMPACTION)
+
+static DEFINE_RATELIMIT_STATE(highorderalloc_rs,
+		DEFAULT_RATELIMIT_INTERVAL,
+		DEFAULT_RATELIMIT_BURST);
+
+static noinline void __check_page_alloc_costly_order(unsigned int order,
+							gfp_t flags)
+{
+	if ((flags & __GFP_NOWARN) || !__ratelimit(&highorderalloc_rs))
+		return;
+
+	pr_warn("%s: try allocating high-order allocation: "
+		"order:%d, mode:0x%x\n", current->comm, order, flags);
+	pr_warn("Enable CONFIG_COMPACTION if high-order allocations are "
+		"very few and rare.\n");
+	pr_warn("If you see this message frequently and regularly, "
+		"CONFIG_COMPACTION wouldn't help it. Then, please send "
+		"an email to linux-mm@kvack.org\n");
+	dump_stack();
+}
+
+static __always_inline void check_page_alloc_costly_order(unsigned int order,
+							gfp_t flags)
+{
+	if (unlikely(order > PAGE_ALLOC_COSTLY_ORDER))
+		__check_page_alloc_costly_order(order, flags);
+}
+#else
+static inline void check_page_alloc_costly_order(unsigned int order,
+							gfp_t flags)
+{
+}
+#endif
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -2353,6 +2388,8 @@ rebalance:
 	if (!wait)
 		goto nopage;
 
+	check_page_alloc_costly_order(order, gfp_mask);
+
 	/* Avoid recursion of direct reclaim */
 	if (current->flags & PF_MEMALLOC)
 		goto nopage;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
