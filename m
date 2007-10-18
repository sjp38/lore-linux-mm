Date: Thu, 18 Oct 2007 12:23:34 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 002/002](memory hotplug) rearrange patch for notifier of memory hotplug
In-Reply-To: <20071018120343.5146.Y-GOTO@jp.fujitsu.com>
References: <20071018120343.5146.Y-GOTO@jp.fujitsu.com>
Message-Id: <20071018122210.514D.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Current memory notifier has some defects yet. (Fortunately, nothing uses it.)
This patch is to fix and rearrange for them.

  - Add information of start_pfn, nr_pages, and node id if node status is
    changes from/to memoryless node for callback functions.
    Callbacks can't do anything without those information.
  - Add notification going-online status.
    It is necessary for creating per node structure before the node's
    pages are available.
  - Move GOING_OFFLINE status notification after page isolation.
    It is good place for return memory like cache for callback,
    because returned page is not used again.
  - Make CANCEL events for rollingback when error occurs.
  - Delete MEM_MAPPING_INVALID notification. It will be not used.
  - Fix compile error of (un)register_memory_notifier().


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


---
 drivers/base/memory.c  |    9 +--------
 include/linux/memory.h |   27 +++++++++++++++------------
 mm/memory_hotplug.c    |   48 +++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 61 insertions(+), 23 deletions(-)

Index: current/drivers/base/memory.c
===================================================================
--- current.orig/drivers/base/memory.c	2007-10-17 21:17:54.000000000 +0900
+++ current/drivers/base/memory.c	2007-10-17 21:21:30.000000000 +0900
@@ -137,7 +137,7 @@ static ssize_t show_mem_state(struct sys
 	return len;
 }
 
-static inline int memory_notify(unsigned long val, void *v)
+int memory_notify(unsigned long val, void *v)
 {
 	return blocking_notifier_call_chain(&memory_chain, val, v);
 }
@@ -183,7 +183,6 @@ memory_block_action(struct memory_block 
 			break;
 		case MEM_OFFLINE:
 			mem->state = MEM_GOING_OFFLINE;
-			memory_notify(MEM_GOING_OFFLINE, NULL);
 			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
 			ret = remove_memory(start_paddr,
 					    PAGES_PER_SECTION << PAGE_SHIFT);
@@ -191,7 +190,6 @@ memory_block_action(struct memory_block 
 				mem->state = old_state;
 				break;
 			}
-			memory_notify(MEM_MAPPING_INVALID, NULL);
 			break;
 		default:
 			printk(KERN_WARNING "%s(%p, %ld) unknown action: %ld\n",
@@ -199,11 +197,6 @@ memory_block_action(struct memory_block 
 			WARN_ON(1);
 			ret = -EINVAL;
 	}
-	/*
-	 * For now, only notify on successful memory operations
-	 */
-	if (!ret)
-		memory_notify(action, NULL);
 
 	return ret;
 }
Index: current/include/linux/memory.h
===================================================================
--- current.orig/include/linux/memory.h	2007-10-17 21:17:54.000000000 +0900
+++ current/include/linux/memory.h	2007-10-17 21:21:30.000000000 +0900
@@ -41,18 +41,15 @@ struct memory_block {
 #define	MEM_ONLINE		(1<<0) /* exposed to userspace */
 #define	MEM_GOING_OFFLINE	(1<<1) /* exposed to userspace */
 #define	MEM_OFFLINE		(1<<2) /* exposed to userspace */
+#define	MEM_GOING_ONLINE	(1<<3)
+#define	MEM_CANCEL_ONLINE	(1<<4)
+#define	MEM_CANCEL_OFFLINE	(1<<5)
 
-/*
- * All of these states are currently kernel-internal for notifying
- * kernel components and architectures.
- *
- * For MEM_MAPPING_INVALID, all notifier chains with priority >0
- * are called before pfn_to_page() becomes invalid.  The priority=0
- * entry is reserved for the function that actually makes
- * pfn_to_page() stop working.  Any notifiers that want to be called
- * after that should have priority <0.
- */
-#define	MEM_MAPPING_INVALID	(1<<3)
+struct memory_notify {
+	unsigned long start_pfn;
+	unsigned long nr_pages;
+	int status_change_nid;
+};
 
 struct notifier_block;
 struct mem_section;
@@ -69,12 +66,18 @@ static inline int register_memory_notifi
 static inline void unregister_memory_notifier(struct notifier_block *nb)
 {
 }
+static inline int memory_notify(unsigned long val, void *v)
+{
+	return 0;
+}
 #else
+extern int register_memory_notifier(struct notifier_block *nb);
+extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_new_memory(struct mem_section *);
 extern int unregister_memory_section(struct mem_section *);
 extern int memory_dev_init(void);
 extern int remove_memory_block(unsigned long, struct mem_section *, int);
-
+extern int memory_notify(unsigned long val, void *v);
 #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
 
 
Index: current/mm/memory_hotplug.c
===================================================================
--- current.orig/mm/memory_hotplug.c	2007-10-17 21:17:54.000000000 +0900
+++ current/mm/memory_hotplug.c	2007-10-17 21:21:30.000000000 +0900
@@ -187,7 +187,24 @@ int online_pages(unsigned long pfn, unsi
 	unsigned long onlined_pages = 0;
 	struct zone *zone;
 	int need_zonelists_rebuild = 0;
+	int nid;
+	int ret;
+	struct memory_notify arg;
+
+	arg.start_pfn = pfn;
+	arg.nr_pages = nr_pages;
+	arg.status_change_nid = -1;
+
+	nid = page_to_nid(pfn_to_page(pfn));
+	if (node_present_pages(nid) == 0)
+		arg.status_change_nid = nid;
 
+	ret = memory_notify(MEM_GOING_ONLINE, &arg);
+	ret = notifier_to_errno(ret);
+	if (ret) {
+		memory_notify(MEM_CANCEL_ONLINE, &arg);
+		return ret;
+	}
 	/*
 	 * This doesn't need a lock to do pfn_to_page().
 	 * The section can't be removed here because of the
@@ -222,6 +239,10 @@ int online_pages(unsigned long pfn, unsi
 		build_all_zonelists();
 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
+
+	if (onlined_pages)
+		memory_notify(MEM_ONLINE, &arg);
+
 	return 0;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
@@ -467,8 +488,9 @@ int offline_pages(unsigned long start_pf
 {
 	unsigned long pfn, nr_pages, expire;
 	long offlined_pages;
-	int ret, drain, retry_max;
+	int ret, drain, retry_max, node;
 	struct zone *zone;
+	struct memory_notify arg;
 
 	BUG_ON(start_pfn >= end_pfn);
 	/* at least, alignment against pageblock is necessary */
@@ -480,11 +502,27 @@ int offline_pages(unsigned long start_pf
 	   we assume this for now. .*/
 	if (!test_pages_in_a_zone(start_pfn, end_pfn))
 		return -EINVAL;
+
+	zone = page_zone(pfn_to_page(start_pfn));
+	node = zone_to_nid(zone);
+	nr_pages = end_pfn - start_pfn;
+
 	/* set above range as isolated */
 	ret = start_isolate_page_range(start_pfn, end_pfn);
 	if (ret)
 		return ret;
-	nr_pages = end_pfn - start_pfn;
+
+	arg.start_pfn = start_pfn;
+	arg.nr_pages = nr_pages;
+	arg.status_change_nid = -1;
+	if (nr_pages >= node_present_pages(node))
+		arg.status_change_nid = node;
+
+	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
+	ret = notifier_to_errno(ret);
+	if (ret)
+		goto failed_removal;
+
 	pfn = start_pfn;
 	expire = jiffies + timeout;
 	drain = 0;
@@ -539,20 +577,24 @@ repeat:
 	/* reset pagetype flags */
 	start_isolate_page_range(start_pfn, end_pfn);
 	/* removal success */
-	zone = page_zone(pfn_to_page(start_pfn));
 	zone->present_pages -= offlined_pages;
 	zone->zone_pgdat->node_present_pages -= offlined_pages;
 	totalram_pages -= offlined_pages;
 	num_physpages -= offlined_pages;
+
 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
+
+	memory_notify(MEM_OFFLINE, &arg);
 	return 0;
 
 failed_removal:
 	printk(KERN_INFO "memory offlining %lx to %lx failed\n",
 		start_pfn, end_pfn);
+	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
 	undo_isolate_page_range(start_pfn, end_pfn);
+
 	return ret;
 }
 #else

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
