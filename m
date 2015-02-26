Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 15C6E6B006C
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 19:23:57 -0500 (EST)
Received: by iecat20 with SMTP id at20so9758078iec.12
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:23:56 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id n198si5739594ion.33.2015.02.25.16.23.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 16:23:56 -0800 (PST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so10556599igb.5
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:23:56 -0800 (PST)
Date: Wed, 25 Feb 2015 16:23:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, thp: really limit transparent hugepage allocation
 to local node
Message-ID: <alpine.DEB.2.10.1502251623030.10303@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 077fcf116c8c ("mm/thp: allocate transparent hugepages on local
node") restructured alloc_hugepage_vma() with the intent of only
allocating transparent hugepages locally when there was not an effective
interleave mempolicy.

alloc_pages_exact_node() does not limit the allocation to the single
node, however, but rather prefers it.  This is because __GFP_THISNODE is
not set which would cause the node-local nodemask to be passed.  Without
it, only a nodemask that prefers the local node is passed.

Fix this by passing __GFP_THISNODE and falling back to small pages when
the allocation fails.

Commit 9f1b868a13ac ("mm: thp: khugepaged: add policy for finding target
node") suffers from a similar problem for khugepaged, which is also
fixed.

Fixes: 077fcf116c8c ("mm/thp: allocate transparent hugepages on local node")
Fixes: 9f1b868a13ac ("mm: thp: khugepaged: add policy for finding target node")
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c | 9 +++++++--
 mm/mempolicy.c   | 3 ++-
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2311,8 +2311,14 @@ static struct page
 		       struct vm_area_struct *vma, unsigned long address,
 		       int node)
 {
+	gfp_t flags;
+
 	VM_BUG_ON_PAGE(*hpage, *hpage);
 
+	/* Only allocate from the target node */
+	flags = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
+	        __GFP_THISNODE;
+
 	/*
 	 * Before allocating the hugepage, release the mmap_sem read lock.
 	 * The allocation can take potentially a long time if it involves
@@ -2321,8 +2327,7 @@ static struct page
 	 */
 	up_read(&mm->mmap_sem);
 
-	*hpage = alloc_pages_exact_node(node, alloc_hugepage_gfpmask(
-		khugepaged_defrag(), __GFP_OTHER_NODE), HPAGE_PMD_ORDER);
+	*hpage = alloc_pages_exact_node(node, flags, HPAGE_PMD_ORDER);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1985,7 +1985,8 @@ retry_cpuset:
 		nmask = policy_nodemask(gfp, pol);
 		if (!nmask || node_isset(node, *nmask)) {
 			mpol_cond_put(pol);
-			page = alloc_pages_exact_node(node, gfp, order);
+			page = alloc_pages_exact_node(node,
+						gfp | __GFP_THISNODE, order);
 			goto out;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
