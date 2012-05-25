Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 919AB6B00F8
	for <linux-mm@kvack.org>; Fri, 25 May 2012 13:03:19 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 15/35] autonuma: init knuma_migrated queues
Date: Fri, 25 May 2012 19:02:19 +0200
Message-Id: <1337965359-29725-16-git-send-email-aarcange@redhat.com>
In-Reply-To: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

Initialize the knuma_migrated queues at boot time.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/page_alloc.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3d69735..3d1ee70 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -58,6 +58,7 @@
 #include <linux/memcontrol.h>
 #include <linux/prefetch.h>
 #include <linux/page-debug-flags.h>
+#include <linux/autonuma.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -4295,8 +4296,18 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	int nid = pgdat->node_id;
 	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 	int ret;
+#ifdef CONFIG_AUTONUMA
+	int node_iter;
+#endif
 
 	pgdat_resize_init(pgdat);
+#ifdef CONFIG_AUTONUMA
+	spin_lock_init(&pgdat->autonuma_lock);
+	init_waitqueue_head(&pgdat->autonuma_knuma_migrated_wait);
+	pgdat->autonuma_nr_migrate_pages = 0;
+	for_each_node(node_iter)
+		INIT_LIST_HEAD(&pgdat->autonuma_migrate_head[node_iter]);
+#endif
 	pgdat->nr_zones = 0;
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	pgdat->kswapd_max_order = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
