From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199909072027.NAA23624@google.engr.sgi.com>
Subject: [PATCH] [RFT] kanoj-mm16-2.3.16 rawio fixes
Date: Tue, 7 Sep 1999 13:27:51 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, sct@redhat.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus/Stephen,

Here's a couple of fixes to the vm part of rawio. Let me prepend 
a little explanation as to why each of this is needed.

1. map_user_kiobuf must enforce a security check that the caller
is not trying to do raw-io into read-only memory (else it could
mmap a readonly file, then destroy the file contents by doing 
rawio into it). The other changes to map_user_kiobuf are mostly
picked from the fault handling code before it invokes handle_mm_fault.

2. unmap_kiobuf must unlock the page before freeing it (else, it
will catch the assert in __free_page). Also, unmap_kiobuf must
release any resources (like swap handles etc) associated with the
page, instead of just freeing the page. Specially important in
a clone'd environment, where one clone starts a rawio, and another
just unmaps the target vma, this will prevent resource leakage.

3. copy_page_range must break c-o-w for pages into which rawio is
in progress. To understand why, imagine clone C1 doing the rawio
into page P, whereas clone C2 is doing a fork. If C2 ends up marking
P c-o-w, then turns around and writes to the page, C1/C2 will get a
new page, thus loosing the contents of the rawio. This is something
that the app can not guard against, given that C2 might be writing
to the top half of the page, whereas C1 might be doing rawio into
the bottom half of the page. NOTE: the copy_page_range fix is *not
perfect*, since the PageLocking check might trigger for file pages
too (think which is the bigger evil and pick the other one). The 
problem is, there is no way to figure out whether a rawio is in progress 
in the current implementation. Instead of using the PG_locked bit 
to mark pages on which rawio is in flight, having a raw_count field 
in the page structure is a better way to keep track of this information, 
but even in that case, a 100% perfect fix to copy_page_range is not 
possible. Although, having a raw_count would mean multiple rawio's 
could be in flight on the same page (which I imagine is not a rare 
thing to be wanted by database apps), instead of the map_user_kiobuf 
code doing complicated repeat loops. Linus, I could look into this, 
if you are not inherently opposed to the idea of a raw_count field 
in the page structure. Let me know.

I will be out of email access for the next 7 days, so all responses
will be answered after that.

Thanks.

Kanoj

--- /usr/tmp/p_rdiff_a00CUW/memory.c	Tue Sep  7 12:49:38 1999
+++ linux/mm/memory.c	Tue Sep  7 11:45:10 1999
@@ -66,6 +66,17 @@
 	copy_bigpage(to, from);
 }
 
+static inline void break_cow(struct vm_area_struct * vma, unsigned long 
+		old_page, unsigned long new_page, unsigned long address, 
+		pte_t *page_table)
+{
+	copy_cow_page(old_page,new_page);
+	flush_page_to_ram(new_page);
+	flush_cache_page(vma, address);
+	set_pte(page_table, pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot))));
+	flush_tlb_page(vma, address);
+}
+
 mem_map_t * mem_map = NULL;
 
 /*
@@ -239,6 +250,20 @@
 				}
 				/* If it's a COW mapping, write protect it both in the parent and the child */
 				if (cow) {
+					/*
+					 * Raw io might be in progress on
+					 * this page via a different clone.
+					 * For dmaout, could still do cow,
+					 * except there's no way to make out.
+					 */
+					if (PageLocked(mem_map + page_nr)) {
+						unsigned long new_page =
+						   __get_free_page(GFP_BIGUSER);
+						if (!new_page)
+							goto nomem;
+						break_cow(vma, pte_page(pte), new_page, address, dst_pte);
+						goto cont_copy_pte_range;
+					}
 					pte = pte_wrprotect(pte);
 					set_pte(src_pte, pte);
 				}
@@ -446,6 +471,7 @@
 	int			doublepage = 0;
 	int			repeat = 0;
 	int			i;
+	int			datain = (rw == READ);
 	
 	/* Make sure the iobuf is not already mapped somewhere. */
 	if (iobuf->nr_pages)
@@ -478,8 +504,19 @@
 			vma = find_vma(current->mm, ptr);
 			if (!vma) 
 				goto out_unlock;
+			if (vma->vm_start > ptr) {
+				if (!(vma->vm_flags & VM_GROWSDOWN))
+					goto out_unlock;
+				if (expand_stack(vma, ptr))
+					goto out_unlock;
+			}
+			if (((datain) && (!(vma->vm_flags & VM_WRITE))) ||
+					(!(vma->vm_flags & VM_READ))) {
+				err = -EACCES;
+				goto out_unlock;
+			}
 		}
-		if (handle_mm_fault(current, vma, ptr, (rw==READ)) <= 0) 
+		if (handle_mm_fault(current, vma, ptr, datain) <= 0) 
 			goto out_unlock;
 		spin_lock(&mm->page_table_lock);
 		page = follow_page(ptr);
@@ -566,8 +603,8 @@
 		map = iobuf->maplist[i];
 		
 		if (map && iobuf->locked) {
-			__free_page(map);
 			UnlockPage(map);
+			free_page_and_swap_cache(page_address(map));
 		}
 	}
 	
@@ -824,12 +861,7 @@
 	if (pte_val(*page_table) == pte_val(pte)) {
 		if (PageReserved(page))
 			++vma->vm_mm->rss;
-		copy_cow_page(old_page,new_page);
-		flush_page_to_ram(new_page);
-		flush_cache_page(vma, address);
-		set_pte(page_table, pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot))));
-		flush_tlb_page(vma, address);
-
+		break_cow(vma, old_page, new_page, address, page_table);
 		/* Free the old page.. */
 		new_page = old_page;
 	}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
