Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88FB16B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 17:40:32 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n141so215380qke.20
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 14:40:32 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id q16si1160716qtb.351.2018.03.06.14.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 14:40:31 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2] mm: might_sleep warning
Date: Tue,  6 Mar 2018 17:40:04 -0500
Message-Id: <20180306224004.25150-1-pasha.tatashin@oracle.com>
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

Also, as noticed by Andrew, change spin_lock to spin_lock_irq, in order
to disable interrupts and avoid possible deadlock with
deferred_grow_zone().

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b337a026007c..5df1ca40a2ff 100644
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
-	spin_lock(&deferred_zone_grow_lock);
+	spin_lock_irq(&deferred_zone_grow_lock);
+	deferred_zone_grow = false;
+	spin_unlock_irq(&deferred_zone_grow_lock);
 	static_branch_disable(&deferred_pages);
-	spin_unlock(&deferred_zone_grow_lock);
 
 	/* There will be num_node_state(N_MEMORY) threads */
 	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
