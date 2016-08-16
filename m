Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E97946B0260
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 22:51:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so149638349pfx.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:51:29 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id l88si29626249pfj.272.2016.08.15.19.51.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 19:51:29 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id y134so4657216pfg.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:51:29 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 2/6] mm/debug_pagealloc: don't allocate page_ext if we don't use guard page
Date: Tue, 16 Aug 2016 11:51:15 +0900
Message-Id: <1471315879-32294-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1471315879-32294-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

What debug_pagealloc does is just mapping/unmapping page table.
Basically, it doesn't need additional memory space to memorize something.
But, with guard page feature, it requires additional memory to distinguish
if the page is for guard or not. Guard page is only used when
debug_guardpage_minorder is non-zero so this patch removes additional
memory allocation (page_ext) if debug_guardpage_minorder is zero.

It saves memory if we just use debug_pagealloc and not guard page.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5e7944b..45cb021 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -608,6 +608,9 @@ static bool need_debug_guardpage(void)
 	if (!debug_pagealloc_enabled())
 		return false;
 
+	if (!debug_guardpage_minorder())
+		return false;
+
 	return true;
 }
 
@@ -616,6 +619,9 @@ static void init_debug_guardpage(void)
 	if (!debug_pagealloc_enabled())
 		return;
 
+	if (!debug_guardpage_minorder())
+		return;
+
 	_debug_guardpage_enabled = true;
 }
 
@@ -636,7 +642,7 @@ static int __init debug_guardpage_minorder_setup(char *buf)
 	pr_info("Setting debug_guardpage_minorder to %lu\n", res);
 	return 0;
 }
-__setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
+early_param("debug_guardpage_minorder", debug_guardpage_minorder_setup);
 
 static inline bool set_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
