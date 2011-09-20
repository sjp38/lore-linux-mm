Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E7EFF9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 13:57:24 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate7.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p8KHvMQm029013
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 17:57:22 GMT
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8KHvLlX2486390
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 18:57:21 +0100
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8KHvK8R022803
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 11:57:21 -0600
Date: Tue, 20 Sep 2011 18:03:10 +0100
From: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 4/26]   uprobes: Define hooks for
 mmap/munmap.
Message-ID: <20110920170310.GB27959@stefanha-thinkpad.localdomain>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920120040.25326.63549.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 20, 2011 at 05:30:40PM +0530, Srikar Dronamraju wrote:
> +static void build_probe_list(struct inode *inode, struct list_head *head)
> +{
> +	struct uprobe *uprobe;
> +	struct rb_node *n;
> +	unsigned long flags;
> +
> +	n = uprobes_tree.rb_node;
> +	spin_lock_irqsave(&uprobes_treelock, flags);

Not sure whether grabbing root.rb_node outside the spinlock is safe?  If
the tree is rotated on another CPU you could catch and out-of-date node?

> +static void dec_mm_uprobes_count(struct vm_area_struct *vma,
> +		struct inode *inode)
> +{
> +	struct uprobe *uprobe;
> +	struct rb_node *n;
> +	unsigned long flags;
> +
> +	n = uprobes_tree.rb_node;
> +	spin_lock_irqsave(&uprobes_treelock, flags);

Same here.

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
