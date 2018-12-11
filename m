Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC8998E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:30:09 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w15so7010261edl.21
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:30:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k21-v6si805323ejp.31.2018.12.11.06.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 06:30:08 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 1/3] mm, thp: restore __GFP_NORETRY for madvised thp fault allocations
Date: Tue, 11 Dec 2018 15:29:39 +0100
Message-Id: <20181211142941.20500-2-vbabka@suse.cz>
In-Reply-To: <20181211142941.20500-1-vbabka@suse.cz>
References: <20181211142941.20500-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

Commit 2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and
madvised allocations") intended to make THP faults in MADV_HUGEPAGE areas more
successful for processes that indicate that they are willing to pay a higher
initial setup cost for long-term THP benefits. In the current page allocator
implementation this means that the allocations will try to use reclaim and the
more costly sync compaction mode, in case the initial direct async compaction
fails.

However, THP faults also include __GFP_THISNODE, which, combined with direct
reclaim, can result in a node-reclaim-like local node thrashing behavior, as
reported by Andrea [1].

While this patch is not a full fix, the first step is to restore __GFP_NORETRY
for madvised THP faults. The expected downside are potentially worse THP
fault success rates for the madvised areas, which will have to then rely more
on khugepaged. For khugepaged, __GFP_NORETRY is not restored, as its activity
should be limited enough by sleeping to cause noticeable thrashing.

Note that alloc_new_node_page() and new_page() is probably another candidate as
they handle the migrate_pages(2), resp. mbind(2) syscall, which can thus allow
unprivileged node-reclaim-like behavior.

The patch also updates the comments in alloc_hugepage_direct_gfpmask() because
elsewhere compaction during page fault is called direct compaction, and
'synchronous' refers to the migration mode, which is not used for THP faults.

[1] https://lkml.kernel.org/m/20180820032204.9591-1-aarcange@redhat.com

Reported-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/huge_memory.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5da55b38b1b7..c442b12b060c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -633,24 +633,23 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 {
 	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
 
-	/* Always do synchronous compaction */
+	/* Always try direct compaction */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
+		return GFP_TRANSHUGE | __GFP_NORETRY;
 
 	/* Kick kcompactd and fail quickly */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
 		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
 
-	/* Synchronous compaction if madvised, otherwise kick kcompactd */
+	/* Direct compaction if madvised, otherwise kick kcompactd */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
 		return GFP_TRANSHUGE_LIGHT |
-			(vma_madvised ? __GFP_DIRECT_RECLAIM :
+			(vma_madvised ? (__GFP_DIRECT_RECLAIM | __GFP_NORETRY):
 					__GFP_KSWAPD_RECLAIM);
 
-	/* Only do synchronous compaction if madvised */
+	/* Only do direct compaction if madvised */
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT |
-		       (vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
+		return vma_madvised ? (GFP_TRANSHUGE | __GFP_NORETRY) : GFP_TRANSHUGE_LIGHT;
 
 	return GFP_TRANSHUGE_LIGHT;
 }
-- 
2.19.2
