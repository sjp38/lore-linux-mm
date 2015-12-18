Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id BAA776B000A
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:03:45 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p187so55178976wmp.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 01:03:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2si24173537wje.1.2015.12.18.01.03.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 01:03:37 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 02/14] mm, tracing: make show_gfp_flags() up to date
Date: Fri, 18 Dec 2015 10:03:14 +0100
Message-Id: <1450429406-7081-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
References: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

The show_gfp_flags() macro provides human-friendly printing of gfp flags in
tracepoints. However, it is somewhat out of date and missing several flags.
This patches fills in the missing flags, and distinguishes properly between
GFP_ATOMIC and __GFP_ATOMIC which were both translated to "GFP_ATOMIC".

Also add a note in gfp.h so hopefully future changes will be synced better.

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
 include/linux/gfp.h             | 5 +++++
 include/trace/events/gfpflags.h | 9 +++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 91f74e741aa2..6ffee7f93af7 100644
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
diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
index dde6bf092c8a..8395798d97b0 100644
--- a/include/trace/events/gfpflags.h
+++ b/include/trace/events/gfpflags.h
@@ -19,9 +19,13 @@
 	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
 	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		\
 	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		\
+	{(unsigned long)GFP_NOWAIT,		"GFP_NOWAIT"},		\
+	{(unsigned long)__GFP_DMA,		"GFP_DMA"},		\
+	{(unsigned long)__GFP_DMA32,		"GFP_DMA32"},		\
 	{(unsigned long)__GFP_HIGH,		"GFP_HIGH"},		\
-	{(unsigned long)__GFP_ATOMIC,		"GFP_ATOMIC"},		\
+	{(unsigned long)__GFP_ATOMIC,		"__GFP_ATOMIC"},	\
 	{(unsigned long)__GFP_IO,		"GFP_IO"},		\
+	{(unsigned long)__GFP_FS,		"GFP_FS"},		\
 	{(unsigned long)__GFP_COLD,		"GFP_COLD"},		\
 	{(unsigned long)__GFP_NOWARN,		"GFP_NOWARN"},		\
 	{(unsigned long)__GFP_REPEAT,		"GFP_REPEAT"},		\
@@ -36,8 +40,9 @@
 	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
 	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
 	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
+	{(unsigned long)__GFP_WRITE,		"GFP_WRITE"},		\
 	{(unsigned long)__GFP_DIRECT_RECLAIM,	"GFP_DIRECT_RECLAIM"},	\
 	{(unsigned long)__GFP_KSWAPD_RECLAIM,	"GFP_KSWAPD_RECLAIM"},	\
 	{(unsigned long)__GFP_OTHER_NODE,	"GFP_OTHER_NODE"}	\
-	) : "GFP_NOWAIT"
+	) : "none"
 
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
