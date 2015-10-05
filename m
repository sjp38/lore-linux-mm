Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id AB21C440321
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 04:24:00 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so30000307pad.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 01:24:00 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id rs4si38544754pbb.50.2015.10.05.01.23.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Oct 2015 01:23:59 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH] zsmalloc: fix obj_to_head use page_private(page) as value but not pointer
Date: Mon, 5 Oct 2015 16:23:01 +0800
Message-ID: <1444033381-5726-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

In function obj_malloc:
	if (!class->huge)
		/* record handle in the header of allocated chunk */
		link->handle = handle;
	else
		/* record handle in first_page->private */
		set_page_private(first_page, handle);
The huge's page save handle to private directly.

But in obj_to_head:
	if (class->huge) {
		VM_BUG_ON(!is_first_page(page));
		return page_private(page);
	} else
		return *(unsigned long *)obj;
It is used as a pointer.

So change obj_to_head use page_private(page) as value but not pointer
in obj_to_head.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f135b1b..e881d4f 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -824,7 +824,7 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
 {
 	if (class->huge) {
 		VM_BUG_ON(!is_first_page(page));
-		return *(unsigned long *)page_private(page);
+		return page_private(page);
 	} else
 		return *(unsigned long *)obj;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
