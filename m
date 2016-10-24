Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4246B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:57:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f193so35049908wmg.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 08:57:16 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id s2si16796562wjx.245.2016.10.24.08.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 08:57:15 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] slub: avoid false-postive warning
Date: Mon, 24 Oct 2016 17:56:13 +0200
Message-Id: <20161024155704.3114445-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <labbott@fedoraproject.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The slub allocator gives us some incorrect warnings when
CONFIG_PROFILE_ANNOTATED_BRANCHES is set, as the unlikely()
macro prevents it from seeing that the return code matches
what it was before:

mm/slub.c: In function a??kmem_cache_free_bulka??:
mm/slub.c:262:23: error: a??df.sa?? may be used uninitialized in this function [-Werror=maybe-uninitialized]
mm/slub.c:2943:3: error: a??df.cnta?? may be used uninitialized in this function [-Werror=maybe-uninitialized]
mm/slub.c:2933:4470: error: a??df.freelista?? may be used uninitialized in this function [-Werror=maybe-uninitialized]
mm/slub.c:2943:3: error: a??df.taila?? may be used uninitialized in this function [-Werror=maybe-uninitialized]

I have not been able to come up with a perfect way for dealing with
this, the three options I see are:

- add a bogus initialization, which would increase the runtime overhead
- replace unlikely() with unlikely_notrace()
- remove the unlikely() annotation completely

I checked the object code for a typical x86 configuration and the
last two cases produce the same result, so I went for the last
one, which is the simplest.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2b3e740609e9..68b84f93d38d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3076,7 +3076,7 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 		struct detached_freelist df;
 
 		size = build_detached_freelist(s, size, p, &df);
-		if (unlikely(!df.page))
+		if (!df.page)
 			continue;
 
 		slab_free(df.s, df.page, df.freelist, df.tail, df.cnt,_RET_IP_);
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
