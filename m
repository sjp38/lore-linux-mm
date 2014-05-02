Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7386B0044
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:53:04 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id m20so1633023qcx.12
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:03 -0700 (PDT)
Received: from mail-qa0-x22e.google.com (mail-qa0-x22e.google.com [2607:f8b0:400d:c00::22e])
        by mx.google.com with ESMTPS id c43si14185480qge.49.2014.05.02.06.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:53:03 -0700 (PDT)
Received: by mail-qa0-f46.google.com with SMTP id w8so4344116qac.33
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:53:03 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 04/11] interval_tree: helper to find previous item of a node in rb interval tree
Date: Fri,  2 May 2014 09:52:03 -0400
Message-Id: <1399038730-25641-5-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

It is often usefull to find the entry right before a given one in an rb
interval tree.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/interval_tree_generic.h | 79 +++++++++++++++++++++++++++++++++++
 1 file changed, 79 insertions(+)

diff --git a/include/linux/interval_tree_generic.h b/include/linux/interval_tree_generic.h
index 58370e1..97dd71b 100644
--- a/include/linux/interval_tree_generic.h
+++ b/include/linux/interval_tree_generic.h
@@ -188,4 +188,83 @@ ITPREFIX ## _iter_next(ITSTRUCT *node, ITTYPE start, ITTYPE last)	      \
 		else if (start <= ITLAST(node))		/* Cond2 */	      \
 			return node;					      \
 	}								      \
+}									      \
+									      \
+static ITSTRUCT *							      \
+ITPREFIX ## _subtree_rmost(ITSTRUCT *node, ITTYPE start, ITTYPE last)	      \
+{									      \
+	while (true) {							      \
+		/*							      \
+		 * Loop invariant: last >= ITSTART(node)		      \
+		 * (Cond1 is satisfied)					      \
+		 */							      \
+		if (node->ITRB.rb_right) {				      \
+			ITSTRUCT *right = rb_entry(node->ITRB.rb_right,	      \
+						   ITSTRUCT, ITRB);	      \
+			if (last >= ITSTART(right)) {			      \
+				/*					      \
+				 * Some nodes in right subtree satisfy Cond1. \
+				 * Iterate to find the rightmost such node N. \
+				 * If it also satisfies Cond2, that's the     \
+				 * match we are looking for.		      \
+				 */					      \
+				node = right;				      \
+				continue;				      \
+			}						      \
+			/* Left branch might still have a candidate. */	      \
+			if (right->ITRB.rb_left) {			      \
+				right = rb_entry(right->ITRB.rb_left,	      \
+						 ITSTRUCT, ITRB);	      \
+				if (last >= ITSTART(right)) {		      \
+					node = right;			      \
+					continue;			      \
+				}					      \
+			}						      \
+		}							      \
+		/* At this point node is the rightmost candidate. */	      \
+		if (last >= ITSTART(node)) {		/* Cond1 */	      \
+			if (start <= ITLAST(node))	/* Cond2 */	      \
+				return node;	/* node is rightmost match */ \
+		}							      \
+		return NULL;	/* No match */				      \
+	}								      \
+}									      \
+									      \
+ITSTATIC ITSTRUCT *							      \
+ITPREFIX ## _iter_prev(ITSTRUCT *node, ITTYPE start, ITTYPE last)	      \
+{									      \
+	struct rb_node *rb = node->ITRB.rb_left, *prev;			      \
+									      \
+	while (true) {							      \
+		/*							      \
+		 * Loop invariants:					      \
+		 *   Cond2: start <= ITLAST(node)			      \
+		 *   rb == node->ITRB.rb_left				      \
+		 *							      \
+		 * First, search left subtree if suitable		      \
+		 */							      \
+		if (rb) {						      \
+			ITSTRUCT *left = rb_entry(rb, ITSTRUCT, ITRB);	      \
+			if (start <= left->ITSUBTREE)			      \
+				return ITPREFIX ## _subtree_rmost(left,       \
+								  start,      \
+								  last);      \
+		}							      \
+									      \
+		/* Move up the tree until we come from a node's right child */\
+		do {							      \
+			rb = rb_parent(&node->ITRB);			      \
+			if (!rb)					      \
+				return NULL;				      \
+			prev = &node->ITRB;				      \
+			node = rb_entry(rb, ITSTRUCT, ITRB);		      \
+			rb = node->ITRB.rb_left;			      \
+		} while (prev == rb);					      \
+									      \
+		/* Check if the node intersects [start;last] */		      \
+		if (start > ITLAST(node))		/* !Cond2 */	      \
+			return NULL;					      \
+		else if (ITSTART(node) <= last)		/* Cond1 */	      \
+			return node;					      \
+	}								      \
 }
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
