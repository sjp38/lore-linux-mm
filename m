Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 1F2396B0062
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 19:26:43 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so317822pbb.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2012 16:26:42 -0700 (PDT)
Date: Fri, 7 Sep 2012 16:26:38 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 1/7] mm: interval tree updates
Message-ID: <20120907232638.GA7991@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
 <1346750457-12385-2-git-send-email-walken@google.com>
 <20120907151341.79cb5638.akpm@linux-foundation.org>
 <CANN689HMxteeUT9q5BgKutEnNQF6sKv2n9ze11Z=wkOoC+XGqw@mail.gmail.com>
 <20120907155514.3fad7887.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120907155514.3fad7887.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org

On Fri, Sep 07, 2012 at 03:55:14PM -0700, Andrew Morton wrote:
> On Fri, 7 Sep 2012 15:29:36 -0700
> Michel Lespinasse <walken@google.com> wrote:
> 
> > > Ho hum.  I don't think I can be bothered untangling all this.
> > 
> > I don't think you should have to do it yourself either.
> 
> Patch wrangling is what I do ;)
> 
> > But, if you're willing to take it, I can send you replacement patches for
> > (mm-replace-vma-prio_tree-with-an-interval-tree.patch +
> > mm-interval-tree-updates.patch) collapsed into one, and
> > rbtree-move-augmented-rbtree-functionality-to-rbtree_augmentedh.patch
> > fixed so that it'd apply after the collapsed patch (and get to the
> > same end state).
> 
> Yes please, I suppose we should do this.

Here is the replacement for
+ rbtree-move-augmented-rbtree-functionality-to-rbtree_augmentedh.patch

(I also copied the signed-offs and ccs from the original change)

-----------------------------8<-------------------------------------
From: Michel Lespinasse <walken@google.com>
Subject: rbtree: move augmented rbtree functionality to rbtree_augmented.h

Provide rb_insert_augmented() and rb_erase_augmented through
a new rbtree_augmented.h include file. rb_erase_augmented() is defined
there as an __always_inline function, in order to allow inlining of
augmented rbtree callbacks into it. Since this generates a relatively
large function, each augmented rbtree users should make sure to
have a single call site.

Signed-off-by: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Hillf Danton <dhillf@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/rbtree.txt              |   13 ++
 arch/x86/mm/pat_rbtree.c              |    2 +-
 include/linux/interval_tree_generic.h |    2 +
 include/linux/rbtree.h                |   48 -------
 include/linux/rbtree_augmented.h      |  223 +++++++++++++++++++++++++++++++++
 lib/rbtree.c                          |  162 ++----------------------
 lib/rbtree_test.c                     |    2 +-
 7 files changed, 251 insertions(+), 201 deletions(-)
 create mode 100644 include/linux/rbtree_augmented.h

diff --git a/Documentation/rbtree.txt b/Documentation/rbtree.txt
index 0a0b6dce3e08..61b6c48871a0 100644
--- a/Documentation/rbtree.txt
+++ b/Documentation/rbtree.txt
@@ -202,6 +202,14 @@ An rbtree user who wants this feature will have to call the augmentation
 functions with the user provided augmentation callback when inserting
 and erasing nodes.
 
+C files implementing augmented rbtree manipulation must include
+<linux/rbtree_augmented.h> instead of <linus/rbtree.h>. Note that
+linux/rbtree_augmented.h exposes some rbtree implementations details
+you are not expected to rely on; please stick to the documented APIs
+there and do not include <linux/rbtree_augmented.h> from header files
+either so as to minimize chances of your users accidentally relying on
+such implementation details.
+
 On insertion, the user must update the augmented information on the path
 leading to the inserted node, then call rb_link_node() as usual and
 rb_augment_inserted() instead of the usual rb_insert_color() call.
@@ -227,6 +235,11 @@ In both cases, the callbacks are provided through struct rb_augment_callbacks.
   subtree to a newly assigned subtree root AND recomputes the augmented
   information for the former subtree root.
 
+The compiled code for rb_erase_augmented() may inline the propagation and
+copy callbacks, which results in a large function, so each augmented rbtree
+user should have a single rb_erase_augmented() call site in order to limit
+compiled code size.
+
 
 Sample usage:
 
diff --git a/arch/x86/mm/pat_rbtree.c b/arch/x86/mm/pat_rbtree.c
index 4d116959075d..415f6c4ced36 100644
--- a/arch/x86/mm/pat_rbtree.c
+++ b/arch/x86/mm/pat_rbtree.c
@@ -12,7 +12,7 @@
 #include <linux/debugfs.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/rbtree.h>
+#include <linux/rbtree_augmented.h>
 #include <linux/sched.h>
 #include <linux/gfp.h>
 
diff --git a/include/linux/interval_tree_generic.h b/include/linux/interval_tree_generic.h
index 46232114dde0..58370e1862ad 100644
--- a/include/linux/interval_tree_generic.h
+++ b/include/linux/interval_tree_generic.h
@@ -19,6 +19,8 @@
   include/linux/interval_tree_generic.h
 */
 
+#include <linux/rbtree_augmented.h>
+
 /*
  * Template for implementing interval trees
  *
diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 8d1e83b1c87b..0022c1bb1e26 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -62,54 +62,6 @@ extern void rb_insert_color(struct rb_node *, struct rb_root *);
 extern void rb_erase(struct rb_node *, struct rb_root *);
 
 
-struct rb_augment_callbacks {
-	void (*propagate)(struct rb_node *node, struct rb_node *stop);
-	void (*copy)(struct rb_node *old, struct rb_node *new);
-	void (*rotate)(struct rb_node *old, struct rb_node *new);
-};
-
-extern void __rb_insert_augmented(struct rb_node *node, struct rb_root *root,
-	void (*augment_rotate)(struct rb_node *old, struct rb_node *new));
-extern void rb_erase_augmented(struct rb_node *node, struct rb_root *root,
-			       const struct rb_augment_callbacks *augment);
-static inline void
-rb_insert_augmented(struct rb_node *node, struct rb_root *root,
-		    const struct rb_augment_callbacks *augment)
-{
-	__rb_insert_augmented(node, root, augment->rotate);
-}
-
-#define RB_DECLARE_CALLBACKS(rbstatic, rbname, rbstruct, rbfield,	      \
-			     rbtype, rbaugmented, rbcompute)		      \
-static void rbname ## _propagate(struct rb_node *rb, struct rb_node *stop)    \
-{									      \
-	while (rb != stop) {						      \
-		rbstruct *node = rb_entry(rb, rbstruct, rbfield);	      \
-		rbtype augmented = rbcompute(node);			      \
-		if (node->rbaugmented == augmented)			      \
-			break;						      \
-		node->rbaugmented = augmented;				      \
-		rb = rb_parent(&node->rbfield);				      \
-	}								      \
-}									      \
-static void rbname ## _copy(struct rb_node *rb_old, struct rb_node *rb_new)   \
-{									      \
-	rbstruct *old = rb_entry(rb_old, rbstruct, rbfield);		      \
-	rbstruct *new = rb_entry(rb_new, rbstruct, rbfield);		      \
-	new->rbaugmented = old->rbaugmented;				      \
-}									      \
-static void rbname ## _rotate(struct rb_node *rb_old, struct rb_node *rb_new) \
-{									      \
-	rbstruct *old = rb_entry(rb_old, rbstruct, rbfield);		      \
-	rbstruct *new = rb_entry(rb_new, rbstruct, rbfield);		      \
-	new->rbaugmented = old->rbaugmented;				      \
-	old->rbaugmented = rbcompute(old);				      \
-}									      \
-rbstatic const struct rb_augment_callbacks rbname = {			      \
-	rbname ## _propagate, rbname ## _copy, rbname ## _rotate	      \
-};
-
-
 /* Find logical next and previous nodes in a tree */
 extern struct rb_node *rb_next(const struct rb_node *);
 extern struct rb_node *rb_prev(const struct rb_node *);
diff --git a/include/linux/rbtree_augmented.h b/include/linux/rbtree_augmented.h
new file mode 100644
index 000000000000..214caa33433b
--- /dev/null
+++ b/include/linux/rbtree_augmented.h
@@ -0,0 +1,223 @@
+/*
+  Red Black Trees
+  (C) 1999  Andrea Arcangeli <andrea@suse.de>
+  (C) 2002  David Woodhouse <dwmw2@infradead.org>
+  (C) 2012  Michel Lespinasse <walken@google.com>
+
+  This program is free software; you can redistribute it and/or modify
+  it under the terms of the GNU General Public License as published by
+  the Free Software Foundation; either version 2 of the License, or
+  (at your option) any later version.
+
+  This program is distributed in the hope that it will be useful,
+  but WITHOUT ANY WARRANTY; without even the implied warranty of
+  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+  GNU General Public License for more details.
+
+  You should have received a copy of the GNU General Public License
+  along with this program; if not, write to the Free Software
+  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+  linux/include/linux/rbtree_augmented.h
+*/
+
+#ifndef _LINUX_RBTREE_AUGMENTED_H
+#define _LINUX_RBTREE_AUGMENTED_H
+
+#include <linux/rbtree.h>
+
+/*
+ * Please note - only struct rb_augment_callbacks and the prototypes for
+ * rb_insert_augmented() and rb_erase_augmented() are intended to be public.
+ * The rest are implementation details you are not expected to depend on.
+ *
+ * See Documentation/rbtree.txt for documentation and samples.
+ */
+
+struct rb_augment_callbacks {
+	void (*propagate)(struct rb_node *node, struct rb_node *stop);
+	void (*copy)(struct rb_node *old, struct rb_node *new);
+	void (*rotate)(struct rb_node *old, struct rb_node *new);
+};
+
+extern void __rb_insert_augmented(struct rb_node *node, struct rb_root *root,
+	void (*augment_rotate)(struct rb_node *old, struct rb_node *new));
+static inline void
+rb_insert_augmented(struct rb_node *node, struct rb_root *root,
+		    const struct rb_augment_callbacks *augment)
+{
+	__rb_insert_augmented(node, root, augment->rotate);
+}
+
+#define RB_DECLARE_CALLBACKS(rbstatic, rbname, rbstruct, rbfield,	\
+			     rbtype, rbaugmented, rbcompute)		\
+static inline void							\
+rbname ## _propagate(struct rb_node *rb, struct rb_node *stop)		\
+{									\
+	while (rb != stop) {						\
+		rbstruct *node = rb_entry(rb, rbstruct, rbfield);	\
+		rbtype augmented = rbcompute(node);			\
+		if (node->rbaugmented == augmented)			\
+			break;						\
+		node->rbaugmented = augmented;				\
+		rb = rb_parent(&node->rbfield);				\
+	}								\
+}									\
+static inline void							\
+rbname ## _copy(struct rb_node *rb_old, struct rb_node *rb_new)		\
+{									\
+	rbstruct *old = rb_entry(rb_old, rbstruct, rbfield);		\
+	rbstruct *new = rb_entry(rb_new, rbstruct, rbfield);		\
+	new->rbaugmented = old->rbaugmented;				\
+}									\
+static void								\
+rbname ## _rotate(struct rb_node *rb_old, struct rb_node *rb_new)	\
+{									\
+	rbstruct *old = rb_entry(rb_old, rbstruct, rbfield);		\
+	rbstruct *new = rb_entry(rb_new, rbstruct, rbfield);		\
+	new->rbaugmented = old->rbaugmented;				\
+	old->rbaugmented = rbcompute(old);				\
+}									\
+rbstatic const struct rb_augment_callbacks rbname = {			\
+	rbname ## _propagate, rbname ## _copy, rbname ## _rotate	\
+};
+
+
+#define	RB_RED		0
+#define	RB_BLACK	1
+
+#define __rb_parent(pc)    ((struct rb_node *)(pc & ~3))
+
+#define __rb_color(pc)     ((pc) & 1)
+#define __rb_is_black(pc)  __rb_color(pc)
+#define __rb_is_red(pc)    (!__rb_color(pc))
+#define rb_color(rb)       __rb_color((rb)->__rb_parent_color)
+#define rb_is_red(rb)      __rb_is_red((rb)->__rb_parent_color)
+#define rb_is_black(rb)    __rb_is_black((rb)->__rb_parent_color)
+
+static inline void rb_set_parent(struct rb_node *rb, struct rb_node *p)
+{
+	rb->__rb_parent_color = rb_color(rb) | (unsigned long)p;
+}
+
+static inline void rb_set_parent_color(struct rb_node *rb,
+				       struct rb_node *p, int color)
+{
+	rb->__rb_parent_color = (unsigned long)p | color;
+}
+
+static inline void
+__rb_change_child(struct rb_node *old, struct rb_node *new,
+		  struct rb_node *parent, struct rb_root *root)
+{
+	if (parent) {
+		if (parent->rb_left == old)
+			parent->rb_left = new;
+		else
+			parent->rb_right = new;
+	} else
+		root->rb_node = new;
+}
+
+extern void __rb_erase_color(struct rb_node *parent, struct rb_root *root,
+	void (*augment_rotate)(struct rb_node *old, struct rb_node *new));
+
+static __always_inline void
+rb_erase_augmented(struct rb_node *node, struct rb_root *root,
+		   const struct rb_augment_callbacks *augment)
+{
+	struct rb_node *child = node->rb_right, *tmp = node->rb_left;
+	struct rb_node *parent, *rebalance;
+	unsigned long pc;
+
+	if (!tmp) {
+		/*
+		 * Case 1: node to erase has no more than 1 child (easy!)
+		 *
+		 * Note that if there is one child it must be red due to 5)
+		 * and node must be black due to 4). We adjust colors locally
+		 * so as to bypass __rb_erase_color() later on.
+		 */
+		pc = node->__rb_parent_color;
+		parent = __rb_parent(pc);
+		__rb_change_child(node, child, parent, root);
+		if (child) {
+			child->__rb_parent_color = pc;
+			rebalance = NULL;
+		} else
+			rebalance = __rb_is_black(pc) ? parent : NULL;
+		tmp = parent;
+	} else if (!child) {
+		/* Still case 1, but this time the child is node->rb_left */
+		tmp->__rb_parent_color = pc = node->__rb_parent_color;
+		parent = __rb_parent(pc);
+		__rb_change_child(node, tmp, parent, root);
+		rebalance = NULL;
+		tmp = parent;
+	} else {
+		struct rb_node *successor = child, *child2;
+		tmp = child->rb_left;
+		if (!tmp) {
+			/*
+			 * Case 2: node's successor is its right child
+			 *
+			 *    (n)          (s)
+			 *    / \          / \
+			 *  (x) (s)  ->  (x) (c)
+			 *        \
+			 *        (c)
+			 */
+			parent = successor;
+			child2 = successor->rb_right;
+			augment->copy(node, successor);
+		} else {
+			/*
+			 * Case 3: node's successor is leftmost under
+			 * node's right child subtree
+			 *
+			 *    (n)          (s)
+			 *    / \          / \
+			 *  (x) (y)  ->  (x) (y)
+			 *      /            /
+			 *    (p)          (p)
+			 *    /            /
+			 *  (s)          (c)
+			 *    \
+			 *    (c)
+			 */
+			do {
+				parent = successor;
+				successor = tmp;
+				tmp = tmp->rb_left;
+			} while (tmp);
+			parent->rb_left = child2 = successor->rb_right;
+			successor->rb_right = child;
+			rb_set_parent(child, successor);
+			augment->copy(node, successor);
+			augment->propagate(parent, successor);
+		}
+
+		successor->rb_left = tmp = node->rb_left;
+		rb_set_parent(tmp, successor);
+
+		pc = node->__rb_parent_color;
+		tmp = __rb_parent(pc);
+		__rb_change_child(node, successor, tmp, root);
+		if (child2) {
+			successor->__rb_parent_color = pc;
+			rb_set_parent_color(child2, parent, RB_BLACK);
+			rebalance = NULL;
+		} else {
+			unsigned long pc2 = successor->__rb_parent_color;
+			successor->__rb_parent_color = pc;
+			rebalance = __rb_is_black(pc2) ? parent : NULL;
+		}
+		tmp = successor;
+	}
+
+	augment->propagate(tmp, NULL);
+	if (rebalance)
+		__rb_erase_color(rebalance, root, augment->rotate);
+}
+
+#endif	/* _LINUX_RBTREE_AUGMENTED_H */
diff --git a/lib/rbtree.c b/lib/rbtree.c
index c0088ca345f9..4f56a11d67fa 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -21,7 +21,7 @@
   linux/lib/rbtree.c
 */
 
-#include <linux/rbtree.h>
+#include <linux/rbtree_augmented.h>
 #include <linux/export.h>
 
 /*
@@ -44,52 +44,16 @@
  *  parentheses and have some accompanying text comment.
  */
 
-#define	RB_RED		0
-#define	RB_BLACK	1
-
-#define __rb_parent(pc)    ((struct rb_node *)(pc & ~3))
-
-#define __rb_color(pc)     ((pc) & 1)
-#define __rb_is_black(pc)  __rb_color(pc)
-#define __rb_is_red(pc)    (!__rb_color(pc))
-#define rb_color(rb)       __rb_color((rb)->__rb_parent_color)
-#define rb_is_red(rb)      __rb_is_red((rb)->__rb_parent_color)
-#define rb_is_black(rb)    __rb_is_black((rb)->__rb_parent_color)
-
 static inline void rb_set_black(struct rb_node *rb)
 {
 	rb->__rb_parent_color |= RB_BLACK;
 }
 
-static inline void rb_set_parent(struct rb_node *rb, struct rb_node *p)
-{
-	rb->__rb_parent_color = rb_color(rb) | (unsigned long)p;
-}
-
-static inline void rb_set_parent_color(struct rb_node *rb,
-				       struct rb_node *p, int color)
-{
-	rb->__rb_parent_color = (unsigned long)p | color;
-}
-
 static inline struct rb_node *rb_red_parent(struct rb_node *red)
 {
 	return (struct rb_node *)red->__rb_parent_color;
 }
 
-static inline void
-__rb_change_child(struct rb_node *old, struct rb_node *new,
-		  struct rb_node *parent, struct rb_root *root)
-{
-	if (parent) {
-		if (parent->rb_left == old)
-			parent->rb_left = new;
-		else
-			parent->rb_right = new;
-	} else
-		root->rb_node = new;
-}
-
 /*
  * Helper function for rotations:
  * - old's parent and color get assigned to new
@@ -230,9 +194,9 @@ __rb_insert(struct rb_node *node, struct rb_root *root,
 	}
 }
 
-static __always_inline void
+__always_inline void
 __rb_erase_color(struct rb_node *parent, struct rb_root *root,
-		 const struct rb_augment_callbacks *augment)
+	void (*augment_rotate)(struct rb_node *old, struct rb_node *new))
 {
 	struct rb_node *node = NULL, *sibling, *tmp1, *tmp2;
 
@@ -261,7 +225,7 @@ __rb_erase_color(struct rb_node *parent, struct rb_root *root,
 				rb_set_parent_color(tmp1, parent, RB_BLACK);
 				__rb_rotate_set_parents(parent, sibling, root,
 							RB_RED);
-				augment->rotate(parent, sibling);
+				augment_rotate(parent, sibling);
 				sibling = tmp1;
 			}
 			tmp1 = sibling->rb_right;
@@ -313,7 +277,7 @@ __rb_erase_color(struct rb_node *parent, struct rb_root *root,
 				if (tmp1)
 					rb_set_parent_color(tmp1, sibling,
 							    RB_BLACK);
-				augment->rotate(sibling, tmp2);
+				augment_rotate(sibling, tmp2);
 				tmp1 = sibling;
 				sibling = tmp2;
 			}
@@ -336,7 +300,7 @@ __rb_erase_color(struct rb_node *parent, struct rb_root *root,
 				rb_set_parent(tmp2, parent);
 			__rb_rotate_set_parents(parent, sibling, root,
 						RB_BLACK);
-			augment->rotate(parent, sibling);
+			augment_rotate(parent, sibling);
 			break;
 		} else {
 			sibling = parent->rb_left;
@@ -347,7 +311,7 @@ __rb_erase_color(struct rb_node *parent, struct rb_root *root,
 				rb_set_parent_color(tmp1, parent, RB_BLACK);
 				__rb_rotate_set_parents(parent, sibling, root,
 							RB_RED);
-				augment->rotate(parent, sibling);
+				augment_rotate(parent, sibling);
 				sibling = tmp1;
 			}
 			tmp1 = sibling->rb_left;
@@ -374,7 +338,7 @@ __rb_erase_color(struct rb_node *parent, struct rb_root *root,
 				if (tmp1)
 					rb_set_parent_color(tmp1, sibling,
 							    RB_BLACK);
-				augment->rotate(sibling, tmp2);
+				augment_rotate(sibling, tmp2);
 				tmp1 = sibling;
 				sibling = tmp2;
 			}
@@ -386,109 +350,12 @@ __rb_erase_color(struct rb_node *parent, struct rb_root *root,
 				rb_set_parent(tmp2, parent);
 			__rb_rotate_set_parents(parent, sibling, root,
 						RB_BLACK);
-			augment->rotate(parent, sibling);
+			augment_rotate(parent, sibling);
 			break;
 		}
 	}
 }
-
-static __always_inline void
-__rb_erase(struct rb_node *node, struct rb_root *root,
-	   const struct rb_augment_callbacks *augment)
-{
-	struct rb_node *child = node->rb_right, *tmp = node->rb_left;
-	struct rb_node *parent, *rebalance;
-	unsigned long pc;
-
-	if (!tmp) {
-		/*
-		 * Case 1: node to erase has no more than 1 child (easy!)
-		 *
-		 * Note that if there is one child it must be red due to 5)
-		 * and node must be black due to 4). We adjust colors locally
-		 * so as to bypass __rb_erase_color() later on.
-		 */
-		pc = node->__rb_parent_color;
-		parent = __rb_parent(pc);
-		__rb_change_child(node, child, parent, root);
-		if (child) {
-			child->__rb_parent_color = pc;
-			rebalance = NULL;
-		} else
-			rebalance = __rb_is_black(pc) ? parent : NULL;
-		tmp = parent;
-	} else if (!child) {
-		/* Still case 1, but this time the child is node->rb_left */
-		tmp->__rb_parent_color = pc = node->__rb_parent_color;
-		parent = __rb_parent(pc);
-		__rb_change_child(node, tmp, parent, root);
-		rebalance = NULL;
-		tmp = parent;
-	} else {
-		struct rb_node *successor = child, *child2;
-		tmp = child->rb_left;
-		if (!tmp) {
-			/*
-			 * Case 2: node's successor is its right child
-			 *
-			 *    (n)          (s)
-			 *    / \          / \
-			 *  (x) (s)  ->  (x) (c)
-			 *        \
-			 *        (c)
-			 */
-			parent = successor;
-			child2 = successor->rb_right;
-			augment->copy(node, successor);
-		} else {
-			/*
-			 * Case 3: node's successor is leftmost under
-			 * node's right child subtree
-			 *
-			 *    (n)          (s)
-			 *    / \          / \
-			 *  (x) (y)  ->  (x) (y)
-			 *      /            /
-			 *    (p)          (p)
-			 *    /            /
-			 *  (s)          (c)
-			 *    \
-			 *    (c)
-			 */
-			do {
-				parent = successor;
-				successor = tmp;
-				tmp = tmp->rb_left;
-			} while (tmp);
-			parent->rb_left = child2 = successor->rb_right;
-			successor->rb_right = child;
-			rb_set_parent(child, successor);
-			augment->copy(node, successor);
-			augment->propagate(parent, successor);
-		}
-
-		successor->rb_left = tmp = node->rb_left;
-		rb_set_parent(tmp, successor);
-
-		pc = node->__rb_parent_color;
-		tmp = __rb_parent(pc);
-		__rb_change_child(node, successor, tmp, root);
-		if (child2) {
-			successor->__rb_parent_color = pc;
-			rb_set_parent_color(child2, parent, RB_BLACK);
-			rebalance = NULL;
-		} else {
-			unsigned long pc2 = successor->__rb_parent_color;
-			successor->__rb_parent_color = pc;
-			rebalance = __rb_is_black(pc2) ? parent : NULL;
-		}
-		tmp = successor;
-	}
-
-	augment->propagate(tmp, NULL);
-	if (rebalance)
-		__rb_erase_color(rebalance, root, augment);
-}
+EXPORT_SYMBOL(__rb_erase_color);
 
 /*
  * Non-augmented rbtree manipulation functions.
@@ -513,7 +380,7 @@ EXPORT_SYMBOL(rb_insert_color);
 
 void rb_erase(struct rb_node *node, struct rb_root *root)
 {
-	__rb_erase(node, root, &dummy_callbacks);
+	rb_erase_augmented(node, root, &dummy_callbacks);
 }
 EXPORT_SYMBOL(rb_erase);
 
@@ -531,13 +398,6 @@ void __rb_insert_augmented(struct rb_node *node, struct rb_root *root,
 }
 EXPORT_SYMBOL(__rb_insert_augmented);
 
-void rb_erase_augmented(struct rb_node *node, struct rb_root *root,
-			const struct rb_augment_callbacks *augment)
-{
-	__rb_erase(node, root, augment);
-}
-EXPORT_SYMBOL(rb_erase_augmented);
-
 /*
  * This function returns the first node (in sort order) of the tree.
  */
diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index b20e99969b0f..268b23951fec 100644
--- a/lib/rbtree_test.c
+++ b/lib/rbtree_test.c
@@ -1,5 +1,5 @@
 #include <linux/module.h>
-#include <linux/rbtree.h>
+#include <linux/rbtree_augmented.h>
 #include <linux/random.h>
 #include <asm/timex.h>
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
