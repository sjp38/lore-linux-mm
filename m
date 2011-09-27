Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D2A949000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:42:05 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for
 mmap/munmap.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 27 Sep 2011 13:41:21 +0200
In-Reply-To: <20110926154414.GB13535@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
	 <1317045191.1763.22.camel@twins>
	 <20110926154414.GB13535@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317123681.15383.37.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2011-09-26 at 21:14 +0530, Srikar Dronamraju wrote:
> > Why not something like:
> >=20
> >=20
> > +static struct uprobe *__find_uprobe(struct inode * inode, loff_t offse=
t,
> >                                       bool inode_only)
> > +{
> >         struct uprobe u =3D { .inode =3D inode, .offset =3D inode_only =
? 0 : offset };
> > +       struct rb_node *n =3D uprobes_tree.rb_node;
> > +       struct uprobe *uprobe;
> >       struct uprobe *ret =3D NULL;
> > +       int match;
> > +
> > +       while (n) {
> > +               uprobe =3D rb_entry(n, struct uprobe, rb_node);
> > +               match =3D match_uprobe(&u, uprobe);
> > +               if (!match) {
> >                       if (!inode_only)
> >                              atomic_inc(&uprobe->ref);
> > +                       return uprobe;
> > +               }
> >               if (inode_only && uprobe->inode =3D=3D inode)
> >                       ret =3D uprobe;
> > +               if (match < 0)
> > +                       n =3D n->rb_left;
> > +               else
> > +                       n =3D n->rb_right;
> > +
> > +       }
> >         return ret;
> > +}
> >=20
>=20
> I am not comfortable with this change.
> find_uprobe() was suppose to return back a uprobe if and only if
> the inode and offset match,

And it will, because find_uprobe() will never expose that third
argument.

>  However with your approach, we end up
> returning a uprobe that isnt matching and one that isnt refcounted.
> Moreover if even if we have a matching uprobe, we end up sending a
> unrefcounted uprobe back.=20

Because the matching isn't the important part, you want to return the
leftmost node matching the specified inode. Also, in that case you
explicitly don't want the ref, since the first thing you do on the
call-site is drop the ref if there was a match. You don't care about
inode:0 in particular, you want a place to start iterating all of
inode:*.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
