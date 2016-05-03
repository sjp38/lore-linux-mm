Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC6D76B025F
	for <linux-mm@kvack.org>; Tue,  3 May 2016 01:23:15 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so15028302pac.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:15 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id 20si2321171pfp.114.2016.05.02.22.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 22:23:15 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id xk12so4965273pac.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 22:23:14 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 3/6] mm/page_owner: copy last_migrate_reason in copy_page_owner()
Date: Tue,  3 May 2016 14:23:01 +0900
Message-Id: <1462252984-8524-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, copy_page_owner() doesn't copy all the owner information.
It skips last_migrate_reason because copy_page_owner() is used for
migration and it will be properly set soon. But, following patch
will use copy_page_owner() and this skip will cause the problem that
allocated page has uninitialied last_migrate_reason. To prevent it,
this patch also copy last_migrate_reason in copy_page_owner().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_owner.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 792b56d..6693959 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -101,6 +101,7 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 
 	new_ext->order = old_ext->order;
 	new_ext->gfp_mask = old_ext->gfp_mask;
+	new_ext->last_migrate_reason = old_ext->last_migrate_reason;
 	new_ext->nr_entries = old_ext->nr_entries;
 
 	for (i = 0; i < ARRAY_SIZE(new_ext->trace_entries); i++)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
