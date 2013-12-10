Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 479E06B0071
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 21:33:51 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so6355881pdj.12
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 18:33:50 -0800 (PST)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id fn9si8995539pab.87.2013.12.09.18.33.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 18:33:48 -0800 (PST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 12:33:44 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 715662BB002D
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:33:41 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA2FLYH58130434
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:15:21 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA2XevT032546
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:33:40 +1100
Date: Tue, 10 Dec 2013 10:33:38 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/7] mm/migrate: remove putback_lru_pages, fix comment
 on putback_movable_pages
Message-ID: <52a67d8c.6966420a.7a42.555fSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386580248-22431-5-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 06:10:45PM +0900, Joonsoo Kim wrote:
>Some part of putback_lru_pages() and putback_movable_pages() is
>duplicated, so it could confuse us what we should use.
>We can remove putback_lru_pages() since it is not really needed now.
>This makes us undestand and maintain the code more easily.
>
>And comment on putback_movable_pages() is stale now, so fix it.
>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>diff --git a/include/linux/migrate.h b/include/linux/migrate.h
>index f5096b5..e4671f9 100644
>--- a/include/linux/migrate.h
>+++ b/include/linux/migrate.h
>@@ -35,7 +35,6 @@ enum migrate_reason {
>
> #ifdef CONFIG_MIGRATION
>
>-extern void putback_lru_pages(struct list_head *l);
> extern void putback_movable_pages(struct list_head *l);
> extern int migrate_page(struct address_space *,
> 			struct page *, struct page *, enum migrate_mode);
>@@ -58,7 +57,6 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
> 		struct buffer_head *head, enum migrate_mode mode);
> #else
>
>-static inline void putback_lru_pages(struct list_head *l) {}
> static inline void putback_movable_pages(struct list_head *l) {}
> static inline int migrate_pages(struct list_head *l, new_page_t x,
> 		unsigned long private, enum migrate_mode mode, int reason)
>diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>index b7c1716..1debdea 100644
>--- a/mm/memory-failure.c
>+++ b/mm/memory-failure.c
>@@ -1569,7 +1569,13 @@ static int __soft_offline_page(struct page *page, int flags)
> 		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
> 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
> 		if (ret) {
>-			putback_lru_pages(&pagelist);
>+			if (!list_empty(&pagelist)) {
>+				list_del(&page->lru);
>+				dec_zone_page_state(page, NR_ISOLATED_ANON +
>+						page_is_file_cache(page));
>+				putback_lru_page(page);
>+			}
>+
> 			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
> 				pfn, ret, page->flags);
> 			if (ret > 0)
>diff --git a/mm/migrate.c b/mm/migrate.c
>index b1cfd01..cdafdc0 100644
>--- a/mm/migrate.c
>+++ b/mm/migrate.c
>@@ -71,28 +71,12 @@ int migrate_prep_local(void)
> }
>
> /*
>- * Add isolated pages on the list back to the LRU under page lock
>- * to avoid leaking evictable pages back onto unevictable list.
>- */
>-void putback_lru_pages(struct list_head *l)
>-{
>-	struct page *page;
>-	struct page *page2;
>-
>-	list_for_each_entry_safe(page, page2, l, lru) {
>-		list_del(&page->lru);
>-		dec_zone_page_state(page, NR_ISOLATED_ANON +
>-				page_is_file_cache(page));
>-			putback_lru_page(page);
>-	}
>-}
>-
>-/*
>  * Put previously isolated pages back onto the appropriate lists
>  * from where they were once taken off for compaction/migration.
>  *
>- * This function shall be used instead of putback_lru_pages(),
>- * whenever the isolated pageset has been built by isolate_migratepages_range()
>+ * This function shall be used whenever the isolated pageset has been
>+ * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
>+ * and isolate_huge_page().
>  */
> void putback_movable_pages(struct list_head *l)
> {
>@@ -1704,6 +1688,12 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
> 	nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_page,
> 				     node, MIGRATE_ASYNC, MR_NUMA_MISPLACED);
> 	if (nr_remaining) {
>+		if (!list_empty(&migratepages)) {
>+			list_del(&page->lru);
>+			dec_zone_page_state(page, NR_ISOLATED_ANON +
>+					page_is_file_cache(page));
>+			putback_lru_page(page);
>+		}
> 		putback_lru_pages(&migratepages);

You should remove this line. Otherwise,

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

> 		isolated = 0;
> 	} else
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
