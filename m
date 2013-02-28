Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id DD0166B0010
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:33 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 16:27:32 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 78B6FC9001A
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:30 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLRTmm305454
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:30 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLTm9I019135
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:29:48 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 20/24] x86: memlayout: add a arch specific inital memlayout setter.
Date: Thu, 28 Feb 2013 13:26:17 -0800
Message-Id: <1362086781-16725-11-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

On x86, we have numa_info specifically to track the numa layout, which
is precisely the data memlayout needs, so use it to create an initial
memlayout.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 arch/x86/mm/numa.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index ff3633c..a2a8dd5 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -11,6 +11,7 @@
 #include <linux/nodemask.h>
 #include <linux/sched.h>
 #include <linux/topology.h>
+#include <linux/dnuma.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
@@ -32,6 +33,29 @@ __initdata
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
+			 PFN_DOWN(blk->start), blk->start, PFN_DOWN(blk->end - PAGE_SIZE / 2 - 1), blk->end - 1, blk->nid);
+		memlayout_new_range(ml, PFN_DOWN(blk->start), PFN_DOWN(blk->end - PAGE_SIZE / 2 - 1), blk->nid);
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
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
