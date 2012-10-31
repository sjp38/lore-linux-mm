Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 822E66B0071
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 12:59:19 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1223572pad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:59:19 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 4/5] mm, highmem: makes flush_all_zero_pkmaps() return index of first flushed entry
Date: Thu,  1 Nov 2012 01:56:36 +0900
Message-Id: <1351702597-10795-5-git-send-email-js1304@gmail.com>
In-Reply-To: <1351702597-10795-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1351702597-10795-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Minchan Kim <minchan@kernel.org>

In current code, after flush_all_zero_pkmaps() is invoked,
then re-iterate all pkmaps. It can be optimized if flush_all_zero_pkmaps()
return index of first flushed entry. With this index,
we can immediately map highmem page to virtual address represented by index.
So change return type of flush_all_zero_pkmaps()
and return index of first flushed entry.

Additionally, update last_pkmap_nr to this index.
It is certain that entry which is below this index is occupied by other mapping,
therefore updating last_pkmap_nr to this index is reasonable optimization.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index ef788b5..97ad208 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -32,6 +32,7 @@ static inline void invalidate_kernel_vmap_range(void *vaddr, int size)
 
 #ifdef CONFIG_HIGHMEM
 #include <asm/highmem.h>
+#define PKMAP_INVALID_INDEX (LAST_PKMAP)
 
 /* declarations for linux/mm/highmem.c */
 unsigned int nr_free_highpages(void);
diff --git a/mm/highmem.c b/mm/highmem.c
index d98b0a9..b365f7b 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -106,10 +106,10 @@ struct page *kmap_to_page(void *vaddr)
 	return virt_to_page(addr);
 }
 
-static void flush_all_zero_pkmaps(void)
+static unsigned int flush_all_zero_pkmaps(void)
 {
 	int i;
-	int need_flush = 0;
+	unsigned int index = PKMAP_INVALID_INDEX;
 
 	flush_cache_kmaps();
 
@@ -141,10 +141,13 @@ static void flush_all_zero_pkmaps(void)
 			  &pkmap_page_table[i]);
 
 		set_page_address(page, NULL);
-		need_flush = 1;
+		if (index == PKMAP_INVALID_INDEX)
+			index = i;
 	}
-	if (need_flush)
+	if (index != PKMAP_INVALID_INDEX)
 		flush_tlb_kernel_range(PKMAP_ADDR(0), PKMAP_ADDR(LAST_PKMAP));
+
+	return index;
 }
 
 /**
@@ -152,14 +155,19 @@ static void flush_all_zero_pkmaps(void)
  */
 void kmap_flush_unused(void)
 {
+	unsigned int index;
+
 	lock_kmap();
-	flush_all_zero_pkmaps();
+	index = flush_all_zero_pkmaps();
+	if (index != PKMAP_INVALID_INDEX && (index < last_pkmap_nr))
+		last_pkmap_nr = index;
 	unlock_kmap();
 }
 
 static inline unsigned long map_new_virtual(struct page *page)
 {
 	unsigned long vaddr;
+	unsigned int index = PKMAP_INVALID_INDEX;
 	int count;
 
 start:
@@ -168,40 +176,45 @@ start:
 	for (;;) {
 		last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;
 		if (!last_pkmap_nr) {
-			flush_all_zero_pkmaps();
-			count = LAST_PKMAP;
+			index = flush_all_zero_pkmaps();
+			break;
 		}
-		if (!pkmap_count[last_pkmap_nr])
+		if (!pkmap_count[last_pkmap_nr]) {
+			index = last_pkmap_nr;
 			break;	/* Found a usable entry */
-		if (--count)
-			continue;
-
-		/*
-		 * Sleep for somebody else to unmap their entries
-		 */
-		{
-			DECLARE_WAITQUEUE(wait, current);
-
-			__set_current_state(TASK_UNINTERRUPTIBLE);
-			add_wait_queue(&pkmap_map_wait, &wait);
-			unlock_kmap();
-			schedule();
-			remove_wait_queue(&pkmap_map_wait, &wait);
-			lock_kmap();
-
-			/* Somebody else might have mapped it while we slept */
-			if (page_address(page))
-				return (unsigned long)page_address(page);
-
-			/* Re-start */
-			goto start;
 		}
+		if (--count == 0)
+			break;
 	}
-	vaddr = PKMAP_ADDR(last_pkmap_nr);
+
+	/*
+	 * Sleep for somebody else to unmap their entries
+	 */
+	if (index == PKMAP_INVALID_INDEX) {
+		DECLARE_WAITQUEUE(wait, current);
+
+		__set_current_state(TASK_UNINTERRUPTIBLE);
+		add_wait_queue(&pkmap_map_wait, &wait);
+		unlock_kmap();
+		schedule();
+		remove_wait_queue(&pkmap_map_wait, &wait);
+		lock_kmap();
+
+		/* Somebody else might have mapped it while we slept */
+		vaddr = (unsigned long)page_address(page);
+		if (vaddr)
+			return vaddr;
+
+		/* Re-start */
+		goto start;
+	}
+
+	vaddr = PKMAP_ADDR(index);
 	set_pte_at(&init_mm, vaddr,
-		   &(pkmap_page_table[last_pkmap_nr]), mk_pte(page, kmap_prot));
+		   &(pkmap_page_table[index]), mk_pte(page, kmap_prot));
 
-	pkmap_count[last_pkmap_nr] = 1;
+	pkmap_count[index] = 1;
+	last_pkmap_nr = index;
 	set_page_address(page, (void *)vaddr);
 
 	return vaddr;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
