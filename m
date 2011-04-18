Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE40900088
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:21:14 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 6/26]  6: Uprobes:
 register/unregister probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110401143338.15455.98645.sendpatchset@localhost6.localdomain6>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143338.15455.98645.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 18 Apr 2011 14:20:36 +0200
Message-ID: <1303129236.32491.778.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-04-01 at 20:03 +0530, Srikar Dronamraju wrote:
> +static int remove_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
> +{
> +       int ret =3D 0;
> +
> +       /*TODO: remove breakpoint */
> +       if (!ret)
> +               atomic_dec(&mm->uprobes_count);
> +
> +       return ret;
> +}

> +static void delete_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
> +{
> +       down_read(&mm->mmap_sem);
> +       remove_uprobe(mm, uprobe);
> +       list_del(&mm->uprobes_list);
> +       up_read(&mm->mmap_sem);
> +       mmput(mm);
> +}

> +static void erase_uprobe(struct uprobe *uprobe)
> +{
> +       unsigned long flags;
> +
> +       synchronize_sched();
> +       spin_lock_irqsave(&treelock, flags);
> +       rb_erase(&uprobe->rb_node, &uprobes_tree);
> +       spin_unlock_irqrestore(&treelock, flags);
> +       iput(uprobe->inode);
> +}=20

remove,delete,erase.. head spins.. ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
