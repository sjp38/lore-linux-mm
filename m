Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9EF6B0257
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:46:37 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l65so102515427wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:46:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si4173135wmd.71.2016.01.26.04.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 02/14] mm, tracing: make show_gfp_flags() up to date
Date: Tue, 26 Jan 2016 13:45:41 +0100
Message-Id: <1453812353-26744-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

The show_gfp_flags() macro provides human-friendly printing of gfp flags in
tracepoints. However, it is somewhat out of date and missing several flags.
This patches fills in the missing flags, and distinguishes properly between
GFP_ATOMIC and __GFP_ATOMIC which were both translated to "GFP_ATOMIC".
More generally, all __GFP_X flags which were previously printed as GFP_X, are
now printed as __GFP_X, since ommiting the underscores results in output that
doesn't actually match the source code, and can only lead to confusion. Where
both variants are defined equal (e.g. _DMA and _DMA32), the variant without
underscores are preferred.

Also add a note in gfp.h so hopefully future changes will be synced better.

__GFP_MOVABLE is defined twice in include/linux/gfp.h with different comments.
Leave just the newer one, which was intended to replace the old one.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Reviewed-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/gfp.h             |  6 ++++-
 include/trace/events/gfpflags.h | 53 ++++++++++++++++++++++++-----------------
 2 files changed, 36 insertions(+), 23 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 28ad5f6494b0..e5f7d222177d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -9,6 +9,11 @@
 
 struct vm_area_struct;
 
+/*
+ * In case of changes, please don't forget to update
+ * include/trace/events/gfpflags.h
+ */
+
 /* Plain integer GFP bitmasks. Do not use this directly. */
 #define ___GFP_DMA		0x01u
 #define ___GFP_HIGHMEM		0x02u
@@ -48,7 +53,6 @@ struct vm_area_struct;
 #define __GFP_DMA	((__force gfp_t)___GFP_DMA)
 #define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
 #define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
-#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* Page is movable */
 #define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
 #define GFP_ZONEMASK	(__GFP_DMA|__GFP_HIGHMEM|__GFP_DMA32|__GFP_MOVABLE)
 
diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
index dde6bf092c8a..f53b216c9311 100644
--- a/include/trace/events/gfpflags.h
+++ b/include/trace/events/gfpflags.h
@@ -11,33 +11,42 @@
 #define show_gfp_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
 	{(unsigned long)GFP_TRANSHUGE,		"GFP_TRANSHUGE"},	\
-	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, \
+	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"},\
 	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
 	{(unsigned long)GFP_USER,		"GFP_USER"},		\
 	{(unsigned long)GFP_TEMPORARY,		"GFP_TEMPORARY"},	\
+	{(unsigned long)GFP_KERNEL_ACCOUNT,	"GFP_KERNEL_ACCOUNT"},	\
 	{(unsigned long)GFP_KERNEL,		"GFP_KERNEL"},		\
 	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
 	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		\
 	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		\
-	{(unsigned long)__GFP_HIGH,		"GFP_HIGH"},		\
-	{(unsigned long)__GFP_ATOMIC,		"GFP_ATOMIC"},		\
-	{(unsigned long)__GFP_IO,		"GFP_IO"},		\
-	{(unsigned long)__GFP_COLD,		"GFP_COLD"},		\
-	{(unsigned long)__GFP_NOWARN,		"GFP_NOWARN"},		\
-	{(unsigned long)__GFP_REPEAT,		"GFP_REPEAT"},		\
-	{(unsigned long)__GFP_NOFAIL,		"GFP_NOFAIL"},		\
-	{(unsigned long)__GFP_NORETRY,		"GFP_NORETRY"},		\
-	{(unsigned long)__GFP_COMP,		"GFP_COMP"},		\
-	{(unsigned long)__GFP_ZERO,		"GFP_ZERO"},		\
-	{(unsigned long)__GFP_NOMEMALLOC,	"GFP_NOMEMALLOC"},	\
-	{(unsigned long)__GFP_MEMALLOC,		"GFP_MEMALLOC"},	\
-	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
-	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
-	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
-	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
-	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
-	{(unsigned long)__GFP_DIRECT_RECLAIM,	"GFP_DIRECT_RECLAIM"},	\
-	{(unsigned long)__GFP_KSWAPD_RECLAIM,	"GFP_KSWAPD_RECLAIM"},	\
-	{(unsigned long)__GFP_OTHER_NODE,	"GFP_OTHER_NODE"}	\
-	) : "GFP_NOWAIT"
+	{(unsigned long)GFP_NOWAIT,		"GFP_NOWAIT"},		\
+	{(unsigned long)GFP_DMA,		"GFP_DMA"},		\
+	{(unsigned long)__GFP_HIGHMEM,		"__GFP_HIGHMEM"},	\
+	{(unsigned long)GFP_DMA32,		"GFP_DMA32"},		\
+	{(unsigned long)__GFP_HIGH,		"__GFP_HIGH"},		\
+	{(unsigned long)__GFP_ATOMIC,		"__GFP_ATOMIC"},	\
+	{(unsigned long)__GFP_IO,		"__GFP_IO"},		\
+	{(unsigned long)__GFP_FS,		"__GFP_FS"},		\
+	{(unsigned long)__GFP_COLD,		"__GFP_COLD"},		\
+	{(unsigned long)__GFP_NOWARN,		"__GFP_NOWARN"},	\
+	{(unsigned long)__GFP_REPEAT,		"__GFP_REPEAT"},	\
+	{(unsigned long)__GFP_NOFAIL,		"__GFP_NOFAIL"},	\
+	{(unsigned long)__GFP_NORETRY,		"__GFP_NORETRY"},	\
+	{(unsigned long)__GFP_COMP,		"__GFP_COMP"},		\
+	{(unsigned long)__GFP_ZERO,		"__GFP_ZERO"},		\
+	{(unsigned long)__GFP_NOMEMALLOC,	"__GFP_NOMEMALLOC"},	\
+	{(unsigned long)__GFP_MEMALLOC,		"__GFP_MEMALLOC"},	\
+	{(unsigned long)__GFP_HARDWALL,		"__GFP_HARDWALL"},	\
+	{(unsigned long)__GFP_THISNODE,		"__GFP_THISNODE"},	\
+	{(unsigned long)__GFP_RECLAIMABLE,	"__GFP_RECLAIMABLE"},	\
+	{(unsigned long)__GFP_MOVABLE,		"__GFP_MOVABLE"},	\
+	{(unsigned long)__GFP_ACCOUNT,		"__GFP_ACCOUNT"},	\
+	{(unsigned long)__GFP_NOTRACK,		"__GFP_NOTRACK"},	\
+	{(unsigned long)__GFP_WRITE,		"__GFP_WRITE"},		\
+	{(unsigned long)__GFP_RECLAIM,		"__GFP_RECLAIM"},	\
+	{(unsigned long)__GFP_DIRECT_RECLAIM,	"__GFP_DIRECT_RECLAIM"},\
+	{(unsigned long)__GFP_KSWAPD_RECLAIM,	"__GFP_KSWAPD_RECLAIM"},\
+	{(unsigned long)__GFP_OTHER_NODE,	"__GFP_OTHER_NODE"}	\
+	) : "none"
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
