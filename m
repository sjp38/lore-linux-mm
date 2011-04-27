Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D7F1E6B0024
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:36:51 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 4/8] mm: make gather_stats() type-safe and remove forward declaration
Date: Wed, 27 Apr 2011 19:35:45 -0400
Message-Id: <1303947349-3620-5-git-send-email-wilsons@start.ca>
In-Reply-To: <1303947349-3620-1-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Improve the prototype of gather_stats() to take a struct numa_maps as
argument instead of a generic void *.  Update all callers to make the
required type explicit.

Since gather_stats() is not needed before its definition and is
scheduled to be moved out of mempolicy.c the declaration is removed as
well.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 mm/mempolicy.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 63c0d69..d4c0b8d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -456,7 +456,6 @@ static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
 	},
 };
 
-static void gather_stats(struct page *, void *, int pte_dirty);
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
@@ -2538,9 +2537,8 @@ struct numa_maps {
 	unsigned long node[MAX_NUMNODES];
 };
 
-static void gather_stats(struct page *page, void *private, int pte_dirty)
+static void gather_stats(struct page *page, struct numa_maps *md, int pte_dirty)
 {
-	struct numa_maps *md = private;
 	int count = page_mapcount(page);
 
 	md->pages++;
@@ -2568,6 +2566,7 @@ static void gather_stats(struct page *page, void *private, int pte_dirty)
 static int gather_pte_stats(pte_t *pte, unsigned long addr,
 		unsigned long pte_size, struct mm_walk *walk)
 {
+	struct numa_maps *md;
 	struct page *page;
 	int nid;
 
@@ -2582,7 +2581,8 @@ static int gather_pte_stats(pte_t *pte, unsigned long addr,
 	if (!node_isset(nid, node_states[N_HIGH_MEMORY]))
 		return 0;
 
-	gather_stats(page, walk->private, pte_dirty(*pte));
+	md = walk->private;
+	gather_stats(page, md, pte_dirty(*pte));
 	return 0;
 }
 
@@ -2619,6 +2619,7 @@ static void check_huge_range(struct vm_area_struct *vma,
 static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
+	struct numa_maps *md;
 	struct page *page;
 
 	if (pte_none(*pte))
@@ -2628,7 +2629,8 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 	if (!page)
 		return 0;
 
-	gather_stats(page, walk->private, pte_dirty(*pte));
+	md = walk->private;
+	gather_stats(page, md, pte_dirty(*pte));
 	return 0;
 }
 
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
