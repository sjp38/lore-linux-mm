Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 765EC6B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 10:54:49 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so25431126wic.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:54:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h15si14346964wjq.149.2015.06.18.07.54.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Jun 2015 07:54:47 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, thp: respect MPOL_PREFERRED policy with non-local node
Date: Thu, 18 Jun 2015 16:54:33 +0200
Message-Id: <1434639273-9527-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>

Since commit 077fcf116c8c ("mm/thp: allocate transparent hugepages on local
node"), we handle THP allocations on page fault in a special way - for
non-interleave memory policies, the allocation is only attempted on the node
local to the current CPU, if the policy's nodemask allows the node.

This is motivated by the assumption that THP benefits cannot offset the cost
of remote accesses, so it's better to fallback to base pages on the local node
(which might still be available, while huge pages are not due to
fragmentation) than to allocate huge pages on a remote node.

The nodemask check prevents us from violating e.g. MPOL_BIND policies where
the local node is not among the allowed nodes. However, the current
implementation can still give surprising results for the MPOL_PREFERRED policy
when the preferred node is different than the current CPU's local node.

In such case we should honor the preferred node and not use the local node,
which is what this patch does. If hugepage allocation on the preferred node
fails, we fall back to base pages and don't try other nodes, with the same
motivation as is done for the local node hugepage allocations.
The patch also moves the MPOL_INTERLEAVE check around to simplify the hugepage
specific test.

The difference can be demonstrated using in-tree transhuge-stress test on the
following 2-node machine where half memory on one node was occupied to show
the difference.

> numactl --hardware
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 24 25 26 27 28 29 30 31 32 33 34 35
node 0 size: 7878 MB
node 0 free: 3623 MB
node 1 cpus: 12 13 14 15 16 17 18 19 20 21 22 23 36 37 38 39 40 41 42 43 44 45 46 47
node 1 size: 8045 MB
node 1 free: 7818 MB
node distances:
node   0   1
  0:  10  21
  1:  21  10

Before the patch:
> numactl -p0 -C0 ./transhuge-stress
transhuge-stress: 2.197 s/loop, 0.276 ms/page,   7249.168 MiB/s 7962 succeed,    0 failed, 1786 different pages

> numactl -p0 -C12 ./transhuge-stress
transhuge-stress: 2.962 s/loop, 0.372 ms/page,   5376.172 MiB/s 7962 succeed,    0 failed, 3873 different pages

Number of successful THP allocations corresponds to free memory on node 0 in
the first case and node 1 in the second case, i.e. -p parameter is ignored and
cpu binding "wins".

After the patch:
> numactl -p0 -C0 ./transhuge-stress
transhuge-stress: 2.183 s/loop, 0.274 ms/page,   7295.516 MiB/s 7962 succeed,    0 failed, 1760 different pages

> numactl -p0 -C12 ./transhuge-stress
transhuge-stress: 2.878 s/loop, 0.361 ms/page,   5533.638 MiB/s 7962 succeed,    0 failed, 1750 different pages

> numactl -p1 -C0 ./transhuge-stress
transhuge-stress: 4.628 s/loop, 0.581 ms/page,   3440.893 MiB/s 7962 succeed,    0 failed, 3918 different pages

The -p parameter is respected regardless of cpu binding.

> numactl -C0 ./transhuge-stress
transhuge-stress: 2.202 s/loop, 0.277 ms/page,   7230.003 MiB/s 7962 succeed,    0 failed, 1750 different pages

> numactl -C12 ./transhuge-stress
transhuge-stress: 3.020 s/loop, 0.379 ms/page,   5273.324 MiB/s 7962 succeed,    0 failed, 3916 different pages

Without -p parameter, hugepage restriction to CPU-local node works as before.

Fixes: 077fcf116c8c ("mm/thp: allocate transparent hugepages on local node")
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>
---
 mm/mempolicy.c | 38 ++++++++++++++++++++++----------------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7477432..99d4c1d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1972,35 +1972,41 @@ retry_cpuset:
 	pol = get_vma_policy(vma, addr);
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
-	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage &&
-					pol->mode != MPOL_INTERLEAVE)) {
+	if (pol->mode == MPOL_INTERLEAVE) {
+		unsigned nid;
+
+		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
+		mpol_cond_put(pol);
+		page = alloc_page_interleave(gfp, order, nid);
+		goto out;
+	}
+
+	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
+		int hpage_node = node;
+
 		/*
 		 * For hugepage allocation and non-interleave policy which
-		 * allows the current node, we only try to allocate from the
-		 * current node and don't fall back to other nodes, as the
-		 * cost of remote accesses would likely offset THP benefits.
+		 * allows the current node (or other explicitly preferred
+		 * node) we only try to allocate from the current/preferred
+		 * node and don't fall back to other nodes, as the cost of
+		 * remote accesses would likely offset THP benefits.
 		 *
 		 * If the policy is interleave, or does not allow the current
 		 * node in its nodemask, we allocate the standard way.
 		 */
+		if (pol->mode == MPOL_PREFERRED &&
+						!(pol->flags & MPOL_F_LOCAL))
+			hpage_node = pol->v.preferred_node;
+
 		nmask = policy_nodemask(gfp, pol);
-		if (!nmask || node_isset(node, *nmask)) {
+		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
-			page = alloc_pages_exact_node(node,
+			page = alloc_pages_exact_node(hpage_node,
 						gfp | __GFP_THISNODE, order);
 			goto out;
 		}
 	}
 
-	if (pol->mode == MPOL_INTERLEAVE) {
-		unsigned nid;
-
-		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
-		mpol_cond_put(pol);
-		page = alloc_page_interleave(gfp, order, nid);
-		goto out;
-	}
-
 	nmask = policy_nodemask(gfp, pol);
 	zl = policy_zonelist(gfp, pol, node);
 	mpol_cond_put(pol);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
