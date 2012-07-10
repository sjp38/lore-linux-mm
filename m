Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 081056B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 18:18:07 -0400 (EDT)
Date: Wed, 11 Jul 2012 00:17:50 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] mm: sparse: fix section usemap placement calculation
Message-ID: <20120710221750.GI1779@cmpxchg.org>
References: <20120626234630.A54C9A0341@akpm.mtv.corp.google.com>
 <CAE9FiQUeQG6nr_k54ixEA4pvRT00e4bWoMJ+m0NO=FPEnBDB8Q@mail.gmail.com>
 <CAE9FiQX_ovuiGHShf72kLOe4WJybZiyWiGaQ9KUnc1jm3cvdHw@mail.gmail.com>
 <20120710212005.GG1779@cmpxchg.org>
 <20120710221559.GH1779@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120710221559.GH1779@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>

238305b "mm: remove sparsemem allocation details from the bootmem
allocator" introduced a bug in the allocation goal calculation that
put section usemaps not in the same section as the node descriptors,
creating unnecessary hotplug dependencies between them:

[    0.000000] node 0 must be removed before remove section 16399
[    0.000000] node 1 must be removed before remove section 16399
[    0.000000] node 2 must be removed before remove section 16399
[    0.000000] node 3 must be removed before remove section 16399
[    0.000000] node 4 must be removed before remove section 16399
[    0.000000] node 5 must be removed before remove section 16399
[    0.000000] node 6 must be removed before remove section 16399

The reason is that it applies PAGE_SECTION_MASK to the physical
address of the node descriptor when finding a suitable place to put
the usemap, when this mask is actually intended to be used with PFNs.
Because the PFN mask is wider, the target address will point beyond
the wanted section holding the node descriptor and the node must be
offlined before the section holding the usemap can go.

Fix this by extending the mask to address width before use.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/sparse.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 6a4bf91..e861397 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -287,7 +287,7 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	 * from the same section as the pgdat where possible to avoid
 	 * this problem.
 	 */
-	goal = __pa(pgdat) & PAGE_SECTION_MASK;
+	goal = __pa(pgdat) & (PAGE_SECTION_MASK << PAGE_SHIFT);
 	host_pgdat = NODE_DATA(early_pfn_to_nid(goal >> PAGE_SHIFT));
 	return __alloc_bootmem_node_nopanic(host_pgdat, size,
 					    SMP_CACHE_BYTES, goal);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
