From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 3/4  -ac to newer rmap
Message-Id: <20021113113716Z80405-30305+1115@imladris.surriel.com>
Date: Wed, 13 Nov 2002 09:37:05 -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.5 backport: get pte_chains from the slab cache (William Lee Irwin III)

--- linux-2.4.19/init/main.c.pteslab	2002-11-13 08:48:31.000000000 -0200
+++ linux-2.4.19/init/main.c	2002-11-13 09:22:16.000000000 -0200
@@ -98,6 +98,7 @@
 extern void sysctl_init(void);
 extern void signals_init(void);
 extern int init_pcmcia_ds(void);
+extern void pte_chain_init(void);
 
 extern void free_initmem(void);
 
@@ -392,6 +393,7 @@
 	mem_init();
 	kmem_cache_sizes_init();
 	pgtable_cache_init();
+	pte_chain_init();
 
 	/*
 	 * For architectures that have highmem, num_mappedpages represents
--- linux-2.4.19/mm/page_alloc.c.pteslab	2002-11-13 08:48:31.000000000 -0200
+++ linux-2.4.19/mm/page_alloc.c	2002-11-13 09:22:16.000000000 -0200
@@ -950,11 +950,9 @@
 		zone->inactive_clean_pages = 0;
 		zone->inactive_dirty_pages = 0;
 		zone->need_balance = 0;
-		zone->pte_chain_freelist = NULL;
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_dirty_list);
 		INIT_LIST_HEAD(&zone->inactive_clean_list);
-		spin_lock_init(&zone->pte_chain_freelist_lock);
 
 		if (!size)
 			continue;
--- linux-2.4.19/mm/rmap.c.pteslab	2002-11-13 08:48:31.000000000 -0200
+++ linux-2.4.19/mm/rmap.c	2002-11-13 09:26:17.000000000 -0200
@@ -23,6 +23,8 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
+#include <linux/slab.h>
+#include <linux/init.h>
 
 #include <asm/pgalloc.h>
 #include <asm/rmap.h>
@@ -48,10 +50,10 @@
 	pte_t * ptep;
 };
 
-static inline struct pte_chain * pte_chain_alloc(zone_t *);
+static kmem_cache_t * pte_chain_cache;
+static inline struct pte_chain * pte_chain_alloc(void);
 static inline void pte_chain_free(struct pte_chain *, struct pte_chain *,
-		struct page *, zone_t *);
-static void alloc_new_pte_chains(zone_t *);
+		struct page *);
 
 /**
  * page_referenced - test if the page was referenced
@@ -114,7 +116,7 @@
 	pte_chain_unlock(page);
 #endif
 
-	pte_chain = pte_chain_alloc(page_zone(page));
+	pte_chain = pte_chain_alloc();
 
 	pte_chain_lock(page);
 
@@ -139,19 +141,16 @@
 void page_remove_rmap(struct page * page, pte_t * ptep)
 {
 	struct pte_chain * pc, * prev_pc = NULL;
-	zone_t *zone;
 
 	if (!page || !ptep)
 		BUG();
 	if (!VALID_PAGE(page) || PageReserved(page))
 		return;
 
-	zone = page_zone(page);
-
 	pte_chain_lock(page);
 	for (pc = page->pte_chain; pc; prev_pc = pc, pc = pc->next) {
 		if (pc->ptep == ptep) {
-			pte_chain_free(pc, prev_pc, page, zone);
+			pte_chain_free(pc, prev_pc, page);
 			goto out;
 		}
 	}
@@ -259,7 +258,6 @@
 int try_to_unmap(struct page * page)
 {
 	struct pte_chain * pc, * next_pc, * prev_pc = NULL;
-	zone_t *zone = page_zone(page);
 	int ret = SWAP_SUCCESS;
 
 	/* This page should not be on the pageout lists. */
@@ -276,7 +274,7 @@
 		switch (try_to_unmap_one(page, pc->ptep)) {
 			case SWAP_SUCCESS:
 				/* Free the pte_chain struct. */
-				pte_chain_free(pc, prev_pc, page, zone);
+				pte_chain_free(pc, prev_pc, page);
 				break;
 			case SWAP_AGAIN:
 				/* Skip this pte, remembering status. */
@@ -335,31 +333,11 @@
  ** functions.
  **/
 
-static inline void pte_chain_push(zone_t * zone,
-		struct pte_chain * pte_chain)
-{
-	pte_chain->ptep = NULL;
-	pte_chain->next = zone->pte_chain_freelist;
-	zone->pte_chain_freelist = pte_chain;
-}
-
-static inline struct pte_chain * pte_chain_pop(zone_t * zone)
-{
-	struct pte_chain *pte_chain;
-
-	pte_chain = zone->pte_chain_freelist;
-	zone->pte_chain_freelist = pte_chain->next;
-	pte_chain->next = NULL;
-
-	return pte_chain;
-}
-
 /**
  * pte_chain_free - free pte_chain structure
  * @pte_chain: pte_chain struct to free
  * @prev_pte_chain: previous pte_chain on the list (may be NULL)
  * @page: page this pte_chain hangs off (may be NULL)
- * @zone: memory zone to free pte chain in
  *
  * This function unlinks pte_chain from the singly linked list it
  * may be on and adds the pte_chain to the free list. May also be
@@ -367,67 +345,45 @@
  * Caller needs to hold the pte_chain_lock if the page is non-NULL.
  */
 static inline void pte_chain_free(struct pte_chain * pte_chain,
-		struct pte_chain * prev_pte_chain, struct page * page,
-		zone_t * zone)
+		struct pte_chain * prev_pte_chain, struct page * page)
 {
 	if (prev_pte_chain)
 		prev_pte_chain->next = pte_chain->next;
 	else if (page)
 		page->pte_chain = pte_chain->next;
 
-	spin_lock(&zone->pte_chain_freelist_lock);
-	pte_chain_push(zone, pte_chain);
-	spin_unlock(&zone->pte_chain_freelist_lock);
+	kmem_cache_free(pte_chain_cache, pte_chain);
 }
 
 /**
  * pte_chain_alloc - allocate a pte_chain struct
- * @zone: memory zone to allocate pte_chain for
  *
  * Returns a pointer to a fresh pte_chain structure. Allocates new
  * pte_chain structures as required.
  * Caller needs to hold the page's pte_chain_lock.
  */
-static inline struct pte_chain * pte_chain_alloc(zone_t * zone)
+static inline struct pte_chain * pte_chain_alloc(void)
 {
 	struct pte_chain * pte_chain;
 
-	spin_lock(&zone->pte_chain_freelist_lock);
-
-	/* Allocate new pte_chain structs as needed. */
-	if (!zone->pte_chain_freelist)
-		alloc_new_pte_chains(zone);
+	pte_chain = kmem_cache_alloc(pte_chain_cache, GFP_ATOMIC);
 
-	/* Grab the first pte_chain from the freelist. */
-	pte_chain = pte_chain_pop(zone);
-
-	spin_unlock(&zone->pte_chain_freelist_lock);
+	/* I don't think anybody managed to trigger this one -- Rik */
+	if (unlikely(pte_chain == NULL))
+		panic("fix pte_chain OOM handling\n");
 
 	return pte_chain;
 }
 
-/**
- * alloc_new_pte_chains - convert a free page to pte_chain structures
- * @zone: memory zone to allocate pte_chains for
- *
- * Grabs a free page and converts it to pte_chain structures. We really
- * should pre-allocate these earlier in the pagefault path or come up
- * with some other trick.
- *
- * Note that we cannot use the slab cache because the pte_chain structure
- * is way smaller than the minimum size of a slab cache allocation.
- * Caller needs to hold the zone->pte_chain_freelist_lock
- */
-static void alloc_new_pte_chains(zone_t *zone)
+void __init pte_chain_init(void)
 {
-	struct pte_chain * pte_chain = (void *) get_zeroed_page(GFP_ATOMIC);
-	int i = PAGE_SIZE / sizeof(struct pte_chain);
+	pte_chain_cache = kmem_cache_create(	"pte_chain",
+						sizeof(struct pte_chain),
+						0,
+						0,
+						NULL,
+						NULL);
 
-	if (pte_chain) {
-		for (; i-- > 0; pte_chain++)
-			pte_chain_push(zone, pte_chain);
-	} else {
-		/* Yeah yeah, I'll fix the pte_chain allocation ... */
-		panic("Fix pte_chain allocation!\n");
-	}
+	if (!pte_chain_cache)
+		panic("failed to create pte_chain cache!\n");
 }
--- linux-2.4.19/include/linux/mmzone.h.pteslab	2002-11-13 08:48:31.000000000 -0200
+++ linux-2.4.19/include/linux/mmzone.h	2002-11-13 09:22:16.000000000 -0200
@@ -63,8 +63,6 @@
 	struct list_head	inactive_dirty_list;
 	struct list_head	inactive_clean_list;
 	free_area_t		free_area[MAX_ORDER];
-	spinlock_t		pte_chain_freelist_lock;
-	struct pte_chain	*pte_chain_freelist;
 
 	/*
 	 * wait_table           -- the array holding the hash table
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
