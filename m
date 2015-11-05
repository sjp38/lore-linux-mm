Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id DDF3982F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 10:38:08 -0500 (EST)
Received: by ykba4 with SMTP id a4so136905823ykb.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 07:38:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p196si4953191vkp.103.2015.11.05.07.38.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 07:38:08 -0800 (PST)
Subject: [PATCH V2 2/2] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 05 Nov 2015 16:38:06 +0100
Message-ID: <20151105153756.1115.41409.stgit@firesoul>
In-Reply-To: <20151105153704.1115.10475.stgit@firesoul>
References: <20151105153704.1115.10475.stgit@firesoul>
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

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2: Fixes according to input from:
 Vladimir Davydov <vdavydov@virtuozzo.com>
 and Joonsoo Kim <iamjoonsoo.kim@lge.com>

 mm/slub.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 8e9e9b2ee6f3..bc64514ad1bb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2890,6 +2890,9 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 	do {
 		struct detached_freelist df;
 
+		/* Support for memcg */
+		s = cache_from_obj(s, p[size - 1]);
+
 		size = build_detached_freelist(s, size, p, &df);
 		if (unlikely(!df.page))
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
