Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0B66B026B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:41:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v67so29508927pfv.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:41:34 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id ad9si2807779pad.196.2016.09.27.06.41.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 06:41:33 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RFC PATCH v2 1/1] mm/vmalloc.c: correct a few logic error for
 __insert_vmap_area()
Message-ID: <57EA76F7.5090401@zoho.com>
Date: Tue, 27 Sep 2016 21:41:11 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, torvalds@linux-foundation.org, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, npiggin@gmail.com, mhocko@kernel.org

From: zijun_hu <zijun_hu@htc.com>

__insert_vmap_area() has a few obvious logic errors as shown by comments
within below code segments
static void __insert_vmap_area(struct vmap_area *va)
{
as a internal function parameter, we assume vmap_area @va has nonzero size
...
		if (va->va_start < tmp->va_end)
			p = &(*p)->rb_left;
		else if (va->va_end > tmp->va_start)
			p = &(*p)->rb_right;
this else if condition is always true and meaningless due to
va->va_end > va->va_start >= tmp_va->va_end > tmp_va->va_start normally
		else
			BUG();
this BUG() is meaningless too due to never be touched normally
...
}

the function don't implement the below desire behavior based on context
if the vmap_area @va to be inserted is lower than that on the rbtree then
we walk around the left branch of the given rbtree node; else if higher
then right branch; else the former vmap_area has overlay with the latter
then the existing BUG() is triggered

it is fixed by correcting vmap_area rbtree walk manner as mentioned above
BTW, we consider (va->va_end == tmp_va->va_start) as legal case since it
indicate vmap_area @va neighbors with @tmp_va tightly

Fixes: db64fe02258f ("mm: rewrite vmap layer")
Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 Hi npiggin,
 could you offer some comments for this patch since __insert_vmap_area()
 was introduced by you?
 thanks a lot

 Changes in v2:
  - more detailed commit message is provided

 mm/vmalloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e78c516..cc6ecd60cc0e 100644
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
