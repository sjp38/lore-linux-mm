Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C04C26B0055
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 12:20:59 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 08 Oct 2009 12:25:01 -0400
Message-Id: <20091008162501.23192.66287.sendpatchset@localhost.localdomain>
In-Reply-To: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain>
Subject: [PATCH 1/12] nodemask:  make NODEMASK_ALLOC more general
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

From: David Rientjes <rientjes@google.com>

[PATCH 1/12] nodemask:  make NODEMASK_ALLOC more general

NODEMASK_ALLOC(x, m) assumes x is a type of struct, which is unnecessary.
It's perfectly reasonable to use this macro to allocate a nodemask_t,
which is anonymous, either dynamically or on the stack depending on
NODES_SHIFT.

---

Against:  2.6.31-mmotm-090925-1435

New in V10

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>

 include/linux/nodemask.h |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

Index: linux-2.6.31-mmotm-090925-1435/include/linux/nodemask.h
===================================================================
--- linux-2.6.31-mmotm-090925-1435.orig/include/linux/nodemask.h	2009-10-07 12:31:51.000000000 -0400
+++ linux-2.6.31-mmotm-090925-1435/include/linux/nodemask.h	2009-10-07 12:31:53.000000000 -0400
@@ -481,14 +481,14 @@ static inline int num_node_state(enum no
 
 /*
  * For nodemask scrach area.(See CPUMASK_ALLOC() in cpumask.h)
+ * NODEMASK_ALLOC(x, m) allocates an object of type 'x' with the name 'm'.
  */
-
 #if NODES_SHIFT > 8 /* nodemask_t > 64 bytes */
-#define NODEMASK_ALLOC(x, m) struct x *m = kmalloc(sizeof(*m), GFP_KERNEL)
-#define NODEMASK_FREE(m) kfree(m)
+#define NODEMASK_ALLOC(x, m)		x *m = kmalloc(sizeof(*m), GFP_KERNEL)
+#define NODEMASK_FREE(m)		kfree(m)
 #else
-#define NODEMASK_ALLOC(x, m) struct x _m, *m = &_m
-#define NODEMASK_FREE(m)
+#define NODEMASK_ALLOC(x, m)		x _m, *m = &_m
+#define NODEMASK_FREE(m)		do {} while (0)
 #endif
 
 /* A example struture for using NODEMASK_ALLOC, used in mempolicy. */
@@ -497,8 +497,9 @@ struct nodemask_scratch {
 	nodemask_t	mask2;
 };
 
-#define NODEMASK_SCRATCH(x) NODEMASK_ALLOC(nodemask_scratch, x)
-#define NODEMASK_SCRATCH_FREE(x)  NODEMASK_FREE(x)
+#define NODEMASK_SCRATCH(x)	\
+		NODEMASK_ALLOC(struct nodemask_scratch, x)
+#define NODEMASK_SCRATCH_FREE(x)	NODEMASK_FREE(x)
 
 
 #endif /* __LINUX_NODEMASK_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
