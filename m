Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 133646B025E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 00:24:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id p53so76627834qtp.0
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 21:24:52 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id j62si24073028qkd.130.2016.09.20.21.24.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 21:24:51 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 1/5] mm/vmalloc.c: correct a few logic error for
 __insert_vmap_area()
Message-ID: <57E20B54.5020408@zoho.com>
Date: Wed, 21 Sep 2016 12:23:48 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

From: zijun_hu <zijun_hu@htc.com>

correct a few logic error for __insert_vmap_area() since the else
if condition is always true and meaningless

in order to fix this issue, if vmap_area inserted is lower than one
on rbtree then walk around left branch; if higher then right branch
otherwise intersects with the other then BUG_ON() is triggered

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/vmalloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e7..cc6ecd6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -321,10 +321,10 @@ static void __insert_vmap_area(struct vmap_area *va)
 
 		parent = *p;
 		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
-		if (va->va_start < tmp_va->va_end)
-			p = &(*p)->rb_left;
-		else if (va->va_end > tmp_va->va_start)
-			p = &(*p)->rb_right;
+		if (va->va_end <= tmp_va->va_start)
+			p = &parent->rb_left;
+		else if (va->va_start >= tmp_va->va_end)
+			p = &parent->rb_right;
 		else
 			BUG();
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
