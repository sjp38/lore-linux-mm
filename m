Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3229000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 07:19:26 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 1/26]   uprobes: Auxillary routines to
 insert, find, delete uprobes
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 26 Sep 2011 13:18:40 +0200
In-Reply-To: <20110920115949.25326.2469.sendpatchset@srdronam.in.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920115949.25326.2469.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317035920.9084.84.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-09-20 at 17:29 +0530, Srikar Dronamraju wrote:
> +static struct uprobe *__insert_uprobe(struct uprobe *uprobe)
> +{
> +       struct rb_node **p =3D &uprobes_tree.rb_node;
> +       struct rb_node *parent =3D NULL;
> +       struct uprobe *u;
> +       int match;
> +
> +       while (*p) {
> +               parent =3D *p;
> +               u =3D rb_entry(parent, struct uprobe, rb_node);
> +               match =3D match_uprobe(uprobe, u);
> +               if (!match) {
> +                       atomic_inc(&u->ref);
> +                       return u;
> +               }
> +
> +               if (match < 0)
> +                       p =3D &parent->rb_left;
> +               else
> +                       p =3D &parent->rb_right;
> +
> +       }
> +       u =3D NULL;
> +       rb_link_node(&uprobe->rb_node, parent, p);
> +       rb_insert_color(&uprobe->rb_node, &uprobes_tree);
> +       /* get access + drop ref */
> +       atomic_set(&uprobe->ref, 2);
> +       return u;
> +}=20

If you ever want to make a 'lockless' lookup work you need to set the
refcount of the new object before its fully visible, instead of after.

Now much of a problem now since its fully serialized by that
uprobes_treelock thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
