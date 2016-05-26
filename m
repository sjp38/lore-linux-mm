Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 830FC6B0253
	for <linux-mm@kvack.org>; Wed, 25 May 2016 22:38:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so18152929pfc.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 19:38:06 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id yv7si10728782pab.33.2016.05.25.19.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 19:38:05 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id b124so6994227pfb.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 19:38:05 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 3/7] mm/page_owner: copy last_migrate_reason in copy_page_owner()
Date: Thu, 26 May 2016 11:37:51 +0900
Message-Id: <1464230275-25791-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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
