Date: Sat, 6 Jul 2002 12:06:55 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH][RFT](2) minimal rmap for 2.5 - akpm tested
In-Reply-To: <3D268E19.B68559F6@zip.com.au>
Message-ID: <Pine.LNX.4.44.0207061205001.1157-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 5 Jul 2002, Andrew Morton wrote:
>
> The box died, but not due to rmap.  We have a lock ranking
> bug:
>
>         do_exit
>         ->mmput
>           ->exit_mmap                           page_table_lock
>             ->removed_shared_vm_struct
>               ->lock_vma_mappings               i_shared_lock

I _think_ we should just move the remove_shared_vm_struct() down into the
case where we're closing the mapping, ie something like the appended.

That way we _only_ do the actual page table stuff under the page table
lock, and do all the generic VM/FS stuff outside the lock.

Comments?

		Linus

-------------------------------
--- 1.34/mm/mmap.c	Thu Jun 27 00:35:55 2002
+++ edited/mm/mmap.c	Sat Jul  6 12:06:02 2002
@@ -1121,7 +1121,6 @@
 		unsigned long end = mpnt->vm_end;

 		mm->map_count--;
-		remove_shared_vm_struct(mpnt);
 		unmap_page_range(tlb, mpnt, start, end);
 		mpnt = mpnt->vm_next;
 	}
@@ -1148,6 +1147,7 @@
 	 */
 	while (mpnt) {
 		struct vm_area_struct * next = mpnt->vm_next;
+		remove_shared_vm_struct(mpnt);
 		if (mpnt->vm_ops) {
 			if (mpnt->vm_ops->close)
 				mpnt->vm_ops->close(mpnt);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
