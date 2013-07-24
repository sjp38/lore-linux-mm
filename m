From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/8] migrate: make core migration code aware of hugepage
Date: Wed, 24 Jul 2013 10:28:28 +0800
Message-ID: <13037.7263449647$1374632979@news.gmane.org>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1opU-0000VJ-FG
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 04:29:29 +0200
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id E4FB46B0034
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 22:29:25 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 07:51:25 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 99955E0054
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 07:59:17 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O2TC0w44630246
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 07:59:12 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O2TFNA031664
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 12:29:15 +1000
Content-Disposition: inline
In-Reply-To: <1374183272-10153-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 18, 2013 at 05:34:25PM -0400, Naoya Horiguchi wrote:
>Before enabling each user of page migration to support hugepage,
>this patch enables the list of pages for migration to link not only
>LRU pages, but also hugepages. As a result, putback_movable_pages()
>and migrate_pages() can handle both of LRU pages and hugepages.
>
>ChangeLog v3:
> - revert introducing migrate_movable_pages
> - add isolate_huge_page
>
>ChangeLog v2:
> - move code removing VM_HUGETLB from vma_migratable check into a
>   separate patch
> - hold hugetlb_lock in putback_active_hugepage
> - update comment near the definition of hugetlb_lock
>
>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> include/linux/hugetlb.h |  6 ++++++
> mm/hugetlb.c            | 32 +++++++++++++++++++++++++++++++-
> mm/migrate.c            | 10 +++++++++-
> 3 files changed, 46 insertions(+), 2 deletions(-)
>
>diff --git v3.11-rc1.orig/include/linux/hugetlb.h v3.11-rc1/include/linux/hugetlb.h
>index c2b1801..0b7a9e7 100644
>--- v3.11-rc1.orig/include/linux/hugetlb.h
>+++ v3.11-rc1/include/linux/hugetlb.h
>@@ -66,6 +66,9 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
> 						vm_flags_t vm_flags);
> void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
> int dequeue_hwpoisoned_huge_page(struct page *page);
>+bool isolate_huge_page(struct page *page, struct list_head *l);
>+void putback_active_hugepage(struct page *page);
>+void putback_active_hugepages(struct list_head *l);
> void copy_huge_page(struct page *dst, struct page *src);
>
> #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
>@@ -134,6 +137,9 @@ static inline int dequeue_hwpoisoned_huge_page(struct page *page)
> 	return 0;
> }
>
>+#define isolate_huge_page(p, l) false
>+#define putback_active_hugepage(p)
>+#define putback_active_hugepages(l)
> static inline void copy_huge_page(struct page *dst, struct page *src)
> {
> }
>diff --git v3.11-rc1.orig/mm/hugetlb.c v3.11-rc1/mm/hugetlb.c
>index 83aff0a..4c48a70 100644
>--- v3.11-rc1.orig/mm/hugetlb.c
>+++ v3.11-rc1/mm/hugetlb.c
>@@ -48,7 +48,8 @@ static unsigned long __initdata default_hstate_max_huge_pages;
> static unsigned long __initdata default_hstate_size;
>
> /*
>- * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
>+ * Protects updates to hugepage_freelists, hugepage_activelist, nr_huge_pages,
>+ * free_huge_pages, and surplus_huge_pages.
>  */
> DEFINE_SPINLOCK(hugetlb_lock);
>
>@@ -3431,3 +3432,32 @@ int dequeue_hwpoisoned_huge_page(struct page *hpage)
> 	return ret;
> }
> #endif
>+
>+bool isolate_huge_page(struct page *page, struct list_head *l)
>+{
>+	VM_BUG_ON(!PageHead(page));
>+	if (!get_page_unless_zero(page))
>+		return false;
>+	spin_lock(&hugetlb_lock);
>+	list_move_tail(&page->lru, l);
>+	spin_unlock(&hugetlb_lock);
>+	return true;
>+}
>+
>+void putback_active_hugepage(struct page *page)
>+{
>+	VM_BUG_ON(!PageHead(page));
>+	spin_lock(&hugetlb_lock);
>+	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
>+	spin_unlock(&hugetlb_lock);
>+	put_page(page);
>+}
>+
>+void putback_active_hugepages(struct list_head *l)
>+{
>+	struct page *page;
>+	struct page *page2;
>+
>+	list_for_each_entry_safe(page, page2, l, lru)
>+		putback_active_hugepage(page);
>+}
>diff --git v3.11-rc1.orig/mm/migrate.c v3.11-rc1/mm/migrate.c
>index 6f0c244..b44a067 100644
>--- v3.11-rc1.orig/mm/migrate.c
>+++ v3.11-rc1/mm/migrate.c
>@@ -100,6 +100,10 @@ void putback_movable_pages(struct list_head *l)
> 	struct page *page2;
>
> 	list_for_each_entry_safe(page, page2, l, lru) {
>+		if (unlikely(PageHuge(page))) {
>+			putback_active_hugepage(page);
>+			continue;
>+		}
> 		list_del(&page->lru);
> 		dec_zone_page_state(page, NR_ISOLATED_ANON +
> 				page_is_file_cache(page));
>@@ -1025,7 +1029,11 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> 		list_for_each_entry_safe(page, page2, from, lru) {
> 			cond_resched();
>
>-			rc = unmap_and_move(get_new_page, private,
>+			if (PageHuge(page))
>+				rc = unmap_and_move_huge_page(get_new_page,
>+						private, page, pass > 2, mode);
>+			else
>+				rc = unmap_and_move(get_new_page, private,
> 						page, pass > 2, mode);
>
> 			switch(rc) {
>-- 
>1.8.3.1
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
