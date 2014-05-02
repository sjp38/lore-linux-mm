Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id B665D6B0038
	for <linux-mm@kvack.org>; Fri,  2 May 2014 15:04:07 -0400 (EDT)
Received: by mail-yh0-f41.google.com with SMTP id i57so4588886yha.0
        for <linux-mm@kvack.org>; Fri, 02 May 2014 12:04:07 -0700 (PDT)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id i62si35690044yhg.200.2014.05.02.12.04.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 12:04:07 -0700 (PDT)
Received: by mail-yk0-f169.google.com with SMTP id 200so479414ykr.28
        for <linux-mm@kvack.org>; Fri, 02 May 2014 12:04:07 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 2/4] plist: add helper functions
Date: Fri,  2 May 2014 15:02:28 -0400
Message-Id: <1399057350-16300-3-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1399057350-16300-1-git-send-email-ddstreet@ieee.org>
References: <1397336454-13855-1-git-send-email-ddstreet@ieee.org>
 <1399057350-16300-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Dan Streetman <ddstreet@ieee.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijieut@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>

Add PLIST_HEAD() to plist.h, equivalent to LIST_HEAD() from list.h, to
define and initialize a struct plist_head.

Add plist_for_each_continue() and plist_for_each_entry_continue(),
equivalent to list_for_each_continue() and list_for_each_entry_continue(),
to iterate over a plist continuing after the current position.

Add plist_prev() and plist_next(), equivalent to (struct list_head*)->prev
and ->next, implemented by list_prev_entry() and list_next_entry(), to
access the prev/next struct plist_node entry.  These are needed because
unlike struct list_head, direct access of the prev/next struct plist_node
isn't possible; the list must be navigated via the contained struct list_head.
e.g. instead of accessing the prev by list_prev_entry(node, node_list)
it can be accessed by plist_prev(node).

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Thomas Gleixner <tglx@linutronix.de>

---

This is new to this patch set, and these helper functions are used
by the following 2 patches.  They aren't critical, as their functionality
can be achieved using regular list functions, but they help simplify
code that uses them.

 include/linux/plist.h | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/include/linux/plist.h b/include/linux/plist.h
index aa0fb39..c815491 100644
--- a/include/linux/plist.h
+++ b/include/linux/plist.h
@@ -98,6 +98,13 @@ struct plist_node {
 }
 
 /**
+ * PLIST_HEAD - declare and init plist_head
+ * @head:	name for struct plist_head variable
+ */
+#define PLIST_HEAD(head) \
+	struct plist_head head = PLIST_HEAD_INIT(head)
+
+/**
  * PLIST_NODE_INIT - static struct plist_node initializer
  * @node:	struct plist_node variable name
  * @__prio:	initial node priority
@@ -143,6 +150,16 @@ extern void plist_del(struct plist_node *node, struct plist_head *head);
 	 list_for_each_entry(pos, &(head)->node_list, node_list)
 
 /**
+ * plist_for_each_continue - continue iteration over the plist
+ * @pos:	the type * to use as a loop cursor
+ * @head:	the head for your list
+ *
+ * Continue to iterate over plist, continuing after the current position.
+ */
+#define plist_for_each_continue(pos, head)	\
+	 list_for_each_entry_continue(pos, &(head)->node_list, node_list)
+
+/**
  * plist_for_each_safe - iterate safely over a plist of given type
  * @pos:	the type * to use as a loop counter
  * @n:	another type * to use as temporary storage
@@ -163,6 +180,18 @@ extern void plist_del(struct plist_node *node, struct plist_head *head);
 	 list_for_each_entry(pos, &(head)->node_list, mem.node_list)
 
 /**
+ * plist_for_each_entry_continue - continue iteration over list of given type
+ * @pos:	the type * to use as a loop cursor
+ * @head:	the head for your list
+ * @m:		the name of the list_struct within the struct
+ *
+ * Continue to iterate over list of given type, continuing after
+ * the current position.
+ */
+#define plist_for_each_entry_continue(pos, head, m)	\
+	list_for_each_entry_continue(pos, &(head)->node_list, m.node_list)
+
+/**
  * plist_for_each_entry_safe - iterate safely over list of given type
  * @pos:	the type * to use as a loop counter
  * @n:		another type * to use as temporary storage
@@ -229,6 +258,20 @@ static inline int plist_node_empty(const struct plist_node *node)
 #endif
 
 /**
+ * plist_next - get the next entry in list
+ * @pos:	the type * to cursor
+ */
+#define plist_next(pos) \
+	list_next_entry(pos, node_list)
+
+/**
+ * plist_prev - get the prev entry in list
+ * @pos:	the type * to cursor
+ */
+#define plist_prev(pos) \
+	list_prev_entry(pos, node_list)
+
+/**
  * plist_first - return the first node (and thus, highest priority)
  * @head:	the &struct plist_head pointer
  *
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
