Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 84FB36B0083
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 20:44:56 -0400 (EDT)
Received: from mail.atheros.com ([10.10.20.105])
	by sidewinder.atheros.com
	for <linux-mm@kvack.org>; Fri, 04 Sep 2009 17:45:00 -0700
From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: [PATCH v3 3/5] kmemleak: move common painting code together
Date: Fri, 4 Sep 2009 17:44:52 -0700
Message-ID: <1252111494-7593-4-git-send-email-lrodriguez@atheros.com>
In-Reply-To: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
References: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, mcgrof@gmail.com, "Luis R. Rodriguez" <lrodriguez@atheros.com>
List-ID: <linux-mm.kvack.org>

When painting grey or black we do the same thing, bring
this together into a helper and identify coloring grey or
black explicitly with defines. This makes this a little
easier to read.

Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
---
 mm/kmemleak.c |   68 +++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 40 insertions(+), 28 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 76dd7af..18dfd62 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -122,6 +122,9 @@ struct kmemleak_scan_area {
 	size_t length;
 };
 
+#define KMEMLEAK_GREY	0
+#define KMEMLEAK_BLACK	-1
+
 /*
  * Structure holding the metadata for each allocated memory block.
  * Modifications to such objects should be made while holding the
@@ -307,17 +310,19 @@ static void hex_dump_object(struct seq_file *seq,
  */
 static bool color_white(const struct kmemleak_object *object)
 {
-	return object->count != -1 && object->count < object->min_count;
+	return object->count != KMEMLEAK_BLACK &&
+		object->count < object->min_count;
 }
 
 static bool color_gray(const struct kmemleak_object *object)
 {
-	return object->min_count != -1 && object->count >= object->min_count;
+	return object->min_count != KMEMLEAK_BLACK &&
+		object->count >= object->min_count;
 }
 
 static bool color_black(const struct kmemleak_object *object)
 {
-	return object->min_count == -1;
+	return object->min_count == KMEMLEAK_BLACK;
 }
 
 /*
@@ -658,47 +663,54 @@ static void delete_object_part(unsigned long ptr, size_t size)
 
 	put_object(object);
 }
-/*
- * Make a object permanently as gray-colored so that it can no longer be
- * reported as a leak. This is used in general to mark a false positive.
- */
-static void make_gray_object(unsigned long ptr)
+
+static void __paint_it(struct kmemleak_object *object, int color)
+{
+	object->min_count = color;
+	if (color == KMEMLEAK_BLACK)
+		object->flags |= OBJECT_NO_SCAN;
+}
+
+static void paint_it(struct kmemleak_object *object, int color)
 {
 	unsigned long flags;
+	spin_lock_irqsave(&object->lock, flags);
+	__paint_it(object, color);
+	spin_unlock_irqrestore(&object->lock, flags);
+}
+
+static void paint_ptr(unsigned long ptr, int color)
+{
 	struct kmemleak_object *object;
 
 	object = find_and_get_object(ptr, 0);
 	if (!object) {
-		kmemleak_warn("Graying unknown object at 0x%08lx\n", ptr);
+		kmemleak_warn("Tried to color unknown object "
+			      "at 0x%08lx as %s\n", ptr,
+			      (color == KMEMLEAK_GREY) ? "Grey" :
+			      (color == KMEMLEAK_BLACK) ? "Black" : "Unknown");
 		return;
 	}
-
-	spin_lock_irqsave(&object->lock, flags);
-	object->min_count = 0;
-	spin_unlock_irqrestore(&object->lock, flags);
+	paint_it(object, color);
 	put_object(object);
 }
 
 /*
+ * Make a object permanently as gray-colored so that it can no longer be
+ * reported as a leak. This is used in general to mark a false positive.
+ */
+static void make_gray_object(unsigned long ptr)
+{
+	paint_ptr(ptr, KMEMLEAK_GREY);
+}
+
+/*
  * Mark the object as black-colored so that it is ignored from scans and
  * reporting.
  */
 static void make_black_object(unsigned long ptr)
 {
-	unsigned long flags;
-	struct kmemleak_object *object;
-
-	object = find_and_get_object(ptr, 0);
-	if (!object) {
-		kmemleak_warn("Blacking unknown object at 0x%08lx\n", ptr);
-		return;
-	}
-
-	spin_lock_irqsave(&object->lock, flags);
-	object->min_count = -1;
-	object->flags |= OBJECT_NO_SCAN;
-	spin_unlock_irqrestore(&object->lock, flags);
-	put_object(object);
+	paint_ptr(ptr, KMEMLEAK_BLACK);
 }
 
 /*
@@ -1422,7 +1434,7 @@ static void kmemleak_clear(void)
 		spin_lock_irqsave(&object->lock, flags);
 		if ((object->flags & OBJECT_REPORTED) &&
 		    unreferenced_object(object))
-			object->min_count = -1;
+			__paint_it(object, KMEMLEAK_GREY);
 		spin_unlock_irqrestore(&object->lock, flags);
 	}
 	rcu_read_unlock();
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
