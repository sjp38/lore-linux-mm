From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 24 May 2007 13:29:13 -0400
Message-Id: <20070524172913.13933.45017.sendpatchset@localhost>
In-Reply-To: <20070524172821.13933.80093.sendpatchset@localhost>
References: <20070524172821.13933.80093.sendpatchset@localhost>
Subject: [PATCH/RFC 7/8] Mapped File Policy: fix migration of private mappings
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nish.aravamudan@gmail.com, clameter@sgi.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Mapped File Policy  7/8 - fix migration of private mappings

Against 2.6.22-rc2-mm1

Don't allow migration of file backed pages mapped with
MAP_PRIVATE if the file has a shared policy.  Rather, only
migrate any private, anon copies that the task has "COWed".

Define a new internal flag that we set in check_range() for
private mappings of files with shared policy.  Then, 
migrate_page_add() will skip non-anon pages when this flag
is set.

May also be able to use this flag to force unmapping of
anon pages that may be shared with relatives during automigrate
on internode task migration--e.g., by using:
	MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_ANON_ONLY
But, that's the subject of a different patch series.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-05-23 11:34:46.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-05-23 11:34:50.000000000 -0400
@@ -102,6 +102,7 @@
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
 #define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
+#define MPOL_MF_MOVE_ANON_ONLY (MPOL_MF_INTERNAL << 3)
 
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sp_cache;
@@ -362,13 +363,19 @@ check_range(struct mm_struct *mm, unsign
 		     ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
 				vma_migratable(vma)))) {
 			unsigned long endvma = vma->vm_end;
+			unsigned long anononly = 0;
 
 			if (endvma > end)
 				endvma = end;
 			if (vma->vm_start > start)
 				start = vma->vm_start;
+
+			if (vma->vm_file && !(vma->vm_flags & VM_SHARED) &&
+					vma->vm_file->f_mapping->spolicy)
+				anononly = MPOL_MF_MOVE_ANON_ONLY;
+
 			err = check_pgd_range(vma, start, endvma, nodes,
-						flags, private);
+						flags|anononly, private);
 			if (err) {
 				first = ERR_PTR(err);
 				break;
@@ -621,9 +628,11 @@ static void migrate_page_add(struct page
 				unsigned long flags)
 {
 	/*
-	 * Avoid migrating a page that is shared with others.
+	 * Avoid migrating a file backed page in a private mapping or
+	 * a page that is shared with others.
 	 */
-	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1)
+	if ((!(flags & MPOL_MF_MOVE_ANON_ONLY) || PageAnon(page)) &&
+		((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1))
 		isolate_lru_page(page, pagelist);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
