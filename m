Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 637D66B00A3
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 10:12:33 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so923179pde.4
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 07:12:33 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id vb7si3228950pbc.155.2014.11.05.07.12.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 05 Nov 2014 07:12:32 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NEK00MH7NPF1LC0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 05 Nov 2014 15:15:15 +0000 (GMT)
Content-transfer-encoding: 8BIT
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] mm: slub: fix format mismatches in slab_err() callers
Date: Wed, 05 Nov 2014 18:12:21 +0300
Message-id: <1415200341-9619-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Adding __printf(3, 4) to slab_err exposed following:

mm/slub.c: In function a??check_slaba??:
mm/slub.c:852:4: warning: format a??%ua?? expects argument of type a??unsigned inta??, but argument 4 has type a??const char *a?? [-Wformat=]
    s->name, page->objects, maxobj);
    ^
mm/slub.c:852:4: warning: too many arguments for format [-Wformat-extra-args]
mm/slub.c:857:4: warning: format a??%ua?? expects argument of type a??unsigned inta??, but argument 4 has type a??const char *a?? [-Wformat=]
    s->name, page->inuse, page->objects);
    ^
mm/slub.c:857:4: warning: too many arguments for format [-Wformat-extra-args]

mm/slub.c: In function a??on_freelista??:
mm/slub.c:905:4: warning: format a??%da?? expects argument of type a??inta??, but argument 5 has type a??long unsigned inta?? [-Wformat=]
    "should be %d", page->objects, max_objects);

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slub.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 80c170e..850a94a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -849,12 +849,12 @@ static int check_slab(struct kmem_cache *s, struct page *page)
 	maxobj = order_objects(compound_order(page), s->size, s->reserved);
 	if (page->objects > maxobj) {
 		slab_err(s, page, "objects %u > max %u",
-			s->name, page->objects, maxobj);
+			page->objects, maxobj);
 		return 0;
 	}
 	if (page->inuse > page->objects) {
 		slab_err(s, page, "inuse %u > max %u",
-			s->name, page->inuse, page->objects);
+			page->inuse, page->objects);
 		return 0;
 	}
 	/* Slab_pad_check fixes things up after itself */
@@ -902,7 +902,7 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 
 	if (page->objects != max_objects) {
 		slab_err(s, page, "Wrong number of objects. Found %d but "
-			"should be %d", page->objects, max_objects);
+			"should be %ld", page->objects, max_objects);
 		page->objects = max_objects;
 		slab_fix(s, "Number of objects adjusted.");
 	}
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
