Date: Thu, 13 Sep 2007 15:23:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] oom: add verbose_oom sysctl to dump tasklist
Message-Id: <20070913152359.85949e0e.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.0.9999.0709070115130.19525@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709070115130.19525@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Sep 2007 01:17:27 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Adds 'verbose_oom' sysctl to dump the tasklist and pertinent memory usage
> information on an OOM killing.  Information included is pid, uid, tgid,
> VM size, RSS, last cpu, oom_adj score, and name.

Would be useful to have some description of why this is needed, how we will
use it to fix stuff, etc.  IOW: what value does it bring??

And if it _is_ valuable, how come it's tunable offable?  I guess the
tasklist dump will be pretty huge..

We should be dumping more stuff at oom-time.  I thought we were dumping the
sysrq-m-style output but that patch which did that got lost years ago.


> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -207,6 +207,7 @@ enum
>  	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
>  	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
>  	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
> +	VM_VERBOSE_OOM=36,	/* OOM killer verbosity */
>  
>  	/* s390 vm cmm sysctls */
>  	VM_CMM_PAGES=1111,
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -63,6 +63,7 @@ extern int print_fatal_signals;
>  extern int sysctl_overcommit_memory;
>  extern int sysctl_overcommit_ratio;
>  extern int sysctl_panic_on_oom;
> +extern int sysctl_verbose_oom;
>  extern int max_threads;
>  extern int core_uses_pid;
>  extern int suid_dumpable;
> @@ -790,6 +791,14 @@ static ctl_table vm_table[] = {
>  		.proc_handler	= &proc_dointvec,
>  	},
>  	{
> +		.ctl_name	= VM_VERBOSE_OOM,

We've stopped adding new sysctl numbers: this should use CTL_UNNUMBERED. 
See the nice comment at the end of this array...

> +		.procname	= "verbose_oom",
> +		.data		= &sysctl_verbose_oom,
> +		.maxlen		= sizeof(sysctl_verbose_oom),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec,
> +	},
> +	{
>  		.ctl_name	= VM_OVERCOMMIT_RATIO,
>  		.procname	= "overcommit_ratio",
>  		.data		= &sysctl_overcommit_ratio,
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -27,6 +27,7 @@
>  #include <linux/notifier.h>
>  
>  int sysctl_panic_on_oom;
> +int sysctl_verbose_oom;
>  /* #define DEBUG */
>  
>  unsigned long VM_is_OOM;
> @@ -146,6 +147,29 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  	return points;
>  }
>  
> +static inline void dump_tasks(void)
> +{
> +	struct task_struct *g, *p;
> +
> +	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj name\n");
> +	do_each_thread(g, p) {
> +		/*
> +		 * total_vm and rss sizes do not exist for tasks with a
> +		 * detached mm so there's no need to report them.  They are
> +		 * not eligible for OOM killing anyway.
> +		 */
> +		if (!p->mm)
> +			continue;
> +
> +		task_lock(p);
> +		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
> +		       p->pid, p->uid, p->tgid, p->mm->total_vm,
> +		       get_mm_rss(p->mm), (int)task_cpu(p), p->oomkilladj,
> +		       p->comm);
> +		task_unlock(p);
> +	} while_each_thread(g, p);
> +}

There's no need to inline this.

Also, it appears to be 100% generic and useful, so perhaps it should be put
into kernel/something.c and made available to other code.  Probably there's
already code out there which should be converted to a call to this
function?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
