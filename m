Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CFF336B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 00:45:59 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so8875397pac.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 21:45:59 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id ku5si54631531pbc.25.2015.10.06.21.45.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Oct 2015 21:45:59 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH v2] zsmalloc: fix obj_to_head use page_private(page) as value but not pointer
Date: Wed, 7 Oct 2015 12:45:52 +0800
Message-ID: <1444193152-17473-1-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <20151006135303.GA31853@blaptop>
References: <20151006135303.GA31853@blaptop>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

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
		return *(unsigned long *)page_private(page);
	} else
		return *(unsigned long *)obj;
It is used as a pointer.

The reason why there is no problem until now is huge-class page is
born with ZS_FULL so it couldn't be migrated.
Therefore, it shouldn't be real bug in practice.
However, we need this patch for future-work "VM-aware zsmalloced
page migration" to reduce external fragmentation.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
Acked-by: Minchan Kim <minchan@kernel.org>
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
