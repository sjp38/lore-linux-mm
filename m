Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 9138B6B0037
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 04:38:12 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fz6so5976859pac.3
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 01:38:11 -0700 (PDT)
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [PATCH v9 02/13] hashtable: add hash_for_each_possible_rcu_notrace()
Date: Wed, 28 Aug 2013 18:37:39 +1000
Message-Id: <1377679070-3515-3-git-send-email-aik@ozlabs.ru>
In-Reply-To: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org

This adds hash_for_each_possible_rcu_notrace() which is basically
a notrace clone of hash_for_each_possible_rcu() which cannot be
used in real mode due to its tracing/debugging capability.

Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>

---
Changes:
v8:
* fixed warnings from check_patch.pl
---
 include/linux/hashtable.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/linux/hashtable.h b/include/linux/hashtable.h
index a9df51f..519b6e2 100644
--- a/include/linux/hashtable.h
+++ b/include/linux/hashtable.h
@@ -174,6 +174,21 @@ static inline void hash_del_rcu(struct hlist_node *node)
 		member)
 
 /**
+ * hash_for_each_possible_rcu_notrace - iterate over all possible objects hashing
+ * to the same bucket in an rcu enabled hashtable in a rcu enabled hashtable
+ * @name: hashtable to iterate
+ * @obj: the type * to use as a loop cursor for each entry
+ * @member: the name of the hlist_node within the struct
+ * @key: the key of the objects to iterate over
+ *
+ * This is the same as hash_for_each_possible_rcu() except that it does
+ * not do any RCU debugging or tracing.
+ */
+#define hash_for_each_possible_rcu_notrace(name, obj, member, key) \
+	hlist_for_each_entry_rcu_notrace(obj, \
+		&name[hash_min(key, HASH_BITS(name))], member)
+
+/**
  * hash_for_each_possible_safe - iterate over all possible objects hashing to the
  * same bucket safe against removals
  * @name: hashtable to iterate
-- 
1.8.4.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
