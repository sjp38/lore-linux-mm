Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 9EBBF6B0036
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:22 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 26 Jul 2013 17:14:21 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F31A038C8027
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:16 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6QLEI34163584
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:18 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6QLEGpW013388
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 18:14:17 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 2/5] rbtree: add rbtree_postorder_for_each_entry_safe() helper
Date: Fri, 26 Jul 2013 14:13:40 -0700
Message-Id: <1374873223-25557-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Because deletion (of the entire tree) is a relatively common use of the
rbtree_postorder iteration, and because doing it safely means fiddling
with temporary storage, provide a helper to simplify postorder rbtree
iteration.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/rbtree.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 2879e96..64ab98b 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -85,4 +85,21 @@ static inline void rb_link_node(struct rb_node * node, struct rb_node * parent,
 	*rb_link = node;
 }
 
+/**
+ * rbtree_postorder_for_each_entry_safe - iterate over rb_root in post order of
+ * given type safe against removal of rb_node entry
+ *
+ * @pos:	the 'type *' to use as a loop cursor.
+ * @n:		another 'type *' to use as temporary storage
+ * @root:	'rb_root *' of the rbtree.
+ * @field:	the name of the rb_node field within 'type'.
+ */
+#define rbtree_postorder_for_each_entry_safe(pos, n, root, field) \
+	for (pos = rb_entry(rb_first_postorder(root), typeof(*pos), field),\
+	      n = rb_entry(rb_next_postorder(&pos->field), \
+		      typeof(*pos), field); \
+	     &pos->field; \
+	     pos = n, \
+	      n = rb_entry(rb_next_postorder(&pos->field), typeof(*pos), field))
+
 #endif	/* _LINUX_RBTREE_H */
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
