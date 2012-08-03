Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 9AEE36B005A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 10:23:14 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so397078bkc.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 07:23:12 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
Date: Fri,  3 Aug 2012 16:23:02 +0200
Message-Id: <1344003788-1417-2-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

This hashtable implementation is using hlist buckets to provide a simple
hashtable to prevent it from getting reimplemented all over the kernel.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/hashtable.h |   75 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 75 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/hashtable.h

diff --git a/include/linux/hashtable.h b/include/linux/hashtable.h
new file mode 100644
index 0000000..b004cf7
--- /dev/null
+++ b/include/linux/hashtable.h
@@ -0,0 +1,75 @@
+#ifndef _LINUX_HASHTABLE_H
+#define _LINUX_HASHTABLE_H
+
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/hash.h>
+
+struct hash_table {
+	size_t bits;
+	struct hlist_head buckets[];
+};
+
+#define DEFINE_STATIC_HASHTABLE(n, b)					\
+	static struct hash_table n = { .bits = (b),			\
+		.buckets = { [0 ... ((1 << (b)) - 1)] = HLIST_HEAD_INIT } }
+
+#define DEFINE_HASHTABLE(n, b)						\
+	union {								\
+		struct hash_table n;					\
+		struct {						\
+			size_t bits;					\
+			struct hlist_head buckets[1 << (b)];		\
+		} __##n ;						\
+	};
+
+#define HASH_BITS(name) ((name)->bits)
+#define HASH_SIZE(name) (1 << (HASH_BITS(name)))
+
+__attribute__ ((unused))
+static void hash_init(struct hash_table *ht, size_t bits)
+{
+	size_t i;
+
+	ht->bits = bits;
+	for (i = 0; i < (1 << bits); i++)
+		INIT_HLIST_HEAD(&ht->buckets[i]);
+}
+
+static void hash_add(struct hash_table *ht, struct hlist_node *node, long key)
+{
+	hlist_add_head(node,
+		&ht->buckets[hash_long((unsigned long)key, HASH_BITS(ht))]);
+}
+
+
+#define hash_get(name, key, type, member, cmp_fn)			\
+({									\
+	struct hlist_node *__node;					\
+	typeof(key) __key = key;					\
+	type *__obj = NULL;						\
+	hlist_for_each_entry(__obj, __node, &(name)->buckets[		\
+			hash_long((unsigned long) __key,		\
+			HASH_BITS(name))], member)			\
+		if (cmp_fn(__obj, __key))				\
+			break;						\
+	__obj;								\
+})
+
+__attribute__ ((unused))
+static void hash_del(struct hlist_node *node)
+{
+	hlist_del_init(node);
+}
+
+#define hash_for_each(bkt, node, name, obj, member)			\
+	for (bkt = 0; bkt < HASH_SIZE(name); bkt++)			\
+		hlist_for_each_entry(obj, node, &(name)->buckets[i], member)
+
+#define hash_for_each_possible(name, node, obj, member, key)		\
+	hlist_for_each_entry(obj, node,					\
+		&(name)->buckets[hash_long((unsigned long) key,		\
+			HASH_BITS(name))], member)
+
+#endif
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
