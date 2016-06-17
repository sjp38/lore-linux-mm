Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECBA6B0261
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:57:54 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b126so163491876ite.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:57:54 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id ff3si21083205pab.126.2016.06.17.00.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 00:57:54 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id fg1so5345165pad.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:57:54 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 3/9] mm/page_owner: copy last_migrate_reason in copy_page_owner()
Date: Fri, 17 Jun 2016 16:57:33 +0900
Message-Id: <1466150259-27727-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, copy_page_owner() doesn't copy all the owner information.  It
skips last_migrate_reason because copy_page_owner() is used for migration
and it will be properly set soon.  But, following patch will use
copy_page_owner() and this skip will cause the problem that allocated page
has uninitialied last_migrate_reason.  To prevent it, this patch also copy
last_migrate_reason in copy_page_owner().

Link: http://lkml.kernel.org/r/1464230275-25791-3-git-send-email-iamjoonsoo.kim@lge.com
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Alexander Potapenko <glider@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/page_owner.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index c6cda3e..73e202f 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -118,6 +118,7 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 
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
