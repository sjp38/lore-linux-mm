Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B426E6B02F5
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 18:48:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e9so122481456pgc.5
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:48:43 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j9si28665996pgn.234.2016.11.15.15.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 15:48:43 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v3 4/8] mm/swap: skip read ahead for unreferenced swap slots
Date: Tue, 15 Nov 2016 15:47:37 -0800
Message-Id: <f3c0d6651970fb6ff8245816440850a2b693e3b3.1479252493.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1479252493.git.tim.c.chen@linux.intel.com>
References: <cover.1479252493.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1479252493.git.tim.c.chen@linux.intel.com>
References: <cover.1479252493.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

We can avoid needlessly allocating page for swap slots that
are not used by anyone. No pages have to be read in for
these slots.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Co-developed-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h |  6 ++++++
 mm/swap_state.c      |  4 ++++
 mm/swapfile.c        | 47 +++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 6bda950..13bbc5f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -424,6 +424,7 @@ extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
+extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
 extern bool reuse_swap_page(struct page *, int *);
@@ -518,6 +519,11 @@ static inline int page_swapcount(struct page *page)
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
index 9df26c9..c761104 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -323,6 +323,10 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		if (found_page)
 			break;
 
+		/* Just skip read ahead for unused swap slot */
+		if (!__swp_swapcount(entry))
+			return NULL;
+
 		/*
 		 * Get a new page to read into from swap.
 		 */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 4f1b721..19e3ea9 100644
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
