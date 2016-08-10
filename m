Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5845F6B025E
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:16:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so64594183pfg.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:27 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id y15si46810708pfb.247.2016.08.09.23.16.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 23:16:25 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id h186so2233062pfg.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:22 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 2/5] mm/debug_pagealloc: don't allocate page_ext if we don't use guard page
Date: Wed, 10 Aug 2016 15:16:21 +0900
Message-Id: <1470809784-11516-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
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
