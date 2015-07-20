Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id A83B69003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:00:35 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so89201675wib.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:00:35 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id pc3si12010796wic.24.2015.07.20.01.00.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 01:00:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 135BA98C18
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:00:24 +0000 (UTC)
From: Mel Gorman <mgorman@suse.com>
Subject: [PATCH 07/10] mm, page_alloc: Use masks and shifts when converting GFP flags to migrate types
Date: Mon, 20 Jul 2015 09:00:16 +0100
Message-Id: <1437379219-9160-8-git-send-email-mgorman@suse.com>
In-Reply-To: <1437379219-9160-1-git-send-email-mgorman@suse.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Mel Gorman <mgorman@suse.de>

This patch redefines which GFP bits are used for specifying mobility and
the order of the migrate types. Once redefined it's possible to convert
GFP flags to a migrate type with a simple mask and shift. The only downside
is that readers of OOM kill messages and allocation failures may have been
used to the existing values but scripts/gfp-translate will help.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h    | 12 +++++++-----
 include/linux/mmzone.h |  2 +-
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 5a27bbba63ed..ec00a8263f5b 100644
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
+	BUILD_BUG_ON(1UL << GFP_MOVABLE_SHIFT != ___GFP_MOVABLE);
+	BUILD_BUG_ON(___GFP_MOVABLE >> GFP_MOVABLE_SHIFT != MIGRATE_MOVABLE);
 
 	if (page_group_by_mobility_disabled())
 		return MIGRATE_UNMOVABLE;
 
 	/* Group based on mobility */
-	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
-		((gfp_flags & __GFP_RECLAIMABLE) != 0);
+	return (gfp_flags & GFP_MOVABLE_MASK) >> GFP_MOVABLE_SHIFT;
 }
 
 #ifdef CONFIG_HIGHMEM
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c9497519340a..3afd1ca2ca98 100644
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
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
