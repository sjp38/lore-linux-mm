Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 625506B004D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 20:44:55 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so1661806bkc.14
        for <linux-mm@kvack.org>; Mon, 06 Aug 2012 17:44:54 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [RFC v3 1/7] hashtable: introduce a small and naive hashtable
Date: Tue,  7 Aug 2012 02:45:10 +0200
Message-Id: <1344300317-23189-2-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1344300317-23189-1-git-send-email-levinsasha928@gmail.com>
References: <1344300317-23189-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, Sasha Levin <levinsasha928@gmail.com>

This hashtable implementation is using hlist buckets to provide a simple
hashtable to prevent it from getting reimplemented all over the kernel.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/hashtable.h |   82 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 82 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/hashtable.h

diff --git a/include/linux/hashtable.h b/include/linux/hashtable.h
new file mode 100644
index 0000000..394652b
--- /dev/null
+++ b/include/linux/hashtable.h
@@ -0,0 +1,82 @@
+/*
+ * Hash table implementation
+ * (C) 2012  Sasha Levin <levinsasha928@gmail.com>
+ */
+
+#ifndef _LINUX_HASHTABLE_H
+#define _LINUX_HASHTABLE_H
+
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/hash.h>
+
+#define DEFINE_HASHTABLE(name, bits)					\
+	struct hlist_head name[HASH_SIZE(bits)];
+
+#define HASH_SIZE(bits) (1 << (bits))
+
+/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
+#define hash_min(val, bits) ((sizeof(val)==4)?hash_32((val), (bits)):hash_long((val), (bits)))
+
+/**
+ * hash_init - initialize a hash table
+ * @hashtable: hashtable to be initialized
+ * @bits: bit count of hashing function
+ *
+ * Initializes a hash table with 2**bits buckets.
+ */
+static inline void hash_init(struct hlist_head *hashtable, int bits)
+{
+	int i;
+
+	for (i = 0; i < HASH_SIZE(bits); i++)
+		INIT_HLIST_HEAD(hashtable + i);
+}
+
+/**
+ * hash_add - add an object to a hashtable
+ * @hashtable: hashtable to add to
+ * @bits: bit count used for hashing
+ * @node: the &struct hlist_node of the object to be added
+ * @key: the key of the object to be added
+ */
+#define hash_add(hashtable, bits, node, key)				\
+	hlist_add_head(node, &hashtable[hash_min(key, bits)]);
+
+/**
+ * hash_del - remove an object from a hashtable
+ * @node: &struct hlist_node of the object to remove
+ */
+static inline void hash_del(struct hlist_node *node)
+{
+	hlist_del_init(node);
+}
+
+/**
+ * hash_for_each - iterate over a hashtable
+ * @name: hashtable to iterate
+ * @bits: bit count of hashing function of the hashtable
+ * @bkt: integer to use as bucket loop cursor
+ * @node: the &struct list_head to use as a loop cursor for each bucket
+ * @obj: the type * to use as a loop cursor for each bucket
+ * @member: the name of the hlist_node within the struct
+ */
+#define hash_for_each(name, bits, bkt, node, obj, member)		\
+	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)			\
+		hlist_for_each_entry(obj, node, &name[i], member)
+
+/**
+ * hash_for_each_possible - iterate over all possible objects for a giver key
+ * @name: hashtable to iterate
+ * @obj: the type * to use as a loop cursor for each bucke
+ * @bits: bit count of hashing function of the hashtable
+ * @node: the &struct list_head to use as a loop cursor for each bucket
+ * @member: the name of the hlist_node within the struct
+ * @key: the key of the objects to iterate over
+ */
+#define hash_for_each_possible(name, obj, bits, node, member, key)	\
+	hlist_for_each_entry(obj, node,					\
+		&name[hash_min(key, bits)], member)
+
+#endif
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
