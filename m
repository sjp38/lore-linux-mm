Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 64F1A82F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 09:05:36 -0400 (EDT)
Received: by qkcl124 with SMTP id l124so13302965qkc.3
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 06:05:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n98si1132293qkh.60.2015.10.29.06.05.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 06:05:35 -0700 (PDT)
Subject: [PATCH] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 29 Oct 2015 14:05:31 +0100
Message-ID: <20151029130531.15158.58018.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Initial implementation missed support for kmem cgroup support
in kmem_cache_free_bulk() call, add this.

If CONFIG_MEMCG_KMEM is not enabled, the compiler should
be smart enough to not add any asm code.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 9be12ffae9fc..9875864ad7b8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2845,6 +2845,9 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
 	if (!object)
 		return 0;
 
+	/* Support for kmemcg */
+	s = cache_from_obj(s, object);
+
 	/* Start new detached freelist */
 	set_freepointer(s, object, NULL);
 	df->page = virt_to_head_page(object);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
