Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id EAD626B0194
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 10:31:02 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/16] mm: Micro-optimise slab to avoid a function call
Date: Fri, 22 Jun 2012 15:30:40 +0100
Message-Id: <1340375443-22455-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1340375443-22455-1-git-send-email-mgorman@suse.de>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

Getting and putting objects in SLAB currently requires a function call
but the bulk of the work is related to PFMEMALLOC reserves which are
only consumed when network-backed storage is critical. Use an inline
function to determine if the function call is required.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/slab.c |   28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d9fe508..84f471e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -117,6 +117,8 @@
 #include	<linux/memory.h>
 #include	<linux/prefetch.h>
 
+#include	<net/sock.h>
+
 #include	<asm/cacheflush.h>
 #include	<asm/tlbflush.h>
 #include	<asm/page.h>
@@ -991,7 +993,7 @@ out:
 	spin_unlock_irqrestore(&l3->list_lock, flags);
 }
 
-static void *ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
+static void *__ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
 						gfp_t flags, bool force_refill)
 {
 	int i;
@@ -1038,7 +1040,20 @@ static void *ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
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
 	if (unlikely(pfmemalloc_active)) {
@@ -1048,6 +1063,15 @@ static void ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
