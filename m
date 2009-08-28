Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 928146B0085
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 12:00:39 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 28 Aug 2009 12:03:38 -0400
Message-Id: <20090828160338.11080.51282.sendpatchset@localhost.localdomain>
In-Reply-To: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/6] hugetlb:  introduce alloc_nodemask_of_node
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 4/6] - hugetlb:  introduce alloc_nodemask_of_node()

Against:  2.6.31-rc7-mmotm-090827-0057

New in V5 of series

Introduce nodemask macro to allocate a nodemask and 
initialize it to contain a single node, using the macro
init_nodemask_of_node() factored out of the nodemask_of_node()
macro.

alloc_nodemask_of_node() coded as a macro to avoid header
dependency hell.

This will be used to construct the huge pages "nodes_allowed"
nodemask for a single node when a persistent huge page
pool page count is modified via a per node sysfs attribute.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/nodemask.h |   20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

Index: linux-2.6.31-rc7-mmotm-090827-0057/include/linux/nodemask.h
===================================================================
--- linux-2.6.31-rc7-mmotm-090827-0057.orig/include/linux/nodemask.h	2009-08-28 09:21:19.000000000 -0400
+++ linux-2.6.31-rc7-mmotm-090827-0057/include/linux/nodemask.h	2009-08-28 09:21:29.000000000 -0400
@@ -245,18 +245,34 @@ static inline int __next_node(int n, con
 	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
 }
 
+#define init_nodemask_of_nodes(mask, node)				\
+	nodes_clear(*(mask));						\
+	node_set((node), *(mask));
+
 #define nodemask_of_node(node)						\
 ({									\
 	typeof(_unused_nodemask_arg_) m;				\
 	if (sizeof(m) == sizeof(unsigned long)) {			\
 		m.bits[0] = 1UL<<(node);				\
 	} else {							\
-		nodes_clear(m);						\
-		node_set((node), m);					\
+		init_nodemask_of_nodes(&m, (node));			\
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
+		init_nodemask_of_nodes(nmp, (node));			\
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
