From: Andi Kleen <andi@firstfloor.org>
References: <20080318209.039112899@firstfloor.org>
In-Reply-To: <20080318209.039112899@firstfloor.org>
Subject: [PATCH prototype] [3/8] Make readahead max pinned value a sysctl
Message-Id: <20080318010937.4D96C1B41E1@basil.firstfloor.org>
Date: Tue, 18 Mar 2008 02:09:37 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Previously it was hard coded to 2MB, which seems dubious as systems
are getting more and more memory. With a sysctl it is easier to play 
around with it and tune it.

Signed-off-by: Andi Kleen <andi@firstfloor.org>

---
 include/linux/mm.h |    2 ++
 kernel/sysctl.c    |   10 ++++++++++
 mm/readahead.c     |   14 ++++++++++++--
 3 files changed, 24 insertions(+), 2 deletions(-)

Index: linux/mm/readahead.c
===================================================================
--- linux.orig/mm/readahead.c
+++ linux/mm/readahead.c
@@ -17,6 +17,14 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
+/*
+ * Max memory pinned during forced readahead.
+ * Should be probably auto scaled with available memory.
+ */
+unsigned ra_max_pinned = 2*1024*1024;
+
+#define MAX_PINNED_CHUNK ra_max_pinned
+
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page)
 {
 }
@@ -176,7 +184,7 @@ out:
 }
 
 /*
- * Chunk the readahead into 2 megabyte units, so that we don't pin too much
+ * Chunk the readahead into MAX_PINNED_CHUNK units, so that we don't pin too much
  * memory at once.
  */
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
@@ -190,7 +198,7 @@ int force_page_cache_readahead(struct ad
 	while (nr_to_read) {
 		int err;
 
-		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_CACHE_SIZE;
+		unsigned long this_chunk = MAX_PINNED_CHUNK / PAGE_CACHE_SIZE;
 
 		if (this_chunk > nr_to_read)
 			this_chunk = nr_to_read;
@@ -229,6 +237,8 @@ int do_page_cache_readahead(struct addre
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
+	/* AK: RED-PEN for file cached pages there is no reason
+	   to limit ourselves to the current node */
 	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE)
 		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h
+++ linux/include/linux/mm.h
@@ -1113,6 +1113,8 @@ void page_cache_async_readahead(struct a
 
 unsigned long max_sane_readahead(unsigned long nr);
 
+extern unsigned ra_max_pinned;
+
 /* Do stack extension */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
 #ifdef CONFIG_IA64
Index: linux/kernel/sysctl.c
===================================================================
--- linux.orig/kernel/sysctl.c
+++ linux/kernel/sysctl.c
@@ -877,6 +877,16 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "ra_max_pinned",
+		.data		= &ra_max_pinned,
+		.maxlen 	= sizeof(ra_max_pinned),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec,
+		.extra1 	= &zero,
+	},
+	{
 		.ctl_name	= VM_DIRTY_BACKGROUND,
 		.procname	= "dirty_background_ratio",
 		.data		= &dirty_background_ratio,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
