Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 599106B0275
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:40:07 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id c20so17864631pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:40:07 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id b9si9814747pas.197.2016.04.05.13.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:40:06 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id td3so17538881pab.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:40:06 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:40:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 01/10] mm: update_lru_size warn and reset bad lru_size
In-Reply-To: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051337450.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Though debug kernels have a VM_BUG_ON to help protect from misaccounting
lru_size, non-debug kernels are liable to wrap it around: and then the
vast unsigned long size draws page reclaim into a loop of repeatedly
doing nothing on an empty list, without even a cond_resched().

That soft lockup looks confusingly like an over-busy reclaim scenario,
with lots of contention on the lru_lock in shrink_inactive_list():
yet has a totally different origin.

Help differentiate with a custom warning in mem_cgroup_update_lru_size(),
even in non-debug kernels; and reset the size to avoid the lockup.  But
the particular bug which suggested this change was mine alone, and since
fixed.

Make it a WARN_ONCE: the first occurrence is the most informative, a
flurry may follow, yet even when rate-limited little more is learnt.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mm_inline.h |    2 +-
 mm/memcontrol.c           |   24 ++++++++++++++++++++----
 2 files changed, 21 insertions(+), 5 deletions(-)

--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -35,8 +35,8 @@ static __always_inline void del_page_fro
 				struct lruvec *lruvec, enum lru_list lru)
 {
 	int nr_pages = hpage_nr_pages(page);
-	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
 	list_del(&page->lru);
+	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
 	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, -nr_pages);
 }
 
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1022,22 +1022,38 @@ out:
  * @lru: index of lru list the page is sitting on
  * @nr_pages: positive when adding or negative when removing
  *
- * This function must be called when a page is added to or removed from an
- * lru list.
+ * This function must be called under lru_lock, just before a page is added
+ * to or just after a page is removed from an lru list (that ordering being
+ * so as to allow it to check that lru_size 0 is consistent with list_empty).
  */
 void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 				int nr_pages)
 {
 	struct mem_cgroup_per_zone *mz;
 	unsigned long *lru_size;
+	long size;
+	bool empty;
 
 	if (mem_cgroup_disabled())
 		return;
 
 	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
 	lru_size = mz->lru_size + lru;
-	*lru_size += nr_pages;
-	VM_BUG_ON((long)(*lru_size) < 0);
+	empty = list_empty(lruvec->lists + lru);
+
+	if (nr_pages < 0)
+		*lru_size += nr_pages;
+
+	size = *lru_size;
+	if (WARN_ONCE(size < 0 || empty != !size,
+		"%s(%p, %d, %d): lru_size %ld but %sempty\n",
+		__func__, lruvec, lru, nr_pages, size, empty ? "" : "not ")) {
+		VM_BUG_ON(1);
+		*lru_size = 0;
+	}
+
+	if (nr_pages > 0)
+		*lru_size += nr_pages;
 }
 
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
