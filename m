Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0406B0082
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 10:29:41 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so78645742qkh.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 07:29:41 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e145si2651492qhc.95.2015.06.08.07.29.37
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 07:29:38 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2 4/4] mm: kmemleak: Avoid deadlock on the kmemleak object insertion error path
Date: Mon,  8 Jun 2015 15:29:18 +0100
Message-Id: <1433773758-21994-5-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1433773758-21994-1-git-send-email-catalin.marinas@arm.com>
References: <1433773758-21994-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, vigneshr@codeaurora.org

While very unlikely (usually kmemleak or sl*b bug), the create_object()
function in mm/kmemleak.c may fail to insert a newly allocated object
into the rb tree. When this happens, kmemleak disables itself and prints
additional information about the object already found in the rb tree.
Such printing is done with the parent->lock acquired, however the
kmemleak_lock is already held. This is a potential race with the
scanning thread which acquires object->lock and kmemleak_lock in a
different order.

This patch removes the locking around the 'parent' object information
printing. Such object cannot be freed or removed from object_tree_root
and object_list since kmemleak_lock is already held. There is a very
small risk that some of the object data is being modified on another CPU
but the only downside is inconsistent information printing.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/kmemleak.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 8a57e34625fa..c0fd7769d227 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -53,6 +53,11 @@
  *   modifications to the memory scanning parameters including the scan_thread
  *   pointer
  *
+ * Locks and mutexes should only be acquired/nested in the following order:
+ *
+ *   scan_mutex -> object->lock -> other_object->lock (SINGLE_DEPTH_NESTING)
+ *				-> kmemleak_lock
+ *
  * The kmemleak_object structures have a use_count incremented or decremented
  * using the get_object()/put_object() functions. When the use_count becomes
  * 0, this count can no longer be incremented and put_object() schedules the
@@ -603,11 +608,13 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 			kmemleak_stop("Cannot insert 0x%lx into the object "
 				      "search tree (overlaps existing)\n",
 				      ptr);
+			/*
+			 * No need for parent->lock here since "parent" cannot
+			 * be freed while the kmemleak_lock is held.
+			 */
+			dump_object_info(parent);
 			kmem_cache_free(object_cache, object);
-			object = parent;
-			spin_lock(&object->lock);
-			dump_object_info(object);
-			spin_unlock(&object->lock);
+			object = NULL;
 			goto out;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
