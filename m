Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA11744
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 11:52:00 -0500
Date: Sat, 19 Dec 1998 17:46:12 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: PG_clean for shared mapping smart syncing
In-Reply-To: <Pine.LNX.3.96.981219173054.756A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.981219174511.964A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sat, 19 Dec 1998, Andrea Arcangeli wrote:

>previous update_shared_mappings() patch. So I think we could drop
>completly my last patch and return to my old code and solve the problem to
>handle the mmap_sem locking right...

Here the remainings cleanup/fixes...

Index: mm//filemap.c
===================================================================
RCS file: /var/cvs/linux/mm/filemap.c,v
retrieving revision 1.1.1.1.2.16
diff -u -r1.1.1.1.2.16 filemap.c
--- filemap.c	1998/12/19 16:38:04	1.1.1.1.2.16
+++ linux/mm/filemap.c	1998/12/19 16:43:44
@@ -30,6 +30,10 @@
  * Shared mappings now work. 15.8.1995  Bruno.
  */
 
+/*
+ * Some cleanup of filemap_sync_pte(). 19 Dec 1998, Andrea Arcangeli
+ */
+
 unsigned long page_cache_size = 0;
 struct page * page_hash_table[PAGE_HASH_SIZE];
 
@@ -1210,8 +1214,9 @@
 	unsigned long address, unsigned int flags)
 {
 	pte_t pte = *ptep;
-	unsigned long page;
+	unsigned long page = pte_page(pte);
 	int error;
+	struct page * map = mem_map + MAP_NR(page);
 
 	if (!(flags & MS_INVALIDATE)) {
 		if (!pte_present(pte))
@@ -1222,8 +1227,7 @@
 		flush_cache_page(vma, address);
 		set_pte(ptep, pte_mkclean(pte));
 		flush_tlb_page(vma, address);
-		page = pte_page(pte);
-		atomic_inc(&mem_map[MAP_NR(page)].count);
+		atomic_inc(&map->count);
 	} else {
 		if (pte_none(pte))
 			return 0;
@@ -1234,14 +1238,13 @@
 			swap_free(pte_val(pte));
 			return 0;
 		}
-		page = pte_page(pte);
 		if (!pte_dirty(pte) || flags == MS_INVALIDATE) {
-			free_page(page);
+			__free_page(map);
 			return 0;
 		}
 	}
 	error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, page);
-	free_page(page);
+	__free_page(map);
 	return error;
 }
 
Index: mm//memory.c
===================================================================
RCS file: /var/cvs/linux/mm/memory.c,v
retrieving revision 1.1.1.1.2.3
diff -u -r1.1.1.1.2.3 memory.c
--- memory.c	1998/12/19 16:38:04	1.1.1.1.2.3
+++ linux/mm/memory.c	1998/12/19 16:42:25
@@ -33,6 +33,10 @@
  * 		Idea by Alex Bligh (alex@cconcepts.co.uk)
  */
 
+/*
+ * Some fix and cleanup to of do_wp_page(). 19 Dec 1998, Andrea Arcangeli
+ */
+
 #include <linux/mm.h>
 #include <linux/mman.h>
 #include <linux/swap.h>
@@ -623,11 +627,10 @@
 	unsigned long address, pte_t *page_table)
 {
 	pte_t pte;
-	unsigned long old_page, new_page;
+	unsigned long old_page;
 	struct page * page_map;
 	
 	pte = *page_table;
-	new_page = __get_free_page(GFP_USER);
 	/* Did someone else copy this page for us while we slept? */
 	if (pte_val(*page_table) != pte_val(pte))
 		goto end_wp_page;
@@ -645,11 +648,13 @@
 	 * Do we need to copy?
 	 */
 	if (is_page_shared(page_map)) {
+		unsigned long new_page;
 		unlock_kernel();
+		new_page = __get_free_page(GFP_USER);
 		if (!new_page)
 			return 0;
 
-		if (PageReserved(mem_map + MAP_NR(old_page)))
+		if (PageReserved(page_map))
 			++vma->vm_mm->rss;
 		copy_cow_page(old_page,new_page);
 		flush_page_to_ram(old_page);
@@ -670,16 +675,15 @@
 	flush_cache_page(vma, address);
 	set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
 	flush_tlb_page(vma, address);
+	return 1;
 end_wp_page:
-	if (new_page)
-		free_page(new_page);
+	unlock_kernel();
 	return 1;
 
 bad_wp_page:
+	unlock_kernel();
 	printk("do_wp_page: bogus page at address %08lx (%08lx)\n",address,old_page);
 	send_sig(SIGKILL, tsk, 1);
-	if (new_page)
-		free_page(new_page);
 	return 0;
 }
 


Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
