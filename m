Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE4E6B0258
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:52:52 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so109983809wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:52:52 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id eo6si16221950wib.90.2015.09.21.03.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 03:52:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 2EA2099020
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:52:44 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 04/10] mm, page_alloc: Use masks and shifts when converting GFP flags to migrate types
Date: Mon, 21 Sep 2015 11:52:36 +0100
Message-Id: <1442832762-7247-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/gfp.h    | 12 +++++++-----
 include/linux/mmzone.h |  2 +-
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f92cbd2f4450..440fca3e7e5d 100644
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
@@ -126,6 +126,7 @@ struct vm_area_struct;
 
 /* This mask makes up all the page movable related flags */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
+#define GFP_MOVABLE_SHIFT 3
 
 /* Control page allocator reclaim behavior */
 #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
@@ -152,14 +153,15 @@ struct vm_area_struct;
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
index 8687467a6e84..b489e0b5ab48 100644
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
