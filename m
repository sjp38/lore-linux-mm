Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B774D6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 02:42:45 -0500 (EST)
Received: by padhx2 with SMTP id hx2so57225419pad.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:42:45 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id mr9si18249259pbb.183.2015.11.11.23.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 23:42:45 -0800 (PST)
Received: by padhk6 with SMTP id hk6so7436498pad.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:42:44 -0800 (PST)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [PATCH] mm: change trace_mm_vmscan_writepage() proto type
Date: Thu, 12 Nov 2015 15:42:33 +0800
Message-Id: <1447314153-10625-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rostedt@goodmis.org, mingo@redhat.com, namhyung@kernel.org, acme@redhat.com, yalin.wang2010@gmail.com, akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@techsingularity.net, bywxiaobai@163.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Move trace_reclaim_flags() into trace function,
so that we don't need caculate these flags if the trace is disabled.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 include/trace/events/vmscan.h | 7 +++----
 mm/vmscan.c                   | 2 +-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index f66476b..dae7836 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -330,10 +330,9 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 
 TRACE_EVENT(mm_vmscan_writepage,
 
-	TP_PROTO(struct page *page,
-		int reclaim_flags),
+	TP_PROTO(struct page *page),
 
-	TP_ARGS(page, reclaim_flags),
+	TP_ARGS(page),
 
 	TP_STRUCT__entry(
 		__field(unsigned long, pfn)
@@ -342,7 +341,7 @@ TRACE_EVENT(mm_vmscan_writepage,
 
 	TP_fast_assign(
 		__entry->pfn = page_to_pfn(page);
-		__entry->reclaim_flags = reclaim_flags;
+		__entry->reclaim_flags = trace_reclaim_flags(page);
 	),
 
 	TP_printk("page=%p pfn=%lu flags=%s",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a4507ec..83cea53 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -594,7 +594,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			/* synchronous write or broken a_ops? */
 			ClearPageReclaim(page);
 		}
-		trace_mm_vmscan_writepage(page, trace_reclaim_flags(page));
+		trace_mm_vmscan_writepage(page);
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
