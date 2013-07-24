From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/8] soft-offline: use migrate_pages() instead of
 migrate_huge_page()
Date: Wed, 24 Jul 2013 10:40:56 +0800
Message-ID: <47071.2042799734$1374633681@news.gmane.org>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1p0l-0006XK-6P
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 04:41:07 +0200
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 942F16B0034
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 22:41:04 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 08:01:09 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 0C203394004E
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 08:10:54 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O2fsTh34603020
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 08:11:54 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O2evdh007997
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 12:40:58 +1000
Content-Disposition: inline
In-Reply-To: <1374183272-10153-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 18, 2013 at 05:34:26PM -0400, Naoya Horiguchi wrote:
>Currently migrate_huge_page() takes a pointer to a hugepage to be
>migrated as an argument, instead of taking a pointer to the list of
>hugepages to be migrated. This behavior was introduced in commit
>189ebff28 ("hugetlb: simplify migrate_huge_page()"), and was OK
>because until now hugepage migration is enabled only for soft-offlining
>which migrates only one hugepage in a single call.
>
>But the situation will change in the later patches in this series
>which enable other users of page migration to support hugepage migration.
>They can kick migration for both of normal pages and hugepages
>in a single call, so we need to go back to original implementation
>which uses linked lists to collect the hugepages to be migrated.
>
>With this patch, soft_offline_huge_page() switches to use migrate_pages(),
>and migrate_huge_page() is not used any more. So let's remove it.
>
>ChangeLog v3:
> - Merged with another cleanup patch (4/10 in previous version)
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>---
> include/linux/migrate.h |  5 -----
> mm/memory-failure.c     | 15 ++++++++++++---
> mm/migrate.c            | 28 ++--------------------------
> 3 files changed, 14 insertions(+), 34 deletions(-)
>
>diff --git v3.11-rc1.orig/include/linux/migrate.h v3.11-rc1/include/linux/migrate.h
>index a405d3dc..6fe5214 100644
>--- v3.11-rc1.orig/include/linux/migrate.h
>+++ v3.11-rc1/include/linux/migrate.h
>@@ -41,8 +41,6 @@ extern int migrate_page(struct address_space *,
> 			struct page *, struct page *, enum migrate_mode);
> extern int migrate_pages(struct list_head *l, new_page_t x,
> 		unsigned long private, enum migrate_mode mode, int reason);
>-extern int migrate_huge_page(struct page *, new_page_t x,
>-		unsigned long private, enum migrate_mode mode);
>
> extern int fail_migrate_page(struct address_space *,
> 			struct page *, struct page *);
>@@ -62,9 +60,6 @@ static inline void putback_movable_pages(struct list_head *l) {}
> static inline int migrate_pages(struct list_head *l, new_page_t x,
> 		unsigned long private, enum migrate_mode mode, int reason)
> 	{ return -ENOSYS; }
>-static inline int migrate_huge_page(struct page *page, new_page_t x,
>-		unsigned long private, enum migrate_mode mode)
>-	{ return -ENOSYS; }
>
> static inline int migrate_prep(void) { return -ENOSYS; }
> static inline int migrate_prep_local(void) { return -ENOSYS; }
>diff --git v3.11-rc1.orig/mm/memory-failure.c v3.11-rc1/mm/memory-failure.c
>index 2c13aa7..af6f61c 100644
>--- v3.11-rc1.orig/mm/memory-failure.c
>+++ v3.11-rc1/mm/memory-failure.c
>@@ -1467,6 +1467,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
> 	int ret;
> 	unsigned long pfn = page_to_pfn(page);
> 	struct page *hpage = compound_head(page);
>+	LIST_HEAD(pagelist);
>
> 	/*
> 	 * This double-check of PageHWPoison is to avoid the race with
>@@ -1482,12 +1483,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
> 	unlock_page(hpage);
>
> 	/* Keep page count to indicate a given hugepage is isolated. */
>-	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
>-				MIGRATE_SYNC);
>-	put_page(hpage);
>+	list_move(&hpage->lru, &pagelist);
>+	ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
>+				MIGRATE_SYNC, MR_MEMORY_FAILURE);
> 	if (ret) {
> 		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
> 			pfn, ret, page->flags);
>+		/*
>+		 * We know that soft_offline_huge_page() tries to migrate
>+		 * only one hugepage pointed to by hpage, so we need not
>+		 * run through the pagelist here.
>+		 */
>+		putback_active_hugepage(hpage);
>+		if (ret > 0)
>+			ret = -EIO;
> 	} else {
> 		set_page_hwpoison_huge_page(hpage);
> 		dequeue_hwpoisoned_huge_page(hpage);
>diff --git v3.11-rc1.orig/mm/migrate.c v3.11-rc1/mm/migrate.c
>index b44a067..3ec47d3 100644
>--- v3.11-rc1.orig/mm/migrate.c
>+++ v3.11-rc1/mm/migrate.c
>@@ -979,6 +979,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>
> 	unlock_page(hpage);
> out:
>+	if (rc != -EAGAIN)
>+		putback_active_hugepage(hpage);
> 	put_page(new_hpage);
> 	if (result) {
> 		if (rc)
>@@ -1066,32 +1068,6 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> 	return rc;
> }
>
>-int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
>-		      unsigned long private, enum migrate_mode mode)
>-{
>-	int pass, rc;
>-
>-	for (pass = 0; pass < 10; pass++) {
>-		rc = unmap_and_move_huge_page(get_new_page, private,
>-						hpage, pass > 2, mode);
>-		switch (rc) {
>-		case -ENOMEM:
>-			goto out;
>-		case -EAGAIN:
>-			/* try again */
>-			cond_resched();
>-			break;
>-		case MIGRATEPAGE_SUCCESS:
>-			goto out;
>-		default:
>-			rc = -EIO;
>-			goto out;
>-		}
>-	}
>-out:
>-	return rc;
>-}
>-
> #ifdef CONFIG_NUMA
> /*
>  * Move a list of individual pages
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
