Date: Mon, 19 Mar 2001 23:03:02 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 3rd version of R/W mmap_sem patch available
In-Reply-To: <Pine.LNX.4.31.0103192233230.1056-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.31.0103192300570.1195-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Rik van Riel <riel@conectiva.com.br>, Mike Galbraith <mikeg@wen-online.de>, linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, MOLNAR Ingo <mingo@chiara.elte.hu>
List-ID: <linux-mm.kvack.org>


On Mon, 19 Mar 2001, Linus Torvalds wrote:
>
> Although I'd prefer to see somebody check out the other architectures,
> to do the (pretty trivial) changes to make them support properly
> threaded page faults. I'd hate to have two pre-patches without any
> input from other architectures..

These are the trivial fixes to make -pre5 be spinlock-debugging-clean and
fix the missing unlock in copy_page_range(). I'd really like to hear from
architecture maintainers if possible.

		Linus

----
diff -u --recursive --new-file pre5/linux/arch/i386/mm/ioremap.c linux/arch/i386/mm/ioremap.c
--- pre5/linux/arch/i386/mm/ioremap.c	Mon Mar 19 18:49:18 2001
+++ linux/arch/i386/mm/ioremap.c	Mon Mar 19 21:25:16 2001
@@ -62,6 +62,7 @@
 static int remap_area_pages(unsigned long address, unsigned long phys_addr,
 				 unsigned long size, unsigned long flags)
 {
+	int error;
 	pgd_t * dir;
 	unsigned long end = address + size;

@@ -70,17 +71,21 @@
 	flush_cache_all();
 	if (address >= end)
 		BUG();
+	spin_lock(&init_mm.page_table_lock);
 	do {
 		pmd_t *pmd;
 		pmd = pmd_alloc(&init_mm, dir, address);
+		error = -ENOMEM;
 		if (!pmd)
-			return -ENOMEM;
+			break;
 		if (remap_area_pmd(pmd, address, end - address,
 					 phys_addr + address, flags))
-			return -ENOMEM;
+			break;
+		error = 0;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
+	spin_unlock(&init_mm.page_table_lock);
 	flush_tlb_all();
 	return 0;
 }
diff -u --recursive --new-file pre5/linux/mm/memory.c linux/mm/memory.c
--- pre5/linux/mm/memory.c	Mon Mar 19 18:49:20 2001
+++ linux/mm/memory.c	Mon Mar 19 22:49:39 2001
@@ -160,6 +160,7 @@
 	src_pgd = pgd_offset(src, address)-1;
 	dst_pgd = pgd_offset(dst, address)-1;

+	spin_lock(&dst->page_table_lock);
 	for (;;) {
 		pmd_t * src_pmd, * dst_pmd;

@@ -178,7 +179,6 @@
 			continue;
 		}

-		spin_lock(&dst->page_table_lock);
 		src_pmd = pmd_offset(src_pgd, address);
 		dst_pmd = pmd_alloc(dst, dst_pgd, address);
 		if (!dst_pmd)
@@ -247,13 +247,10 @@
 cont_copy_pmd_range:	src_pmd++;
 			dst_pmd++;
 		} while ((unsigned long)src_pmd & PMD_TABLE_MASK);
-		spin_unlock(&dst->page_table_lock);
 	}
-out:
-	return 0;
-
 out_unlock:
 	spin_unlock(&src->page_table_lock);
+out:
 	spin_unlock(&dst->page_table_lock);
 	return 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
