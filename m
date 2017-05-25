Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5907E6B02F4
	for <linux-mm@kvack.org>; Thu, 25 May 2017 11:42:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b74so232556199pfd.2
        for <linux-mm@kvack.org>; Thu, 25 May 2017 08:42:30 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n6si28330875pfb.286.2017.05.25.08.42.29
        for <linux-mm@kvack.org>;
        Thu, 25 May 2017 08:42:29 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2 2/3] mm: kmemleak: Factor object reference updating out of scan_block()
Date: Thu, 25 May 2017 16:42:16 +0100
Message-Id: <1495726937-23557-3-git-send-email-catalin.marinas@arm.com>
In-Reply-To: <1495726937-23557-1-git-send-email-catalin.marinas@arm.com>
References: <1495726937-23557-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@amacapital.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

The scan_block() function updates the number of references (pointers) to
objects, adding them to the gray_list when object->min_count is reached.
The patch factors out this functionality into a separate update_refs()
function.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/kmemleak.c | 43 +++++++++++++++++++++++++------------------
 1 file changed, 25 insertions(+), 18 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 964b12eba2c1..266482f460c2 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1188,6 +1188,30 @@ static bool update_checksum(struct kmemleak_object *object)
 }
 
 /*
+ * Update an object's references. object->lock must be held by the caller.
+ */
+static void update_refs(struct kmemleak_object *object)
+{
+	if (!color_white(object)) {
+		/* non-orphan, ignored or new */
+		return;
+	}
+
+	/*
+	 * Increase the object's reference count (number of pointers to the
+	 * memory block). If this count reaches the required minimum, the
+	 * object's color will become gray and it will be added to the
+	 * gray_list.
+	 */
+	object->count++;
+	if (color_gray(object)) {
+		/* put_object() called when removing from gray_list */
+		WARN_ON(!get_object(object));
+		list_add_tail(&object->gray_list, &gray_list);
+	}
+}
+
+/*
  * Memory scanning is a long process and it needs to be interruptable. This
  * function checks whether such interrupt condition occurred.
  */
@@ -1259,24 +1283,7 @@ static void scan_block(void *_start, void *_end,
 		 * enclosed by scan_mutex.
 		 */
 		spin_lock_nested(&object->lock, SINGLE_DEPTH_NESTING);
-		if (!color_white(object)) {
-			/* non-orphan, ignored or new */
-			spin_unlock(&object->lock);
-			continue;
-		}
-
-		/*
-		 * Increase the object's reference count (number of pointers
-		 * to the memory block). If this count reaches the required
-		 * minimum, the object's color will become gray and it will be
-		 * added to the gray_list.
-		 */
-		object->count++;
-		if (color_gray(object)) {
-			/* put_object() called when removing from gray_list */
-			WARN_ON(!get_object(object));
-			list_add_tail(&object->gray_list, &gray_list);
-		}
+		update_refs(object);
 		spin_unlock(&object->lock);
 	}
 	read_unlock_irqrestore(&kmemleak_lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
