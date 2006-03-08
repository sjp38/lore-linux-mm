Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
        by fgwmail7.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28DgeDu011412 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:42:40 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m1.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28DgdtL025928 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:42:39 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp (s6 [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A501B29C297
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:42:39 +0900 (JST)
Received: from ml6.s.css.fujitsu.com (ml6.s.css.fujitsu.com [10.23.4.196])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BD9BF29C34D
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:42:38 +0900 (JST)
Date: Wed, 08 Mar 2006 22:42:38 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 011/017](RFC) Memory hotplug for new nodes v.3. (start kswapd)
Message-Id: <20060308213333.0038.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

When node is hot-added, kswapd for the node should start.
This export kswapd start function as kswapd_run().


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: pgdat6/mm/vmscan.c
===================================================================
--- pgdat6.orig/mm/vmscan.c	2006-03-06 18:25:37.000000000 +0900
+++ pgdat6/mm/vmscan.c	2006-03-06 18:26:25.000000000 +0900
@@ -35,6 +35,7 @@
 #include <linux/notifier.h>
 #include <linux/rwsem.h>
 #include <linux/delay.h>
+#include <linux/kthread.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1842,17 +1843,36 @@ static int __devinit cpu_callback(struct
 }
 #endif /* CONFIG_HOTPLUG_CPU */
 
+/*
+ * This kswapd start function will be called by init anod node-hot-add.
+ * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
+ */
+int kswapd_run(int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+	int ret = 0;
+
+	if (pgdat->kswapd)
+		return 0;
+
+	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
+	if (pgdat->kswapd == ERR_PTR(-ENOMEM)) {
+		/* failure at boot is fatal */
+		BUG_ON(system_state == SYSTEM_BOOTING);
+		printk("faled to run kswapd on node %d\n",nid);
+		ret = -1;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(kswapd_run);
+
 static int __init kswapd_init(void)
 {
-	pg_data_t *pgdat;
+	int nid;
 
 	swap_setup();
-	for_each_online_pgdat(pgdat) {
-		pid_t pid;
-
-		pid = kernel_thread(kswapd, pgdat, CLONE_KERNEL);
-		BUG_ON(pid < 0);
-		pgdat->kswapd = find_task_by_pid(pid);
+	for_each_online_node(nid) {
+		kswapd_run(nid);
 	}
 	total_memory = nr_free_pagecache_pages();
 	hotcpu_notifier(cpu_callback, 0);
Index: pgdat6/include/linux/swap.h
===================================================================
--- pgdat6.orig/include/linux/swap.h	2006-03-06 18:25:37.000000000 +0900
+++ pgdat6/include/linux/swap.h	2006-03-06 18:26:25.000000000 +0900
@@ -208,6 +208,11 @@ static inline int migrate_pages(struct l
 #define fail_migrate_page NULL
 #endif
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+/* start new kswapd for new node */
+extern int kswapd_run(int nid);
+#endif
+
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
