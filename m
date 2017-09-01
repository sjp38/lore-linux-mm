Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E78BD6B025F
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 11:19:11 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u15so1047435pgb.7
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 08:19:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 59si275032plp.650.2017.09.01.08.19.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 08:19:11 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,page_alloc: apply gfp_allowed_mask before the first allocation attempt.
Date: Fri,  1 Sep 2017 23:11:31 +0900
Message-Id: <1504275091-4427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

We are by error initializing alloc_flags before gfp_allowed_mask is
applied. Apply gfp_allowed_mask before initializing alloc_flags so that
the first allocation attempt uses correct flags.

Fixes: 9cd7555875bb09da ("mm, page_alloc: split alloc_pages_nodemask()")
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6dbc49e..a123dee 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4179,10 +4179,11 @@ struct page *
 {
 	struct page *page;
 	unsigned int alloc_flags = ALLOC_WMARK_LOW;
-	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
+	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = { };
 
 	gfp_mask &= gfp_allowed_mask;
+	alloc_mask = gfp_mask;
 	if (!prepare_alloc_pages(gfp_mask, order, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
 		return NULL;
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
