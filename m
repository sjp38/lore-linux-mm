Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id AE8C74403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:14:44 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id b35so300585478qge.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:14:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h66si36844424qgf.80.2016.01.12.07.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:14:44 -0800 (PST)
Subject: [PATCH V2 05/11] mm: kmemcheck skip object if slab allocation failed
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:14:41 +0100
Message-ID: <20160112151435.31725.39167.stgit@firesoul>
In-Reply-To: <20160112151257.31725.71327.stgit@firesoul>
References: <20160112151257.31725.71327.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

In the SLAB allocator kmemcheck_slab_alloc() is guarded against
being called in case the object is NULL.  In SLUB allocator this
NULL pointer invocation can happen, which seems like an oversight.

Move the NULL pointer check into kmemcheck code (kmemcheck_slab_alloc)
so the check gets moved out of the fastpath, when not compiled
with CONFIG_KMEMCHECK.

This is a step towards sharing post_alloc_hook between SLUB and
SLAB, because slab_post_alloc_hook() does not perform this check
before calling kmemcheck_slab_alloc().

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
