Date: Tue, 30 Nov 1999 00:27:55 -0500
From: "Kevin O'Connor" <koconnor@cse.Buffalo.EDU>
Subject: Re: [patch] rbtrees [was Re: AVL trees vs. Red-Black trees]
Message-ID: <19991130002755.A22847@armstrong.cse.Buffalo.EDU>
References: <Pine.LNX.4.10.9911291649470.5133-100000@alpha.random> <3842D179.7FBD6A69@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3842D179.7FBD6A69@colorfullife.com>; from Manfred Spraul on Mon, Nov 29, 1999 at 08:18:17PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Oliver Xymoron <oxymoron@waste.org>, Kevin O'Connor <koconnor@cse.Buffalo.EDU>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Marc Lehmann <pcg@opengroup.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 1999 at 08:18:17PM +0100, Manfred Spraul wrote:
> What about something similar to the "end_request()" implementation?
> 
> ie you #define a name and the (inline) compare function, then you
> #include <rbtree.h>. <rbtree.h> creates all functions that you need.

I don't much like this method - IMO, it obfuscates the #include directive.
That said, however, I implemented a generic AVL tree implementation using a
similar idea.  Basically, I define a couple of MACROs: AVL_FIND and
AVL_FINDWITHSTACK (needed by AVL trees to do a bottom-up insert/delete).
These macros take a compare function as a parameter.  If the compare
function is declared as inline, or if it is a macro, it will be compiled
inline and without the overhead of a call instruction.

I'm including a sample usage, plus an excerpt from my avltree.h header file
- just to give a sample of how I would implement generic trees.

I can provide more code upon request.  I've got inserts working, but
removes are becoming a myriad of special cases..

Note: I tried to be "clever", and store the tree height in the low-order
bytes of a pointer.  It works, but it's pretty ugly.

-Kevin

=============  Sample application usage ===============

struct hrmm {
	int num;
	avl_node_t treenode;
};

static inline int
mycmp(avl_node_t *x, avl_node_t *y)
{
	int a,b;

	a = avl_entry(x, struct hrmm, treenode)->num;
	b = avl_entry(y, struct hrmm, treenode)->num;

	return (a < b ? -1 : a > b ? 1 : 0);
}

int
my_insert(avl_node_t **tree, struct hrmm *node)
{
	return AVL_INSERT(tree,&node->treenode,mycmp);
}

int
my_remove(avl_node_t **tree, struct hrmm *node)
{
	return AVL_REMOVE(tree,&node->treenode,mycmp);
}

struct hrmm *
my_find(avl_node_t *tree, struct hrmm *node)
{
	return avl_entry(AVL_FIND(tree,&node->treenode,mycmp)
			 , struct hrmm, treenode);
}

=============  Macros from header file  ===============

#define AVL_FIND(__Tree,__Node,__Compare) ({			\
	avl_node_t *__tree = (__Tree);				\
								\
	while (__tree) {					\
		int __compval = __Compare((__Node),__tree);	\
								\
		if (__compval < 0) {				\
			__tree = getChild(__tree, TREE_LEFT);	\
		} else if (__compval > 0) {			\
			__tree = getChild(__tree, TREE_RIGHT);	\
		} else {					\
			break;					\
		}						\
	}							\
	__tree;})

#define AVL_FINDWITHSTACK(__TreeP,__Node,__Stack,__Count,__Compare) ({	\
	avl_node_t **__tree = (__TreeP), *__tmp;		  	\
	avl_dptr_t *__stack = (__Stack);			     	\
	int *__count = (__Count), __found=0;			     	\
								     	\
	__tmp = *__tree;					     	\
	*__count = 0;						     	\
	__stack[0] = (avl_dptr_t) __tree;			     	\
	while (__tmp) {						     	\
		int __compval = __Compare((__Node), __tmp);	     	\
								     	\
		if (__compval < 0) {				     	\
			(*__count)++;				     	\
			setPtr(&__stack[*__count], __tmp, TREE_LEFT);   \
			__tmp = getChild(__tmp, TREE_LEFT);	     	\
		} else if (__compval > 0) {			     	\
			(*__count)++;				     	\
			setPtr(&__stack[*__count], __tmp, TREE_RIGHT);  \
			__tmp = getChild(__tmp, TREE_RIGHT);	     	\
		} else {					     	\
			__found = 1;				     	\
			break;					     	\
		}						     	\
	}							     	\
	__found;})

#define AVL_REMOVE(__TreeP,__Node,__Compare) ({			\
	avl_dptr_t __stk[AVL_MAXHEIGHT];			\
	int __cnt, __ret;					\
								\
	if (! AVL_FINDWITHSTACK((__TreeP),(__Node)		\
				,__stk,&__cnt,__Compare)) {	\
		__ret = 0;					\
	} else {						\
		avl_remove(__stk, __cnt);			\
		__ret = 1;					\
	}							\
	__ret;})

#define AVL_INSERT(__TreeP,__Node,__Compare) ({			\
	avl_dptr_t __stk[AVL_MAXHEIGHT];			\
	int __cnt, __ret;					\
								\
	if (AVL_FINDWITHSTACK((__TreeP),(__Node)		\
				,__stk,&__cnt,__Compare)) {	\
		__ret = 0;					\
	} else {						\
		avl_insert((__Node), __stk, __cnt);		\
		__ret = 1;					\
	}							\
	__ret;})



-- 
 ------------------------------------------------------------------------
 | Kevin O'Connor                     "BTW, IMHO we need a FAQ for      |
 | koconnor@cse.buffalo.edu            'IMHO', 'FAQ', 'BTW', etc. !"    |
 ------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
