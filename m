Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1E56B0082
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:41:10 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 15 Sep 2009 16:44:31 -0400
Message-Id: <20090915204431.4828.82976.sendpatchset@localhost.localdomain>
In-Reply-To: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
References: <20090915204327.4828.4349.sendpatchset@localhost.localdomain>
Subject: [PATCH 3/11] hugetlb:  introduce alloc_nodemask_of_node
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 3/11] - hugetlb:  introduce alloc_nodemask_of_node()

Against:  2.6.31-mmotm-090914-0157

New in V5 of series

V6: + rename 'init_nodemask_of_nodes()' to 'init_nodemask_of_node()'
    + redefine init_nodemask_of_node() as static inline fcn
    + move this patch back 1 in series

Introduce nodemask macro to allocate a nodemask and 
initialize it to contain a single node, using the macro
init_nodemask_of_node() factored out of the nodemask_of_node()
macro.

alloc_nodemask_of_node() coded as a macro to avoid header
dependency hell.

This will be used to construct the huge pages "nodes_allowed"
nodemask for a single node when basing nodes_allowed on a
preferred/local mempolicy or when a persistent huge page
pool page count is modified via a per node sysfs attribute.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/nodemask.h |   22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

Index: linux-2.6.31-mmotm-090914-0157/include/linux/nodemask.h
===================================================================
--- linux-2.6.31-mmotm-090914-0157.orig/include/linux/nodemask.h	2009-09-15 13:38:32.000000000 -0400
+++ linux-2.6.31-mmotm-090914-0157/include/linux/nodemask.h	2009-09-15 13:42:18.000000000 -0400
@@ -245,18 +245,36 @@ static inline int __next_node(int n, con
 	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
 }
 
+static inline void init_nodemask_of_node(nodemask_t *mask, int node)
+{
+	nodes_clear(*(mask));
+	node_set((node), *(mask));
+}
+
 #define nodemask_of_node(node)						\
 ({									\
 	typeof(_unused_nodemask_arg_) m;				\
 	if (sizeof(m) == sizeof(unsigned long)) {			\
 		m.bits[0] = 1UL<<(node);				\
 	} else {							\
-		nodes_clear(m);						\
-		node_set((node), m);					\
+		init_nodemask_of_node(&m, (node));			\
 	}								\
 	m;								\
 })
 
+/*
+ * returns pointer to kmalloc()'d nodemask initialized to contain the
+ * specified node.  Caller must free with kfree().
+ */
+#define alloc_nodemask_of_node(node)					\
+({									\
+	typeof(_unused_nodemask_arg_) *nmp;				\
+	nmp = kmalloc(sizeof(*nmp), GFP_KERNEL);			\
+	if (nmp)							\
+		init_nodemask_of_node(nmp, (node));			\
+	nmp;								\
+})
+
 #define first_unset_node(mask) __first_unset_node(&(mask))
 static inline int __first_unset_node(const nodemask_t *maskp)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
