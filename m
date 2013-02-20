From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Date: Wed, 20 Feb 2013 19:37:57 +0800
Message-ID: <19348.4896830798$1361360320@news.gmane.org>
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com>
 <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1U880Q-0006kq-72
	for glkm-linux-mm-2@m.gmane.org; Wed, 20 Feb 2013 12:38:34 +0100
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 6F1626B0008
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 06:38:11 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 20 Feb 2013 21:30:46 +1000
Content-Disposition: inline
In-Reply-To: <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

On Tue, Feb 05, 2013 at 05:21:52PM +0800, Lin Feng wrote:
>get_user_pages() always tries to allocate pages from movable zone, which is not
> reliable to memory hotremove framework in some case.
>
>This patch introduces a new library function called get_user_pages_non_movable()
> to pin pages only from zone non-movable in memory.
>It's a wrapper of get_user_pages() but it makes sure that all pages come from
>non-movable zone via additional page migration.
>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Mel Gorman <mgorman@suse.de>
>Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>Cc: Jeff Moyer <jmoyer@redhat.com>
>Cc: Minchan Kim <minchan@kernel.org>
>Cc: Zach Brown <zab@redhat.com>
>Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
>Reviewed-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
>Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
>---
> include/linux/mm.h     |    3 ++
> include/linux/mmzone.h |    4 ++
> mm/memory.c            |   83 ++++++++++++++++++++++++++++++++++++++++++++++++
> mm/page_isolation.c    |    5 +++
> 4 files changed, 95 insertions(+), 0 deletions(-)
>
>diff --git a/include/linux/mm.h b/include/linux/mm.h
>index 12f5a09..3ff9eba 100644
>--- a/include/linux/mm.h
>+++ b/include/linux/mm.h
>@@ -1049,6 +1049,9 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> 			struct page **pages, struct vm_area_struct **vmas);
> int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> 			struct page **pages);
>+int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
>+		unsigned long start, int nr_pages, int write, int force,
>+		struct page **pages, struct vm_area_struct **vmas);
> struct kvec;
> int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
> 			struct page **pages);
>diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>index e25ab6f..1506351 100644
>--- a/include/linux/mmzone.h
>+++ b/include/linux/mmzone.h
>@@ -841,6 +841,10 @@ static inline int is_normal_idx(enum zone_type idx)
> 	return (idx == ZONE_NORMAL);
> }
>
>+static inline int zone_is_movable(struct zone *zone)
>+{
>+	return zone_idx(zone) == ZONE_MOVABLE;
>+}
> /**
>  * is_highmem - helper function to quickly check if a struct zone is a 
>  *              highmem zone or not.  This is an attempt to keep references
>diff --git a/mm/memory.c b/mm/memory.c
>index bb1369f..ede53cc 100644
>--- a/mm/memory.c
>+++ b/mm/memory.c
>@@ -58,6 +58,8 @@
> #include <linux/elf.h>
> #include <linux/gfp.h>
> #include <linux/migrate.h>
>+#include <linux/page-isolation.h>
>+#include <linux/mm_inline.h>
> #include <linux/string.h>
>
> #include <asm/io.h>
>@@ -1995,6 +1997,87 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> }
> EXPORT_SYMBOL(get_user_pages);
>
>+#ifdef CONFIG_MEMORY_HOTREMOVE
>+/**
>+ * It's a wrapper of get_user_pages() but it makes sure that all pages come from
>+ * non-movable zone via additional page migration. It's designed for memory
>+ * hotremove framework.
>+ *
>+ * Currently get_user_pages() always tries to allocate pages from movable zone,
>+ * in some case users of get_user_pages() is easy to pin user pages for a long
>+ *  time(for now we found that pages pinned as aio ring pages is such case),
>+ * which is fatal for memory hotremove framework.
>+ *
>+ * This function first calls get_user_pages() to get the candidate pages, and
>+ * then check to ensure all pages are from non movable zone. Otherwise migrate

How about "Otherwise migrate candidate pages which have already been 
isolated to non movable zone."?

>+ * them to non movable zone, then retry. It will at most retry once.
>+ */
>+int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
>+		unsigned long start, int nr_pages, int write, int force,
>+		struct page **pages, struct vm_area_struct **vmas)
>+{
>+	int ret, i, isolate_err, migrate_pre_flag;
>+	LIST_HEAD(pagelist);
>+
>+retry:
>+	ret = get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
>+				vmas);
>+	if (ret <= 0)
>+		return ret;
>+
>+	isolate_err = 0;
>+	migrate_pre_flag = 0;
>+
>+	for (i = 0; i < ret; i++) {
>+		if (zone_is_movable(page_zone(pages[i]))) {
>+			if (!migrate_pre_flag) {
>+				if (migrate_prep())
>+					goto release_page;
>+				migrate_pre_flag = 1;
>+			}
>+
>+			if (!isolate_lru_page(pages[i])) {
>+				inc_zone_page_state(pages[i], NR_ISOLATED_ANON +
>+						 page_is_file_cache(pages[i]));
>+				list_add_tail(&pages[i]->lru, &pagelist);
>+			} else {
>+				isolate_err = 1;
>+				goto release_page;
>+			}
>+		}
>+	}
>+
>+	/* All pages are non movable, we are done :) */
>+	if (i == ret && list_empty(&pagelist))
>+		return ret;
>+
>+release_page:
>+	/* Undo the effects of former get_user_pages(), we won't pin anything */
>+	release_pages(pages, ret, 1);
>+
>+	if (migrate_pre_flag && !isolate_err) {
>+		ret = migrate_pages(&pagelist, alloc_migrate_target, 1,
>+					false, MIGRATE_SYNC, MR_SYSCALL);
>+		/* Steal pages from non-movable zone successfully? */
>+		if (!ret)
>+			goto retry;
>+	}
>+
>+	putback_lru_pages(&pagelist);
>+	/* Migration failed, we pin 0 page, tell caller the truth */
>+	return 0;
>+}
>+#else
>+inline int get_user_pages_non_movable(struct task_struct *tsk, struct mm_struct *mm,
>+		unsigned long start, int nr_pages, int write, int force,
>+		struct page **pages, struct vm_area_struct **vmas)
>+{
>+	return get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
>+				vmas);
>+}
>+#endif
>+EXPORT_SYMBOL(get_user_pages_non_movable);
>+
> /**
>  * get_dump_page() - pin user page in memory while writing it to core dump
>  * @addr: user address
>diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>index 383bdbb..1b7bd17 100644
>--- a/mm/page_isolation.c
>+++ b/mm/page_isolation.c
>@@ -247,6 +247,9 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
> 	return ret ? 0 : -EBUSY;
> }
>
>+/**
>+ * @private: 0 means page can be alloced from movable zone, otherwise forbidden
>+ */
> struct page *alloc_migrate_target(struct page *page, unsigned long private,
> 				  int **resultp)
> {
>@@ -254,6 +257,8 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
>
> 	if (PageHighMem(page))
> 		gfp_mask |= __GFP_HIGHMEM;
>+	if (unlikely(private != 0))
>+		gfp_mask &= ~__GFP_MOVABLE;
>
> 	return alloc_page(gfp_mask);
> }
>-- 
>1.7.1
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
