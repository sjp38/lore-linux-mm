Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CC0246B0026
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:37:19 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 3/8] mm: remove MPOL_MF_STATS
Date: Wed, 27 Apr 2011 19:35:44 -0400
Message-Id: <1303947349-3620-4-git-send-email-wilsons@start.ca>
In-Reply-To: <1303947349-3620-1-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Mapping statistics in a NUMA environment is now computed using the
generic walk_page_range() logic.  Remove the old/equivalent
functionality.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 mm/mempolicy.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index dfe27e3..63c0d69 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -99,7 +99,6 @@
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
-#define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
 
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sn_cache;
@@ -492,9 +491,7 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
 			continue;
 
-		if (flags & MPOL_MF_STATS)
-			gather_stats(page, private, pte_dirty(*pte));
-		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 			migrate_page_add(page, private, flags);
 		else
 			break;
@@ -2572,6 +2569,7 @@ static int gather_pte_stats(pte_t *pte, unsigned long addr,
 		unsigned long pte_size, struct mm_walk *walk)
 {
 	struct page *page;
+	int nid;
 
 	if (pte_none(*pte))
 		return 0;
@@ -2580,6 +2578,10 @@ static int gather_pte_stats(pte_t *pte, unsigned long addr,
 	if (!page)
 		return 0;
 
+	nid = page_to_nid(page);
+	if (!node_isset(nid, node_states[N_HIGH_MEMORY]))
+		return 0;
+
 	gather_stats(page, walk->private, pte_dirty(*pte));
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
