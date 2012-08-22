Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0C4B36B0068
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 22:26:56 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id x4so779582obh.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 19:26:56 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
Date: Wed, 22 Aug 2012 04:26:56 +0200
Message-Id: <1345602432-27673-2-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com, Sasha Levin <levinsasha928@gmail.com>

This hashtable implementation is using hlist buckets to provide a simple
hashtable to prevent it from getting reimplemented all over the kernel.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/hashtable.h |  291 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 291 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/hashtable.h

diff --git a/include/linux/hashtable.h b/include/linux/hashtable.h
new file mode 100644
index 0000000..d2d6ed0
--- /dev/null
+++ b/include/linux/hashtable.h
@@ -0,0 +1,291 @@
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
+#include <linux/rculist.h>
+
+#define DEFINE_HASHTABLE(name, bits)					\
+	struct hlist_head name[HASH_SIZE(bits)];
+
+#define HASH_SIZE(bits) (1 << (bits))
+#define HASH_BITS(name) (ilog2(ARRAY_SIZE(name)))
+#define HASH_REQUIRED_SIZE(bits) (sizeof(struct hlist_head) * HASH_SIZE(bits))
+
+/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
+#define hash_min(val, bits) ((sizeof(val)==4) ? hash_32((val), (bits)) : hash_long((val), (bits)))
+
+/**
+ * hash_init_size - initialize a hash table
+ * @hashtable: hashtable to be initialized
+ * @bits: bit count of hashing function
+ *
+ * Initializes a hash table with 2**bits buckets.
+ */
+static inline void hash_init_size(struct hlist_head *hashtable, int bits)
+{
+	int i;
+
+	for (i = 0; i < HASH_SIZE(bits); i++)
+		INIT_HLIST_HEAD(hashtable + i);
+}
+
+/**
+ * hash_init - initialize a hash table
+ * @hashtable: hashtable to be initialized
+ *
+ * Calculates the size of the hashtable from the given parameter, otherwise
+ * same as hash_init_size.
+ */
+#define hash_init(name) hash_init_size(name, HASH_BITS(name))
+
+/**
+ * hash_add_size - add an object to a hashtable
+ * @hashtable: hashtable to add to
+ * @bits: bit count used for hashing
+ * @node: the &struct hlist_node of the object to be added
+ * @key: the key of the object to be added
+ */
+#define hash_add_size(hashtable, bits, node, key)				\
+	hlist_add_head(node, &hashtable[hash_min(key, bits)]);
+
+/**
+ * hash_add - add an object to a hashtable
+ * @hashtable: hashtable to add to
+ * @node: the &struct hlist_node of the object to be added
+ * @key: the key of the object to be added
+ */
+#define hash_add(hashtable, node, key)						\
+	hash_add_size(hashtable, HASH_BITS(hashtable), node, key)
+
+/**
+ * hash_add_rcu_size - add an object to a rcu enabled hashtable
+ * @hashtable: hashtable to add to
+ * @bits: bit count used for hashing
+ * @node: the &struct hlist_node of the object to be added
+ * @key: the key of the object to be added
+ */
+#define hash_add_rcu_size(hashtable, bits, node, key)				\
+	hlist_add_head_rcu(node, &hashtable[hash_min(key, bits)]);
+
+/**
+ * hash_add_rcu - add an object to a rcu enabled hashtable
+ * @hashtable: hashtable to add to
+ * @node: the &struct hlist_node of the object to be added
+ * @key: the key of the object to be added
+ */
+#define hash_add_rcu(hashtable, node, key)					\
+	hash_add_rcu_size(hashtable, HASH_BITS(hashtable), node, key)
+
+/**
+ * hash_hashed - check whether an object is in any hashtable
+ * @node: the &struct hlist_node of the object to be checked
+ */
+#define hash_hashed(node) (!hlist_unhashed(node))
+
+/**
+ * hash_empty_size - check whether a hashtable is empty
+ * @hashtable: hashtable to check
+ * @bits: bit count used for hashing
+ */
+static inline bool hash_empty_size(struct hlist_head *hashtable, int bits)
+{
+	int i;
+
+	for (i = 0; i < HASH_SIZE(bits); i++)
+		if (!hlist_empty(&hashtable[i]))
+			return false;
+
+	return true;
+}
+
+/**
+ * hash_empty - check whether a hashtable is empty
+ * @hashtable: hashtable to check
+ */
+#define hash_empty(name) hash_empty_size(name, HASH_BITS(name))
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
+ * hash_del_rcu - remove an object from a rcu enabled hashtable
+ * @node: &struct hlist_node of the object to remove
+ */
+static inline void hash_del_rcu(struct hlist_node *node)
+{
+	hlist_del_init_rcu(node);
+}
+
+/**
+ * hash_for_each_size - iterate over a hashtable
+ * @name: hashtable to iterate
+ * @bits: bit count of hashing function of the hashtable
+ * @bkt: integer to use as bucket loop cursor
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @obj: the type * to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ */
+#define hash_for_each_size(name, bits, bkt, node, obj, member)			\
+	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)				\
+		hlist_for_each_entry(obj, node, &name[bkt], member)
+
+/**
+ * hash_for_each - iterate over a hashtable
+ * @name: hashtable to iterate
+ * @bkt: integer to use as bucket loop cursor
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @obj: the type * to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ */
+#define hash_for_each(name, bkt, node, obj, member)				\
+	hash_for_each_size(name, HASH_BITS(name), bkt, node, obj, member)
+
+/**
+ * hash_for_each_rcu_size - iterate over a rcu enabled hashtable
+ * @name: hashtable to iterate
+ * @bits: bit count of hashing function of the hashtable
+ * @bkt: integer to use as bucket loop cursor
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @obj: the type * to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ */
+#define hash_for_each_rcu_size(name, bits, bkt, node, obj, member)		\
+	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)				\
+		hlist_for_each_entry_rcu(obj, node, &name[bkt], member)
+
+/**
+ * hash_for_each_rcu - iterate over a rcu enabled hashtable
+ * @name: hashtable to iterate
+ * @bkt: integer to use as bucket loop cursor
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @obj: the type * to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ */
+#define hash_for_each_rcu(name, bkt, node, obj, member)				\
+	hash_for_each_rcu_size(name, HASH_BITS(name), bkt, node, obj, member)
+
+/**
+ * hash_for_each_safe_size - iterate over a hashtable safe against removal of
+ * hash entry
+ * @name: hashtable to iterate
+ * @bkt: integer to use as bucket loop cursor
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @tmp: another &struct hlist_node to use as temporary storage
+ * @obj: the type * to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ */
+#define hash_for_each_safe_size(name, bits, bkt, node, tmp, obj, member)	\
+	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)                     	\
+		hlist_for_each_entry_safe(obj, node, tmp, &name[bkt], member)
+
+/**
+ * hash_for_each_safe_size - iterate over a hashtable safe against removal of
+ * hash entry
+ * @name: hashtable to iterate
+ * @bkt: integer to use as bucket loop cursor
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @obj: the type * to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ */
+#define hash_for_each_safe(name, bkt, node, tmp, obj, member)			\
+	hash_for_each_safe_size(name, HASH_BITS(name), bkt, node,		\
+				tmp, obj, member)
+
+/**
+ * hash_for_each_possible - iterate over all possible objects hasing to the
+ * same bucket
+ * @name: hashtable to iterate
+ * @obj: the type * to use as a loop cursor for each entry
+ * @bits: bit count of hashing function of the hashtable
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ * @key: the key of the objects to iterate over
+ */
+#define hash_for_each_possible_size(name, obj, bits, node, member, key)		\
+	hlist_for_each_entry(obj, node,	&name[hash_min(key, bits)], member)
+
+/**
+ * hash_for_each_possible - iterate over all possible objects hashing to the
+ * same bucket
+ * @name: hashtable to iterate
+ * @obj: the type * to use as a loop cursor for each entry
+ * @bits: bit count of hashing function of the hashtable
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ * @key: the key of the objects to iterate over
+ */
+#define hash_for_each_possible(name, obj, node, member, key)			\
+	hash_for_each_possible_size(name, obj, HASH_BITS(name), node, member, key)
+
+/**
+ * hash_for_each_possible - iterate over all possible objects hashing to the
+ * same bucket
+ * in a rcu enabled hashtable
+ * @name: hashtable to iterate
+ * @obj: the type * to use as a loop cursor for each entry
+ * @bits: bit count of hashing function of the hashtable
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ * @key: the key of the objects to iterate over
+ */
+#define hash_for_each_possible_rcu_size(name, obj, bits, node, member, key)	\
+	hlist_for_each_entry_rcu(obj, node, &name[hash_min(key, bits)], member)
+
+/**
+ * hash_for_each_possible - iterate over all possible objects hashing to the
+ * same bucket
+ * in a rcu enabled hashtable
+ * @name: hashtable to iterate
+ * @obj: the type * to use as a loop cursor for each entry
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ * @key: the key of the objects to iterate over
+ */
+#define hash_for_each_possible_rcu(name, obj, node, member, key)		\
+	hash_for_each_possible_rcu_size(name, obj, HASH_BITS(name),		\
+					node, member, key)
+
+/**
+ * hash_for_each_possible - iterate over all possible objects hashing to the
+ * same bucket
+ * safe against removal of hash entry
+ * @name: hashtable to iterate
+ * @obj: the type * to use as a loop cursor for each entry
+ * @bits: bit count of hashing function of the hashtable
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ * @key: the key of the objects to iterate over
+ */
+#define hash_for_each_possible_safe_size(name, obj, bits, node, tmp, member, key)\
+	hlist_for_each_entry_safe(obj, node, tmp,				\
+		&name[hash_min(key, bits)], member)
+
+/**
+ * hash_for_each_possible - iterate over all possible objects hashing to the
+ * same bucket
+ * safe against removal of hash entry
+ * @name: hashtable to iterate
+ * @obj: the type * to use as a loop cursor for each entry
+ * @node: the &struct list_head to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ * @key: the key of the objects to iterate over
+ */
+#define hash_for_each_possible_safe(name, obj, node, tmp, member, key)		\
+	hash_for_each_possible_safe_size(name, obj, HASH_BITS(name),		\
+						node, tmp, member, key)
+
+#endif
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
