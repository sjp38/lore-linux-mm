Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B8BB26B0089
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 20:44:57 -0400 (EDT)
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <linux-mm@kvack.org>; Fri, 04 Sep 2009 17:45:02 -0700
From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: [PATCH v3 4/5] kmemleak: fix sparse warning over overshadowed flags
Date: Fri, 4 Sep 2009 17:44:53 -0700
Message-ID: <1252111494-7593-5-git-send-email-lrodriguez@atheros.com>
In-Reply-To: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
References: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, mcgrof@gmail.com, "Luis R. Rodriguez" <lrodriguez@atheros.com>
List-ID: <linux-mm.kvack.org>

A secondary irq_save is not required as a locking before it was
already disabling irqs.

This fixes this sparse warning:
mm/kmemleak.c:512:31: warning: symbol 'flags' shadows an earlier one
mm/kmemleak.c:448:23: originally declared here

Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
---
 mm/kmemleak.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 18dfd62..d078621 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -552,6 +552,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	object->tree_node.last = ptr + size - 1;
 
 	write_lock_irqsave(&kmemleak_lock, flags);
+
 	min_addr = min(min_addr, ptr);
 	max_addr = max(max_addr, ptr + size);
 	node = prio_tree_insert(&object_tree_root, &object->tree_node);
@@ -562,14 +563,12 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	 * random memory blocks.
 	 */
 	if (node != &object->tree_node) {
-		unsigned long flags;
-
 		kmemleak_stop("Cannot insert 0x%lx into the object search tree "
 			      "(already existing)\n", ptr);
 		object = lookup_object(ptr, 1);
-		spin_lock_irqsave(&object->lock, flags);
+		spin_lock(&object->lock);
 		dump_object_info(object);
-		spin_unlock_irqrestore(&object->lock, flags);
+		spin_unlock(&object->lock);
 
 		goto out;
 	}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
