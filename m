Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73F0328024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:18:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v67so40665115pfv.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:18:30 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o69si3516793pfg.61.2016.09.27.10.18.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 10:18:29 -0700 (PDT)
Date: Tue, 27 Sep 2016 10:18:27 -0700
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 4/8] mm/swap: skip read ahead for unreferenced swap slots
Message-ID: <20160927171826.GA17884@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

We can avoid needlessly allocating page for swap slots that
are not used by anyone. No pages have to be read in for
these slots.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h |  6 ++++++
 mm/swap_state.c      |  4 ++++
 mm/swapfile.c        | 47 +++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 5302cce..68ab90c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -422,6 +422,7 @@ extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
+extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
 extern bool reuse_swap_page(struct page *, int *);
@@ -516,6 +517,11 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
+static inline int __swp_swapcount(swp_entry_t entry)
+{
+	return 0;
+}
+
 static inline int swp_swapcount(swp_entry_t entry)
 {
 	return 0;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 102595c..579807d 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -316,6 +316,10 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 	*new_page_allocated = false;
 
 	do {
+		/* Just skip read ahead for unused swap slot */
+		if (!__swp_swapcount(entry))
+			return NULL;
+
 		/*
 		 * First check the swap cache.  Since this is normally
 		 * called after lookup_swap_cache() failed, re-calling
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 870f61f..980047d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -803,7 +803,7 @@ swp_entry_t get_swap_page_of_type(int type)
 	return (swp_entry_t) {0};
 }
 
-static struct swap_info_struct *_swap_info_get(swp_entry_t entry)
+static struct swap_info_struct *__swap_info_get(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
 	unsigned long offset, type;
@@ -819,13 +819,8 @@ static struct swap_info_struct *_swap_info_get(swp_entry_t entry)
 	offset = swp_offset(entry);
 	if (offset >= p->max)
 		goto bad_offset;
-	if (!p->swap_map[offset])
-		goto bad_free;
 	return p;
 
-bad_free:
-	pr_err("swap_info_get: %s%08lx\n", Unused_offset, entry.val);
-	goto out;
 bad_offset:
 	pr_err("swap_info_get: %s%08lx\n", Bad_offset, entry.val);
 	goto out;
@@ -838,6 +833,24 @@ out:
 	return NULL;
 }
 
+static struct swap_info_struct *_swap_info_get(swp_entry_t entry)
+{
+	struct swap_info_struct *p;
+
+	p = __swap_info_get(entry);
+	if (!p)
+		goto out;
+	if (!p->swap_map[swp_offset(entry)])
+		goto bad_free;
+	return p;
+
+bad_free:
+	pr_err("swap_info_get: %s%08lx\n", Unused_offset, entry.val);
+	goto out;
+out:
+	return NULL;
+}
+
 static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
@@ -993,6 +1006,28 @@ int page_swapcount(struct page *page)
 
 /*
  * How many references to @entry are currently swapped out?
+ * This does not give an exact answer when swap count is continued,
+ * but does include the high COUNT_CONTINUED flag to allow for that.
+ */
+int __swp_swapcount(swp_entry_t entry)
+{
+	int count = 0;
+	pgoff_t offset;
+	struct swap_info_struct *si;
+	struct swap_cluster_info *ci;
+
+	si = __swap_info_get(entry);
+	if (si) {
+		offset = swp_offset(entry);
+		ci = lock_cluster_or_swap_info(si, offset);
+		count = swap_count(si->swap_map[offset]);
+		unlock_cluster_or_swap_info(si, ci);
+	}
+	return count;
+}
+
+/*
+ * How many references to @entry are currently swapped out?
  * This considers COUNT_CONTINUED so it returns exact answer.
  */
 int swp_swapcount(swp_entry_t entry)
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
