Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E62826B038D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 05:49:33 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f21so44037821pgi.4
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 02:49:33 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h69si18191268pgc.108.2017.02.20.02.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 02:49:33 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 3/5] mm: convert kmemleak_object.use_count from atomic_t to refcount_t
Date: Mon, 20 Feb 2017 12:49:12 +0200
Message-Id: <1487587754-10610-4-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1487587754-10610-1-git-send-email-elena.reshetova@intel.com>
References: <1487587754-10610-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Elena Reshetova <elena.reshetova@intel.com>, Hans Liljestrand <ishkamiel@gmail.com>, Kees Cook <keescook@chromium.org>, David Windsor <dwindsor@gmail.com>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 mm/kmemleak.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index da34369..2e1167b 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -105,7 +105,7 @@
 
 #include <asm/sections.h>
 #include <asm/processor.h>
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 
 #include <linux/kasan.h>
 #include <linux/kmemcheck.h>
@@ -154,7 +154,7 @@ struct kmemleak_object {
 	struct rb_node rb_node;
 	struct rcu_head rcu;		/* object_list lockless traversal */
 	/* object usage count; object freed when use_count == 0 */
-	atomic_t use_count;
+	refcount_t use_count;
 	unsigned long pointer;
 	size_t size;
 	/* minimum number of a pointers found before it is considered leak */
@@ -434,7 +434,7 @@ static struct kmemleak_object *lookup_object(unsigned long ptr, int alias)
  */
 static int get_object(struct kmemleak_object *object)
 {
-	return atomic_inc_not_zero(&object->use_count);
+	return refcount_inc_not_zero(&object->use_count);
 }
 
 /*
@@ -467,7 +467,7 @@ static void free_object_rcu(struct rcu_head *rcu)
  */
 static void put_object(struct kmemleak_object *object)
 {
-	if (!atomic_dec_and_test(&object->use_count))
+	if (!refcount_dec_and_test(&object->use_count))
 		return;
 
 	/* should only get here after delete_object was called */
@@ -556,7 +556,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	INIT_LIST_HEAD(&object->gray_list);
 	INIT_HLIST_HEAD(&object->area_list);
 	spin_lock_init(&object->lock);
-	atomic_set(&object->use_count, 1);
+	refcount_set(&object->use_count, 1);
 	object->flags = OBJECT_ALLOCATED;
 	object->pointer = ptr;
 	object->size = size;
@@ -629,7 +629,7 @@ static void __delete_object(struct kmemleak_object *object)
 	unsigned long flags;
 
 	WARN_ON(!(object->flags & OBJECT_ALLOCATED));
-	WARN_ON(atomic_read(&object->use_count) < 1);
+	WARN_ON(refcount_read(&object->use_count) < 1);
 
 	/*
 	 * Locking here also ensures that the corresponding memory block
@@ -1396,9 +1396,9 @@ static void kmemleak_scan(void)
 		 * With a few exceptions there should be a maximum of
 		 * 1 reference to any object at this point.
 		 */
-		if (atomic_read(&object->use_count) > 1) {
+		if (refcount_read(&object->use_count) > 1) {
 			pr_debug("object->use_count = %d\n",
-				 atomic_read(&object->use_count));
+				 refcount_read(&object->use_count));
 			dump_object_info(object);
 		}
 #endif
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
