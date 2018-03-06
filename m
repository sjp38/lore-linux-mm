Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4CB6B0005
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 14:20:46 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id w79-v6so4051632ybe.19
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 11:20:46 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id x8-v6si2636553ybm.130.2018.03.06.11.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 11:20:44 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH] mm: might_sleep warning
Date: Tue,  6 Mar 2018 14:20:22 -0500
Message-Id: <20180306192022.28289-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, pasha.tatashin@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Robot reported this issue:
https://lkml.org/lkml/2018/2/27/851

That is introduced by:
mm: initialize pages on demand during boot

The problem is caused by changing static branch value within spin lock.
Spin lock disables preemption, and changing static branch value takes
mutex lock in its path, and thus may sleep.

The fix is to add another boolean variable to avoid the need to change
static branch within spinlock.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b337a026007c..52edc6695b2b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1579,6 +1579,7 @@ static int __init deferred_init_memmap(void *data)
  * page_alloc_init_late() soon after smp_init() is complete.
  */
 static __initdata DEFINE_SPINLOCK(deferred_zone_grow_lock);
+static bool deferred_zone_grow __initdata = true;
 static DEFINE_STATIC_KEY_TRUE(deferred_pages);
 
 /*
@@ -1616,7 +1617,7 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
 	 * Bail if we raced with another thread that disabled on demand
 	 * initialization.
 	 */
-	if (!static_branch_unlikely(&deferred_pages)) {
+	if (!static_branch_unlikely(&deferred_pages) || !deferred_zone_grow) {
 		spin_unlock_irqrestore(&deferred_zone_grow_lock, flags);
 		return false;
 	}
@@ -1683,10 +1684,15 @@ void __init page_alloc_init_late(void)
 	/*
 	 * We are about to initialize the rest of deferred pages, permanently
 	 * disable on-demand struct page initialization.
+	 *
+	 * Note: it is prohibited to modify static branches in non-preemptible
+	 * context. Since, spin_lock() disables preemption, we must use an
+	 * extra boolean deferred_zone_grow.
 	 */
 	spin_lock(&deferred_zone_grow_lock);
-	static_branch_disable(&deferred_pages);
+	deferred_zone_grow = false;
 	spin_unlock(&deferred_zone_grow_lock);
+	static_branch_disable(&deferred_pages);
 
 	/* There will be num_node_state(N_MEMORY) threads */
 	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
