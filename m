Date: Mon, 29 Jan 2001 22:43:11 +0100
From: Rasmus Andersen <rasmus@jaquet.dk>
Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11)
Message-ID: <20010129224311.H603@jaquet.dk>
References: <20010129222337.F603@jaquet.dk> <Pine.LNX.4.21.0101291929120.1321-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0101291929120.1321-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Jan 29, 2001 at 07:30:01PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 29, 2001 at 07:30:01PM -0200, Rik van Riel wrote:
> On Mon, 29 Jan 2001, Rasmus Andersen wrote:
> 
> > Please comment. Or else I will continue to sumbit it :)
> 
> The following will hang the kernel on SMP, since you're
> already holding the spinlock here. Try compiling with
> CONFIG_SMP and see what happens...

You are right. Sloppy research by me :(

New patch below with the vmscan part removed.


diff -aur linux-2.4.1-pre11-clean/mm/memory.c linux/mm/memory.c
--- linux-2.4.1-pre11-clean/mm/memory.c	Sun Jan 28 20:53:13 2001
+++ linux/mm/memory.c	Sun Jan 28 22:43:04 2001
@@ -377,7 +377,6 @@
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
-	spin_unlock(&mm->page_table_lock);
 	/*
 	 * Update rss for the mm_struct (not necessarily current->mm)
 	 * Notice that rss is an unsigned long.
@@ -386,6 +385,7 @@
 		mm->rss -= freed;
 	else
 		mm->rss = 0;
+	spin_unlock(&mm->page_table_lock);
 }
 
 
@@ -1038,7 +1038,9 @@
 		flush_icache_page(vma, page);
 	}
 
+	spin_lock(&mm->page_table_lock);
 	mm->rss++;
+	spin_unlock(&mm->page_table_lock);
 
 	pte = mk_pte(page, vma->vm_page_prot);
 
@@ -1072,7 +1074,9 @@
 			return -1;
 		clear_user_highpage(page, addr);
 		entry = pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
+		spin_lock(&mm->page_table_lock);
 		mm->rss++;
+		spin_unlock(&mm->page_table_lock);
 		flush_page_to_ram(page);
 	}
 	set_pte(page_table, entry);
@@ -1111,7 +1115,9 @@
 		return 0;
 	if (new_page == NOPAGE_OOM)
 		return -1;
+	spin_lock(&mm->page_table_lock);
 	++mm->rss;
+	spin_unlock(&mm->page_table_lock);
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
 	 * due to the bad i386 page protection. But it's valid
diff -aur linux-2.4.1-pre11-clean/mm/mmap.c linux/mm/mmap.c
--- linux-2.4.1-pre11-clean/mm/mmap.c	Sat Dec 30 18:35:19 2000
+++ linux/mm/mmap.c	Sun Jan 28 22:43:04 2001
@@ -879,8 +879,8 @@
 	spin_lock(&mm->page_table_lock);
 	mpnt = mm->mmap;
 	mm->mmap = mm->mmap_avl = mm->mmap_cache = NULL;
-	spin_unlock(&mm->page_table_lock);
 	mm->rss = 0;
+	spin_unlock(&mm->page_table_lock);
 	mm->total_vm = 0;
 	mm->locked_vm = 0;
 	while (mpnt) {
diff -aur linux-2.4.1-pre11-clean/mm/swapfile.c linux/mm/swapfile.c
--- linux-2.4.1-pre11-clean/mm/swapfile.c	Fri Dec 29 23:07:24 2000
+++ linux/mm/swapfile.c	Sun Jan 28 22:43:04 2001
@@ -231,7 +231,9 @@
 	set_pte(dir, pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 	swap_free(entry);
 	get_page(page);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	++vma->vm_mm->rss;
+	spin_unlock(&vma->vm_mm->page_table_lock);
 }
 
 static inline void unuse_pmd(struct vm_area_struct * vma, pmd_t *dir,

-- 
        Rasmus(rasmus@jaquet.dk)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
