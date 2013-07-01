Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 6F0726B0038
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:02 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 03/13] mm: PRAM: implement page stream operations
Date: Mon, 1 Jul 2013 15:57:38 +0400
Message-ID: <058d7295434214c8a6b4f3f6a812351dfd025da1.1372582755.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

Using the pram_save_page() function, one can populate PRAM nodes with
memory pages, which can be then loaded using the pram_load_page()
function. Saving a memory page to PRAM is implemented as storing the pfn
in the PRAM node and incrementing its ref count so that it will not get
freed after the last user puts it.
---
 include/linux/pram.h |    3 +
 mm/pram.c            |  166 +++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 167 insertions(+), 2 deletions(-)

diff --git a/include/linux/pram.h b/include/linux/pram.h
index 5b8c2c1..dd17316 100644
--- a/include/linux/pram.h
+++ b/include/linux/pram.h
@@ -6,10 +6,13 @@
 #include <linux/mm_types.h>
 
 struct pram_node;
+struct pram_link;
 
 struct pram_stream {
 	gfp_t gfp_mask;
 	struct pram_node *node;
+	struct pram_link *link;		/* current link */
+	unsigned int page_index;	/* next page index in link */
 };
 
 #define PRAM_NAME_MAX		256	/* including nul */
diff --git a/mm/pram.c b/mm/pram.c
index 3af2039..a443eb0 100644
--- a/mm/pram.c
+++ b/mm/pram.c
@@ -5,19 +5,48 @@
 #include <linux/mm.h>
 #include <linux/mutex.h>
 #include <linux/pram.h>
+#include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/types.h>
 
 /*
+ * Represents a reference to a data page saved to PRAM.
+ */
+struct pram_entry {
+	__u32 flags;		/* see PRAM_PAGE_* flags */
+	__u64 pfn;		/* the page frame number */
+};
+
+/*
+ * Keeps references to data pages saved to PRAM.
+ * The structure occupies a memory page.
+ */
+struct pram_link {
+	__u64	link_pfn;	/* points to the next link of the node */
+
+	/* the array occupies the rest of the link page; if the link is not
+	 * full, the rest of the array must be filled with zeros */
+	struct pram_entry entry[0];
+};
+
+#define PRAM_LINK_ENTRIES_MAX \
+	((PAGE_SIZE-sizeof(struct pram_link))/sizeof(struct pram_entry))
+
+/*
  * Persistent memory is divided into nodes that can be saved or loaded
  * independently of each other. The nodes are identified by unique name
  * strings.
  *
+ * References to data pages saved to a persistent memory node are kept in a
+ * singly-linked list of PRAM link structures (see above), the node has a
+ * pointer to the head of.
+ *
  * The structure occupies a memory page.
  */
 struct pram_node {
 	__u32	flags;		/* see PRAM_* flags below */
 	__u32	type;		/* data type, see enum pram_stream_type */
+	__u64	link_pfn;	/* points to the first link of the node */
 
 	__u8	name[PRAM_NAME_MAX];
 };
@@ -62,12 +91,46 @@ static struct pram_node *pram_find_node(const char *name)
 	return NULL;
 }
 
+static void pram_truncate_link(struct pram_link *link)
+{
+	int i;
+	unsigned long pfn;
+	struct page *page;
+
+	for (i = 0; i < PRAM_LINK_ENTRIES_MAX; i++) {
+		pfn = link->entry[i].pfn;
+		if (!pfn)
+			continue;
+		page = pfn_to_page(pfn);
+		put_page(page);
+	}
+}
+
+static void pram_truncate_node(struct pram_node *node)
+{
+	unsigned long link_pfn;
+	struct pram_link *link;
+
+	link_pfn = node->link_pfn;
+	while (link_pfn) {
+		link = pfn_to_kaddr(link_pfn);
+		pram_truncate_link(link);
+		link_pfn = link->link_pfn;
+		pram_free_page(link);
+		cond_resched();
+	}
+	node->link_pfn = 0;
+
+}
+
 static void pram_stream_init(struct pram_stream *ps,
 			     struct pram_node *node, gfp_t gfp_mask)
 {
 	memset(ps, 0, sizeof(*ps));
 	ps->gfp_mask = gfp_mask;
 	ps->node = node;
+	if (node->link_pfn)
+		ps->link = pfn_to_kaddr(node->link_pfn);
 }
 
 /**
@@ -157,6 +220,7 @@ void pram_discard_save(struct pram_stream *ps)
 	pram_delete_node(node);
 	mutex_unlock(&pram_mutex);
 
+	pram_truncate_node(node);
 	pram_free_page(node);
 }
 
@@ -220,9 +284,46 @@ void pram_finish_load(struct pram_stream *ps)
 
 	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_LOAD);
 
+	pram_truncate_node(node);
 	pram_free_page(node);
 }
 
+/*
+ * Insert page to PRAM node allocating a new PRAM link if necessary.
+ */
+static int __pram_save_page(struct pram_stream *ps,
+			    struct page *page, int flags)
+{
+	struct pram_node *node = ps->node;
+	struct pram_link *link = ps->link;
+	struct pram_entry *entry;
+
+	if (!link || ps->page_index >= PRAM_LINK_ENTRIES_MAX) {
+		struct page *link_page;
+		unsigned long link_pfn;
+
+		link_page = pram_alloc_page((ps->gfp_mask & GFP_RECLAIM_MASK) |
+					    __GFP_ZERO);
+		if (!link_page)
+			return -ENOMEM;
+
+		link_pfn = page_to_pfn(link_page);
+		if (link)
+			link->link_pfn = link_pfn;
+		else
+			node->link_pfn = link_pfn;
+
+		ps->link = link = page_address(link_page);
+		ps->page_index = 0;
+	}
+
+	get_page(page);
+	entry = &link->entry[ps->page_index++];
+	entry->flags = flags;
+	entry->pfn = page_to_pfn(page);
+	return 0;
+}
+
 /**
  * Save page @page to the persistent memory node associated with stream @ps.
  * The stream must be initialized with pram_prepare_save().
@@ -231,10 +332,66 @@ void pram_finish_load(struct pram_stream *ps)
  * have the PRAM_PAGE_LRU bit set.
  *
  * Returns 0 on success, -errno on failure.
+ *
+ * Error values:
+ *    %ENOMEM: insufficient amount of memory available
+ *
+ * Saving a page to persistent memory is simply incrementing its refcount so
+ * that it will not get freed after the last user puts it. That means it is
+ * safe to use the page as usual after it has been saved.
  */
 int pram_save_page(struct pram_stream *ps, struct page *page, int flags)
 {
-	return -ENOSYS;
+	struct pram_node *node = ps->node;
+
+	BUG_ON(node->type != PRAM_PAGE_STREAM);
+	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_SAVE);
+
+	BUG_ON(PageCompound(page));
+
+	return __pram_save_page(ps, page, flags);
+}
+
+/*
+ * Extract the next page from persistent memory freeing a PRAM link if it
+ * becomes empty.
+ */
+static struct page *__pram_load_page(struct pram_stream *ps, int *flags)
+{
+	struct pram_node *node = ps->node;
+	struct pram_link *link = ps->link;
+	struct pram_entry *entry;
+	struct page *page = NULL;
+	bool eof = false;
+
+	if (!link)
+		return NULL;
+
+	BUG_ON(ps->page_index >= PRAM_LINK_ENTRIES_MAX);
+	entry = &link->entry[ps->page_index];
+	if (entry->pfn) {
+		page = pfn_to_page(entry->pfn);
+		if (flags)
+			*flags = entry->flags;
+	} else
+		eof = true;
+
+	/* clear to avoid double free (see pram_truncate_link()) */
+	memset(entry, 0, sizeof(*entry));
+
+	if (eof || ++ps->page_index >= PRAM_LINK_ENTRIES_MAX) {
+		if (link->link_pfn) {
+			WARN_ON(eof);
+			ps->link = pfn_to_kaddr(link->link_pfn);
+			ps->page_index = 0;
+		} else
+			ps->link = NULL;
+
+		node->link_pfn = link->link_pfn;
+		pram_free_page(link);
+	}
+
+	return page;
 }
 
 /**
@@ -251,7 +408,12 @@ int pram_save_page(struct pram_stream *ps, struct page *page, int flags)
  */
 struct page *pram_load_page(struct pram_stream *ps, int *flags)
 {
-	return NULL;
+	struct pram_node *node = ps->node;
+
+	BUG_ON(node->type != PRAM_PAGE_STREAM);
+	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_LOAD);
+
+	return __pram_load_page(ps, flags);
 }
 
 /**
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
