Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC4C6B0260
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 09:53:36 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so10776786wjc.6
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:53:36 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id xu5si54550576wjb.254.2016.12.14.06.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 06:53:35 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id xy5so5207323wjc.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:53:34 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] oom, trace: add compaction retry tracepoint
Date: Wed, 14 Dec 2016 15:53:24 +0100
Message-Id: <20161214145324.26261-4-mhocko@kernel.org>
In-Reply-To: <20161214145324.26261-1-mhocko@kernel.org>
References: <20161214145324.26261-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Higher order requests oom debugging is currently quite hard. We do have
some compaction points which can tell us how the compaction is operating
but there is no trace point to tell us about compaction retry logic.
This patch adds a one which will have the following format

            bash-3126  [001] ....  1498.220001: compact_retry: order=9 priority=COMPACT_PRIO_SYNC_LIGHT compaction_result=withdrawn retries=0 max_retries=16 should_retry=0

we can see that the order 9 request is not retried even though we are in
the highest compaction priority mode becase the last compaction attempt
was withdrawn. This means that compaction_zonelist_suitable must have
returned false and there is no suitable zone to compact for this request
and so no need to retry further.

another example would be
           <...>-3137  [001] ....    81.501689: compact_retry: order=9 priority=COMPACT_PRIO_SYNC_LIGHT compaction_result=failed retries=0 max_retries=16 should_retry=0

in this case the order-9 compaction failed to find any suitable
block. We do not retry anymore because this is a costly request
and those do not go below COMPACT_PRIO_SYNC_LIGHT priority.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/mmflags.h | 26 ++++++++++++++++++++++++++
 include/trace/events/oom.h     | 39 +++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c                | 22 ++++++++++++++++------
 3 files changed, 81 insertions(+), 6 deletions(-)

diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 7e4cfede873c..aa4caa6914a9 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -187,8 +187,32 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
 	EM( COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")	\
 	EMe(COMPACT_CONTENDED,		"contended")
+
+/* High-level compaction status feedback */
+#define COMPACTION_FAILED	1
+#define COMPACTION_WITHDRAWN	2
+#define COMPACTION_PROGRESS	3
+
+#define compact_result_to_feedback(result)	\
+({						\
+ 	enum compact_result __result = result;	\
+	(compaction_failed(__result)) ? COMPACTION_FAILED : \
+		(compaction_withdrawn(__result)) ? COMPACTION_WITHDRAWN : COMPACTION_PROGRESS; \
+})
+
+#define COMPACTION_FEEDBACK		\
+	EM(COMPACTION_FAILED,		"failed")	\
+	EM(COMPACTION_WITHDRAWN,	"withdrawn")	\
+	EMe(COMPACTION_PROGRESS,	"progress")
+
+#define COMPACTION_PRIORITY						\
+	EM(COMPACT_PRIO_SYNC_FULL,	"COMPACT_PRIO_SYNC_FULL")	\
+	EM(COMPACT_PRIO_SYNC_LIGHT,	"COMPACT_PRIO_SYNC_LIGHT")	\
+	EMe(COMPACT_PRIO_ASYNC,		"COMPACT_PRIO_ASYNC")
 #else
 #define COMPACTION_STATUS
+#define COMPACTION_PRIORITY
+#define COMPACTION_FEEDBACK
 #endif
 
 #ifdef CONFIG_ZONE_DMA
@@ -226,6 +250,8 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 #define EMe(a, b)	TRACE_DEFINE_ENUM(a);
 
 COMPACTION_STATUS
+COMPACTION_PRIORITY
+COMPACTION_FEEDBACK
 ZONE_TYPE
 
 /*
diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
index 9160da7a26a0..e9d690665b7a 100644
--- a/include/trace/events/oom.h
+++ b/include/trace/events/oom.h
@@ -69,6 +69,45 @@ TRACE_EVENT(reclaim_retry_zone,
 			__entry->no_progress_loops,
 			__entry->wmark_check)
 );
+
+#ifdef CONFIG_COMPACTION
+TRACE_EVENT(compact_retry,
+
+	TP_PROTO(int order,
+		enum compact_priority priority,
+		enum compact_result result,
+		int retries,
+		int max_retries,
+		bool ret),
+
+	TP_ARGS(order, priority, result, retries, max_retries, ret),
+
+	TP_STRUCT__entry(
+		__field(	int, order)
+		__field(	int, priority)
+		__field(	int, result)
+		__field(	int, retries)
+		__field(	int, max_retries)
+		__field(	bool, ret)
+	),
+
+	TP_fast_assign(
+		__entry->order = order;
+		__entry->priority = priority;
+		__entry->result = result;
+		__entry->retries = retries;
+		__entry->max_retries = max_retries;
+		__entry->ret = ret;
+	),
+
+	TP_printk("order=%d priority=%s compaction_result=%s retries=%d max_retries=%d should_retry=%d",
+			__entry->order,
+			__print_symbolic(__entry->priority, COMPACTION_PRIORITY),
+			__print_symbolic(__entry->result, COMPACTION_FEEDBACK),
+			__entry->retries, __entry->max_retries,
+			__entry->ret)
+);
+#endif /* CONFIG_COMPACTION */
 #endif
 
 /* This part must be outside protection */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 23ca951a8380..150245328882 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3201,6 +3201,9 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 {
 	int max_retries = MAX_COMPACT_RETRIES;
 	int min_priority;
+	bool ret = false;
+	int retries = *compaction_retries;
+	enum compact_priority priority = *compact_priority;
 
 	if (!order)
 		return false;
@@ -3222,8 +3225,10 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 * But do not retry if the given zonelist is not suitable for
 	 * compaction.
 	 */
-	if (compaction_withdrawn(compact_result))
-		return compaction_zonelist_suitable(ac, order, alloc_flags);
+	if (compaction_withdrawn(compact_result)) {
+		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
+		goto out;
+	}
 
 	/*
 	 * !costly requests are much more important than __GFP_REPEAT
@@ -3235,8 +3240,10 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 */
 	if (order > PAGE_ALLOC_COSTLY_ORDER)
 		max_retries /= 4;
-	if (*compaction_retries <= max_retries)
-		return true;
+	if (*compaction_retries <= max_retries) {
+		ret = true;
+		goto out;
+	}
 
 	/*
 	 * Make sure there are attempts at the highest priority if we exhausted
@@ -3245,12 +3252,15 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 check_priority:
 	min_priority = (order > PAGE_ALLOC_COSTLY_ORDER) ?
 			MIN_COMPACT_COSTLY_PRIORITY : MIN_COMPACT_PRIORITY;
+
 	if (*compact_priority > min_priority) {
 		(*compact_priority)--;
 		*compaction_retries = 0;
-		return true;
+		ret = true;
 	}
-	return false;
+out:
+	trace_compact_retry(order, priority, compact_result, retries, max_retries, ret);
+	return ret;
 }
 #else
 static inline struct page *
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
