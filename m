Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DCF156B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:33:55 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so8858782pab.14
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:33:55 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id yy11si10513813pac.80.2014.05.12.09.33.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 09:33:55 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so9047259pab.0
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:33:54 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: Re: [PATCH 1/3] mm: add comment for __mod_zone_page_stat
Date: Tue, 13 May 2014 00:33:43 +0800
Message-Id: <1399912423-25601-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, akpm@linux-foundation.org, riel@redhat.com, aarcange@redhat.com, oleg@redhat.com, cldu@marvell.com, fabf@skynet.be, nasa4836@gmail.com, sasha.levin@oracle.com, zhangyanfei@cn.fujitsu.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com, minchan@kernel.org, dave.hansen@linux.intel.com, toshi.kani@hp.com, paul.gortmaker@windriver.com, srivatsa.bhat@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

>> This means they guarantee that even they are preemted the vm
>> counter won't be modified incorrectly.  Because the counter is page-related
>> (e.g., a new anon page added), and they are exclusively hold the pte lock.
>
>But there are multiple pte locks for numerous page. Another process could
>modify the counter because the pte lock for a different page was
>available which would cause counter corruption.
>
>
>> So, as you concludes in the other mail that __modd_zone_page_stat
>> couldn't be used.
>> in mlocked_vma_newpage, then what qualifies other call sites for using
>> it, in the same situation?

Thanks, now everything is clear.

I've renewed the patch, would you please review it? Thanks!

---<8---
mm: use the light version __mod_zone_page_state in mlocked_vma_newpage()

mlocked_vma_newpage() is called with pte lock held(a spinlock), which
implies preemtion disabled, and the vm stat counter is not modified from
interrupt context, so we need not use an irq-safe mod_zone_page_state() here,
using a light-weight version __mod_zone_page_state() would be OK.

This patch also documents __mod_zone_page_state() and some of its
callsites. The comment above __mod_zone_page_state() is from Hugh
Dickins, and acked by Christoph.

Most credits to Hugh and Christoph for the clarification on the usage of
the __mod_zone_page_state().

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/internal.h |  7 ++++++-
 mm/rmap.c     | 10 ++++++++++
 mm/vmstat.c   |  4 +++-
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 07b6736..53d439e 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -196,7 +196,12 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
 		return 0;
 
 	if (!TestSetPageMlocked(page)) {
-		mod_zone_page_state(page_zone(page), NR_MLOCK,
+		/*
+		 * We use the irq-unsafe __mod_zone_page_stat because
+		 * this counter is not modified from interrupt context, and the
+		 * pte lock is held(spinlock), which implies preemtion disabled.
+		 */
+		__mod_zone_page_state(page_zone(page), NR_MLOCK,
 				    hpage_nr_pages(page));
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e773..2fa4375 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -986,6 +986,11 @@ void do_page_add_anon_rmap(struct page *page,
 {
 	int first = atomic_inc_and_test(&page->_mapcount);
 	if (first) {
+		/*
+		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
+		 * these counters are not modified in interrupt context, and
+		 * pte lock(a spinlock) is held, which implies preemtion disabled.
+		 */
 		if (PageTransHuge(page))
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
@@ -1077,6 +1082,11 @@ void page_remove_rmap(struct page *page)
 	/*
 	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
 	 * and not charged by memcg for now.
+	 *
+	 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
+	 * these counters are not modified in interrupt context, and
+	 * these counters are not modified in interrupt context, and
+	 * pte lock(a spinlock) is held, which implies preemtion disabled.
 	 */
 	if (unlikely(PageHuge(page)))
 		goto out;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 302dd07..704928e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -207,7 +207,9 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
 }
 
 /*
- * For use when we know that interrupts are disabled.
+ * For use when we know that interrupts are disabled,
+ * or when we know that preemption is disabled and that
+ * particular counter cannot be updated from interrupt context.
  */
 void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 				int delta)
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
