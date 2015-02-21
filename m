Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF806B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 22:51:19 -0500 (EST)
Received: by pdjy10 with SMTP id y10so11900442pdj.13
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:51:19 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id n5si3690167pdr.93.2015.02.20.19.51.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 19:51:18 -0800 (PST)
Received: by pabkq14 with SMTP id kq14so12830023pab.3
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:51:18 -0800 (PST)
Date: Fri, 20 Feb 2015 19:51:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 01/24] mm: update_lru_size warn and reset bad lru_size
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502201949350.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Though debug kernels have a VM_BUG_ON to help protect from misaccounting
lru_size, non-debug kernels are liable to wrap it around: and then the
vast unsigned long size draws page reclaim into a loop of repeatedly
doing nothing on an empty list, without even a cond_resched().

That soft lockup looks confusingly like an over-busy reclaim scenario,
with lots of contention on the lruvec lock in shrink_inactive_list():
yet has a totally different origin.

Help differentiate with a custom warning in mem_cgroup_update_lru_size(),
even in non-debug kernels; and reset the size to avoid the lockup.  But
the particular bug which suggested this change was mine alone, and since
fixed.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mm_inline.h |    2 +-
 mm/memcontrol.c           |   24 ++++++++++++++++++++----
 2 files changed, 21 insertions(+), 5 deletions(-)

--- thpfs.orig/include/linux/mm_inline.h	2013-11-03 15:41:51.000000000 -0800
+++ thpfs/include/linux/mm_inline.h	2015-02-20 19:33:25.928096883 -0800
@@ -35,8 +35,8 @@ static __always_inline void del_page_fro
 				struct lruvec *lruvec, enum lru_list lru)
 {
 	int nr_pages = hpage_nr_pages(page);
-	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
 	list_del(&page->lru);
+	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
 	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, -nr_pages);
 }
 
--- thpfs.orig/mm/memcontrol.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/memcontrol.c	2015-02-20 19:33:25.928096883 -0800
@@ -1296,22 +1296,38 @@ out:
  * @lru: index of lru list the page is sitting on
  * @nr_pages: positive when adding or negative when removing
  *
- * This function must be called when a page is added to or removed from an
- * lru list.
+ * This function must be called under lruvec lock, just before a page is added
+ * to or just after a page is removed from an lru list (that ordering being so
+ * as to allow it to check that lru_size 0 is consistent with list_empty).
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
+	if (WARN(size < 0 || empty != !size,
+	"mem_cgroup_update_lru_size(%p, %d, %d): lru_size %ld but %sempty\n",
+			lruvec, lru, nr_pages, size, empty ? "" : "not ")) {
+		VM_BUG_ON(1);
+		*lru_size = 0;
+	}
+
+	if (nr_pages > 0)
+		*lru_size += nr_pages;
 }
 
 bool mem_cgroup_is_descendant(struct mem_cgroup *memcg, struct mem_cgroup *root)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
