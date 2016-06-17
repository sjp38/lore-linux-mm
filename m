Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7E52828E5
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:58:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so147697869pfa.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:58:08 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id f1si11067251pfb.251.2016.06.17.00.58.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 00:58:07 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id hf6so5335278pac.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:58:07 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 7/9] mm/page_owner: avoid null pointer dereference
Date: Fri, 17 Jun 2016 16:57:37 +0900
Message-Id: <1466150259-27727-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>

We have dereferenced page_ext before checking it. Lets check it first
and then used it.

Link: http://lkml.kernel.org/r/1465249059-7883-1-git-send-email-sudipm.mukherjee@gmail.com
Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_owner.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index dc92241..ec6dc18 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -295,13 +295,15 @@ void __dump_page_owner(struct page *page)
 		.skip = 0
 	};
 	depot_stack_handle_t handle;
-	gfp_t gfp_mask = page_ext->gfp_mask;
-	int mt = gfpflags_to_migratetype(gfp_mask);
+	gfp_t gfp_mask;
+	int mt;
 
 	if (unlikely(!page_ext)) {
 		pr_alert("There is not page extension available.\n");
 		return;
 	}
+	gfp_mask = page_ext->gfp_mask;
+	mt = gfpflags_to_migratetype(gfp_mask);
 
 	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
 		pr_alert("page_owner info is not active (free page?)\n");
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
