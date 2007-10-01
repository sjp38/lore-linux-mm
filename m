Date: Mon, 01 Oct 2007 18:33:03 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch / 001](memory hotplug) fix some defects of memory notifer callback interface.
In-Reply-To: <20071001182329.7A97.Y-GOTO@jp.fujitsu.com>
References: <20071001182329.7A97.Y-GOTO@jp.fujitsu.com>
Message-Id: <20071001183110.7A99.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Current memory notifier has some defects yet. (Nothing uses it.)
This patch is to fix for them.

  - Add information of start_pfn and nr_pages for callback functions.
    They can't do anything without those information.
  - Add notification going-online status.
    It is necessary for creating per node structure before the node's
    pages are available.
  - Fix compile error of (un)register_memory_notifier().


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 drivers/base/memory.c  |   10 +++++++---
 include/linux/memory.h |   16 ++++++++++++----
 2 files changed, 19 insertions(+), 7 deletions(-)

Index: current/drivers/base/memory.c
===================================================================
--- current.orig/drivers/base/memory.c	2007-09-28 11:21:00.000000000 +0900
+++ current/drivers/base/memory.c	2007-09-28 11:23:46.000000000 +0900
@@ -155,10 +155,13 @@ memory_block_action(struct memory_block 
 	struct page *first_page;
 	int ret;
 	int old_state = mem->state;
+	struct memory_notify arg;
 
 	psection = mem->phys_index;
 	first_page = pfn_to_page(psection << PFN_SECTION_SHIFT);
 
+	arg.start_pfn = page_to_pfn(first_page);
+	arg.nr_pages = PAGES_PER_SECTION;
 	/*
 	 * The probe routines leave the pages reserved, just
 	 * as the bootmem code does.  Make sure they're still
@@ -178,12 +181,13 @@ memory_block_action(struct memory_block 
 
 	switch (action) {
 		case MEM_ONLINE:
+			memory_notify(MEM_GOING_ONLINE, &arg);
 			start_pfn = page_to_pfn(first_page);
 			ret = online_pages(start_pfn, PAGES_PER_SECTION);
 			break;
 		case MEM_OFFLINE:
 			mem->state = MEM_GOING_OFFLINE;
-			memory_notify(MEM_GOING_OFFLINE, NULL);
+			memory_notify(MEM_GOING_OFFLINE, &arg);
 			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
 			ret = remove_memory(start_paddr,
 					    PAGES_PER_SECTION << PAGE_SHIFT);
@@ -191,7 +195,7 @@ memory_block_action(struct memory_block 
 				mem->state = old_state;
 				break;
 			}
-			memory_notify(MEM_MAPPING_INVALID, NULL);
+			memory_notify(MEM_MAPPING_INVALID, &arg);
 			break;
 		default:
 			printk(KERN_WARNING "%s(%p, %ld) unknown action: %ld\n",
@@ -203,7 +207,7 @@ memory_block_action(struct memory_block 
 	 * For now, only notify on successful memory operations
 	 */
 	if (!ret)
-		memory_notify(action, NULL);
+		memory_notify(action, &arg);
 
 	return ret;
 }
Index: current/include/linux/memory.h
===================================================================
--- current.orig/include/linux/memory.h	2007-09-28 11:18:25.000000000 +0900
+++ current/include/linux/memory.h	2007-09-28 11:23:46.000000000 +0900
@@ -37,10 +37,16 @@ struct memory_block {
 	struct sys_device sysdev;
 };
 
+struct memory_notify {
+	unsigned long start_pfn;
+	unsigned long nr_pages;
+};
+
 /* These states are exposed to userspace as text strings in sysfs */
-#define	MEM_ONLINE		(1<<0) /* exposed to userspace */
-#define	MEM_GOING_OFFLINE	(1<<1) /* exposed to userspace */
-#define	MEM_OFFLINE		(1<<2) /* exposed to userspace */
+#define MEM_GOING_ONLINE	(1<<0) /* exposed to userspace */
+#define	MEM_ONLINE		(1<<1) /* exposed to userspace */
+#define	MEM_GOING_OFFLINE	(1<<2) /* exposed to userspace */
+#define	MEM_OFFLINE		(1<<3) /* exposed to userspace */
 
 /*
  * All of these states are currently kernel-internal for notifying
@@ -52,7 +58,7 @@ struct memory_block {
  * pfn_to_page() stop working.  Any notifiers that want to be called
  * after that should have priority <0.
  */
-#define	MEM_MAPPING_INVALID	(1<<3)
+#define	MEM_MAPPING_INVALID	(1<<4)
 
 struct notifier_block;
 struct mem_section;
@@ -70,6 +76,8 @@ static inline void unregister_memory_not
 {
 }
 #else
+extern int register_memory_notifier(struct notifier_block *nb);
+extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_new_memory(struct mem_section *);
 extern int unregister_memory_section(struct mem_section *);
 extern int memory_dev_init(void);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
