Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3126B0005
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:03:38 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l126so55804040wml.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 01:03:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m197si10670699wmd.63.2015.12.18.01.03.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 01:03:37 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 03/14] tools, perf: make gfp_compact_table up to date
Date: Fri, 18 Dec 2015 10:03:15 +0100
Message-Id: <1450429406-7081-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
References: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

When updating tracing's show_gfp_flags() I have noticed that perf's
gfp_compact_table is also outdated. Fill in the missing flags and place a
note in gfp.h to increase chance that future updates are synced.

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
Cc: Michal Hocko <mhocko@suse.cz>
---
 include/linux/gfp.h       |  2 +-
 tools/perf/builtin-kmem.c | 11 ++++++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6ffee7f93af7..eed323f58547 100644
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
index 93ce665f976f..acb0d011803a 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -616,9 +616,13 @@ static const struct {
 	{ "GFP_NOFS",			"NF" },
 	{ "GFP_ATOMIC",			"A" },
 	{ "GFP_NOIO",			"NI" },
+	{ "GFP_NOWAIT",			"NW" },
+	{ "GFP_DMA",			"D" },
+	{ "GFP_DMA32",			"D32" },
 	{ "GFP_HIGH",			"H" },
-	{ "GFP_WAIT",			"W" },
+	{ "__GFP_ATOMIC",		"_A" },
 	{ "GFP_IO",			"I" },
+	{ "GFP_FS",			"F" },
 	{ "GFP_COLD",			"CO" },
 	{ "GFP_NOWARN",			"NWR" },
 	{ "GFP_REPEAT",			"R" },
@@ -633,9 +637,10 @@ static const struct {
 	{ "GFP_RECLAIMABLE",		"RC" },
 	{ "GFP_MOVABLE",		"M" },
 	{ "GFP_NOTRACK",		"NT" },
-	{ "GFP_NO_KSWAPD",		"NK" },
+	{ "GFP_WRITE",			"WR" },
+	{ "GFP_DIRECT_RECLAIM",		"DR" },
+	{ "GFP_KSWAPD_RECLAIM",		"KR" },
 	{ "GFP_OTHER_NODE",		"ON" },
-	{ "GFP_NOWAIT",			"NW" },
 };
 
 static size_t max_gfp_len;
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
