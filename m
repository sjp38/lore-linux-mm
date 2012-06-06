Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 509D36B0078
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 04:15:22 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 5/7] highmem: direct struct page_address_map allocation
Date: Wed, 6 Jun 2012 16:14:59 +0800
Message-Id: <1338970501-5098-5-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1338970501-5098-1-git-send-email-laijs@cn.fujitsu.com>
References: <1338970501-5098-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@linux.intel.com>, Ian Campbell <ian.campbell@citrix.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

Always allocate the struct page_address_map with the same index
(in page_address_maps) as kmap index.

it makes the allocation simpler.

pkmap_count[nr] == 0      <==>         page_address_maps[nr] is free
pkmap_count[nr] != 0      <==>         page_address_maps[nr] is in used

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/highmem.c |   69 ++++++++++++++++++---------------------------------------
 1 files changed, 22 insertions(+), 47 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index bf7f168..bd2b9d3 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -92,7 +92,8 @@ static DECLARE_WAIT_QUEUE_HEAD(pkmap_map_wait);
 		do { spin_unlock(&kmap_lock); (void)(flags); } while (0)
 #endif
 
-static void set_high_page_address(struct page *page, void *virtual);
+static void set_high_page_map(struct page *page, unsigned int nr);
+static void clear_high_page_map(unsigned int nr);
 
 static void flush_all_zero_pkmaps(void)
 {
@@ -128,7 +129,7 @@ static void flush_all_zero_pkmaps(void)
 		pte_clear(&init_mm, (unsigned long)page_address(page),
 			  &pkmap_page_table[i]);
 
-		set_high_page_address(page, NULL);
+		clear_high_page_map(i);
 		need_flush = 1;
 	}
 	if (need_flush)
@@ -190,7 +191,7 @@ start:
 		   &(pkmap_page_table[last_pkmap_nr]), mk_pte(page, kmap_prot));
 
 	pkmap_count[last_pkmap_nr] = 1;
-	set_high_page_address(page, (void *)vaddr);
+	set_high_page_map(page, last_pkmap_nr);
 
 	return vaddr;
 }
@@ -312,10 +313,7 @@ struct page_address_map {
 	struct list_head list;
 };
 
-/*
- * page_address_map freelist, allocated from page_address_maps.
- */
-static struct list_head page_address_pool;	/* freelist */
+static struct page_address_map page_address_maps[LAST_PKMAP];
 
 /*
  * Hash table bucket
@@ -365,58 +363,35 @@ done:
 
 EXPORT_SYMBOL(page_address);
 
-/**
- * set_high_page_address - set a page's virtual address
- * @page: &struct page to set
- * @virtual: virtual address to use
- */
-static void set_high_page_address(struct page *page, void *virtual)
+static void set_high_page_map(struct page *page, unsigned int nr)
 {
 	unsigned long flags;
-	struct page_address_slot *pas;
-	struct page_address_map *pam;
+	struct page_address_slot *pas = page_slot(page);
+	struct page_address_map *pam = &page_address_maps[nr];
 
-	BUG_ON(!PageHighMem(page));
+	pam->page = page;
+	pam->virtual = (void *)PKMAP_ADDR(nr);
 
-	pas = page_slot(page);
-	if (virtual) {		/* Add */
-		BUG_ON(list_empty(&page_address_pool));
-
-		pam = list_entry(page_address_pool.next,
-				struct page_address_map, list);
-		list_del(&pam->list);
+	spin_lock_irqsave(&pas->lock, flags);
+	list_add_tail(&pam->list, &pas->lh);
+	spin_unlock_irqrestore(&pas->lock, flags);
+}
 
-		pam->page = page;
-		pam->virtual = virtual;
+static void clear_high_page_map(unsigned int nr)
+{
+	unsigned long flags;
+	struct page_address_map *pam = &page_address_maps[nr];
+	struct page_address_slot *pas = page_slot(pam->page);
 
-		spin_lock_irqsave(&pas->lock, flags);
-		list_add_tail(&pam->list, &pas->lh);
-		spin_unlock_irqrestore(&pas->lock, flags);
-	} else {		/* Remove */
-		spin_lock_irqsave(&pas->lock, flags);
-		list_for_each_entry(pam, &pas->lh, list) {
-			if (pam->page == page) {
-				list_del(&pam->list);
-				spin_unlock_irqrestore(&pas->lock, flags);
-				list_add_tail(&pam->list, &page_address_pool);
-				goto done;
-			}
-		}
-		spin_unlock_irqrestore(&pas->lock, flags);
-	}
-done:
-	return;
+	spin_lock_irqsave(&pas->lock, flags);
+	list_del(&pam->list);
+	spin_unlock_irqrestore(&pas->lock, flags);
 }
 
-static struct page_address_map page_address_maps[LAST_PKMAP];
-
 void __init page_address_init(void)
 {
 	int i;
 
-	INIT_LIST_HEAD(&page_address_pool);
-	for (i = 0; i < ARRAY_SIZE(page_address_maps); i++)
-		list_add(&page_address_maps[i].list, &page_address_pool);
 	for (i = 0; i < ARRAY_SIZE(page_address_htable); i++) {
 		INIT_LIST_HEAD(&page_address_htable[i].lh);
 		spin_lock_init(&page_address_htable[i].lock);
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
