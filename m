Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28Dfb1m014130 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:37 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s5.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28Dfa0Y027975 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:36 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s5.gw.fujitsu.co.jp (s5 [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BD571B8057
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:36 +0900 (JST)
Received: from ml2.s.css.fujitsu.com (ml2.s.css.fujitsu.com [10.23.4.192])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D0F21B8058
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:36 +0900 (JST)
Date: Wed, 08 Mar 2006 22:41:35 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 004/017](RFC) Memory hotplug for new nodes v.3. (generic alloc pgdat)
Message-Id: <20060308212719.002A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

For node hotplug, basically we have to allocate new pgdat.
But, there are several types of implementations of pgdat.

1. Allocate only pgdat.
   This style allocate only pgdat area.
   And its address is recorded in node_data[].
   It is most popular style.

2. Static array of pgdat
   In this case, all of pgdats are static array.
   Some archs use this style.

3. Allocate not only pgdat, but also per node data.
   To increase performance, each node has copy of some data as
   a per node data. So, this area must be allocated too.

   Ia64 is this style. Ia64 has the copies of node_data[] array
   on each per node data to increase performance.

In this series of patches, treat (1) as generic arch.

generic archs can use generic function. (2) and (3) should have
its own if necessary. 

This patch defines pgdat allocator.
Updating NODE_DATA() macro function is in other patch.

( I'll post another patch for (3).
  I don't know (2) which can use memory hotplug.
  So, there is not patch for (2). )

Signed-off-by: Yasonori Goto     <y-goto@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: pgdat6/include/linux/memory_hotplug.h
===================================================================
--- pgdat6.orig/include/linux/memory_hotplug.h	2006-03-06 19:40:57.000000000 +0900
+++ pgdat6/include/linux/memory_hotplug.h	2006-03-06 19:42:21.000000000 +0900
@@ -72,6 +72,56 @@ static inline int arch_nid_probe(u64 sta
 }
 #endif
 
+#ifdef CONFIG_HAVE_ARCH_NODEDATA_EXTENSION
+/*
+ * For supporint node-hotadd, we have to allocate new pgdat.
+ *
+ * If an arch have generic style NODE_DATA(),
+ * node_data[nid] = kzalloc() works well . But it depends on each arch.
+ *
+ * In general, generic_alloc_nodedata() is used.
+ * generic...is a local function in mm/memory_hotplug.c
+ *
+ * Now, arch_free_nodedata() is just defined for error path of node_hot_add.
+ *
+ */
+extern struct pglist_data * arch_alloc_nodedata(int nid);
+extern void arch_free_nodedata(pg_data_t *pgdat);
+
+#else /* !CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
+#define arch_alloc_nodedata(nid)	generic_alloc_nodedata(nid)
+#define arch_free_nodedata(pgdat)	generic_free_nodedata(pgdat)
+
+#ifdef CONFIG_NUMA
+/*
+ * If ARCH_HAS_NODEDATA_EXTENSION=n, this func is used to allocate pgdat.
+ */
+static inline struct pglist_data *generic_alloc_nodedata(int nid)
+{
+	return kzalloc(sizeof(struct pglist_data), GFP_ATOMIC);
+}
+/*
+ * This definition is just for error path in node hotadd.
+ * For node hotremove, we have to replace this.
+ */
+static inline void generic_free_nodedata(struct pglist_data *pgdat)
+{
+	kfree(pgdat);
+}
+
+#else /* !CONFIG_NUMA */
+/* never called */
+static inline struct pglist_data *generic_alloc_nodedata(int nid)
+{
+	BUG();
+	return NULL;
+}
+static inline void generic_free_nodedata(struct pglist_data *pgdat)
+{
+}
+#endif /* CONFIG_NUMA */
+#endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
