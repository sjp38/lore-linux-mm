Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EBE896B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 04:50:22 -0500 (EST)
Message-ID: <1322128199.2921.3.camel@twins>
Subject: Re: Fwd: uprobes: register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 24 Nov 2011 10:49:59 +0100
In-Reply-To: <20111124070303.GB28065@linux.vnet.ibm.com>
References: <hYuXv-26J-3@gated-at.bofh.it> <hYuXw-26J-5@gated-at.bofh.it>
	 <i0nRU-7eK-11@gated-at.bofh.it>
	 <603b0079-5f54-4299-9a9a-a5e237ccca73@l23g2000pro.googlegroups.com>
	 <20111124070303.GB28065@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, tulasidhard@gmail.com

On Thu, 2011-11-24 at 12:33 +0530, Srikar Dronamraju wrote:
> > On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> > > +int register_uprobe(struct inode *inode, loff_t offset,
> > > +                               struct uprobe_consumer *consumer)
> > > +{
> > > +       struct uprobe *uprobe;
> > > +       int ret =3D -EINVAL;
> > > +
> > > +       if (!consumer || consumer->next)
> > > +               return ret;
> > > +
> > > +       inode =3D igrab(inode);
> >=20
> > So why are you dealing with !consumer but not with !inode? and why
> > does
> > it make sense to allow !consumer at all?
> >=20
>=20
>=20
> I am not sure if I got your comment correctly.
>=20
> I do check for inode just after the igrab.

No you don't, you check the return value of igrab(), but you crash hard
when someone calls register_uprobe(.inode=3DNULL).

> I am actually not dealing with !consumer.
> If the consumer is NULL, then we dont have any handler to run so why
> would we want to register such a probe?

Why allow someone calling register_uprobe(.consumer=3DNULL) to begin with?
That doesn't make any sense.

> Also if consumer->next is Non-NULL, that means that this consumer was
> already used.  Reusing the consumer, can result in consumers list getting
> broken into two.

Yeah, although at that point why be nice about it? Just but a WARN_ON()
in or so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
