Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id BC5276B0038
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:57:59 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 02/13] mm: PRAM: implement node load and save functions
Date: Mon, 1 Jul 2013 15:57:37 +0400
Message-ID: <24ab8ab30254b32696c1df58b5c70ae4bd916dea.1372582755.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

Persistent memory is divided into nodes, which can be saved and loaded
independently of each other. PRAM nodes are kept on the list and
identified by unique names. Whenever a save operation is initiated by
calling pram_prepare_save(), a new node is created and linked to the
list. When the save operation has been committed by calling
pram_finish_save(), the node becomes loadable. A load operation can be
then initiated by calling pram_prepare_load(), which deletes the node
from the list and prepares the corresponding stream for loading data
from it. After the load has been finished, the pram_finish_load()
function must be called to free the node. Nodes are also deleted when a
save operation is discarded, i.e. pram_discard_save() is called instead
of pram_finish_save().
---
 include/linux/pram.h |    7 ++-
 mm/pram.c            |  158 ++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 159 insertions(+), 6 deletions(-)

diff --git a/include/linux/pram.h b/include/linux/pram.h
index cf04548..5b8c2c1 100644
--- a/include/linux/pram.h
+++ b/include/linux/pram.h
@@ -5,7 +5,12 @@
 #include <linux/types.h>
 #include <linux/mm_types.h>
 
-struct pram_stream;
+struct pram_node;
+
+struct pram_stream {
+	gfp_t gfp_mask;
+	struct pram_node *node;
+};
 
 #define PRAM_NAME_MAX		256	/* including nul */
 
diff --git a/mm/pram.c b/mm/pram.c
index cea0e87..3af2039 100644
--- a/mm/pram.c
+++ b/mm/pram.c
@@ -1,10 +1,75 @@
 #include <linux/err.h>
 #include <linux/gfp.h>
 #include <linux/kernel.h>
+#include <linux/list.h>
 #include <linux/mm.h>
+#include <linux/mutex.h>
 #include <linux/pram.h>
+#include <linux/string.h>
 #include <linux/types.h>
 
+/*
+ * Persistent memory is divided into nodes that can be saved or loaded
+ * independently of each other. The nodes are identified by unique name
+ * strings.
+ *
+ * The structure occupies a memory page.
+ */
+struct pram_node {
+	__u32	flags;		/* see PRAM_* flags below */
+	__u32	type;		/* data type, see enum pram_stream_type */
+
+	__u8	name[PRAM_NAME_MAX];
+};
+
+#define PRAM_SAVE		1
+#define PRAM_LOAD		2
+#define PRAM_ACCMODE_MASK	3
+
+static LIST_HEAD(pram_nodes);			/* linked through page::lru */
+static DEFINE_MUTEX(pram_mutex);		/* serializes open/close */
+
+static inline struct page *pram_alloc_page(gfp_t gfp_mask)
+{
+	return alloc_page(gfp_mask);
+}
+
+static inline void pram_free_page(void *addr)
+{
+	free_page((unsigned long)addr);
+}
+
+static inline void pram_insert_node(struct pram_node *node)
+{
+	list_add(&virt_to_page(node)->lru, &pram_nodes);
+}
+
+static inline void pram_delete_node(struct pram_node *node)
+{
+	list_del(&virt_to_page(node)->lru);
+}
+
+static struct pram_node *pram_find_node(const char *name)
+{
+	struct page *page;
+	struct pram_node *node;
+
+	list_for_each_entry(page, &pram_nodes, lru) {
+		node = page_address(page);
+		if (strcmp(node->name, name) == 0)
+			return node;
+	}
+	return NULL;
+}
+
+static void pram_stream_init(struct pram_stream *ps,
+			     struct pram_node *node, gfp_t gfp_mask)
+{
+	memset(ps, 0, sizeof(*ps));
+	ps->gfp_mask = gfp_mask;
+	ps->node = node;
+}
+
 /**
  * Create a persistent memory node with name @name and initialize stream @ps
  * for saving data to it.
@@ -18,13 +83,49 @@
  *
  * Returns 0 on success, -errno on failure.
  *
+ * Error values:
+ *    %ENAMETOOLONG: name len >= PRAM_NAME_MAX
+ *    %ENOMEM: insufficient memory available
+ *    %EEXIST: node with specified name already exists
+ *
  * After the save has finished, pram_finish_save() (or pram_discard_save() in
  * case of failure) is to be called.
  */
 int pram_prepare_save(struct pram_stream *ps,
 		const char *name, enum pram_stream_type type, gfp_t gfp_mask)
 {
-	return -ENOSYS;
+	struct page *page;
+	struct pram_node *node;
+	int err = 0;
+
+	BUG_ON(type != PRAM_PAGE_STREAM &&
+	       type != PRAM_BYTE_STREAM);
+
+	if (strlen(name) >= PRAM_NAME_MAX)
+		return -ENAMETOOLONG;
+
+	page = pram_alloc_page(GFP_KERNEL | __GFP_ZERO);
+	if (!page)
+		return -ENOMEM;
+	node = page_address(page);
+
+	node->flags = PRAM_SAVE;
+	node->type = type;
+	strcpy(node->name, name);
+
+	mutex_lock(&pram_mutex);
+	if (!pram_find_node(name))
+		pram_insert_node(node);
+	else
+		err = -EEXIST;
+	mutex_unlock(&pram_mutex);
+	if (err) {
+		__free_page(page);
+		return err;
+	}
+
+	pram_stream_init(ps, node, gfp_mask);
+	return 0;
 }
 
 /**
@@ -33,7 +134,12 @@ int pram_prepare_save(struct pram_stream *ps,
  */
 void pram_finish_save(struct pram_stream *ps)
 {
-	BUG();
+	struct pram_node *node = ps->node;
+
+	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_SAVE);
+
+	smp_wmb();
+	node->flags &= ~PRAM_ACCMODE_MASK;
 }
 
 /**
@@ -43,7 +149,15 @@ void pram_finish_save(struct pram_stream *ps)
  */
 void pram_discard_save(struct pram_stream *ps)
 {
-	BUG();
+	struct pram_node *node = ps->node;
+
+	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_SAVE);
+
+	mutex_lock(&pram_mutex);
+	pram_delete_node(node);
+	mutex_unlock(&pram_mutex);
+
+	pram_free_page(node);
 }
 
 /**
@@ -57,12 +171,42 @@ void pram_discard_save(struct pram_stream *ps)
  *
  * Returns 0 on success, -errno on failure.
  *
+ * Error values:
+ *    %ENOENT: node with specified name does not exist
+ *    %EBUSY: save to required node has not finished yet
+ *    %EPERM: specified type conflicts with type of required node
+ *
  * After the load has finished, pram_finish_load() is to be called.
  */
 int pram_prepare_load(struct pram_stream *ps,
 		const char *name, enum pram_stream_type type)
 {
-	return -ENOSYS;
+	struct pram_node *node;
+	int err = 0;
+
+	mutex_lock(&pram_mutex);
+	node = pram_find_node(name);
+	if (!node) {
+		err = -ENOENT;
+		goto out_unlock;
+	}
+	if (node->flags & PRAM_ACCMODE_MASK) {
+		err = -EBUSY;
+		goto out_unlock;
+	}
+	if (node->type != type) {
+		err = -EPERM;
+		goto out_unlock;
+	}
+	pram_delete_node(node);
+out_unlock:
+	mutex_unlock(&pram_mutex);
+	if (err)
+		return err;
+
+	node->flags |= PRAM_LOAD;
+	pram_stream_init(ps, node, 0);
+	return 0;
 }
 
 /**
@@ -72,7 +216,11 @@ int pram_prepare_load(struct pram_stream *ps,
  */
 void pram_finish_load(struct pram_stream *ps)
 {
-	BUG();
+	struct pram_node *node = ps->node;
+
+	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_LOAD);
+
+	pram_free_page(node);
 }
 
 /**
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
