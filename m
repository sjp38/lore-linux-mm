Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F2DF26B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 18:12:39 -0400 (EDT)
Date: Wed, 8 Jun 2011 18:11:41 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v4 3.0-rc2-tip 13/22] 13: uprobes: Handing int3 and
 singlestep exception.
Message-ID: <20110608221141.GB9965@wicker.gateway.2wire.net>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607130051.28590.68088.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607130051.28590.68088.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>



On Tue, Jun 07, 2011 at 06:30:51PM +0530, Srikar Dronamraju wrote:
> +/*
> + * uprobe_post_notifier gets called in interrupt context.
> + * It completes the single step operation.
> + */
> +int uprobe_post_notifier(struct pt_regs *regs)
> +{
> +	struct uprobe *uprobe;
> +	struct uprobe_task *utask;
> +
> +	if (!current->mm || !current->utask || !current->utask->active_uprobe)
> +		/* task is currently not uprobed */
> +		return 0;
> +
> +	utask = current->utask;
> +	uprobe = utask->active_uprobe;
> +	if (!uprobe)
> +		return 0;
> +
> +	set_thread_flag(TIF_UPROBE);
> +	return 1;
> +}

Looks like this can be simplified.  If current->utask->active_uprobe is
non-null then surely the assignment to uprobe will be too?


-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
