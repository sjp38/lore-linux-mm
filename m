Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5076B0070
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:17:24 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so34560245ieb.7
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:17:24 -0800 (PST)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id w12si2008738ich.56.2015.02.27.14.17.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 14:17:24 -0800 (PST)
Received: by iecrd18 with SMTP id rd18so34617683iec.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:17:24 -0800 (PST)
Date: Fri, 27 Feb 2015 14:17:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 2/3] mm, thp: really limit transparent hugepage allocation
 to local node
In-Reply-To: <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1502271416580.7225@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, dev@openvswitch.org

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
