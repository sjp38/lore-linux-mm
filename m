Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E932C6B00A8
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 14:05:04 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so4023084bkc.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 11:05:04 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC 1/4] hashtable: introduce a small and naive hashtable
Date: Tue, 31 Jul 2012 20:05:17 +0200
Message-Id: <1343757920-19713-2-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, Sasha Levin <levinsasha928@gmail.com>

This hashtable implementation is using hlist buckets to provide a simple
hashtable to prevent it from getting reimplemented all over the kernel.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/hashtable.h |   46 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/hashtable.h

diff --git a/include/linux/hashtable.h b/include/linux/hashtable.h
new file mode 100644
index 0000000..9b29fd1
--- /dev/null
+++ b/include/linux/hashtable.h
@@ -0,0 +1,46 @@
+#ifndef _LINUX_HASHTABLE_H
+#define _LINUX_HASHTABLE_H
+
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/hash.h>
+
+#define DEFINE_HASHTABLE(name, bits)					\
+	struct hlist_head name[1 << bits];
+
+#define HASH_BITS(name) (order_base_2(ARRAY_SIZE(name)))
+#define HASH_SIZE(name) (1 << (HASH_BITS(name)))
+
+#define HASH_INIT(name)							\
+({									\
+	int __i;							\
+	for (__i = 0 ; __i < HASH_SIZE(name) ; __i++)			\
+		INIT_HLIST_HEAD(&name[__i]);				\
+})
+
+#define HASH_ADD(name, obj, key)					\
+	hlist_add_head(obj, &name[					\
+		hash_long((unsigned long)key, HASH_BITS(name))]);
+
+#define HASH_GET(name, key, type, member, cmp_fn)			\
+({									\
+	struct hlist_node *__node;					\
+	typeof(key) __key = key;					\
+	type *__obj = NULL;						\
+	hlist_for_each_entry(__obj, __node, &name[			\
+			hash_long((unsigned long) __key,		\
+			HASH_BITS(name))], member)			\
+		if (cmp_fn(__obj, __key))				\
+			break;						\
+	__obj;								\
+})
+
+#define HASH_DEL(obj, member)						\
+	hlist_del(&obj->member)
+
+#define HASH_FOR_EACH(bkt, node, name, obj, member)			\
+	for (bkt = 0; bkt < HASH_SIZE(name); bkt++)			\
+		hlist_for_each_entry(obj, node, &name[i], member)
+
+#endif
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
