Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F330860021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 18:16:03 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id n92MGEJY017618
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 23:16:14 +0100
Received: from pxi37 (pxi37.prod.google.com [10.243.27.37])
	by wpaz33.hot.corp.google.com with ESMTP id n92MG2b0025486
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 15:16:11 -0700
Received: by pxi37 with SMTP id 37so1470691pxi.15
        for <linux-mm@kvack.org>; Fri, 02 Oct 2009 15:16:11 -0700 (PDT)
Date: Fri, 2 Oct 2009 15:16:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] nodemask: make NODEMASK_ALLOC more general
In-Reply-To: <20091001165832.32248.32725.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910021511030.18180@chino.kir.corp.google.com>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain> <20091001165832.32248.32725.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

NODEMASK_ALLOC(x, m) assumes x is a type of struct, which is unnecessary.
It's perfectly reasonable to use this macro to allocate a nodemask_t,
which is anonymous, either dynamically or on the stack depending on
NODES_SHIFT.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/nodemask.h |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -486,14 +486,14 @@ static inline int num_node_state(enum node_states state)
 
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
@@ -502,8 +502,9 @@ struct nodemask_scratch {
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
