From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051208112955.6309.47344.sendpatchset@cherry.local>
In-Reply-To: <20051208112940.6309.39428.sendpatchset@cherry.local>
References: <20051208112940.6309.39428.sendpatchset@cherry.local>
Subject: [PATCH 03/07] Add anon_vma use count
Date: Thu,  8 Dec 2005 20:27:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Add anon_vma use count.

This patch adds an atomic use counter to struct anon_vma. We do this because
we need to be able to follow page->mapping to determine the map count when
page->_mapcount is missing. Without this patch page->mapping might point
to an already freed struct anon_vma.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 include/linux/rmap.h |    4 +++-
 mm/page_alloc.c      |    6 +++++-
 mm/rmap.c            |   18 ++++++++++--------
 3 files changed, 18 insertions(+), 10 deletions(-)

--- from-0002/include/linux/rmap.h
+++ to-work/include/linux/rmap.h	2005-12-08 12:17:33.000000000 +0900
@@ -27,6 +27,7 @@
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
+	atomic_t use_count;
 };
 
 #ifdef CONFIG_MMU
@@ -40,7 +41,8 @@ static inline struct anon_vma *anon_vma_
 
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
-	kmem_cache_free(anon_vma_cachep, anon_vma);
+	if (atomic_add_negative(-1, &anon_vma->use_count))
+		kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
 static inline void anon_vma_lock(struct vm_area_struct *vma)
--- from-0003/mm/page_alloc.c
+++ to-work/mm/page_alloc.c	2005-12-08 12:17:33.000000000 +0900
@@ -36,6 +36,7 @@
 #include <linux/memory_hotplug.h>
 #include <linux/nodemask.h>
 #include <linux/vmalloc.h>
+#include <linux/rmap.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -683,8 +684,11 @@ static void fastcall free_hot_cold_page(
 
 	arch_free_page(page, 0);
 
-	if (PageAnon(page))
+	if (PageAnon(page)) {
+		anon_vma_free((void *)((unsigned long)
+				       (page->mapping) - PAGE_MAPPING_ANON));
 		page->mapping = NULL;
+	}
 	if (free_pages_check(__FUNCTION__, page))
 		return;
 
--- from-0003/mm/rmap.c
+++ to-work/mm/rmap.c	2005-12-08 12:17:33.000000000 +0900
@@ -100,6 +100,8 @@ int anon_vma_prepare(struct vm_area_stru
 			locked = NULL;
 		}
 
+		atomic_inc(&anon_vma->use_count);
+
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
@@ -121,6 +123,7 @@ void __anon_vma_merge(struct vm_area_str
 {
 	BUG_ON(vma->anon_vma != next->anon_vma);
 	list_del(&next->anon_vma_node);
+	anon_vma_free(vma->anon_vma);
 }
 
 void __anon_vma_link(struct vm_area_struct *vma)
@@ -128,6 +131,7 @@ void __anon_vma_link(struct vm_area_stru
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	if (anon_vma) {
+		atomic_inc(&anon_vma->use_count);
 		list_add(&vma->anon_vma_node, &anon_vma->head);
 		validate_anon_vma(vma);
 	}
@@ -138,6 +142,7 @@ void anon_vma_link(struct vm_area_struct
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	if (anon_vma) {
+		atomic_inc(&anon_vma->use_count);
 		spin_lock(&anon_vma->lock);
 		list_add(&vma->anon_vma_node, &anon_vma->head);
 		validate_anon_vma(vma);
@@ -148,7 +153,6 @@ void anon_vma_link(struct vm_area_struct
 void anon_vma_unlink(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
-	int empty;
 
 	if (!anon_vma)
 		return;
@@ -156,13 +160,8 @@ void anon_vma_unlink(struct vm_area_stru
 	spin_lock(&anon_vma->lock);
 	validate_anon_vma(vma);
 	list_del(&vma->anon_vma_node);
-
-	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head);
 	spin_unlock(&anon_vma->lock);
-
-	if (empty)
-		anon_vma_free(anon_vma);
+	anon_vma_free(anon_vma);
 }
 
 static void anon_vma_ctor(void *data, kmem_cache_t *cachep, unsigned long flags)
@@ -173,6 +172,7 @@ static void anon_vma_ctor(void *data, km
 
 		spin_lock_init(&anon_vma->lock);
 		INIT_LIST_HEAD(&anon_vma->head);
+		atomic_set(&anon_vma->use_count, -1);
 	}
 }
 
@@ -434,7 +434,9 @@ void page_add_anon_rmap(struct page *pag
 		struct anon_vma *anon_vma = vma->anon_vma;
 
 		BUG_ON(!anon_vma);
-		anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
+		atomic_inc(&anon_vma->use_count);
+		anon_vma = (void *) ((unsigned long)anon_vma 
+				     + PAGE_MAPPING_ANON);
 		page->mapping = (struct address_space *) anon_vma;
 
 		page->index = linear_page_index(vma, address);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
