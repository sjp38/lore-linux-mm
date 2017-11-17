Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE5A6B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 12:26:21 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id o12so690078wme.5
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 09:26:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a138sor1208360wmd.42.2017.11.17.09.26.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 09:26:19 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2] lib/stackdepot: use a non-instrumented version of memcmp()
Date: Fri, 17 Nov 2017 18:21:49 +0100
Message-Id: <20171117172149.69562-1-glider@google.com>
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
v2: As requested by Andrey Ryabinin, made the parameters unsigned long *
---
 lib/stackdepot.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index f87d138e9672..e513459a5601 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -163,6 +163,21 @@ static inline u32 hash_stack(unsigned long *entries, unsigned int size)
 			       STACK_HASH_SEED);
 }
 
+/* Use our own, non-instrumented version of memcmp().
+ *
+ * We actually don't care about the order, just the equality.
+ */
+static inline
+int stackdepot_memcmp(const unsigned long *u1, const unsigned long *u2,
+			unsigned int n)
+{
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
@@ -173,10 +188,8 @@ static inline struct stack_record *find_stack(struct stack_record *bucket,
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
