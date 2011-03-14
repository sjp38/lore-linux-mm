Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7F7018D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 12:01:51 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 5/20]  5: Uprobes:
 register/unregister probes.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 14 Mar 2011 12:00:33 -0400
Message-ID: <1300118433.9910.118.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 2011-03-14 at 19:04 +0530, Srikar Dronamraju wrote:
> +/* Returns 0 if it can install one probe */
> +int register_uprobe(struct inode *inode, loff_t offset,
> +                               struct uprobe_consumer *consumer)
> +{
> +       struct prio_tree_iter iter;
> +       struct list_head tmp_list;
> +       struct address_space *mapping;
> +       struct mm_struct *mm, *tmpmm;
> +       struct vm_area_struct *vma;
> +       struct uprobe *uprobe;
> +       int ret = -1;
> +
> +       if (!inode || !consumer || consumer->next)
> +               return -EINVAL;
> +       uprobe = uprobes_add(inode, offset);

What happens if uprobes_add() returns NULL?

-- Steve

> +       INIT_LIST_HEAD(&tmp_list);
> +
> +       mapping = inode->i_mapping;
> +
> +       mutex_lock(&uprobes_mutex);
> +       if (uprobe->consumers) {
> +               ret = 0;
> +               goto consumers_add;
> +       } 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
