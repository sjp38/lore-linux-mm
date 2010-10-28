Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CB6208D000B
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 05:51:46 -0400 (EDT)
Message-ID: <4CC9476D.7050006@parallels.com>
Date: Thu, 28 Oct 2010 13:50:37 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH] slub: Fix slub_lock down/up imbalance
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

There are two places, that do not release the slub_lock.

Respective bugs were introduced by sysfs changes ab4d5ed5 (slub: Enable 
sysfs support for !CONFIG_SLUB_DEBUG) and 2bce6485 ( slub: Allow removal
of slab caches during boot).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/mm/slub.c b/mm/slub.c
index 8fd5401..981fb73 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3273,9 +3273,9 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 		kfree(n);
 		kfree(s);
 	}
+err:
 	up_write(&slub_lock);
 
-err:
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slabcache %s\n", name);
 	else
@@ -3862,6 +3862,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			x += sprintf(buf + x, " N%d=%lu",
 					node, nodes[node]);
 #endif
+	up_read(&slub_lock);
 	kfree(nodes);
 	return x + sprintf(buf + x, "\n");
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
