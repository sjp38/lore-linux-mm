Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 27E206B003D
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:12 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 08/13] mm: PRAM: checksum saved data
Date: Mon, 1 Jul 2013 15:57:43 +0400
Message-ID: <a7b485cb7b82f808846938e0670d73bb439b6846.1372582756.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

Checksum PRAM pages with crc32 to ensure persistent memory is not
corrupted during reboot.
---
 mm/Kconfig |    4 ++
 mm/pram.c  |  128 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 130 insertions(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index f1e11a0..0a4d4c6 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -475,6 +475,10 @@ config FRONTSWAP
 config PRAM
 	bool "Persistent over-kexec memory storage"
 	depends on X86
+	select CRC32
+	select LIBCRC32C
+	select CRYPTO_CRC32C
+	select CRYPTO_CRC32C_INTEL
 	default n
 	help
 	  This option adds the kernel API that enables saving memory pages of
diff --git a/mm/pram.c b/mm/pram.c
index 380735f..8a66a86 100644
--- a/mm/pram.c
+++ b/mm/pram.c
@@ -1,4 +1,6 @@
 #include <linux/bootmem.h>
+#include <linux/crc32.h>
+#include <linux/crc32c.h>
 #include <linux/err.h>
 #include <linux/gfp.h>
 #include <linux/highmem.h>
@@ -19,11 +21,14 @@
 #include <linux/sysfs.h>
 #include <linux/types.h>
 
+#define PRAM_MAGIC		0x7072616D
+
 /*
  * Represents a reference to a data page saved to PRAM.
  */
 struct pram_entry {
 	__u32 flags;		/* see PRAM_PAGE_* flags */
+	__u32 csum;		/* the page csum */
 	__u64 pfn;		/* the page frame number */
 };
 
@@ -32,6 +37,9 @@ struct pram_entry {
  * The structure occupies a memory page.
  */
 struct pram_link {
+	__u32	magic;
+	__u32	csum;
+
 	__u64	link_pfn;	/* points to the next link of the node */
 
 	/* the array occupies the rest of the link page; if the link is not
@@ -57,6 +65,9 @@ struct pram_link {
  * The structure occupies a memory page.
  */
 struct pram_node {
+	__u32	magic;
+	__u32	csum;
+
 	__u32	flags;		/* see PRAM_* flags below */
 	__u32	type;		/* data type, see enum pram_stream_type */
 	__u64	data_len;	/* data size, only for byte streams */
@@ -81,6 +92,9 @@ struct pram_node {
  * The structure occupies a memory page.
  */
 struct pram_super_block {
+	__u32	magic;
+	__u32	csum;
+
 	__u64	node_pfn;		/* points to the first element of
 					 * the node list */
 };
@@ -106,11 +120,34 @@ static int __init parse_pram_sb_pfn(char *arg)
 }
 early_param("pram", parse_pram_sb_pfn);
 
+static u32 pram_data_csum(struct page *page)
+{
+	u32 ret;
+	void *addr;
+
+	addr = kmap_atomic(page);
+	ret = crc32c(0, addr, PAGE_SIZE);
+	kunmap_atomic(addr);
+	return ret;
+}
+
+/* SSE-4.2 crc32c faster than crc32, but not available at early boot */
+static inline u32 pram_meta_csum(void *addr)
+{
+	/* skip magic and csum fields */
+	return crc32(0, addr + 8, PAGE_SIZE - 8);
+}
+
 static void * __init pram_map_meta(unsigned long pfn)
 {
+	__u32 *p;
+
 	if (pfn >= max_low_pfn)
 		return ERR_PTR(-EINVAL);
-	return pfn_to_kaddr(pfn);
+	p = pfn_to_kaddr(pfn);
+	if (p[0] != PRAM_MAGIC || p[1] != pram_meta_csum(p))
+		return ERR_PTR(-EINVAL);
+	return p;
 }
 
 static int __init pram_reserve_page(unsigned long pfn)
@@ -332,6 +369,65 @@ static struct pram_node *pram_find_node(const char *name)
 	return NULL;
 }
 
+static void pram_csum_link(struct pram_link *link)
+{
+	int i;
+	struct pram_entry *entry;
+
+	for (i = 0; i < PRAM_LINK_ENTRIES_MAX; i++) {
+		entry = &link->entry[i];
+		if (entry->pfn)
+			entry->csum = pram_data_csum(pfn_to_page(entry->pfn));
+	}
+}
+
+static void pram_csum_node(struct pram_node *node)
+{
+	unsigned long link_pfn;
+	struct pram_link *link;
+
+	link_pfn = node->link_pfn;
+	while (link_pfn) {
+		link = pfn_to_kaddr(link_pfn);
+		pram_csum_link(link);
+		link_pfn = link->link_pfn;
+		cond_resched();
+	}
+}
+
+static int pram_check_link(struct pram_link *link)
+{
+	int i;
+	struct pram_entry *entry;
+
+	for (i = 0; i < PRAM_LINK_ENTRIES_MAX; i++) {
+		entry = &link->entry[i];
+		if (!entry->pfn)
+			break;
+		if (entry->csum != pram_data_csum(pfn_to_page(entry->pfn)))
+			return -EFAULT;
+	}
+	return 0;
+}
+
+static int pram_check_node(struct pram_node *node)
+{
+	unsigned long link_pfn;
+	struct pram_link *link;
+	int ret = 0;
+
+	link_pfn = node->link_pfn;
+	while (link_pfn) {
+		link = pfn_to_kaddr(link_pfn);
+		ret = pram_check_link(link);
+		if (ret)
+			break;
+		link_pfn = link->link_pfn;
+		cond_resched();
+	}
+	return ret;
+}
+
 static void pram_truncate_link(struct pram_link *link)
 {
 	int i;
@@ -449,6 +545,7 @@ void pram_finish_save(struct pram_stream *ps)
 
 	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_SAVE);
 
+	pram_csum_node(node);
 	smp_wmb();
 	node->flags &= ~PRAM_ACCMODE_MASK;
 }
@@ -488,6 +585,7 @@ void pram_discard_save(struct pram_stream *ps)
  *    %ENOENT: node with specified name does not exist
  *    %EBUSY: save to required node has not finished yet
  *    %EPERM: specified type conflicts with type of required node
+ *    %EFAULT: node corrupted
  *
  * After the load has finished, pram_finish_load() is to be called.
  */
@@ -520,6 +618,13 @@ out_unlock:
 	if (err)
 		return err;
 
+	err = pram_check_node(node);
+	if (err) {
+		pram_truncate_node(node);
+		pram_free_page(node);
+		return err;
+	}
+
 	node->flags |= PRAM_LOAD;
 	pram_stream_init(ps, node, 0);
 	return 0;
@@ -775,8 +880,24 @@ size_t pram_read(struct pram_stream *ps, void *buf, size_t count)
 	return read_count;
 }
 
+static void pram_csum_node_meta(struct pram_node *node)
+{
+	unsigned long link_pfn;
+	struct pram_link *link;
+
+	link_pfn = node->link_pfn;
+	while (link_pfn) {
+		link = pfn_to_kaddr(link_pfn);
+		link->magic = PRAM_MAGIC;
+		link->csum = pram_meta_csum(link);
+		link_pfn = link->link_pfn;
+	}
+	node->magic = PRAM_MAGIC;
+	node->csum = pram_meta_csum(node);
+}
+
 /*
- * Build the list of PRAM nodes.
+ * Build the list of PRAM nodes and update metadata csums.
  */
 static void __pram_reboot(void)
 {
@@ -789,9 +910,12 @@ static void __pram_reboot(void)
 		if (WARN_ON(node->flags & PRAM_ACCMODE_MASK))
 			continue;
 		node->node_pfn = node_pfn;
+		pram_csum_node_meta(node);
 		node_pfn = page_to_pfn(page);
 	}
 	pram_sb->node_pfn = node_pfn;
+	pram_sb->magic = PRAM_MAGIC;
+	pram_sb->csum = pram_meta_csum(pram_sb);
 }
 
 static int pram_reboot(struct notifier_block *notifier,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
