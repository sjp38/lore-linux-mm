Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECAEE6B16E9
	for <linux-mm@kvack.org>; Sun, 19 Aug 2018 23:22:09 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x204-v6so13765785qka.6
        for <linux-mm@kvack.org>; Sun, 19 Aug 2018 20:22:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s1-v6si2744212qta.330.2018.08.19.20.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Aug 2018 20:22:08 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise || always
Date: Sun, 19 Aug 2018 23:22:04 -0400
Message-Id: <20180820032204.9591-3-aarcange@redhat.com>
In-Reply-To: <20180820032204.9591-1-aarcange@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

qemu uses MADV_HUGEPAGE which allows direct compaction (i.e.
__GFP_DIRECT_RECLAIM is set).

The problem is that direct compaction combined with the NUMA
__GFP_THISNODE logic in mempolicy.c is telling reclaim to swap very
hard the local node, instead of failing the allocation if there's no
THP available in the local node.

Such logic was ok until __GFP_THISNODE was added to the THP allocation
path even with MPOL_DEFAULT.

The idea behind the __GFP_THISNODE addition, is that it is better to
provide local memory in PAGE_SIZE units than to use remote NUMA THP
backed memory. That largely depends on the remote latency though, on
threadrippers for example the overhead is relatively low in my
experience.

The combination of __GFP_THISNODE and __GFP_DIRECT_RECLAIM results in
extremely slow qemu startup with vfio, if the VM is larger than the
size of one host NUMA node. This is because it will try very hard to
unsuccessfully swapout get_user_pages pinned pages as result of the
__GFP_THISNODE being set, instead of falling back to PAGE_SIZE
allocations and instead of trying to allocate THP on other nodes (it
would be even worse without vfio type1 GUP pins of course, except it'd
be swapping heavily instead).

It's very easy to reproduce this by setting
transparent_hugepage/defrag to "always", even with a simple memhog.

1) This can be fixed by retaining the __GFP_THISNODE logic also for
   __GFP_DIRECT_RELCAIM by allowing only one compaction run. Not even
   COMPACT_SKIPPED (i.e. compaction failing because not enough free
   memory in the zone) should be allowed to invoke reclaim.

2) An alternative is not use __GFP_THISNODE if __GFP_DIRECT_RELCAIM
   has been set by the caller (i.e. MADV_HUGEPAGE or
   defrag="always"). That would keep the NUMA locality restriction
   only when __GFP_DIRECT_RECLAIM is not set by the caller. So THP
   will be provided from remote nodes if available before falling back
   to PAGE_SIZE units in the local node, but an app using defrag =
   always (or madvise with MADV_HUGEPAGE) supposedly prefers that.

These are the results of 1) (higher GB/s is better).

Finished: 30 GB mapped, 10.188535s elapsed, 2.94GB/s
Finished: 34 GB mapped, 12.274777s elapsed, 2.77GB/s
Finished: 38 GB mapped, 13.847840s elapsed, 2.74GB/s
Finished: 42 GB mapped, 14.288587s elapsed, 2.94GB/s

Finished: 30 GB mapped, 8.907367s elapsed, 3.37GB/s
Finished: 34 GB mapped, 10.724797s elapsed, 3.17GB/s
Finished: 38 GB mapped, 14.272882s elapsed, 2.66GB/s
Finished: 42 GB mapped, 13.929525s elapsed, 3.02GB/s

These are the results of 2) (higher GB/s is better).

Finished: 30 GB mapped, 10.163159s elapsed, 2.95GB/s
Finished: 34 GB mapped, 11.806526s elapsed, 2.88GB/s
Finished: 38 GB mapped, 10.369081s elapsed, 3.66GB/s
Finished: 42 GB mapped, 12.357719s elapsed, 3.40GB/s

Finished: 30 GB mapped, 8.251396s elapsed, 3.64GB/s
Finished: 34 GB mapped, 12.093030s elapsed, 2.81GB/s
Finished: 38 GB mapped, 11.824903s elapsed, 3.21GB/s
Finished: 42 GB mapped, 15.950661s elapsed, 2.63GB/s

This is current upstream (higher GB/s is better).

Finished: 30 GB mapped, 8.821632s elapsed, 3.40GB/s
Finished: 34 GB mapped, 341.979543s elapsed, 0.10GB/s
Finished: 38 GB mapped, 761.933231s elapsed, 0.05GB/s
Finished: 42 GB mapped, 1188.409235s elapsed, 0.04GB/s

vfio is a good test because by pinning all memory it avoids the
swapping and reclaim only wastes CPU, a memhog based test would
created swapout storms and supposedly show a bigger stddev.

What is better between 1) and 2) depends on the hardware and on the
software. Virtualization EPT/NTP gets a bigger boost from THP as well
than host applications.

This commit implements 1).

Reported-by: Alex Williamson <alex.williamson@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/gfp.h | 18 ++++++++++++++++++
 mm/mempolicy.c      | 12 +++++++++++-
 mm/page_alloc.c     |  4 ++++
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index a6afcec53795..3c04d5d90e6d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -44,6 +44,7 @@ struct vm_area_struct;
 #else
 #define ___GFP_NOLOCKDEP	0
 #endif
+#define ___GFP_ONLY_COMPACT	0x1000000u
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -178,6 +179,21 @@ struct vm_area_struct;
  *   definitely preferable to use the flag rather than opencode endless
  *   loop around allocator.
  *   Using this flag for costly allocations is _highly_ discouraged.
+ *
+ * __GFP_ONLY_COMPACT: Only invoke compaction. Do not try to succeed
+ * the allocation by freeing memory. Never risk to free any
+ * "PAGE_SIZE" memory unit even if compaction failed specifically
+ * because of not enough free pages in the zone. This only makes sense
+ * only in combination with __GFP_THISNODE (enforced with a
+ * VM_WARN_ON), to restrict the THP allocation in the local node that
+ * triggered the page fault and fallback into PAGE_SIZE allocations in
+ * the same node. We don't want to invoke reclaim because there may be
+ * plenty of free memory already in the local node. More importantly
+ * there may be even plenty of free THP available in remote nodes so
+ * we should allocate those if something instead of reclaiming any
+ * memory in the local node. Implementation detail: set ___GFP_NORETRY
+ * too so that ___GFP_ONLY_COMPACT only needs to be checked in a slow
+ * path.
  */
 #define __GFP_IO	((__force gfp_t)___GFP_IO)
 #define __GFP_FS	((__force gfp_t)___GFP_FS)
@@ -187,6 +203,8 @@ struct vm_area_struct;
 #define __GFP_RETRY_MAYFAIL	((__force gfp_t)___GFP_RETRY_MAYFAIL)
 #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)
 #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY)
+#define __GFP_ONLY_COMPACT	((__force gfp_t)(___GFP_NORETRY | \
+						 ___GFP_ONLY_COMPACT))
 
 /*
  * Action modifiers
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d6512ef28cde..6bf839f20dcc 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2047,8 +2047,18 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 
 		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
+			/*
+			 * We restricted the allocation to the
+			 * hpage_node so we must use
+			 * __GFP_ONLY_COMPACT to allow at most a
+			 * compaction attempt and not ever get into
+			 * reclaim or it'll swap heavily with
+			 * transparent_hugepage/defrag = always (or
+			 * madvise under MADV_HUGEPAGE).
+			 */
 			page = __alloc_pages_node(hpage_node,
-						gfp | __GFP_THISNODE, order);
+						  gfp | __GFP_THISNODE |
+						  __GFP_ONLY_COMPACT, order);
 			goto out;
 		}
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a790ef4be74e..01a5c2bd0860 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4144,6 +4144,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 			 */
 			if (compact_result == COMPACT_DEFERRED)
 				goto nopage;
+			if (gfp_mask & __GFP_ONLY_COMPACT) {
+				VM_WARN_ON(!(gfp_mask & __GFP_THISNODE));
+				goto nopage;
+			}
 
 			/*
 			 * Looks like reclaim/compaction is worth trying, but
