From: davej@suse.de
Date: Fri, 13 Oct 2000 01:20:23 +0100 (BST)
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
Message-ID: <Pine.LNX.4.21.0010130114090.13322-100000@neo.local>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tytso@mit.edu, Linus Torvalds <torvalds@transmeta.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 9. To Do
>     * mm->rss is modified in some places without holding the
>       page_table_lock (sct)

Any of the mm gurus give the patch below a quick once over ?
Is this adequate, or is there more to this than the description implies?

regards,

Dave.

-- 
| Dave Jones <davej@suse.de>  http://www.suse.de/~davej
| SuSE Labs


diff -urN --exclude-from=/home/davej/.exclude linux/mm/memory.c linux.dj/mm/memory.c
--- linux/mm/memory.c	Sat Sep 16 00:51:21 2000
+++ linux.dj/mm/memory.c	Wed Oct 11 23:41:10 2000
@@ -370,7 +370,6 @@
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
-	spin_unlock(&mm->page_table_lock);
 	/*
 	 * Update rss for the mm_struct (not necessarily current->mm)
 	 * Notice that rss is an unsigned long.
@@ -379,6 +378,7 @@
 		mm->rss -= freed;
 	else
 		mm->rss = 0;
+	spin_unlock(&mm->page_table_lock);
 }
 
 
@@ -1074,7 +1074,9 @@
 		flush_icache_page(vma, page);
 	}
 
+	spin_lock(&mm->page_table_lock);
 	mm->rss++;
+	spin_unlock(&mm->page_table_lock);
 
 	pte = mk_pte(page, vma->vm_page_prot);
 
@@ -1113,7 +1115,9 @@
 			return -1;
 		clear_user_highpage(page, addr);
 		entry = pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
+		spin_lock(&mm->page_table_lock);
 		mm->rss++;
+		spin_unlock(&mm->page_table_lock);
 		flush_page_to_ram(page);
 	}
 	set_pte(page_table, entry);
@@ -1152,7 +1156,9 @@
 		return 0;
 	if (new_page == NOPAGE_OOM)
 		return -1;
+	spin_lock(&mm->page_table_lock);
 	++mm->rss;
+	spin_unlock(&mm->page_table_lock);
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
 	 * due to the bad i386 page protection. But it's valid
diff -urN --exclude-from=/home/davej/.exclude linux/mm/mmap.c linux.dj/mm/mmap.c
--- linux/mm/mmap.c	Tue Aug 29 20:41:12 2000
+++ linux.dj/mm/mmap.c	Wed Oct 11 23:48:30 2000
@@ -844,7 +844,9 @@
 	vmlist_modify_lock(mm);
 	mm->mmap = mm->mmap_avl = mm->mmap_cache = NULL;
 	vmlist_modify_unlock(mm);
+	spin_lock (&mm->page_table_lock);
 	mm->rss = 0;
+	spin_unlock (&mm->page_table_lock);
 	mm->total_vm = 0;
 	mm->locked_vm = 0;
 	while (mpnt) {
diff -urN --exclude-from=/home/davej/.exclude linux/mm/vmscan.c linux.dj/mm/vmscan.c
--- linux/mm/vmscan.c	Mon Oct  2 20:02:20 2000
+++ linux.dj/mm/vmscan.c	Wed Oct 11 23:46:01 2000
@@ -102,7 +102,9 @@
 		set_pte(page_table, swp_entry_to_pte(entry));
 drop_pte:
 		UnlockPage(page);
+		spin_lock (&mm->page_table_lock);
 		mm->rss--;
+		spin_unlock (&mm->page_table_lock);
 		flush_tlb_page(vma, address);
 		deactivate_page(page);
 		page_cache_release(page);
@@ -170,7 +172,9 @@
 		struct file *file = vma->vm_file;
 		if (file) get_file(file);
 		pte_clear(page_table);
+		spin_lock (&mm->page_table_lock);
 		mm->rss--;
+		spin_unlock (&mm->page_table_lock);
 		flush_tlb_page(vma, address);
 		vmlist_access_unlock(mm);
 		error = swapout(page, file);
@@ -202,7 +206,9 @@
 	add_to_swap_cache(page, entry);
 
 	/* Put the swap entry into the pte after the page is in swapcache */
+	spin_lock (&mm->page_table_lock);
 	mm->rss--;
+	spin_unlock (&mm->page_table_lock);
 	set_pte(page_table, swp_entry_to_pte(entry));
 	flush_tlb_page(vma, address);
 	vmlist_access_unlock(mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
