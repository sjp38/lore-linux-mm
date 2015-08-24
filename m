Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE946B0259
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:10:06 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so48116602wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:10:05 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id z17si31651962wjr.115.2015.08.24.05.09.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 05:09:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 9A3C799115
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:09:53 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 06/12] mm, page_alloc: Use masks and shifts when converting GFP flags to migrate types
Date: Mon, 24 Aug 2015 13:09:45 +0100
Message-Id: <1440418191-10894-7-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This patch redefines which GFP bits are used for specifying mobility and
the order of the migrate types. Once redefined it's possible to convert
GFP flags to a migrate type with a simple mask and shift. The only downside
is that readers of OOM kill messages and allocation failures may have been
used to the existing values but scripts/gfp-translate will help.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/gfp.h    | 12 +++++++-----
 include/linux/mmzone.h |  2 +-
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index ad35f300b9a4..a10347ca5053 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -14,7 +14,7 @@ struct vm_area_struct;
 #define ___GFP_HIGHMEM		0x02u
 #define ___GFP_DMA32		0x04u
 #define ___GFP_MOVABLE		0x08u
-#define ___GFP_WAIT		0x10u
+#define ___GFP_RECLAIMABLE	0x10u
 #define ___GFP_HIGH		0x20u
 #define ___GFP_IO		0x40u
 #define ___GFP_FS		0x80u
@@ -29,7 +29,7 @@ struct vm_area_struct;
 #define ___GFP_NOMEMALLOC	0x10000u
 #define ___GFP_HARDWALL		0x20000u
 #define ___GFP_THISNODE		0x40000u
-#define ___GFP_RECLAIMABLE	0x80000u
+#define ___GFP_WAIT		0x80000u
 #define ___GFP_NOACCOUNT	0x100000u
 #define ___GFP_NOTRACK		0x200000u
 #define ___GFP_NO_KSWAPD	0x400000u
@@ -123,6 +123,7 @@ struct vm_area_struct;
 
 /* This mask makes up all the page movable related flags */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
+#define GFP_MOVABLE_SHIFT 3
 
 /* Control page allocator reclaim behavior */
 #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
@@ -149,14 +150,15 @@ struct vm_area_struct;
 /* Convert GFP flags to their corresponding migrate type */
 static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 {
-	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
+	VM_WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
+	BUILD_BUG_ON((1UL << GFP_MOVABLE_SHIFT) != ___GFP_MOVABLE);
+	BUILD_BUG_ON((___GFP_MOVABLE >> GFP_MOVABLE_SHIFT) != MIGRATE_MOVABLE);
 
 	if (unlikely(page_group_by_mobility_disabled))
 		return MIGRATE_UNMOVABLE;
 
 	/* Group based on mobility */
-	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
-		((gfp_flags & __GFP_RECLAIMABLE) != 0);
+	return (gfp_flags & GFP_MOVABLE_MASK) >> GFP_MOVABLE_SHIFT;
 }
 
 #ifdef CONFIG_HIGHMEM
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 99cf4209cd45..fc0457d005f8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -37,8 +37,8 @@
 
 enum {
 	MIGRATE_UNMOVABLE,
-	MIGRATE_RECLAIMABLE,
 	MIGRATE_MOVABLE,
+	MIGRATE_RECLAIMABLE,
 	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
 	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
 #ifdef CONFIG_CMA
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
