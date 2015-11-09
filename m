Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id E045B6B0254
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 13:17:52 -0500 (EST)
Received: by iofh3 with SMTP id h3so27234981iof.3
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 10:17:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k3si11678113ige.22.2015.11.09.10.17.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 10:17:52 -0800 (PST)
Subject: [PATCH V3 2/2] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 09 Nov 2015 19:17:50 +0100
Message-ID: <20151109181736.8231.98629.stgit@firesoul>
In-Reply-To: <20151109181604.8231.22983.stgit@firesoul>
References: <20151109181604.8231.22983.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vdavydov@virtuozzo.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Initial implementation missed support for kmem cgroup support
in kmem_cache_free_bulk() call, add this.

If CONFIG_MEMCG_KMEM is not enabled, the compiler should
be smart enough to not add any asm code.

Incomming bulk free objects can belong to different kmem cgroups, and
object free call can happen at a later point outside memcg context.
Thus, we need to keep the orig kmem_cache, to correctly verify if a
memcg object match against its "root_cache" (s->memcg_params.root_cache).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V3:
 Learned more about memcg, actually tested it and fixed a bug

V2: Fixes according to input from:
 Vladimir Davydov <vdavydov@virtuozzo.com>
 and Joonsoo Kim <iamjoonsoo.kim@lge.com>

 mm/slub.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8e6b929d06d6..e3fa85278706 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2889,13 +2889,17 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
 
 
 /* Note that interrupts must be enabled when calling this function. */
-void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
 {
 	if (WARN_ON(!size))
 		return;
 
 	do {
 		struct detached_freelist df;
+		struct kmem_cache *s;
+
+		/* Support for memcg */
+		s = cache_from_obj(orig_s, p[size - 1]);
 
 		size = build_detached_freelist(s, size, p, &df);
 		if (unlikely(!df.page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
