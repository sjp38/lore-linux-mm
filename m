Received: from northrelay01.pok.ibm.com (northrelay01.pok.ibm.com [9.56.224.149])
	by e2.ny.us.ibm.com (8.12.2/8.12.2) with ESMTP id g69J4Ge8097102
	for <linux-mm@kvack.org>; Tue, 9 Jul 2002 15:04:16 -0400
Received: from baldur.austin.ibm.com (baldur.austin.ibm.com [9.53.216.148])
	by northrelay01.pok.ibm.com (8.11.1m3/NCO/VER6.1) with ESMTP id g69J4ET33476
	for <linux-mm@kvack.org>; Tue, 9 Jul 2002 15:04:14 -0400
Date: Tue, 09 Jul 2002 14:04:14 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH] Optimize out pte_chain take two
Message-ID: <59590000.1026241454@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========906520887=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========906520887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Here's a version of my pte_chain removal patch that does not use anonymous
unions, so it'll compile with gcc 2.95.  Once again, it's based on Rik's
rmap-2.5.25-akpmtested.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========906520887==========
Content-Type: text/plain; charset=iso-8859-1; name="rmap-opt-2.5.25.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="rmap-opt-2.5.25.diff"; size=8482

--- linux-2.5.25-rmap/./include/linux/mm.h	Mon Jul  8 15:37:35 2002
+++ linux-2.5.25-rmap-opt/./include/linux/mm.h	Tue Jul  9 13:41:11 2002
@@ -157,8 +157,11 @@
 					   updated asynchronously */
 	struct list_head lru;		/* Pageout list, eg. active_list;
 					   protected by pagemap_lru_lock !! */
-	struct pte_chain * pte_chain;	/* Reverse pte mapping pointer.
+	union {
+		struct pte_chain * _pte_chain;	/* Reverse pte mapping pointer.
 					 * protected by PG_chainlock */
+		pte_t		 * _pte_direct;
+	} _pte_union;
 	unsigned long private;		/* mapping-private opaque data */
=20
 	/*
@@ -176,6 +179,9 @@
 					   not kmapped, ie. highmem) */
 #endif /* CONFIG_HIGMEM || WANT_PAGE_VIRTUAL */
 };
+
+#define	pte__chain	_pte_union._pte_chain
+#define	pte_direct	_pte_union._pte_direct
=20
 /*
  * Methods to modify the page usage count.
--- linux-2.5.25-rmap/./include/linux/page-flags.h	Mon Jul  8 15:37:35 2002
+++ linux-2.5.25-rmap-opt/./include/linux/page-flags.h	Tue Jul  9 10:31:28 =
2002
@@ -66,6 +66,7 @@
 #define PG_writeback		13	/* Page is under writeback */
 #define PG_nosave		15	/* Used for system suspend/resume */
 #define PG_chainlock		16	/* lock bit for ->pte_chain */
+#define PG_direct		17	/* ->pte_chain points directly at pte */
=20
 /*
  * Global page accounting.  One instance per CPU.
@@ -216,6 +217,12 @@
 #define TestSetPageNosave(page)	test_and_set_bit(PG_nosave, =
&(page)->flags)
 #define ClearPageNosave(page)		clear_bit(PG_nosave, &(page)->flags)
 #define TestClearPageNosave(page)	test_and_clear_bit(PG_nosave, =
&(page)->flags)
+
+#define PageDirect(page)	test_bit(PG_direct, &(page)->flags)
+#define SetPageDirect(page)	set_bit(PG_direct, &(page)->flags)
+#define TestSetPageDirect(page)	test_and_set_bit(PG_direct, =
&(page)->flags)
+#define ClearPageDirect(page)		clear_bit(PG_direct, &(page)->flags)
+#define TestClearPageDirect(page)	test_and_clear_bit(PG_direct, =
&(page)->flags)
=20
 /*
  * inlines for acquisition and release of PG_chainlock
--- linux-2.5.25-rmap/./mm/page_alloc.c	Mon Jul  8 15:37:35 2002
+++ linux-2.5.25-rmap-opt/./mm/page_alloc.c	Tue Jul  9 13:43:46 2002
@@ -92,7 +92,7 @@
 	BUG_ON(PageLRU(page));
 	BUG_ON(PageActive(page));
 	BUG_ON(PageWriteback(page));
-	BUG_ON(page->pte_chain !=3D NULL);
+	BUG_ON(page->pte__chain !=3D NULL);
 	if (PageDirty(page))
 		ClearPageDirty(page);
 	BUG_ON(page_count(page) !=3D 0);
--- linux-2.5.25-rmap/./mm/vmscan.c	Mon Jul  8 15:37:35 2002
+++ linux-2.5.25-rmap-opt/./mm/vmscan.c	Tue Jul  9 13:42:38 2002
@@ -48,7 +48,7 @@
 	struct address_space *mapping =3D page->mapping;
=20
 	/* Page is in somebody's page tables. */
-	if (page->pte_chain)
+	if (page->pte__chain)
 		return 1;
=20
 	/* XXX: does this happen ? */
@@ -151,7 +151,7 @@
 		 *
 		 * XXX: implement swap clustering ?
 		 */
-		if (page->pte_chain && !page->mapping && !PagePrivate(page)) {
+		if (page->pte__chain && !page->mapping && !PagePrivate(page)) {
 			page_cache_get(page);
 			pte_chain_unlock(page);
 			spin_unlock(&pagemap_lru_lock);
@@ -171,7 +171,7 @@
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page->pte_chain) {
+		if (page->pte__chain) {
 			switch (try_to_unmap(page)) {
 				case SWAP_ERROR:
 				case SWAP_FAIL:
@@ -348,7 +348,7 @@
 		entry =3D entry->prev;
=20
 		pte_chain_lock(page);
-		if (page->pte_chain && page_referenced(page)) {
+		if (page->pte__chain && page_referenced(page)) {
 			list_del(&page->lru);
 			list_add(&page->lru, &active_list);
 			pte_chain_unlock(page);
--- linux-2.5.25-rmap/./mm/rmap.c	Mon Jul  8 15:37:35 2002
+++ linux-2.5.25-rmap-opt/./mm/rmap.c	Tue Jul  9 13:41:47 2002
@@ -13,7 +13,7 @@
=20
 /*
  * Locking:
- * - the page->pte_chain is protected by the PG_chainlock bit,
+ * - the page->pte__chain is protected by the PG_chainlock bit,
  *   which nests within the pagemap_lru_lock, then the
  *   mm->page_table_lock, and then the page lock.
  * - because swapout locking is opposite to the locking order
@@ -71,10 +71,15 @@
 	if (TestClearPageReferenced(page))
 		referenced++;
=20
-	/* Check all the page tables mapping this page. */
-	for (pc =3D page->pte_chain; pc; pc =3D pc->next) {
-		if (ptep_test_and_clear_young(pc->ptep))
+	if (PageDirect(page)) {
+		if (ptep_test_and_clear_young(page->pte_direct))
 			referenced++;
+	} else {
+		/* Check all the page tables mapping this page. */
+		for (pc =3D page->pte__chain; pc; pc =3D pc->next) {
+			if (ptep_test_and_clear_young(pc->ptep))
+				referenced++;
+		}
 	}
 	return referenced;
 }
@@ -108,22 +113,39 @@
 	pte_chain_lock(page);
 	{
 		struct pte_chain * pc;
-		for (pc =3D page->pte_chain; pc; pc =3D pc->next) {
-			if (pc->ptep =3D=3D ptep)
+		if (PageDirect(page)) {
+			if (page->pte_direct =3D=3D ptep)
 				BUG();
+		} else {
+			for (pc =3D page->pte__chain; pc; pc =3D pc->next) {
+				if (pc->ptep =3D=3D ptep)
+					BUG();
+			}
 		}
 	}
 	pte_chain_unlock(page);
 #endif
=20
-	pte_chain =3D pte_chain_alloc();
-
 	pte_chain_lock(page);
=20
-	/* Hook up the pte_chain to the page. */
-	pte_chain->ptep =3D ptep;
-	pte_chain->next =3D page->pte_chain;
-	page->pte_chain =3D pte_chain;
+	if (PageDirect(page)) {
+		/* Convert a direct pointer into a pte_chain */
+		pte_chain =3D pte_chain_alloc();
+		pte_chain->ptep =3D page->pte_direct;
+		pte_chain->next =3D NULL;
+		page->pte__chain =3D pte_chain;
+		ClearPageDirect(page);
+	}
+	if (page->pte__chain) {
+		/* Hook up the pte_chain to the page. */
+		pte_chain =3D pte_chain_alloc();
+		pte_chain->ptep =3D ptep;
+		pte_chain->next =3D page->pte__chain;
+		page->pte__chain =3D pte_chain;
+	} else {
+		page->pte_direct =3D ptep;
+		SetPageDirect(page);
+	}
=20
 	pte_chain_unlock(page);
 }
@@ -149,18 +171,38 @@
 		return;
=20
 	pte_chain_lock(page);
-	for (pc =3D page->pte_chain; pc; prev_pc =3D pc, pc =3D pc->next) {
-		if (pc->ptep =3D=3D ptep) {
-			pte_chain_free(pc, prev_pc, page);
+
+	if (PageDirect(page)) {
+		if (page->pte_direct =3D=3D ptep) {
+			page->pte_direct =3D NULL;
+			ClearPageDirect(page);
 			goto out;
 		}
+	} else {
+		for (pc =3D page->pte__chain; pc; prev_pc =3D pc, pc =3D pc->next) {
+			if (pc->ptep =3D=3D ptep) {
+				pte_chain_free(pc, prev_pc, page);
+				/* Check whether we can convert to direct */
+				pc =3D page->pte__chain;
+				if (!pc->next) {
+					page->pte_direct =3D pc->ptep;
+					SetPageDirect(page);
+					pte_chain_free(pc, NULL, NULL);
+				}
+				goto out;
+			}
+		}
 	}
 #ifdef DEBUG_RMAP
 	/* Not found. This should NEVER happen! */
 	printk(KERN_ERR "page_remove_rmap: pte_chain %p not present.\n", ptep);
 	printk(KERN_ERR "page_remove_rmap: only found: ");
-	for (pc =3D page->pte_chain; pc; pc =3D pc->next)
-		printk("%p ", pc->ptep);
+	if (PageDirect(page)) {
+		printk("%p ", page->pte_direct);
+	} else {
+		for (pc =3D page->pte__chain; pc; pc =3D pc->next)
+			printk("%p ", pc->ptep);
+	}
 	printk("\n");
 	printk(KERN_ERR "page_remove_rmap: driver cleared PG_reserved ?\n");
 #endif
@@ -270,22 +312,42 @@
 	if (!page->mapping)
 		BUG();
=20
-	for (pc =3D page->pte_chain; pc; pc =3D next_pc) {
-		next_pc =3D pc->next;
-		switch (try_to_unmap_one(page, pc->ptep)) {
+	if (PageDirect(page)) {
+		switch (ret =3D try_to_unmap_one(page, page->pte_direct)) {
 			case SWAP_SUCCESS:
-				/* Free the pte_chain struct. */
-				pte_chain_free(pc, prev_pc, page);
-				break;
+				page->pte_direct =3D NULL;
+				ClearPageDirect(page);
+				return ret;
 			case SWAP_AGAIN:
-				/* Skip this pte, remembering status. */
-				prev_pc =3D pc;
-				ret =3D SWAP_AGAIN;
-				continue;
 			case SWAP_FAIL:
-				return SWAP_FAIL;
 			case SWAP_ERROR:
-				return SWAP_ERROR;
+				return ret;
+		}
+	} else {		
+		for (pc =3D page->pte__chain; pc; pc =3D next_pc) {
+			next_pc =3D pc->next;
+			switch (try_to_unmap_one(page, pc->ptep)) {
+				case SWAP_SUCCESS:
+					/* Free the pte_chain struct. */
+					pte_chain_free(pc, prev_pc, page);
+					break;
+				case SWAP_AGAIN:
+					/* Skip this pte, remembering status. */
+					prev_pc =3D pc;
+					ret =3D SWAP_AGAIN;
+					continue;
+				case SWAP_FAIL:
+					return SWAP_FAIL;
+				case SWAP_ERROR:
+					return SWAP_ERROR;
+			}
+		}
+		/* Check whether we can convert to direct pte pointer */
+		pc =3D page->pte__chain;
+		if (pc && !pc->next) {
+			page->pte_direct =3D pc->ptep;
+			SetPageDirect(page);
+			pte_chain_free(pc, NULL, NULL);
 		}
 	}
=20
@@ -336,7 +398,7 @@
 	if (prev_pte_chain)
 		prev_pte_chain->next =3D pte_chain->next;
 	else if (page)
-		page->pte_chain =3D pte_chain->next;
+		page->pte__chain =3D pte_chain->next;
=20
 	spin_lock(&pte_chain_freelist_lock);
 	pte_chain_push(pte_chain);

--==========906520887==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
