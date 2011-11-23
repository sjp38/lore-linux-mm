Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4E66B00E5
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 13:24:13 -0500 (EST)
Message-ID: <1322072637.14799.92.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 1/30] uprobes: Auxillary routines to insert,
 find, delete uprobes
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 23 Nov 2011 19:23:57 +0100
In-Reply-To: <20111118110647.10512.51752.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110647.10512.51752.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Fri, 2011-11-18 at 16:36 +0530, Srikar Dronamraju wrote:
> +static struct uprobe *alloc_uprobe(struct inode *inode, loff_t offset)
> +{
> +       struct uprobe *uprobe, *cur_uprobe;
> +
> +       uprobe =3D kzalloc(sizeof(struct uprobe), GFP_KERNEL);
> +       if (!uprobe)
> +               return NULL;
> +
> +       uprobe->inode =3D igrab(inode);
> +       uprobe->offset =3D offset;
> +
> +       /* add to uprobes_tree, sorted on inode:offset */
> +       cur_uprobe =3D insert_uprobe(uprobe);
> +
> +       /* a uprobe exists for this inode:offset combination */
> +       if (cur_uprobe) {
> +               kfree(uprobe);
> +               uprobe =3D cur_uprobe;
> +               iput(inode);
> +       }
> +       return uprobe;
> +}=20

A function called alloc that actually publishes the object is weird.
Usually those things are separated. Alloc does the memory allocation and
sometimes initialization like things, but it never publishes the thing.

This leads to slightly weird code later on. Its not wrong, just weird
and makes reading this stuff slightly more challenging than needed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
