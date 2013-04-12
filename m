Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D84E56B0044
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:41 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 21:14:40 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 3898AC90025
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:37 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EbtM250174
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EauP030297
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:36 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 17/25] x86: memlayout: add a arch specific inital memlayout setter.
Date: Thu, 11 Apr 2013 18:13:49 -0700
Message-Id: <1365729237-29711-18-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

On x86, we have numa_info specifically to track the numa layout, which
is precisely the data memlayout needs, so use it to create an initial
memlayout.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 arch/x86/mm/numa.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index a71c4e2..75819ef 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -11,6 +11,7 @@
 #include <linux/nodemask.h>
 #include <linux/sched.h>
 #include <linux/topology.h>
+#include <linux/dnuma.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -32,6 +33,33 @@ __initdata
 #endif
 ;
 
+#ifdef CONFIG_DYNAMIC_NUMA
+void __init memlayout_global_init(void)
+{
+	struct numa_meminfo *mi = &numa_meminfo;
+	int i;
+	struct numa_memblk *blk;
+	struct memlayout *ml = memlayout_create(ML_INITIAL);
+	if (WARN_ON(!ml))
+		return;
+
+	pr_devel("x86/memlayout: adding ranges from numa_meminfo\n");
+	for (i = 0; i < mi->nr_blks; i++) {
+		blk = mi->blk + i;
+		pr_devel("  adding range {%LX[%LX]-%LX[%LX]}:%d\n",
+			 PFN_DOWN(blk->start), blk->start,
+			 PFN_DOWN(blk->end - PAGE_SIZE / 2 - 1),
+			 blk->end - 1, blk->nid);
+		memlayout_new_range(ml, PFN_DOWN(blk->start),
+				PFN_DOWN(blk->end - PAGE_SIZE / 2 - 1),
+				blk->nid);
+	}
+	pr_devel("  done adding ranges from numa_meminfo\n");
+
+	memlayout_commit(ml);
+}
+#endif
+
 static int numa_distance_cnt;
 static u8 *numa_distance;
 
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
