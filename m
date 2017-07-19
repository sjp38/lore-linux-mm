Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5171F6B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 14:28:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z53so8863995wrz.10
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 11:28:34 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id z37si5023149wrb.382.2017.07.19.11.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 11:28:32 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id k69so6157611wmc.1
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 11:28:32 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] llist: clang: introduce member_address_is_nonnull()
Date: Wed, 19 Jul 2017 20:27:30 +0200
Message-Id: <20170719182730.65794-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, kcc@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, mingo@elte.hu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, md@google.com, ndesaulniers@google.com, ghackmann@google.com, mka@google.com

Currently llist_for_each_entry() and llist_for_each_entry_safe() iterate
until &pos->member != NULL.  But when building the kernel with Clang, the
compiler assumes &pos->member cannot be NULL if the member's offset is
greater than 0 (which would be equivalent to the object being
non-contiguous in memory). Therefore the loop condition is always true,
and the loops become infinite.

To work around this, introduce the member_address_is_nonnull() macro,
which casts object pointer to uintptr_t, thus letting the member pointer
to be NULL.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 include/linux/llist.h | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/linux/llist.h b/include/linux/llist.h
index d11738110a7a..a7cdaeddad35 100644
--- a/include/linux/llist.h
+++ b/include/linux/llist.h
@@ -92,6 +92,23 @@ static inline void init_llist_head(struct llist_head *list)
 #define llist_entry(ptr, type, member)		\
 	container_of(ptr, type, member)
 
+/**
+ * member_address_is_nonnull - check whether the member address is not NULL
+ * @ptr:	the object pointer (struct type * that contains the llist_node)
+ * @member:	the name of the llist_node within the struct.
+ *
+ * This macro is conceptually the same as
+ *	&ptr->member != NULL
+ * , but it works around the fact that compilers can decide that taking a member
+ * address is never a NULL pointer.
+ *
+ * Real objects that start at a high address and have a member at NULL are
+ * unlikely to exist, but such pointers may be returned e.g. by the
+ * container_of() macro.
+ */
+#define member_address_is_nonnull(ptr, member)	\
+	((uintptr_t)(ptr) + offsetof(typeof(*(ptr)), member) != 0)
+
 /**
  * llist_for_each - iterate over some deleted entries of a lock-less list
  * @pos:	the &struct llist_node to use as a loop cursor
@@ -145,7 +162,7 @@ static inline void init_llist_head(struct llist_head *list)
  */
 #define llist_for_each_entry(pos, node, member)				\
 	for ((pos) = llist_entry((node), typeof(*(pos)), member);	\
-	     &(pos)->member != NULL;					\
+	     member_address_is_nonnull(pos, member);			\
 	     (pos) = llist_entry((pos)->member.next, typeof(*(pos)), member))
 
 /**
@@ -167,7 +184,7 @@ static inline void init_llist_head(struct llist_head *list)
  */
 #define llist_for_each_entry_safe(pos, n, node, member)			       \
 	for (pos = llist_entry((node), typeof(*pos), member);		       \
-	     &pos->member != NULL &&					       \
+	     member_address_is_nonnull(pos, member) &&			       \
 	        (n = llist_entry(pos->member.next, typeof(*n), member), true); \
 	     pos = n)
 
-- 
2.14.0.rc0.284.gd933b75aa4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
