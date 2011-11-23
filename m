Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5F04E6B016A
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 11:27:24 -0500 (EST)
Message-ID: <1322065625.14799.82.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 3/30] uprobes: register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 23 Nov 2011 17:27:05 +0100
In-Reply-To: <20111118110713.10512.9461.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110713.10512.9461.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Fri, 2011-11-18 at 16:37 +0530, Srikar Dronamraju wrote:
> +void unregister_uprobe(struct inode *inode, loff_t offset,
> +                               struct uprobe_consumer *consumer)
> +{
> +       struct uprobe *uprobe =3D NULL;
> +
> +       inode =3D igrab(inode);
> +       if (!inode || !consumer)
> +               goto unreg_out;

Why do you take a reference on the inode here? Surely inode is already
made stable by whoever calls us?

> +       uprobe =3D find_uprobe(inode, offset);
> +       if (!uprobe)
> +               goto unreg_out;
> +
> +       mutex_lock(uprobes_hash(inode));
> +       if (!del_consumer(uprobe, consumer)) {
> +               mutex_unlock(uprobes_hash(inode));
> +               goto unreg_out;
> +       }
> +
> +       if (!uprobe->consumers)
> +               __unregister_uprobe(inode, offset, uprobe);
> +
> +       mutex_unlock(uprobes_hash(inode));
> +
> +unreg_out:
> +       if (uprobe)
> +               put_uprobe(uprobe);
> +       if (inode)
> +               iput(inode);
> +}=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
