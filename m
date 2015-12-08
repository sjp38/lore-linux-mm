Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1956B025B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 11:19:16 -0500 (EST)
Received: by qgcc31 with SMTP id c31so23221359qgc.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:19:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m6si4087845qki.10.2015.12.08.08.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 08:18:44 -0800 (PST)
Subject: [RFC PATCH V2 4/9] mm: kmemcheck skip object if slab allocation
 failed
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 08 Dec 2015 17:18:42 +0100
Message-ID: <20151208161842.21945.131.stgit@firesoul>
In-Reply-To: <20151208161751.21945.53936.stgit@firesoul>
References: <20151208161751.21945.53936.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

In the SLAB allocator kmemcheck_slab_alloc() is guarded against
being called in case the object is NULL.  In SLUB allocator this
NULL pointer invocation can happen, which seems like an oversight.

Move the NULL pointer check into kmemcheck code (kmemcheck_slab_alloc)
so the check gets moved out of the fastpath, when not compiled
with CONFIG_KMEMCHECK.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/kmemcheck.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
index cab58bb592d8..6f4f424037c0 100644
--- a/mm/kmemcheck.c
+++ b/mm/kmemcheck.c
@@ -60,6 +60,9 @@ void kmemcheck_free_shadow(struct page *page, int order)
 void kmemcheck_slab_alloc(struct kmem_cache *s, gfp_t gfpflags, void *object,
 			  size_t size)
 {
+	if (unlikely(!object)) /* Skip object if allocation failed */
+		return;
+
 	/*
 	 * Has already been memset(), which initializes the shadow for us
 	 * as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
