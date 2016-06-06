Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 302036B007E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 17:37:47 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id jf8so35144917lbc.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 14:37:47 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id e17si7591500wjx.37.2016.06.06.14.37.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 14:37:46 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n184so19613964wmn.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 14:37:45 -0700 (PDT)
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] mm/page_owner: avoid null pointer dereference
Date: Mon,  6 Jun 2016 22:37:39 +0100
Message-Id: <1465249059-7883-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

We have dereferenced page_ext before checking it. Lets check it first
and then used it.

Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---
 mm/page_owner.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 587dcca..8fa5083 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -291,13 +291,15 @@ void __dump_page_owner(struct page *page)
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
