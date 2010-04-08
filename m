Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0AE406B01F2
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 05:28:27 -0400 (EDT)
From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH] slub: __kmalloc_node_track_caller should trace kmalloc_large_node case
Date: Thu,  8 Apr 2010 17:26:44 +0800
Message-Id: <1270718804-27268-1-git-send-email-dfeng@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Xiaotian Feng <dfeng@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, Vegard Nossum <vegard.nossum@gmail.com>
List-ID: <linux-mm.kvack.org>

commit 94b528d (kmemtrace: SLUB hooks for caller-tracking functions)
missed tracing kmalloc_large_node in __kmalloc_node_track_caller. We
should trace it same as __kmalloc_node.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Vegard Nossum <vegard.nossum@gmail.com>
---
 mm/slub.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b364844..a3a5a18 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3335,8 +3335,15 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 	struct kmem_cache *s;
 	void *ret;
 
-	if (unlikely(size > SLUB_MAX_SIZE))
-		return kmalloc_large_node(size, gfpflags, node);
+	if (unlikely(size > SLUB_MAX_SIZE)) {
+		ret = kmalloc_large_node(size, gfpflags, node);
+
+		trace_kmalloc_node(caller, ret,
+				   size, PAGE_SIZE << get_order(size),
+				   gfpflags, node);
+
+		return ret;
+	}
 
 	s = get_slab(size, gfpflags);
 
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
