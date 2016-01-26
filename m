Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0CF6B0254
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:46:30 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id n5so128342073wmn.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:46:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 70si5281876wmv.76.2016.01.26.04.46.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 03/14] tools, perf: make gfp_compact_table up to date
Date: Tue, 26 Jan 2016 13:45:42 +0100
Message-Id: <1453812353-26744-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

When updating tracing's show_gfp_flags() I have noticed that perf's
gfp_compact_table is also outdated. Fill in the missing flags and place a
note in gfp.h to increase chance that future updates are synced. Convert the
__GFP_X flags from "GFP_X" to "__GFP_X" strings in line with the previous
patch.

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
Cc: Michal Hocko <mhocko@suse.com>
---
 include/linux/gfp.h       |  2 +-
 tools/perf/builtin-kmem.c | 47 ++++++++++++++++++++++++++++-------------------
 2 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index e5f7d222177d..8dbface7ad59 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -11,7 +11,7 @@ struct vm_area_struct;
 
 /*
  * In case of changes, please don't forget to update
- * include/trace/events/gfpflags.h
+ * include/trace/events/gfpflags.h and tools/perf/builtin-kmem.c
  */
 
 /* Plain integer GFP bitmasks. Do not use this directly. */
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index 118010553d0c..778cdc02563a 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -612,30 +612,39 @@ static const struct {
 	{ "GFP_HIGHUSER",		"HU" },
 	{ "GFP_USER",			"U" },
 	{ "GFP_TEMPORARY",		"TMP" },
+	{ "GFP_KERNEL_ACCOUNT",		"KAC" },
 	{ "GFP_KERNEL",			"K" },
 	{ "GFP_NOFS",			"NF" },
 	{ "GFP_ATOMIC",			"A" },
 	{ "GFP_NOIO",			"NI" },
-	{ "GFP_HIGH",			"H" },
-	{ "GFP_WAIT",			"W" },
-	{ "GFP_IO",			"I" },
-	{ "GFP_COLD",			"CO" },
-	{ "GFP_NOWARN",			"NWR" },
-	{ "GFP_REPEAT",			"R" },
-	{ "GFP_NOFAIL",			"NF" },
-	{ "GFP_NORETRY",		"NR" },
-	{ "GFP_COMP",			"C" },
-	{ "GFP_ZERO",			"Z" },
-	{ "GFP_NOMEMALLOC",		"NMA" },
-	{ "GFP_MEMALLOC",		"MA" },
-	{ "GFP_HARDWALL",		"HW" },
-	{ "GFP_THISNODE",		"TN" },
-	{ "GFP_RECLAIMABLE",		"RC" },
-	{ "GFP_MOVABLE",		"M" },
-	{ "GFP_NOTRACK",		"NT" },
-	{ "GFP_NO_KSWAPD",		"NK" },
-	{ "GFP_OTHER_NODE",		"ON" },
 	{ "GFP_NOWAIT",			"NW" },
+	{ "GFP_DMA",			"D" },
+	{ "__GFP_HIGHMEM",		"HM" },
+	{ "GFP_DMA32",			"D32" },
+	{ "__GFP_HIGH",			"H" },
+	{ "__GFP_ATOMIC",		"_A" },
+	{ "__GFP_IO",			"I" },
+	{ "__GFP_FS",			"F" },
+	{ "__GFP_COLD",			"CO" },
+	{ "__GFP_NOWARN",		"NWR" },
+	{ "__GFP_REPEAT",		"R" },
+	{ "__GFP_NOFAIL",		"NF" },
+	{ "__GFP_NORETRY",		"NR" },
+	{ "__GFP_COMP",			"C" },
+	{ "__GFP_ZERO",			"Z" },
+	{ "__GFP_NOMEMALLOC",		"NMA" },
+	{ "__GFP_MEMALLOC",		"MA" },
+	{ "__GFP_HARDWALL",		"HW" },
+	{ "__GFP_THISNODE",		"TN" },
+	{ "__GFP_RECLAIMABLE",		"RC" },
+	{ "__GFP_MOVABLE",		"M" },
+	{ "__GFP_ACCOUNT",		"AC" },
+	{ "__GFP_NOTRACK",		"NT" },
+	{ "__GFP_WRITE",		"WR" },
+	{ "__GFP_RECLAIM",		"R" },
+	{ "__GFP_DIRECT_RECLAIM",	"DR" },
+	{ "__GFP_KSWAPD_RECLAIM",	"KR" },
+	{ "__GFP_OTHER_NODE",		"ON" },
 };
 
 static size_t max_gfp_len;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
