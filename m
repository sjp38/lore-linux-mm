Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF796B0261
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:37:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y84so3937925lfc.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:37:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g129si30335952wmd.47.2016.05.10.00.37.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:37:08 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 06/13] mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations
Date: Tue, 10 May 2016 09:35:56 +0200
Message-Id: <1462865763-22084-7-git-send-email-vbabka@suse.cz>
In-Reply-To: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

After the previous patch, we can distinguish costly allocations that should be
really lightweight, such as THP page faults, with __GFP_NORETRY. This means we
don't need to recognize khugepaged allocations via PF_KTHREAD anymore. We can
also change THP page faults in areas where madvise(MADV_HUGEPAGE) was used to
try as hard as khugepaged, as the process has indicated that it benefits from
THP's and is willing to pay some initial latency costs.

This is implemented by removing __GFP_NORETRY from GFP_TRANSHUGE and applying
it selectively for current GFP_TRANSHUGE users:

* get_huge_zero_page() - the zero page lifetime should be relatively long and
  it's shared by multiple users, so it's worth spending some effort on it.
  __GFP_NORETRY is not added

* alloc_hugepage_khugepaged_gfpmask() - this is khugepaged, so latency is not
  an issue. So if khugepaged "defrag" is enabled (the default), do reclaim
  without __GFP_NORETRY. We can remove the PF_KTHREAD check from page alloc.
  As a side-effect, khugepaged will now no longer check if the initial
  compaction was deferred or contended. This is OK, as khugepaged sleep times
  between collapsion attemps are long enough to prevent noticeable disruption,
  so we should allow it to spend some effort.

* migrate_misplaced_transhuge_page() - already does ~__GFP_RECLAIM, so
  removing __GFP_NORETRY has no effect here

* alloc_hugepage_direct_gfpmask() - vma's with VM_HUGEPAGE (via madvise) are
  now allocating without __GFP_NORETRY. Other vma's keep using __GFP_NORETRY
  if direct reclaim/compaction is at all allowed (by default it's allowed only
  for VM_HUGEPAGE vma's)

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/gfp.h | 3 +--
 mm/huge_memory.c    | 8 +++++---
 mm/page_alloc.c     | 6 ++----
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 570383a41853..0cb09714d960 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -256,8 +256,7 @@ struct vm_area_struct;
 #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
 #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
 #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
-			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
-			 ~__GFP_RECLAIM)
+			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
 
 /* Convert GFP flags to their corresponding migrate type */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a69e1e144050..30a254a5e780 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -882,9 +882,10 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 }
 
 /*
- * If THP is set to always then directly reclaim/compact as necessary
- * If set to defer then do no reclaim and defer to khugepaged
+ * If THP defrag is set to always then directly reclaim/compact as necessary
+ * If set to defer then do only background reclaim/compact and defer to khugepaged
  * If set to madvise and the VMA is flagged then directly reclaim/compact
+ * When direct reclaim/compact is allowed, try a bit harder for flagged VMA's
  */
 static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 {
@@ -896,7 +897,8 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
 		reclaim_flags = __GFP_KSWAPD_RECLAIM;
 	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		reclaim_flags = __GFP_DIRECT_RECLAIM;
+		reclaim_flags = __GFP_DIRECT_RECLAIM |
+					((vma->vm_flags & VM_HUGEPAGE) ? 0 : __GFP_NORETRY);
 
 	return GFP_TRANSHUGE | reclaim_flags;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f5d931e0854a..1a5ff4525a0e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3630,11 +3630,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 			/*
 			 * Looks like reclaim/compaction is worth trying, but
 			 * sync compaction could be very expensive, so keep
-			 * using async compaction, unless it's khugepaged
-			 * trying to collapse.
+			 * using async compaction.
 			 */
-			if (!(current->flags & PF_KTHREAD))
-				migration_mode = MIGRATE_ASYNC;
+			migration_mode = MIGRATE_ASYNC;
 		}
 	}
 
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
