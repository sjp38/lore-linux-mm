Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C228D8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 16:31:51 -0400 (EDT)
Date: Tue, 15 Mar 2011 16:31:17 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 11/20] 11: uprobes: slot allocation
	for uprobes
Message-ID: <20110315203117.GA27063@fibrous.localdomain>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314133610.27435.93666.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110314133610.27435.93666.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


On Mon, Mar 14, 2011 at 07:06:10PM +0530, Srikar Dronamraju wrote:
> diff --git a/kernel/fork.c b/kernel/fork.c
> index de3d10a..0afa0cd 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -551,6 +551,7 @@ void mmput(struct mm_struct *mm)
>  	might_sleep();
>  
>  	if (atomic_dec_and_test(&mm->mm_users)) {
> +		uprobes_free_xol_area(mm);
>  		exit_aio(mm);
>  		ksm_exit(mm);
>  		khugepaged_exit(mm); /* must run before exit_mmap */
> @@ -677,6 +678,9 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
>  	memcpy(mm, oldmm, sizeof(*mm));
>  
>  	/* Initializing for Swap token stuff */
> +#ifdef CONFIG_UPROBES
> +	mm->uprobes_xol_area = NULL;
> +#endif
>  	mm->token_priority = 0;
>  	mm->last_interval = 0;

Perhaps move the uprobes_xol_area initialization away from that comment?
A few lines down beside the hugepage #ifdef would read a bit better.


-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
