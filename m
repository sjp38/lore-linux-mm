Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 079D66B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 10:30:46 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g32so36680452qta.2
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 07:30:46 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id r126si3957975qkf.286.2016.10.12.07.30.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 07:30:45 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RFC PATCH 1/1] mm/vmalloc.c: correct logic errors when insert
 vmap_area
Message-ID: <c2bd0f5d-8d2a-4cba-2663-5c075cd252f2@zoho.com>
Date: Wed, 12 Oct 2016 22:30:13 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@kernel.org, rientjes@google.com, tj@kernel.org, sfr@canb.auug.org.au, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, hannes@cmpxchg.org, chris@chris-wilson.co.uk, vdavydov.dev@gmail.com
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zijun_hu <zijun_hu@htc.com>

the KVA allocator organizes vmap_areas allocated by rbtree. in order to
insert a new vmap_area @i_va into the rbtree, walk around the rbtree from
root and compare the vmap_area @t_va met on the rbtree against @i_va; walk
toward the left branch of @t_va if @i_va is lower than @t_va, and right
branch if higher, otherwise handle this error case since @i_va has overlay
with @t_va; however, __insert_vmap_area() don't follow the desired
procedure rightly, moreover, it includes a meaningless else if condition
and a redundant else branch as shown by comments in below code segments:
static void __insert_vmap_area(struct vmap_area *va)
{
as a internal interface parameter, we assume vmap_area @va has nonzero size
...
			if (va->va_start < tmp->va_end)
					p = &(*p)->rb_left;
			else if (va->va_end > tmp->va_start)
					p = &(*p)->rb_right;
this else if condition is always true and meaningless due to
va->va_end > va->va_start >= tmp_va->va_end > tmp_va->va_start normally
			else
					BUG();
this BUG() is meaningless too due to never be reached normally
...
}

it looks like the else if condition and else branch are canceled. no errors
are caused since the vmap_area @va to insert as a internal interface
parameter doesn't have overlay with any one on the rbtree normally. however
 __insert_vmap_area() looks weird and really has several logic errors as
pointed out above when it is viewed as a separate function.

fix by walking around vmap_area rbtree as described above to insert
a vmap_area.

BTW, (va->va_end == tmp_va->va_start) is consider as legal case since it
indicates vmap_area @va left neighbors with @tmp_va tightly.

Fixes: db64fe02258f ("mm: rewrite vmap layer")
Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/vmalloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 5daf3211b84f..8b80931654b7 100644
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
