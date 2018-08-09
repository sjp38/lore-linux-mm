Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 828EB6B0005
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 04:53:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z5-v6so1866509edr.19
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 01:53:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n38-v6si7379828edn.443.2018.08.09.01.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 01:53:23 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, slub: restore the original intention of prefetch_freepointer()
Date: Thu,  9 Aug 2018 10:52:45 +0200
Message-Id: <20180809085245.22448-1-vbabka@suse.cz>
In-Reply-To: <cc93080f-2d22-71fe-a1fb-d55d1fcc2441@suse.cz>
References: <cc93080f-2d22-71fe-a1fb-d55d1fcc2441@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Menzel <pmenzel+linux-mm@molgen.mpg.de>, Alex Deucher <alexander.deucher@amd.com>, Vlastimil Babka <vbabka@suse.cz>, Kees Cook <keescook@chromium.org>, Daniel Micay <danielmicay@gmail.com>, Eric Dumazet <edumazet@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In SLUB, prefetch_freepointer() is used when allocating an object from cache's
freelist, to make sure the next object in the list is cache-hot, since it's
probable it will be allocated soon.

Commit 2482ddec670f ("mm: add SLUB free list pointer obfuscation") has
unintentionally changed the prefetch in a way where the prefetch is turned to a
real fetch, and only the next->next pointer is prefetched. In case there is not
a stream of allocations that would benefit from prefetching, the extra real
fetch might add a useless cache miss to the allocation. Restore the previous
behavior.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Kees Cook <keescook@chromium.org>
Cc: Daniel Micay <danielmicay@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
While I don't expect this to be causing the bug at hand, it's worth fixing.
For the bug it might mean that the page fault moves elsewhere.

 mm/slub.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 51258eff4178..ce2b9e5cea77 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -271,8 +271,7 @@ static inline void *get_freepointer(struct kmem_cache *s, void *object)
 
 static void prefetch_freepointer(const struct kmem_cache *s, void *object)
 {
-	if (object)
-		prefetch(freelist_dereference(s, object + s->offset));
+	prefetch(object + s->offset);
 }
 
 static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
-- 
2.18.0
