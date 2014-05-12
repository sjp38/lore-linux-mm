Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id BF0C06B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:39:05 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id 29so6634906yhl.9
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:39:05 -0700 (PDT)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id t6si16705695yha.3.2014.05.12.09.39.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 May 2014 09:39:05 -0700 (PDT)
Received: by mail-yk0-f170.google.com with SMTP id 10so6091220ykt.15
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:39:05 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCHv2 3/4] plist: add plist_requeue
Date: Mon, 12 May 2014 12:38:19 -0400
Message-Id: <1399912700-30100-4-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1399912700-30100-1-git-send-email-ddstreet@ieee.org>
References: <1399057350-16300-1-git-send-email-ddstreet@ieee.org>
 <1399912700-30100-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Dan Streetman <ddstreet@ieee.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Weijie Yang <weijieut@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Thomas Gleixner <tglx@linutronix.de>

Add plist_requeue(), which moves the specified plist_node after
all other same-priority plist_nodes in the list.  This is
essentially an optimized plist_del() followed by plist_add().

This is needed by swap, which (with the next patch in this set)
uses a plist of available swap devices.  When a swap device
(either a swap partition or swap file) are added to the system
with swapon(), the device is added to a plist, ordered by
the swap device's priority.  When swap needs to allocate a page
from one of the swap devices, it takes the page from the first swap
device on the plist, which is the highest priority swap device.
The swap device is left in the plist until all its pages are
used, and then removed from the plist when it becomes full.

However, as described in man 2 swapon, swap must allocate pages
from swap devices with the same priority in round-robin order;
to do this, on each swap page allocation, swap uses a page from
the first swap device in the plist, and then calls plist_requeue()
to move that swap device entry to after any other same-priority
swap devices.  The next swap page allocation will again use a
page from the first swap device in the plist and requeue it,
and so on, resulting in round-robin usage of equal-priority
swap devices.

Also add plist_test_requeue() test function, for use by plist_test()
to test plist_requeue() function.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Thomas Gleixner <tglx@linutronix.de>

---

Changes since v1 https://lkml.org/lkml/2014/5/2/494
 -rename plist_rotate() to plist_requeue()
 -change plist_requeue() local var naming to match plist_add() naming
 -update/expand commit log to better explain why swap needs it

 include/linux/plist.h |  2 ++
 lib/plist.c           | 52 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/include/linux/plist.h b/include/linux/plist.h
index c815491..8b6c970 100644
--- a/include/linux/plist.h
+++ b/include/linux/plist.h
@@ -141,6 +141,8 @@ static inline void plist_node_init(struct plist_node *node, int prio)
 extern void plist_add(struct plist_node *node, struct plist_head *head);
 extern void plist_del(struct plist_node *node, struct plist_head *head);
 
+extern void plist_requeue(struct plist_node *node, struct plist_head *head);
+
 /**
  * plist_for_each - iterate over the plist
  * @pos:	the type * to use as a loop counter
diff --git a/lib/plist.c b/lib/plist.c
index b883a7a..d408e77 100644
--- a/lib/plist.c
+++ b/lib/plist.c
@@ -134,6 +134,46 @@ void plist_del(struct plist_node *node, struct plist_head *head)
 	plist_check_head(head);
 }
 
+/**
+ * plist_requeue - Requeue @node at end of same-prio entries.
+ *
+ * This is essentially an optimized plist_del() followed by
+ * plist_add().  It moves an entry already in the plist to
+ * after any other same-priority entries.
+ *
+ * @node:	&struct plist_node pointer - entry to be moved
+ * @head:	&struct plist_head pointer - list head
+ */
+void plist_requeue(struct plist_node *node, struct plist_head *head)
+{
+	struct plist_node *iter;
+	struct list_head *node_next = &head->node_list;
+
+	plist_check_head(head);
+	BUG_ON(plist_head_empty(head));
+	BUG_ON(plist_node_empty(node));
+
+	if (node == plist_last(head))
+		return;
+
+	iter = plist_next(node);
+
+	if (node->prio != iter->prio)
+		return;
+
+	plist_del(node, head);
+
+	plist_for_each_continue(iter, head) {
+		if (node->prio != iter->prio) {
+			node_next = &iter->node_list;
+			break;
+		}
+	}
+	list_add_tail(&node->node_list, node_next);
+
+	plist_check_head(head);
+}
+
 #ifdef CONFIG_DEBUG_PI_LIST
 #include <linux/sched.h>
 #include <linux/module.h>
@@ -170,6 +210,14 @@ static void __init plist_test_check(int nr_expect)
 	BUG_ON(prio_pos->prio_list.next != &first->prio_list);
 }
 
+static void __init plist_test_requeue(struct plist_node *node)
+{
+	plist_requeue(node, &test_head);
+
+	if (node != plist_last(&test_head))
+		BUG_ON(node->prio == plist_next(node)->prio);
+}
+
 static int  __init plist_test(void)
 {
 	int nr_expect = 0, i, loop;
@@ -193,6 +241,10 @@ static int  __init plist_test(void)
 			nr_expect--;
 		}
 		plist_test_check(nr_expect);
+		if (!plist_node_empty(test_node + i)) {
+			plist_test_requeue(test_node + i);
+			plist_test_check(nr_expect);
+		}
 	}
 
 	for (i = 0; i < ARRAY_SIZE(test_node); i++) {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
