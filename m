Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 733F36B0314
	for <linux-mm@kvack.org>; Wed, 24 May 2017 06:04:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p29so109608864pgn.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 03:04:02 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id w6si23753743pfk.420.2017.05.24.03.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 03:04:01 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id s62so16607040pgc.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 03:04:01 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/vmalloc: a slight change of compare target in __insert_vmap_area()
Date: Wed, 24 May 2017 18:03:47 +0800
Message-Id: <20170524100347.8131-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

The vmap RB tree store the elements in order and no overlap between any of
them. The comparison in __insert_vmap_area() is to decide which direction
the search should follow and make sure the new vmap_area is not overlap
with any other.

Current implementation fails to do the overlap check.

When first "if" is not true, it means

    va->va_start >= tmp_va->va_end

And with the truth

    xxx->va_end > xxx->va_start

The deduction is

    va->va_end > tmp_va->va_start

which is the condition in second "if".

This patch changes a little of the comparison in __insert_vmap_area() to
make sure it forbids the overlapped vmap_area.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0b057628a7ba..8087451cb332 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -360,9 +360,9 @@ static void __insert_vmap_area(struct vmap_area *va)
 
 		parent = *p;
 		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
-		if (va->va_start < tmp_va->va_end)
+		if (va->va_end <= tmp_va->va_start)
 			p = &(*p)->rb_left;
-		else if (va->va_end > tmp_va->va_start)
+		else if (va->va_start >= tmp_va->va_end)
 			p = &(*p)->rb_right;
 		else
 			BUG();
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
