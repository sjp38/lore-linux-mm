Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA05911
	for <linux-mm@kvack.org>; Fri, 31 Jan 2003 15:16:35 -0800 (PST)
Date: Fri, 31 Jan 2003 15:18:58 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030131151858.6e9cc35e.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

4/4



The odd thing about hugetlb is that it maintains its own freelist of pages. 
And it has to do that, else it would trivially run out of pages due to buddy
fragmetation.

So we we don't want callers of put_page() to be passing those pages
to __free_pages_ok() on the final put().

So hugetlb installs a destructor in the compound pages to point at
free_huge_page(), which knows how to put these pages back onto the free list.

Also, don't mark hugepages as all PageReserved any more.  That's preenting
callers from doing proper refcounting.  Any code which does a user pagetable
walk and hits part of a hugepage will now handle it transparently.




 arch/i386/mm/hugetlbpage.c    |   22 ++++++++++------------
 arch/ia64/mm/hugetlbpage.c    |    8 ++------
 arch/sparc64/mm/hugetlbpage.c |    7 +------
 3 files changed, 13 insertions(+), 24 deletions(-)

diff -puN arch/i386/mm/hugetlbpage.c~compound-pages-hugetlb arch/i386/mm/hugetlbpage.c
--- 25/arch/i386/mm/hugetlbpage.c~compound-pages-hugetlb	Fri Jan 31 14:34:55 2003
+++ 25-akpm/arch/i386/mm/hugetlbpage.c	Fri Jan 31 14:35:16 2003
@@ -46,6 +46,7 @@ static struct page *alloc_hugetlb_page(v
 	htlbpagemem--;
 	spin_unlock(&htlbpage_lock);
 	set_page_count(page, 1);
+	page->lru.prev = (void *)huge_page_release;
 	for (i = 0; i < (HPAGE_SIZE/PAGE_SIZE); ++i)
 		clear_highpage(&page[i]);
 	return page;
@@ -134,6 +135,7 @@ back1:
 		page = pte_page(pte);
 		if (pages) {
 			page += ((start & ~HPAGE_MASK) >> PAGE_SHIFT);
+			get_page(page);
 			pages[i] = page;
 		}
 		if (vmas)
@@ -218,8 +220,10 @@ follow_huge_pmd(struct mm_struct *mm, un
 	struct page *page;
 
 	page = pte_page(*(pte_t *)pmd);
-	if (page)
+	if (page) {
 		page += ((address & ~HPAGE_MASK) >> PAGE_SHIFT);
+		get_page(page);
+	}
 	return page;
 }
 #endif
@@ -372,8 +376,8 @@ int try_to_free_low(int count)
 
 int set_hugetlb_mem_size(int count)
 {
-	int j, lcount;
-	struct page *page, *map;
+	int lcount;
+	struct page *page;
 	extern long htlbzone_pages;
 	extern struct list_head htlbpage_freelist;
 
@@ -389,11 +393,6 @@ int set_hugetlb_mem_size(int count)
 			page = alloc_pages(__GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
 			if (page == NULL)
 				break;
-			map = page;
-			for (j = 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
-				SetPageReserved(map);
-				map++;
-			}
 			spin_lock(&htlbpage_lock);
 			list_add(&page->list, &htlbpage_freelist);
 			htlbpagemem++;
@@ -415,7 +414,8 @@ int set_hugetlb_mem_size(int count)
 	return (int) htlbzone_pages;
 }
 
-int hugetlb_sysctl_handler(ctl_table *table, int write, struct file *file, void *buffer, size_t *length)
+int hugetlb_sysctl_handler(ctl_table *table, int write,
+		struct file *file, void *buffer, size_t *length)
 {
 	proc_dointvec(table, write, file, buffer, length);
 	htlbpage_max = set_hugetlb_mem_size(htlbpage_max);
@@ -432,15 +432,13 @@ __setup("hugepages=", hugetlb_setup);
 
 static int __init hugetlb_init(void)
 {
-	int i, j;
+	int i;
 	struct page *page;
 
 	for (i = 0; i < htlbpage_max; ++i) {
 		page = alloc_pages(__GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
 		if (!page)
 			break;
-		for (j = 0; j < HPAGE_SIZE/PAGE_SIZE; ++j)
-			SetPageReserved(&page[j]);
 		spin_lock(&htlbpage_lock);
 		list_add(&page->list, &htlbpage_freelist);
 		spin_unlock(&htlbpage_lock);
diff -puN arch/ia64/mm/hugetlbpage.c~compound-pages-hugetlb arch/ia64/mm/hugetlbpage.c
--- 25/arch/ia64/mm/hugetlbpage.c~compound-pages-hugetlb	Fri Jan 31 15:04:32 2003
+++ 25-akpm/arch/ia64/mm/hugetlbpage.c	Fri Jan 31 15:06:27 2003
@@ -227,6 +227,7 @@ back1:
 		page = pte_page(pte);
 		if (pages) {
 			page += ((start & ~HPAGE_MASK) >> PAGE_SHIFT);
+			get_page(page);
 			pages[i] = page;
 		}
 		if (vmas)
@@ -303,11 +304,6 @@ set_hugetlb_mem_size (int count)
 			page = alloc_pages(__GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
 			if (page == NULL)
 				break;
-			map = page;
-			for (j = 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
-				SetPageReserved(map);
-				map++;
-			}
 			spin_lock(&htlbpage_lock);
 			list_add(&page->list, &htlbpage_freelist);
 			htlbpagemem++;
@@ -327,7 +323,7 @@ set_hugetlb_mem_size (int count)
 		map = page;
 		for (j = 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
 			map->flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
-					1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
+					1 << PG_dirty | 1 << PG_active |
 					1 << PG_private | 1<< PG_writeback);
 			map++;
 		}
diff -puN arch/sparc64/mm/hugetlbpage.c~compound-pages-hugetlb arch/sparc64/mm/hugetlbpage.c
--- 25/arch/sparc64/mm/hugetlbpage.c~compound-pages-hugetlb	Fri Jan 31 15:05:00 2003
+++ 25-akpm/arch/sparc64/mm/hugetlbpage.c	Fri Jan 31 15:06:35 2003
@@ -288,6 +288,7 @@ back1:
 		page = pte_page(pte);
 		if (pages) {
 			page += ((start & ~HPAGE_MASK) >> PAGE_SHIFT);
+			get_page(page);
 			pages[i] = page;
 		}
 		if (vmas)
@@ -584,11 +585,6 @@ int set_hugetlb_mem_size(int count)
 			page = alloc_pages(GFP_ATOMIC, HUGETLB_PAGE_ORDER);
 			if (page == NULL)
 				break;
-			map = page;
-			for (j = 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
-				SetPageReserved(map);
-				map++;
-			}
 			spin_lock(&htlbpage_lock);
 			list_add(&page->list, &htlbpage_freelist);
 			htlbpagemem++;
@@ -613,7 +609,6 @@ int set_hugetlb_mem_size(int count)
 			map->flags &= ~(1UL << PG_locked | 1UL << PG_error |
 					1UL << PG_referenced |
 					1UL << PG_dirty | 1UL << PG_active |
-					1UL << PG_reserved |
 					1UL << PG_private | 1UL << PG_writeback);
 			set_page_count(page, 0);
 			map++;

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
