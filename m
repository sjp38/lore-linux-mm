Received: from northrelay01.pok.ibm.com (northrelay01.pok.ibm.com [9.56.224.149])
	by e1.ny.us.ibm.com (8.12.2/8.12.2) with ESMTP id g69Ia2g5177198
	for <linux-mm@kvack.org>; Tue, 9 Jul 2002 14:36:02 -0400
Received: from baldur.austin.ibm.com (baldur.austin.ibm.com [9.53.216.148])
	by northrelay01.pok.ibm.com (8.11.1m3/NCO/VER6.1) with ESMTP id g69IZwT47086
	for <linux-mm@kvack.org>; Tue, 9 Jul 2002 14:35:59 -0400
Date: Tue, 09 Jul 2002 13:35:46 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH] Optimize away pte_chains for single mappings
Message-ID: <55160000.1026239746@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1859459384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========1859459384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Here's a patch that optimizes out using a struct pte_chain when there's
only one mapping for that page.  It re-uses the pte_chain pointer in struct
page, with an appropriate flag.  The patch is based on Rik's latest 2.5.25
rmap patch.

I've done basic testing on it (it boots and runs simple commands).

This version of the patch uses an anonymous union, so it only builds with
gcc 3.x.  I'm working on an alternate version of the patch, but wanted to
get this one out for people to look at.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1859459384==========
Content-Type: text/plain; charset=iso-8859-1; name="rmap-opt-2.5.25.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="rmap-opt-2.5.25.diff"; size=6085

--- linux-2.5.25-rmap/./include/linux/mm.h	Mon Jul  8 15:37:35 2002
+++ linux-2.5.25-rmap-opt/./include/linux/mm.h	Tue Jul  9 13:28:32 2002
@@ -157,8 +157,11 @@
 					   updated asynchronously */
 	struct list_head lru;		/* Pageout list, eg. active_list;
 					   protected by pagemap_lru_lock !! */
-	struct pte_chain * pte_chain;	/* Reverse pte mapping pointer.
+	union {
+		struct pte_chain * pte_chain;	/* Reverse pte mapping pointer.
 					 * protected by PG_chainlock */
+		pte_t		 * pte_direct;
+	};
 	unsigned long private;		/* mapping-private opaque data */
=20
 	/*
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
--- linux-2.5.25-rmap/./mm/rmap.c	Mon Jul  8 15:37:35 2002
+++ linux-2.5.25-rmap-opt/./mm/rmap.c	Tue Jul  9 12:46:07 2002
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
+		for (pc =3D page->pte_chain; pc; pc =3D pc->next) {
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
+			for (pc =3D page->pte_chain; pc; pc =3D pc->next) {
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
+		page->pte_chain =3D pte_chain;
+		ClearPageDirect(page);
+	}
+	if (page->pte_chain) {
+		/* Hook up the pte_chain to the page. */
+		pte_chain =3D pte_chain_alloc();
+		pte_chain->ptep =3D ptep;
+		pte_chain->next =3D page->pte_chain;
+		page->pte_chain =3D pte_chain;
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
+		for (pc =3D page->pte_chain; pc; prev_pc =3D pc, pc =3D pc->next) {
+			if (pc->ptep =3D=3D ptep) {
+				pte_chain_free(pc, prev_pc, page);
+				/* Check whether we can convert to direct */
+				pc =3D page->pte_chain;
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
+		for (pc =3D page->pte_chain; pc; pc =3D pc->next)
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
+		for (pc =3D page->pte_chain; pc; pc =3D next_pc) {
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
+		pc =3D page->pte_chain;
+		if (pc && !pc->next) {
+			page->pte_direct =3D pc->ptep;
+			SetPageDirect(page);
+			pte_chain_free(pc, NULL, NULL);
 		}
 	}
=20

--==========1859459384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
