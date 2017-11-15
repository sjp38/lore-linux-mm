Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 846F76B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 12:34:53 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l8so13324397wre.19
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:34:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z132sor3539932wmg.31.2017.11.15.09.34.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 09:34:52 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] lib/stackdepot: use a non-instrumented version of memcmp()
Date: Wed, 15 Nov 2017 18:34:45 +0100
Message-Id: <20171115173445.37236-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, dvyukov@google.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

stackdepot used to call memcmp(), which compiler tools normally
instrument, therefore every lookup used to unnecessarily call
instrumented code.
This is somewhat ok in the case of KASAN, but under KMSAN a lot of time
was spent in the instrumentation.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 lib/stackdepot.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index f87d138e9672..d372101e8dc2 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -163,6 +163,23 @@ static inline u32 hash_stack(unsigned long *entries, unsigned int size)
 			       STACK_HASH_SEED);
 }
 
+/* Use our own, non-instrumented version of memcmp().
+ *
+ * We actually don't care about the order, just the equality.
+ */
+static inline
+int stackdepot_memcmp(const void *s1, const void *s2, unsigned int n)
+{
+	unsigned long *u1 = (unsigned long *)s1;
+	unsigned long *u2 = (unsigned long *)s2;
+
+	for ( ; n-- ; u1++, u2++) {
+		if (*u1 != *u2)
+			return 1;
+	}
+	return 0;
+}
+
 /* Find a stack that is equal to the one stored in entries in the hash */
 static inline struct stack_record *find_stack(struct stack_record *bucket,
 					     unsigned long *entries, int size,
@@ -173,10 +190,8 @@ static inline struct stack_record *find_stack(struct stack_record *bucket,
 	for (found = bucket; found; found = found->next) {
 		if (found->hash == hash &&
 		    found->size == size &&
-		    !memcmp(entries, found->entries,
-			    size * sizeof(unsigned long))) {
+		    !stackdepot_memcmp(entries, found->entries, size))
 			return found;
-		}
 	}
 	return NULL;
 }
-- 
2.15.0.448.gf294e3d99a-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
