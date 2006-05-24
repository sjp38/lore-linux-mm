Date: Tue, 23 May 2006 18:15:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Allow migration of mlocked pages
Message-ID: <Pine.LNX.4.64.0605231801200.12600@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hugh clarified the role of VM_LOCKED. So we can now implement
page migration for mlocked pages.

Allow the migration of mlocked pages. This means that try_to_unmap
must unmap mlocked pages in the migration case.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm3/mm/rmap.c
===================================================================
--- linux-2.6.17-rc4-mm3.orig/mm/rmap.c	2006-05-23 15:10:22.484505490 -0700
+++ linux-2.6.17-rc4-mm3/mm/rmap.c	2006-05-23 18:13:25.532178041 -0700
@@ -626,9 +626,8 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte)
-				&& !migration)) {
+	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
+			(ptep_clear_flush_young(vma, address, pte)))) {
 		ret = SWAP_FAIL;
 		goto out_unmap;
 	}
@@ -835,7 +834,7 @@ static int try_to_unmap_file(struct page
 
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-		if (vma->vm_flags & VM_LOCKED)
+		if ((vma->vm_flags & VM_LOCKED) && !migration)
 			continue;
 		cursor = (unsigned long) vma->vm_private_data;
 		if (cursor > max_nl_cursor)
@@ -869,7 +868,7 @@ static int try_to_unmap_file(struct page
 	do {
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
 						shared.vm_set.list) {
-			if (vma->vm_flags & VM_LOCKED)
+			if ((vma->vm_flags & VM_LOCKED) && !migration)
 				continue;
 			cursor = (unsigned long) vma->vm_private_data;
 			while ( cursor < max_nl_cursor &&
Index: linux-2.6.17-rc4-mm3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc4-mm3.orig/mm/migrate.c	2006-05-23 15:10:24.505864687 -0700
+++ linux-2.6.17-rc4-mm3/mm/migrate.c	2006-05-23 17:27:20.617652640 -0700
@@ -615,15 +615,13 @@ static int unmap_and_move(new_page_t get
 	/*
 	 * Establish migration ptes or remove ptes
 	 */
-	if (try_to_unmap(page, 1) != SWAP_FAIL) {
-		if (!page_mapped(page))
-			rc = move_to_new_page(newpage, page);
-	} else
-		/* A vma has VM_LOCKED set -> permanent failure */
-		rc = -EPERM;
+	try_to_unmap(page, 1);
+	if (!page_mapped(page))
+		rc = move_to_new_page(newpage, page);
 
 	if (rc)
 		remove_migration_ptes(page, page);
+
 unlock:
 	unlock_page(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
