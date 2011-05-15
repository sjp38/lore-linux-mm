Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9515490010B
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:21:47 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 4/9] mm: make gather_stats() type-safe and remove forward declaration
Date: Sun, 15 May 2011 18:20:24 -0400
Message-Id: <1305498029-11677-5-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-1-git-send-email-wilsons@start.ca>
References: <1305498029-11677-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

Improve the prototype of gather_stats() to take a struct numa_maps as
argument instead of a generic void *.  Update all callers to make the
required type explicit.

Since gather_stats() is not needed before its definition and is
scheduled to be moved out of mempolicy.c the declaration is removed as
well.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 mm/mempolicy.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d43d05e..108f858 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -457,7 +457,6 @@ static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
 	},
 };
 
-static void gather_stats(struct page *, void *, int pte_dirty);
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
@@ -2555,9 +2554,8 @@ struct numa_maps {
 	unsigned long node[MAX_NUMNODES];
 };
 
-static void gather_stats(struct page *page, void *private, int pte_dirty)
+static void gather_stats(struct page *page, struct numa_maps *md, int pte_dirty)
 {
-	struct numa_maps *md = private;
 	int count = page_mapcount(page);
 
 	md->pages++;
@@ -2650,6 +2648,7 @@ static void check_huge_range(struct vm_area_struct *vma,
 static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
+	struct numa_maps *md;
 	struct page *page;
 
 	if (pte_none(*pte))
@@ -2659,7 +2658,8 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 	if (!page)
 		return 0;
 
-	gather_stats(page, walk->private, pte_dirty(*pte));
+	md = walk->private;
+	gather_stats(page, md, pte_dirty(*pte));
 	return 0;
 }
 
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
