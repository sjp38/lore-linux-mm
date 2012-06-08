Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 197866B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 13:25:00 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3276710dak.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 10:24:59 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/4] slub: change declare of get_slab() to inline at all times
Date: Sat,  9 Jun 2012 02:23:14 +0900
Message-Id: <1339176197-13270-1-git-send-email-js1304@gmail.com>
In-Reply-To: <yes>
References: <yes>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

__kmalloc and it's variants are invoked much frequently
and these are performance critical functions,
so their callee functions are declared '__always_inline'
But, currently, get_slab() isn't declared '__always_inline'.
In result, __kmalloc and it's variants call get_slab() on x86.
It is not desirable result, so change it to inline at all times.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 71de9b5..30ceb6d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3320,7 +3320,7 @@ static inline int size_index_elem(size_t bytes)
 	return (bytes - 1) / 8;
 }
 
-static struct kmem_cache *get_slab(size_t size, gfp_t flags)
+static __always_inline struct kmem_cache *get_slab(size_t size, gfp_t flags)
 {
 	int index;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
