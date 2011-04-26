Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E27EE900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 03:37:08 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/13] mm: Micro-optimise slab to avoid a function call
Date: Tue, 26 Apr 2011 08:36:51 +0100
Message-Id: <1303803414-5937-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1303803414-5937-1-git-send-email-mgorman@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Getting and putting objects in SLAB currently requires a function call
but the bulk of the work is related to PFMEMALLOC reserves which are
only consumed when network-backed storage is critical. Use an inline
function to determine if the function call is required.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/slab.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 1925023..3163d31 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -116,6 +116,8 @@
 #include	<linux/kmemcheck.h>
 #include	<linux/memory.h>
 
+#include	<net/sock.h>
+
 #include	<asm/cacheflush.h>
 #include	<asm/tlbflush.h>
 #include	<asm/page.h>
@@ -944,7 +946,7 @@ static void check_ac_pfmemalloc(struct kmem_cache *cachep,
 	ac->pfmemalloc = false;
 }
 
-static void *ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
+static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 						gfp_t flags, bool force_refill)
 {
 	int i;
@@ -991,7 +993,20 @@ static void *ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 	return objp;
 }
 
-static void ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
+static inline void *ac_get_obj(struct kmem_cache *cachep,
+			struct array_cache *ac, gfp_t flags, bool force_refill)
+{
+	void *objp;
+
+	if (unlikely(sk_memalloc_socks()))
+		objp = __ac_get_obj(cachep, ac, flags, force_refill);
+	else
+		objp = ac->entry[--ac->avail];
+
+	return objp;
+}
+
+static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 								void *objp)
 {
 	struct slab *slabp;
@@ -1004,6 +1019,15 @@ static void ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
 			set_obj_pfmemalloc(&objp);
 	}
 
+	return objp;
+}
+
+static inline void ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
+								void *objp)
+{
+	if (unlikely(sk_memalloc_socks()))
+		objp = __ac_put_obj(cachep, ac, objp);
+
 	ac->entry[ac->avail++] = objp;
 }
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
