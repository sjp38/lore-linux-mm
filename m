Date: Thu, 31 Jul 2008 20:56:49 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC:Patch: 002/008](memory hotplug) pgdat_remove_read_lock/unlock
In-Reply-To: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
References: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
Message-Id: <20080731205554.2A45.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is definition for pgdat_remove_read_lock() & read_lock_sleepable().


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


---
 include/linux/memory_hotplug.h |   25 +++++++++++++++++++++++++
 mm/memory_hotplug.c            |   12 ++++++++++++
 2 files changed, 37 insertions(+)

Index: current/include/linux/memory_hotplug.h
===================================================================
--- current.orig/include/linux/memory_hotplug.h	2008-07-29 21:19:13.000000000 +0900
+++ current/include/linux/memory_hotplug.h	2008-07-29 21:19:17.000000000 +0900
@@ -20,6 +20,31 @@ struct mem_section;
 #define MIX_SECTION_INFO	(-1 - 2)
 #define NODE_INFO		(-1 - 3)
 
+#if (defined CONFIG_NUMA && CONFIG_MEMORY_HOTREMOVE)
+/*
+ * pgdat removing lock
+ */
+extern struct srcu_struct pgdat_remove_srcu;
+#define pgdat_remove_read_lock() rcu_read_lock()
+#define pgdat_remove_read_unlock() rcu_read_unlock()
+#define pgdat_remove_read_lock_sleepable() srcu_read_lock(&pgdat_remove_srcu)
+#define pgdat_remove_read_unlock_sleepable(idx) \
+	srcu_read_unlock(&pgdat_remove_srcu, idx)
+#else
+static inline void pgdat_remove_read_lock(void)
+{
+}
+static inline void pgdat_remove_read_unlock(void)
+{
+}
+static inline int pgdat_remove_read_lock_sleepable(void)
+{
+}
+static inline void pgdat_remove_read_unlock_sleepable(int idx)
+{
+}
+#endif
+
 /*
  * pgdat resizing functions
  */
Index: current/mm/memory_hotplug.c
===================================================================
--- current.orig/mm/memory_hotplug.c	2008-07-29 21:19:13.000000000 +0900
+++ current/mm/memory_hotplug.c	2008-07-29 22:17:38.000000000 +0900
@@ -31,6 +31,10 @@
 
 #include "internal.h"
 
+#if (defined CONFIG_NUMA && CONFIG_MEMORY_HOTREMOVE)
+struct srcu_struct pgdat_remove_srcu;
+#endif
+
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
@@ -850,6 +854,14 @@ failed_removal:
 
 	return ret;
 }
+
+static int __init init_pgdat_remove_lock_sleepable(void)
+{
+	init_srcu_struct(&pgdat_remove_srcu);
+	return 0;
+}
+
+subsys_initcall(init_pgdat_remove_lock_sleepable);
 #else
 int remove_memory(u64 start, u64 size)
 {

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
