Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 629F06B0255
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:46:32 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id n5so128343706wmn.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:46:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si1561486wjx.242.2016.01.26.04.46.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 01/14] tracepoints: move trace_print_flags definitions to tracepoint-defs.h
Date: Tue, 26 Jan 2016 13:45:40 +0100
Message-Id: <1453812353-26744-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

The following patch will need to declare array of struct trace_print_flags
in a header. To prevent this header from pulling in all of RCU through
trace_events.h, move the struct trace_print_flags{_64} definitions to the new
lightweight tracepoint-defs.h header.

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
 include/linux/trace_events.h    | 10 ----------
 include/linux/tracepoint-defs.h | 14 ++++++++++++--
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
index 429fdfc3baf5..d91404f89ff2 100644
--- a/include/linux/trace_events.h
+++ b/include/linux/trace_events.h
@@ -15,16 +15,6 @@ struct tracer;
 struct dentry;
 struct bpf_prog;
 
-struct trace_print_flags {
-	unsigned long		mask;
-	const char		*name;
-};
-
-struct trace_print_flags_u64 {
-	unsigned long long	mask;
-	const char		*name;
-};
-
 const char *trace_print_flags_seq(struct trace_seq *p, const char *delim,
 				  unsigned long flags,
 				  const struct trace_print_flags *flag_array);
diff --git a/include/linux/tracepoint-defs.h b/include/linux/tracepoint-defs.h
index e1ee97c713bf..4ac89acb6136 100644
--- a/include/linux/tracepoint-defs.h
+++ b/include/linux/tracepoint-defs.h
@@ -3,13 +3,23 @@
 
 /*
  * File can be included directly by headers who only want to access
- * tracepoint->key to guard out of line trace calls. Otherwise
- * linux/tracepoint.h should be used.
+ * tracepoint->key to guard out of line trace calls, or the definition of
+ * trace_print_flags{_u64}. Otherwise linux/tracepoint.h should be used.
  */
 
 #include <linux/atomic.h>
 #include <linux/static_key.h>
 
+struct trace_print_flags {
+	unsigned long		mask;
+	const char		*name;
+};
+
+struct trace_print_flags_u64 {
+	unsigned long long	mask;
+	const char		*name;
+};
+
 struct tracepoint_func {
 	void *func;
 	void *data;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
