Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 802B16B007B
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 03:17:09 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id ft15so694653pdb.21
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 00:17:09 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id tn8si5262501pac.83.2014.11.06.00.17.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 06 Nov 2014 00:17:08 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NEL008L7Z55MB90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 06 Nov 2014 08:19:53 +0000 (GMT)
Content-transfer-encoding: 8BIT
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v2] mm: slub: fix format mismatches in slab_err() callers
Date: Thu, 06 Nov 2014 11:16:57 +0300
Message-id: <1415261817-5283-1-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <alpine.DEB.2.10.1411051344490.31575@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1411051344490.31575@chino.kir.corp.google.com>
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

Fix first two warnings by removing redundant s->name.
Fix the last by changing type of max_object from unsigned long to int.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---

Changes since v1:
  - To fix the last warning change the type of max_objects instead of changing format string (David)
  - Slightly update changelog

 mm/slub.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 80c170e..ed816f8 100644
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
@@ -871,7 +871,7 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 	int nr = 0;
 	void *fp;
 	void *object = NULL;
-	unsigned long max_objects;
+	int max_objects;
 
 	fp = page->freelist;
 	while (fp && nr <= page->objects) {
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
