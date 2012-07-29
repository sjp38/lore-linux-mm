Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C08066B004D
	for <linux-mm@kvack.org>; Sun, 29 Jul 2012 16:27:43 -0400 (EDT)
Date: 29 Jul 2012 16:27:42 -0400
Message-ID: <20120729202742.26416.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 1/6] rbtree: rb_erase updates and comments
In-Reply-To: <CANN689EPE823oV_SFZXHG+18CiD3oknF34=X26sUiKUiMPTeVQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, walken@google.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

>> Then the end of case 3 of rb_erase becomes:
>>         if (child)
>>                 rb_set_parent_color(child, parent, RB_RED);

> Yes. it's actually even nicer, because we know since the child is red,
> the node being erased is black, and we can thus handle recoloring 'for
> free' by setting child to black here instead of going through
> __rb_erase_color() later. And if we could do that for all 1-child
> cases, it might even be possible to invoke __rb_erase_color() for the
> no-childs case only, at which point we can drop one of that function's
> arguments. Worth investigating, I think.

I haven't wrapped my head around the recoloring functions yet.  I stopped
when I realized that if the child is red, the parent must be black,
but the child might be NULL, in which case the parent could be any color.

But... oh!  I see!  It's not the node being erased, but the node being
grafted.  If it has a red child, then it's part of a virtual 3-node, and
that can be downgraded to a 2-node without requiring any tree rebalancing!

Here's an (untested!) attempt at writing the code.  Be aware that although
I use the same variable names, there are significnt differences in what
they're used for!  In particular, "node" is never chnaged, so there's
no need for "old", and the successor is "child".

The main simplifcation I did was rename "black" to "rebalance", initially
set false, and only set "rebalance = rb_is_black(node)" when necessary.

Given the new variable uses, you could merge the "rebalance" and "parent"
variables, so rebalance = false is implied by parent = NULL.  I'm not
sure the variable saving is worth the code complexity, though.

void rb_erase(struct rb_node * const node, struct rb_root * const root)
{
	struct rb_node *parent;
	struct rb_node *child = node->rb_right;
	struct rb_node *tmp = node->rb_left;
	bool rebalance = false;

	if (!tmp) {
		/* Case 1: node to erase has no more than 1 child (easy!) */
		if (!child) {
			/* Node might be black */
			rebalance = rb_is_black(node);
		} else {
one_child:		/*
			 * Node has a child: it must be black, and the child
			 * must be red.  So promote the child to black, and
			 * no rebalancing needed.
			 */
			child->__rb_parent_color = node->__rb_parent_color;
		}
		parent = tmp = rb_parent(node);	// Hope compiler can CSE
	} else if (!child) {
		/* Still case 1, but this time the child is node->rb_left */
		child = tmp;
		goto one_child;
	} else {
		/*
		 * The node we want to erase has both left and right
		 * children, which makes things difficult.  Let's find the
		 * next node in the tree to have it fill old's position.
		 */
		tmp = child->rb_left;
		if (!tmp) {
			/*
			 * Case 2: Successor is node's right child.
			 *
			 *    (n)          (c)
			 *    / \          / \
			 *  (x) (c)  ->  (x) (z)
			 *        \
			 *        (z)
			 *
			 * Node z may or may not exist.  If it exists, it must
			 * be red, and can be promoted to black with no other
			 * tree rebalancing.
			 */
			tmp = child->rb_right;
			parent = child;
		} else {
			/*
			 * Case 3: Successor is not direct child; it
			 * is the left child of a chain (y) of other
			 * nodes.
			 *
			 *    (n)          (c)
			 *    / \          / \
			 *  (x) (y)  ->  (x) (y)
			 *      /            /
			 *    (c)          (z)
			 *      \
			 *      (z)
			 *
			 * As above, z may or may not exist.
			 */
			do {
				parent = child;
				child = tmp;
				tmp = child->rb_left;
			} while (tmp);

			child->rb_right = tmp = node->rb_right;
			rb_set_parent(tmp, child);
			parent->rb_left = tmp = child->rb_right;
		}
		// Variable usage:
		// "parent" is the bottom of "(y)", which is the same as
		//	"child" in case 2.
		// "tmp" is "(z)"
		// child->rb_right has been set correctly, as has
		// the pointer to (z).
		/*
		 * Here there are two cases, just like in case 1.
		 * If child had a right child, then child was black
		 * and its child was red, and can be promoted with no
		 * rebalancing.  If it did not, child might be either
		 * color, and its parent rebalancing if it was black.
		 */
		if (tmp)
			// tmp->__rb_parent_color = child->__rb_parent_color;
			rb_set_parent_color(tmp, parent, RB_BLACK);
		else
			rebalance = rb_is_black(child);

		child->rb_left = node->rb_left;
		child->__rb_parent_color = node->__rb_parent_color;
		tmp = rb_parent(node);	// Hope compiler can CSE
	}
	if (!tmp)
		root->rb_node = child;
	else if (tmp->rb_left == node)
		tmp->rb_left = child;
	else
		tmp->rb_right = child;
	if (rebalance)
		__rb_erase_color(NULL, parent, root);
}

> Using a helper doesn't hurt, I think. I'm not sure about the unlikely
> thing because near-empty trees could be common for some workloads,
> which is why I've let it the way it currently is.

I wasn't positive, either, but I figured it was easy enough to delete if
you disagreed.

I did think of one possible simplification: return a pointer to the parent's
child pointer and update that:

	*rb_pptr(old, parent, root) = new;

where

static inline struct rb_node **rb_pptr(struct rb_node *rb, struct rb_node *p,
		struct rb_root *root)
{
	if (!p)
		return &root->rb_node;
	else if (parent->rb_left == node)
		return &parent->rb_left;
	else
		return &parent->rb_right;
}

> Yeah, I've had a quick look at left-leaning RBtrees, but they didn't
> seem like an obvious win to me. Plus, I feel like I've been thinking
> about rbtrees too much already, so I kinda want to take a vacation
> from them at this point :)

Ah.  Then I'll stop muttering about ideas that imply major rewrites.

> Thanks for your remarks, especially the one about one-child coloring
> in rb_erase().

You're the one who spotted the major simplification, but I'm glad
to have been of some minor help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
