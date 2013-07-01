Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id D31F56B003B
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:07 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 06/13] mm: PRAM: introduce super block
Date: Mon, 1 Jul 2013 15:57:41 +0400
Message-ID: <d6e8e7216c33ec56c66493bf7377254c43698eb4.1372582756.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

The PRAM super block is the starting point for restoring persistent
memory. If the kernel locates the super block at boot time, it will
preserve the persistent memory structure from the previous kernel. To
point the kernel to the location of the super block, one should pass its
pfn via the 'pram' boot param. For that purpose, the pram super block
pfn is exported via /sys/kernel/pram. If none is passed, persistent
memory will not be preserved, and a new super block will be allocated.

The current patch introduces only super block handling. Memory
preservation will be implemented later.
---
 mm/pram.c |   94 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 92 insertions(+), 2 deletions(-)

diff --git a/mm/pram.c b/mm/pram.c
index c7706dc..58ae9ed 100644
--- a/mm/pram.c
+++ b/mm/pram.c
@@ -3,15 +3,18 @@
 #include <linux/highmem.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/kobject.h>
 #include <linux/list.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/notifier.h>
+#include <linux/pfn.h>
 #include <linux/pram.h>
 #include <linux/reboot.h>
 #include <linux/sched.h>
 #include <linux/string.h>
+#include <linux/sysfs.h>
 #include <linux/types.h>
 
 /*
@@ -66,12 +69,39 @@ struct pram_node {
 #define PRAM_ACCMODE_MASK	3
 
 /*
+ * The PRAM super block contains data needed to restore the persistent memory
+ * structure on boot. The pointer to it (pfn) should be passed via the 'pram'
+ * boot param if one wants to restore persistent data saved by the previously
+ * executing kernel. For that purpose the kernel exports the pfn via
+ * /sys/kernel/pram. If none is passed, persistent memory if any will not be
+ * preserved and a new clean page will be allocated for the super block.
+ *
+ * The structure occupies a memory page.
+ */
+struct pram_super_block {
+	__u64	node_pfn;		/* points to the first element of
+					 * the node list */
+};
+
+static unsigned long __initdata pram_sb_pfn;
+static struct pram_super_block *pram_sb;
+
+/*
  * For convenience sake PRAM nodes are kept in an auxiliary doubly-linked list
  * connected through the lru field of the page struct.
  */
 static LIST_HEAD(pram_nodes);			/* linked through page::lru */
 static DEFINE_MUTEX(pram_mutex);		/* serializes open/close */
 
+/*
+ * The PRAM super block pfn, see above.
+ */
+static int __init parse_pram_sb_pfn(char *arg)
+{
+	return kstrtoul(arg, 16, &pram_sb_pfn);
+}
+early_param("pram", parse_pram_sb_pfn);
+
 static inline struct page *pram_alloc_page(gfp_t gfp_mask)
 {
 	return alloc_page(gfp_mask);
@@ -161,6 +191,7 @@ static void pram_stream_init(struct pram_stream *ps,
  * Returns 0 on success, -errno on failure.
  *
  * Error values:
+ *    %ENODEV: PRAM not available
  *    %ENAMETOOLONG: name len >= PRAM_NAME_MAX
  *    %ENOMEM: insufficient memory available
  *    %EEXIST: node with specified name already exists
@@ -175,6 +206,9 @@ int pram_prepare_save(struct pram_stream *ps,
 	struct pram_node *node;
 	int err = 0;
 
+	if (!pram_sb)
+		return -ENODEV;
+
 	BUG_ON(type != PRAM_PAGE_STREAM &&
 	       type != PRAM_BYTE_STREAM);
 
@@ -250,6 +284,7 @@ void pram_discard_save(struct pram_stream *ps)
  * Returns 0 on success, -errno on failure.
  *
  * Error values:
+ *    %ENODEV: PRAM not available
  *    %ENOENT: node with specified name does not exist
  *    %EBUSY: save to required node has not finished yet
  *    %EPERM: specified type conflicts with type of required node
@@ -262,6 +297,9 @@ int pram_prepare_load(struct pram_stream *ps,
 	struct pram_node *node;
 	int err = 0;
 
+	if (!pram_sb)
+		return -ENODEV;
+
 	mutex_lock(&pram_mutex);
 	node = pram_find_node(name);
 	if (!node) {
@@ -550,6 +588,7 @@ static void __pram_reboot(void)
 		node->node_pfn = node_pfn;
 		node_pfn = page_to_pfn(page);
 	}
+	pram_sb->node_pfn = node_pfn;
 }
 
 static int pram_reboot(struct notifier_block *notifier,
@@ -557,7 +596,8 @@ static int pram_reboot(struct notifier_block *notifier,
 {
 	if (val != SYS_RESTART)
 		return NOTIFY_DONE;
-	__pram_reboot();
+	if (pram_sb)
+		__pram_reboot();
 	return NOTIFY_OK;
 }
 
@@ -565,9 +605,59 @@ static struct notifier_block pram_reboot_notifier = {
 	.notifier_call = pram_reboot,
 };
 
+static ssize_t show_pram_sb_pfn(struct kobject *kobj,
+		struct kobj_attribute *attr, char *buf)
+{
+	unsigned long pfn = pram_sb ? PFN_DOWN(__pa(pram_sb)) : 0;
+	return sprintf(buf, "%lx\n", pfn);
+}
+
+static struct kobj_attribute pram_sb_pfn_attr =
+	__ATTR(pram, 0444, show_pram_sb_pfn, NULL);
+
+static struct attribute *pram_attrs[] = {
+	&pram_sb_pfn_attr.attr,
+	NULL,
+};
+
+static struct attribute_group pram_attr_group = {
+	.attrs = pram_attrs,
+};
+
+/* returns non-zero on success */
+static int __init pram_init_sb(void)
+{
+	unsigned long pfn;
+	struct pram_node *node;
+
+	if (!pram_sb) {
+		struct page *page;
+
+		page = pram_alloc_page(GFP_KERNEL | __GFP_ZERO);
+		if (!page) {
+			pr_err("PRAM: Failed to allocate super block\n");
+			return 0;
+		}
+		pram_sb = page_address(page);
+	}
+
+	/* build auxiliary doubly-linked list of nodes connected through
+	 * page::lru for convenience sake */
+	pfn = pram_sb->node_pfn;
+	while (pfn) {
+		node = pfn_to_kaddr(pfn);
+		pram_insert_node(node);
+		pfn = node->node_pfn;
+	}
+	return 1;
+}
+
 static int __init pram_init(void)
 {
-	register_reboot_notifier(&pram_reboot_notifier);
+	if (pram_init_sb()) {
+		register_reboot_notifier(&pram_reboot_notifier);
+		sysfs_update_group(kernel_kobj, &pram_attr_group);
+	}
 	return 0;
 }
 module_init(pram_init);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
