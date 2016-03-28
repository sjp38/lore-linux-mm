Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 117996B025F
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 01:27:16 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n5so128680584pfn.2
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:16 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id by10si6171648pab.168.2016.03.27.22.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 22:27:15 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id n5so128680433pfn.2
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:15 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 01/11] mm/slab: hold a slab_mutex when calling __kmem_cache_shrink()
Date: Mon, 28 Mar 2016 14:26:51 +0900
Message-Id: <1459142821-20303-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Major kmem_cache metadata in slab subsystem is synchronized with
the slab_mutex. In SLAB, if some of them is changed, node's shared
array cache would be freed and re-populated. If __kmem_cache_shrink()
is called at the same time, it will call drain_array() with n->shared
without holding node lock so problem can happen.

We can fix this small theoretical race condition by holding node lock
in drain_array(), but, holding a slab_mutex in kmem_cache_shrink()
looks more appropriate solution because stable state would make things
less error-prone and this is not performance critical path.

In addtion, annotate on SLAB functions.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c        | 2 ++
 mm/slab_common.c | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index a53a0f6..043606a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2218,6 +2218,7 @@ static void do_drain(void *arg)
 	ac->avail = 0;
 }
 
+/* Should be called with slab_mutex to prevent from freeing shared array */
 static void drain_cpu_caches(struct kmem_cache *cachep)
 {
 	struct kmem_cache_node *n;
@@ -3871,6 +3872,7 @@ skip_setup:
  * Drain an array if it contains any elements taking the node lock only if
  * necessary. Note that the node listlock also protects the array_cache
  * if drain_array() is used on the shared array.
+ * Should be called with slab_mutex to prevent from freeing shared array.
  */
 static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
 			 struct array_cache *ac, int force, int node)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index a65dad7..5bed565 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -755,7 +755,11 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 	get_online_cpus();
 	get_online_mems();
 	kasan_cache_shrink(cachep);
+
+	mutex_lock(&slab_mutex);
 	ret = __kmem_cache_shrink(cachep, false);
+	mutex_unlock(&slab_mutex);
+
 	put_online_mems();
 	put_online_cpus();
 	return ret;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
