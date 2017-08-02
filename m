Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1D036B060B
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 13:45:10 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t7so24426171qta.3
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 10:45:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a1si15241364qkb.286.2017.08.02.10.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 10:45:09 -0700 (PDT)
From: Jonathan Toppins <jtoppins@redhat.com>
Subject: [PATCH] mm: ratelimit PFNs busy info message
Date: Wed,  2 Aug 2017 13:44:57 -0400
Message-Id: <499c0f6cc10d6eb829a67f2a4d75b4228a9b356e.1501695897.git.jtoppins@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-rdma@vger.kernel.org, dledford@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, open list <linux-kernel@vger.kernel.org>

The RDMA subsystem can generate several thousand of these messages per
second eventually leading to a kernel crash. Ratelimit these messages
to prevent this crash.

Signed-off-by: Jonathan Toppins <jtoppins@redhat.com>
Reviewed-by: Doug Ledford <dledford@redhat.com>
Tested-by: Doug Ledford <dledford@redhat.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6d30e914afb6..07b7d3060b21 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7666,7 +7666,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
-		pr_info("%s: [%lx, %lx) PFNs busy\n",
+		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
 			__func__, outer_start, end);
 		ret = -EBUSY;
 		goto done;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
