Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 397996B003A
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:06 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 05/13] mm: PRAM: link nodes by pfn before reboot
Date: Mon, 1 Jul 2013 15:57:40 +0400
Message-ID: <f2817b1c438c8bd6e7a26185c214f73922f20628.1372582756.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

Since page structs, which are used for linking PRAM nodes, are cleared
on boot, organize all PRAM nodes into a list singly-linked by pfn's
before reboot to facilitate the node list restore in the new kernel.
---
 mm/pram.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/mm/pram.c b/mm/pram.c
index f7eebe1..c7706dc 100644
--- a/mm/pram.c
+++ b/mm/pram.c
@@ -1,11 +1,15 @@
 #include <linux/err.h>
 #include <linux/gfp.h>
 #include <linux/highmem.h>
+#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/mm.h>
+#include <linux/module.h>
 #include <linux/mutex.h>
+#include <linux/notifier.h>
 #include <linux/pram.h>
+#include <linux/reboot.h>
 #include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/types.h>
@@ -42,6 +46,9 @@ struct pram_link {
  * singly-linked list of PRAM link structures (see above), the node has a
  * pointer to the head of.
  *
+ * To facilitate data restore in the new kernel, before reboot all PRAM nodes
+ * are organized into a list singly-linked by pfn's (see pram_reboot()).
+ *
  * The structure occupies a memory page.
  */
 struct pram_node {
@@ -49,6 +56,7 @@ struct pram_node {
 	__u32	type;		/* data type, see enum pram_stream_type */
 	__u64	data_len;	/* data size, only for byte streams */
 	__u64	link_pfn;	/* points to the first link of the node */
+	__u64	node_pfn;	/* points to the next node in the node list */
 
 	__u8	name[PRAM_NAME_MAX];
 };
@@ -57,6 +65,10 @@ struct pram_node {
 #define PRAM_LOAD		2
 #define PRAM_ACCMODE_MASK	3
 
+/*
+ * For convenience sake PRAM nodes are kept in an auxiliary doubly-linked list
+ * connected through the lru field of the page struct.
+ */
 static LIST_HEAD(pram_nodes);			/* linked through page::lru */
 static DEFINE_MUTEX(pram_mutex);		/* serializes open/close */
 
@@ -521,3 +533,41 @@ size_t pram_read(struct pram_stream *ps, void *buf, size_t count)
 	}
 	return read_count;
 }
+
+/*
+ * Build the list of PRAM nodes.
+ */
+static void __pram_reboot(void)
+{
+	struct page *page;
+	struct pram_node *node;
+	unsigned long node_pfn = 0;
+
+	list_for_each_entry_reverse(page, &pram_nodes, lru) {
+		node = page_address(page);
+		if (WARN_ON(node->flags & PRAM_ACCMODE_MASK))
+			continue;
+		node->node_pfn = node_pfn;
+		node_pfn = page_to_pfn(page);
+	}
+}
+
+static int pram_reboot(struct notifier_block *notifier,
+		       unsigned long val, void *v)
+{
+	if (val != SYS_RESTART)
+		return NOTIFY_DONE;
+	__pram_reboot();
+	return NOTIFY_OK;
+}
+
+static struct notifier_block pram_reboot_notifier = {
+	.notifier_call = pram_reboot,
+};
+
+static int __init pram_init(void)
+{
+	register_reboot_notifier(&pram_reboot_notifier);
+	return 0;
+}
+module_init(pram_init);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
