Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 1 of 3] list_del_init_rcu
Message-Id: <5e8c41d283ccef7c739b.1214440017@duo.random>
In-Reply-To: <patchbomb.1214440016@duo.random>
Date: Thu, 26 Jun 2008 02:26:57 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
From: Andrea Arcangeli <andrea@qumranet.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm@vger.kernel.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Izik Eidus <izike@qumranet.com>Anthony Liguori <aliguori@us.ibm.com>, Rik van Riel <riel@redhat.com>
Cc: andrea@qumranet.com
List-ID: <linux-mm.kvack.org>

Introduces list_del_init_rcu and documents it (fixes a comment for
list_del_rcu too).

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
---

diff -r 98f755616212 -r 5e8c41d283cc include/linux/list.h
--- a/include/linux/list.h	Tue Jun 24 11:23:35 2008 -0700
+++ b/include/linux/list.h	Wed Jun 25 03:34:11 2008 +0200
@@ -747,7 +747,7 @@ static inline void hlist_del(struct hlis
  * or hlist_del_rcu(), running on this same list.
  * However, it is perfectly legal to run concurrently with
  * the _rcu list-traversal primitives, such as
- * hlist_for_each_entry().
+ * hlist_for_each_entry_rcu().
  */
 static inline void hlist_del_rcu(struct hlist_node *n)
 {
@@ -760,6 +760,34 @@ static inline void hlist_del_init(struct
 	if (!hlist_unhashed(n)) {
 		__hlist_del(n);
 		INIT_HLIST_NODE(n);
+	}
+}
+
+/**
+ * hlist_del_init_rcu - deletes entry from hash list with re-initialization
+ * @n: the element to delete from the hash list.
+ *
+ * Note: list_unhashed() on the node return true after this. It is
+ * useful for RCU based read lockfree traversal if the writer side
+ * must know if the list entry is still hashed or already unhashed.
+ *
+ * In particular, it means that we can not poison the forward pointers
+ * that may still be used for walking the hash list and we can only
+ * zero the pprev pointer so list_unhashed() will return true after
+ * this.
+ *
+ * The caller must take whatever precautions are necessary (such as
+ * holding appropriate locks) to avoid racing with another
+ * list-mutation primitive, such as hlist_add_head_rcu() or
+ * hlist_del_rcu(), running on this same list.  However, it is
+ * perfectly legal to run concurrently with the _rcu list-traversal
+ * primitives, such as hlist_for_each_entry_rcu().
+ */
+static inline void hlist_del_init_rcu(struct hlist_node *n)
+{
+	if (!hlist_unhashed(n)) {
+		__hlist_del(n);
+		n->pprev = NULL;
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
