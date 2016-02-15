Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 01A336B0255
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 13:44:32 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id b35so116449906qge.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 10:44:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d201si35617302qkb.37.2016.02.15.10.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 10:44:31 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCHv2 1/4] slub: Drop lock at the end of free_debug_processing
Date: Mon, 15 Feb 2016 10:44:21 -0800
Message-Id: <1455561864-4217-2-git-send-email-labbott@fedoraproject.org>
In-Reply-To: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>


Currently, free_debug_processing has a comment "Keep node_lock to preserve
integrity until the object is actually freed". In actuallity,
the lock is dropped immediately in __slab_free. Rather than wait until
__slab_free and potentially throw off the unlikely marking, just drop
the lock in __slab_free. This also lets free_debug_processing take
its own copy of the spinlock flags rather than trying to share the ones
from __slab_free. Since there is no use for the node afterwards, change
the return type of free_debug_processing to return an int like
alloc_debug_processing.

Credit to Mathias Krause for the original work which inspired this series

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
I didn't add Christoph's ack from the last time due to some
rebasing.
---
 mm/slub.c | 23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2e1355a..2d5a774 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1068,16 +1068,17 @@ bad:
 }
 
 /* Supports checking bulk free of a constructed freelist */
-static noinline struct kmem_cache_node *free_debug_processing(
+static noinline int free_debug_processing(
 	struct kmem_cache *s, struct page *page,
 	void *head, void *tail, int bulk_cnt,
-	unsigned long addr, unsigned long *flags)
+	unsigned long addr)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 	void *object = head;
 	int cnt = 0;
+	unsigned long uninitialized_var(flags);
 
-	spin_lock_irqsave(&n->list_lock, *flags);
+	spin_lock_irqsave(&n->list_lock, flags);
 	slab_lock(page);
 
 	if (!check_slab(s, page))
@@ -1130,17 +1131,14 @@ out:
 			 bulk_cnt, cnt);
 
 	slab_unlock(page);
-	/*
-	 * Keep node_lock to preserve integrity
-	 * until the object is actually freed
-	 */
-	return n;
+	spin_unlock_irqrestore(&n->list_lock, flags);
+	return 1;
 
 fail:
 	slab_unlock(page);
-	spin_unlock_irqrestore(&n->list_lock, *flags);
+	spin_unlock_irqrestore(&n->list_lock, flags);
 	slab_fix(s, "Object at 0x%p not freed", object);
-	return NULL;
+	return 0;
 }
 
 static int __init setup_slub_debug(char *str)
@@ -1231,7 +1229,7 @@ static inline void setup_object_debug(struct kmem_cache *s,
 static inline int alloc_debug_processing(struct kmem_cache *s,
 	struct page *page, void *object, unsigned long addr) { return 0; }
 
-static inline struct kmem_cache_node *free_debug_processing(
+static inline int free_debug_processing(
 	struct kmem_cache *s, struct page *page,
 	void *head, void *tail, int bulk_cnt,
 	unsigned long addr, unsigned long *flags) { return NULL; }
@@ -2648,8 +2646,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	stat(s, FREE_SLOWPATH);
 
 	if (kmem_cache_debug(s) &&
-	    !(n = free_debug_processing(s, page, head, tail, cnt,
-					addr, &flags)))
+	    !free_debug_processing(s, page, head, tail, cnt, addr))
 		return;
 
 	do {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
