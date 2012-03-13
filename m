Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 526356B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 11:35:48 -0400 (EDT)
Date: Tue, 13 Mar 2012 16:35:25 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 2/2] uprobes/core: Handle breakpoint and singlestep
 exception.
Message-ID: <20120313153524.GB12193@elte.hu>
References: <20120313140303.17134.1401.sendpatchset@srdronam.in.ibm.com>
 <20120313140313.17134.52012.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120313140313.17134.52012.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>


* Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> diff --git a/kernel/fork.c b/kernel/fork.c
> index 26a7a67..36508b9 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -67,6 +67,7 @@
>  #include <linux/oom.h>
>  #include <linux/khugepaged.h>
>  #include <linux/signalfd.h>
> +#include <linux/uprobes.h>
>  
>  #include <asm/pgtable.h>
>  #include <asm/pgalloc.h>
> @@ -731,6 +732,8 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
>  		exit_pi_state_list(tsk);
>  #endif
>  
> +	uprobe_free_utask(tsk);
> +
>  	/* Get rid of any cached register state */
>  	deactivate_mm(tsk, mm);
>  
> @@ -1322,6 +1325,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  	INIT_LIST_HEAD(&p->pi_state_list);
>  	p->pi_state_cache = NULL;
>  #endif
> +#ifdef CONFIG_UPROBES
> +	p->utask = NULL;
> +	p->uprobe_srcu_id = -1;
> +#endif
>  	/*
>  	 * sigaltstack should be cleared when sharing the same VM
>  	 */

Hm, I suspect by looking at the first two hunks you can guess 
how the third hunk should be done more cleanly?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
