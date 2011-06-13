Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 83BF56B0012
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 15:59:04 -0400 (EDT)
Date: Mon, 13 Jun 2011 21:57:01 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
	probes.
Message-ID: <20110613195701.GA14656@redhat.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6> <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 06/07, Srikar Dronamraju wrote:
>
> +int register_uprobe(struct inode *inode, loff_t offset,
> +				struct uprobe_consumer *consumer)
> +{
> +	struct prio_tree_iter iter;
> +	struct list_head try_list, success_list;
> +	struct address_space *mapping;
> +	struct mm_struct *mm, *tmpmm;
> +	struct vm_area_struct *vma;
> +	struct uprobe *uprobe;
> +	int ret = -1;
> +
> +	if (!inode || !consumer || consumer->next)
> +		return -EINVAL;
> +
> +	if (offset > inode->i_size)
> +		return -EINVAL;
> +
> +	uprobe = alloc_uprobe(inode, offset);
> +	if (!uprobe)
> +		return -ENOMEM;
> +
> +	INIT_LIST_HEAD(&try_list);
> +	INIT_LIST_HEAD(&success_list);
> +	mapping = inode->i_mapping;
> +
> +	mutex_lock(&uprobes_mutex);
> +	if (uprobe->consumers) {
> +		ret = 0;
> +		goto consumers_add;
> +	}
> +
> +	mutex_lock(&mapping->i_mmap_mutex);
> +	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, 0, 0) {

I didn't actually read this patch yet, but this looks suspicious.
Why begin == end == 0? Doesn't this mean we are ignoring the mappings
with vm_pgoff != 0 ?

Perhaps this should be offset >> PAGE_SIZE?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
