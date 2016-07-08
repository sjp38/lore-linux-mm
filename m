Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 635E4828E2
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 16:00:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so19022512wma.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 13:00:38 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id w7si3829342wjk.199.2016.07.08.13.00.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 13:00:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 64B2499502
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 20:00:32 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/3] mm, meminit: Ensure node is online before checking whether pages are uninitialised
Date: Fri,  8 Jul 2016 21:00:31 +0100
Message-Id: <1468008031-3848-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468008031-3848-1-git-send-email-mgorman@techsingularity.net>
References: <1468008031-3848-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

early_page_uninitialised looks up an arbitrary PFN. While a machine without
node 0 will boot with "mm, page_alloc: Always return a valid node from
early_pfn_to_nid", it works because it assumes that nodes are always in
PFN order. This is not guaranteed so this patch adds robustness by always
checking if the node being checked is online.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Cc: <stable@vger.kernel.org> # 4.2+
---
 mm/page_alloc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5a616de1adca..03c9322da942 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -286,7 +286,9 @@ static inline void reset_deferred_meminit(pg_data_t *pgdat)
 /* Returns true if the struct page for the pfn is uninitialised */
 static inline bool __meminit early_page_uninitialised(unsigned long pfn)
 {
-	if (pfn >= NODE_DATA(early_pfn_to_nid(pfn))->first_deferred_pfn)
+	int nid = early_pfn_to_nid(pfn);
+
+	if (node_online(nid) && pfn >= NODE_DATA(nid)->first_deferred_pfn)
 		return true;
 
 	return false;
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
