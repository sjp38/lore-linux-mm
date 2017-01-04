Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21DD56B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 05:47:59 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id dh1so52182899wjb.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:47:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 15si77188752wml.145.2017.01.04.02.47.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 02:47:57 -0800 (PST)
Subject: Re: [PATCH 3/3] oom, trace: add compaction retry tracepoint
References: <20161220130135.15719-1-mhocko@kernel.org>
 <20161220130135.15719-4-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6f3a808d-7799-80f5-9c00-4fb996dc31fa@suse.cz>
Date: Wed, 4 Jan 2017 11:47:56 +0100
MIME-Version: 1.0
In-Reply-To: <20161220130135.15719-4-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/20/2016 02:01 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Higher order requests oom debugging is currently quite hard. We do have
> some compaction points which can tell us how the compaction is operating
> but there is no trace point to tell us about compaction retry logic.
> This patch adds a one which will have the following format
> 
>             bash-3126  [001] ....  1498.220001: compact_retry: order=9 priority=COMPACT_PRIO_SYNC_LIGHT compaction_result=withdrawn retries=0 max_retries=16 should_retry=0
> 
> we can see that the order 9 request is not retried even though we are in
> the highest compaction priority mode becase the last compaction attempt
> was withdrawn. This means that compaction_zonelist_suitable must have
> returned false and there is no suitable zone to compact for this request
> and so no need to retry further.
> 
> another example would be
>            <...>-3137  [001] ....    81.501689: compact_retry: order=9 priority=COMPACT_PRIO_SYNC_LIGHT compaction_result=failed retries=0 max_retries=16 should_retry=0
> 
> in this case the order-9 compaction failed to find any suitable
> block. We do not retry anymore because this is a costly request
> and those do not go below COMPACT_PRIO_SYNC_LIGHT priority.
> 
> Changes since v1
> - fix compaction_result into highlevel constants translation as per
>   Vlastimil
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Hmm I've noticed that I didn't suggest the following below here,
although I did for the vmscan tracepoints now. How about adding this
-fix for consistency?

--------8<--------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Wed, 4 Jan 2017 11:44:09 +0100
Subject: [PATCH] oom, trace: add compaction retry tracepoint-fix

Let's print the compaction priorities lower-case and without
prefix for consistency.

Also indent fix in compact_result_to_feedback().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/trace/events/mmflags.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index aa4caa6914a9..e4c3a0febcce 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -195,7 +195,7 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 
 #define compact_result_to_feedback(result)	\
 ({						\
- 	enum compact_result __result = result;	\
+	enum compact_result __result = result;	\
 	(compaction_failed(__result)) ? COMPACTION_FAILED : \
 		(compaction_withdrawn(__result)) ? COMPACTION_WITHDRAWN : COMPACTION_PROGRESS; \
 })
@@ -206,9 +206,9 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 	EMe(COMPACTION_PROGRESS,	"progress")
 
 #define COMPACTION_PRIORITY						\
-	EM(COMPACT_PRIO_SYNC_FULL,	"COMPACT_PRIO_SYNC_FULL")	\
-	EM(COMPACT_PRIO_SYNC_LIGHT,	"COMPACT_PRIO_SYNC_LIGHT")	\
-	EMe(COMPACT_PRIO_ASYNC,		"COMPACT_PRIO_ASYNC")
+	EM(COMPACT_PRIO_SYNC_FULL,	"sync_full")	\
+	EM(COMPACT_PRIO_SYNC_LIGHT,	"sync_light")	\
+	EMe(COMPACT_PRIO_ASYNC,		"async")
 #else
 #define COMPACTION_STATUS
 #define COMPACTION_PRIORITY
-- 
2.11.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
