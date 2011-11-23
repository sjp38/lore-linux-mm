Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 812DF6B00EE
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 11:22:52 -0500 (EST)
Message-ID: <1322065356.14799.81.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 3/30] uprobes: register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 23 Nov 2011 17:22:36 +0100
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
> +int register_uprobe(struct inode *inode, loff_t offset,
> +                               struct uprobe_consumer *consumer)
> +{
> +       struct uprobe *uprobe;
> +       int ret =3D -EINVAL;
> +
> +       if (!consumer || consumer->next)
> +               return ret;
> +
> +       inode =3D igrab(inode);

So why are you dealing with !consumer but not with !inode? and why does
it make sense to allow !consumer at all?

> +       if (!inode)
> +               return ret;
> +
> +       if (offset > i_size_read(inode))
> +               goto reg_out;
> +
> +       ret =3D 0;
> +       mutex_lock(uprobes_hash(inode));
> +       uprobe =3D alloc_uprobe(inode, offset);
> +       if (uprobe && !add_consumer(uprobe, consumer)) {
> +               ret =3D __register_uprobe(inode, offset, uprobe);
> +               if (ret) {
> +                       uprobe->consumers =3D NULL;
> +                       __unregister_uprobe(inode, offset, uprobe);
> +               }
> +       }
> +
> +       mutex_unlock(uprobes_hash(inode));
> +       put_uprobe(uprobe);
> +
> +reg_out:
> +       iput(inode);
> +       return ret;
> +}=20

So if this function returns an error the caller is responsible for
cleaning up consumer, otherwise we take responsibility.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
