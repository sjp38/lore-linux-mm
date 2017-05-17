Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40FBD6B02F3
	for <linux-mm@kvack.org>; Wed, 17 May 2017 04:11:58 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y22so644779wry.1
        for <linux-mm@kvack.org>; Wed, 17 May 2017 01:11:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 88si1401142wre.266.2017.05.17.01.11.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 01:11:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 6/6] mm, mempolicy: don't check cpuset seqlock where it doesn't matter
Date: Wed, 17 May 2017 10:11:40 +0200
Message-Id: <20170517081140.30654-7-vbabka@suse.cz>
In-Reply-To: <20170517081140.30654-1-vbabka@suse.cz>
References: <20170517081140.30654-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

Two wrappers of __alloc_pages_nodemask() are checking task->mems_allowed_seq
themselves to retry allocation that has raced with a cpuset update. This has
been shown to be ineffective in preventing premature OOM's which can happen in
__alloc_pages_slowpath() long before it returns back to the wrappers to detect
the race at that level. Previous patches have made __alloc_pages_slowpath()
more robust, so we can now simply remove the seqlock checking in the wrappers
to prevent further wrong impression that it can actually help.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mempolicy.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 047181452040..7d8e56214ac0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1898,12 +1898,9 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	struct mempolicy *pol;
 	struct page *page;
 	int preferred_nid;
-	unsigned int cpuset_mems_cookie;
 	nodemask_t *nmask;
 
-retry_cpuset:
 	pol = get_vma_policy(vma, addr);
-	cpuset_mems_cookie = read_mems_allowed_begin();
 
 	if (pol->mode == MPOL_INTERLEAVE) {
 		unsigned nid;
@@ -1945,8 +1942,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
 	mpol_cond_put(pol);
 out:
-	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
-		goto retry_cpuset;
 	return page;
 }
 
@@ -1964,23 +1959,15 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
  *	Allocate a page from the kernel page pool.  When not in
  *	interrupt context and apply the current process NUMA policy.
  *	Returns NULL when no page can be allocated.
- *
- *	Don't call cpuset_update_task_memory_state() unless
- *	1) it's ok to take cpuset_sem (can WAIT), and
- *	2) allocating for current task (not interrupt).
  */
 struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 {
 	struct mempolicy *pol = &default_policy;
 	struct page *page;
-	unsigned int cpuset_mems_cookie;
 
 	if (!in_interrupt() && !(gfp & __GFP_THISNODE))
 		pol = get_task_policy(current);
 
-retry_cpuset:
-	cpuset_mems_cookie = read_mems_allowed_begin();
-
 	/*
 	 * No reference counting needed for current->mempolicy
 	 * nor system default_policy
@@ -1992,9 +1979,6 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 				policy_node(gfp, pol, numa_node_id()),
 				policy_nodemask(gfp, pol));
 
-	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
-		goto retry_cpuset;
-
 	return page;
 }
 EXPORT_SYMBOL(alloc_pages_current);
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
