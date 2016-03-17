Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5DAF16B025E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 13:40:58 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id l68so36634668wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 10:40:58 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id 193si3970115wmf.95.2016.03.17.10.40.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 10:40:57 -0700 (PDT)
From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH] mm/page_isolation: fix tracepoint to mirror check function behavior
Date: Thu, 17 Mar 2016 18:40:56 +0100
Message-Id: <1458236456-465-1-git-send-email-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

Page isolation has not failed if the fin pfn extends beyond the end pfn
and test_pages_isolated checks this correctly. Fix the tracepoint to
report the same result as the actual check function.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 include/trace/events/page_isolation.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/trace/events/page_isolation.h b/include/trace/events/page_isolation.h
index 6fb644029c80..8738a78e6bf4 100644
--- a/include/trace/events/page_isolation.h
+++ b/include/trace/events/page_isolation.h
@@ -29,7 +29,7 @@ TRACE_EVENT(test_pages_isolated,
 
 	TP_printk("start_pfn=0x%lx end_pfn=0x%lx fin_pfn=0x%lx ret=%s",
 		__entry->start_pfn, __entry->end_pfn, __entry->fin_pfn,
-		__entry->end_pfn == __entry->fin_pfn ? "success" : "fail")
+		__entry->end_pfn <= __entry->fin_pfn ? "success" : "fail")
 );
 
 #endif /* _TRACE_PAGE_ISOLATION_H */
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
