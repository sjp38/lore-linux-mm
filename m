Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5182C6B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 16:31:07 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so120783532lfe.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 13:31:07 -0700 (PDT)
Received: from andre.telenet-ops.be (andre.telenet-ops.be. [2a02:1800:120:4::f00:15])
        by mx.google.com with ESMTPS id v2si9757606wjh.115.2016.08.03.13.31.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 13:31:06 -0700 (PDT)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] slub: Drop bogus inline for fixup_red_left()
Date: Wed,  3 Aug 2016 22:31:02 +0200
Message-Id: <1470256262-1586-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

With m68k-linux-gnu-gcc-4.1:

    include/linux/slub_def.h:126: warning: a??fixup_red_lefta?? declared inline after being called
    include/linux/slub_def.h:126: warning: previous declaration of a??fixup_red_lefta?? was here

Commit c146a2b98eb5898e ("mm, kasan: account for object redzone in
SLUB's nearest_obj()") made fixup_red_left() global, but forgot to
remove the inline keyword.

Fixes: c146a2b98eb5898e ("mm, kasan: account for object redzone in SLUB's nearest_obj()")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 26eb6a99540e8530..850737bdfbd82410 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -124,7 +124,7 @@ static inline int kmem_cache_debug(struct kmem_cache *s)
 #endif
 }
 
-inline void *fixup_red_left(struct kmem_cache *s, void *p)
+void *fixup_red_left(struct kmem_cache *s, void *p)
 {
 	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE)
 		p += s->red_left_pad;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
