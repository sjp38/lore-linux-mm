Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 3B4C96B028B
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:42 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 20:01:41 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id F29606E8048
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:34 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301b9b63569984
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:37 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301a9o026484
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:37 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 23/31] x86: memlayout: add a arch specific inital memlayout setter.
Date: Thu,  2 May 2013 17:00:55 -0700
Message-Id: <1367539263-19999-24-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

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
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
