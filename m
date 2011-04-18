Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF4FE900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:21:13 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 5/26]  5: uprobes: Adding and remove
 a uprobe in a rb tree.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110401143328.15455.19094.sendpatchset@localhost6.localdomain6>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143328.15455.19094.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 18 Apr 2011 14:20:28 +0200
Message-ID: <1303129228.32491.777.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-04-01 at 20:03 +0530, Srikar Dronamraju wrote:
> +static int match_inode(struct uprobe *uprobe, struct inode *inode,
> +                                               struct rb_node **p)
> +{
> +       struct rb_node *n =3D *p;
> +
> +       if (inode < uprobe->inode)
> +               *p =3D n->rb_left;
> +       else if (inode > uprobe->inode)
> +               *p =3D n->rb_right;
> +       else
> +               return 1;
> +       return 0;
> +}
> +
> +static int match_offset(struct uprobe *uprobe, loff_t offset,
> +                                               struct rb_node **p)
> +{
> +       struct rb_node *n =3D *p;
> +
> +       if (offset < uprobe->offset)
> +               *p =3D n->rb_left;
> +       else if (offset > uprobe->offset)
> +               *p =3D n->rb_right;
> +       else
> +               return 1;
> +       return 0;
> +}
>+
> +/* Called with treelock held */
> +static struct uprobe *__find_uprobe(struct inode * inode,
> +                        loff_t offset, struct rb_node **near_match)
> +{
> +       struct rb_node *n =3D uprobes_tree.rb_node;
> +       struct uprobe *uprobe, *u =3D NULL;
> +
> +       while (n) {
> +               uprobe =3D rb_entry(n, struct uprobe, rb_node);
> +               if (match_inode(uprobe, inode, &n)) {
> +                       if (near_match)
> +                               *near_match =3D n;
> +                       if (match_offset(uprobe, offset, &n)) {
> +                               /* get access ref */
> +                               atomic_inc(&uprobe->ref);
> +                               u =3D uprobe;
> +                               break;
> +                       }
> +               }
> +       }
> +       return u;
> +}

Here you break out the match functions for some reason.

> +/*
> + * Find a uprobe corresponding to a given inode:offset
> + * Acquires treelock
> + */
> +static struct uprobe *find_uprobe(struct inode * inode, loff_t offset)
> +{
> +       struct uprobe *uprobe;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&treelock, flags);
> +       uprobe =3D __find_uprobe(inode, offset, NULL);
> +       spin_unlock_irqrestore(&treelock, flags);
> +       return uprobe;
> +}
> +
> +/*
> + * Acquires treelock.
> + * Matching uprobe already exists in rbtree;
> + *     increment (access refcount) and return the matching uprobe.
> + *
> + * No matching uprobe; insert the uprobe in rb_tree;
> + *     get a double refcount (access + creation) and return NULL.
> + */
> +static struct uprobe *insert_uprobe(struct uprobe *uprobe)
> +{
> +       struct rb_node **p =3D &uprobes_tree.rb_node;
> +       struct rb_node *parent =3D NULL;
> +       struct uprobe *u;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&treelock, flags);
> +       while (*p) {
> +               parent =3D *p;
> +               u =3D rb_entry(parent, struct uprobe, rb_node);
> +               if (u->inode > uprobe->inode)
> +                       p =3D &(*p)->rb_left;
> +               else if (u->inode < uprobe->inode)
> +                       p =3D &(*p)->rb_right;
> +               else {
> +                       if (u->offset > uprobe->offset)
> +                               p =3D &(*p)->rb_left;
> +                       else if (u->offset < uprobe->offset)
> +                               p =3D &(*p)->rb_right;
> +                       else {
> +                               /* get access ref */
> +                               atomic_inc(&u->ref);
> +                               goto unlock_return;
> +                       }
> +               }
> +       }
> +       u =3D NULL;
> +       rb_link_node(&uprobe->rb_node, parent, p);
> +       rb_insert_color(&uprobe->rb_node, &uprobes_tree);
> +       /* get access + drop ref */
> +       atomic_set(&uprobe->ref, 2);
> +
> +unlock_return:
> +       spin_unlock_irqrestore(&treelock, flags);
> +       return u;
> +}=20

And here you open-code the match functions..

Why not have something like:

static int match_probe(struct uprobe *l, struct uprobe *r)
{
	if (l->inode < r->inode)
		return -1;
	else if (l->inode > r->inode)
		return 1;
	else {
		if (l->offset < r->offset)
			return -1;
		else if (l->offset > r->offset)
			return 1;
	}

	return 0;
}

And use that as:

static struct uprobe *
__find_uprobe(struct inode *inode, loff_t offset)
{
	struct uprobe r =3D { .inode =3D inode, .offset =3D offset };
	struct rb_node *n =3D uprobes_tree.rb_node;
	struct uprobe *uprobe;
	int match;

	while (n) {
		uprobe =3D rb_node(n, struct uprobe, rb_node);
		match =3D match_probe(uprobe, &r);
		if (!match) {
			atomic_inc(&uprobe->ref);
			return uprobe;
		}
		if (match < 0)
			n =3D n->rb_left;
		else
			n =3D n->rb_right;
	}

	return NULL;
}

static struct uprobe *__insert_uprobe(struct uprobe *uprobe)
{
	struct rb_node **p =3D &uprobes_tree.rb_node;
	struct rn_node *parent =3D NULL;
	struct uprobe *u;
	int match;

	while (*p) {
		parent =3D *p;
		u =3D rb_entry(parent, struct uprobe, rb_node);
		match =3D match_uprobe(u, uprobe);
		if (!match) {
			atomic_inc(&u->ref);
			return u;
		}
		if (match < 0)
			p =3D &parent->rb_left;
		else
			p =3D &parent->rb_right;
	}

	atomic_set(&uprobe->ref, 2);
	rb_link_node(&uprobe->rb_node, parent, p);
	rb_insert_color(&uprobe->rb_node, &uprobes_tree);
	return uprobe;
}

Isn't that much nicer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
