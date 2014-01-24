Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id B193E6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 16:15:36 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id w7so2990197lbi.13
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 13:15:36 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q6si1129733lbp.36.2014.01.24.13.15.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 13:15:35 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] slab: fix wrong retval on kmem_cache_create_memcg error path
Date: Sat, 25 Jan 2014 01:15:26 +0400
Message-ID: <1390598126-4332-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

From: Dave Jones <davej@redhat.com>

On kmem_cache_create_memcg() error path we set 'err', but leave 's' (the
new cache ptr) undefined. The latter can be NULL if we could not
allocate the cache, or pointing to a freed area if we failed somewhere
later while trying to initialize it. Initially we checked 'err'
immediately before exiting the function and returned NULL if it was set
ignoring the value of 's':

    out_unlock:
        ...
        if (err) {
            ...
            return NULL;
        }
        return s;

Recently this check was, in fact, broken by commit f717eb3abb5e ("slab:
do not panic if we fail to create memcg cache"), which turned it to:

    out_unlock:
        ...
        if (err && !memcg) {
            ...
            return NULL;
        }
        return s;

As a result, if we are failing creating a cache for a memcg, we will
skip the check and return 's' that can contain crap. Let's fix it by
assuring that on error path there are always two conditions satisfied at
the same time, err != 0 and s == NULL, by explicitly zeroing 's' after
freeing it on error path.

Signed-off-by: Dave Jones <davej@redhat.com>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
---
 mm/slab_common.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8e40321..499b53c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -249,7 +249,6 @@ out_unlock:
 				name, err);
 			dump_stack();
 		}
-		return NULL;
 	}
 	return s;
 
@@ -257,6 +256,7 @@ out_free_cache:
 	memcg_free_cache_params(s);
 	kfree(s->name);
 	kmem_cache_free(kmem_cache, s);
+	s = NULL;
 	goto out_unlock;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
