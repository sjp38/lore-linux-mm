Date: Tue, 11 Apr 2006 23:59:07 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] support for panic at OOM
Message-Id: <20060411235907.6a59ecba.akpm@osdl.org>
In-Reply-To: <20060412155301.10d611ca.kamezawa.hiroyu@jp.fujitsu.com>
References: <20060412155301.10d611ca.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@engr.sgi.com, riel@redhat.com, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> This patch adds a feature to panic at OOM, oom_die.

Makes sense I guess.

> ===================================================================
> --- linux-2.6.17-rc1-mm2.orig/kernel/sysctl.c
> +++ linux-2.6.17-rc1-mm2/kernel/sysctl.c
> @@ -60,6 +60,7 @@ extern int proc_nr_files(ctl_table *tabl
>  extern int C_A_D;
>  extern int sysctl_overcommit_memory;
>  extern int sysctl_overcommit_ratio;
> +extern int sysctl_oom_die;
>  extern int max_threads;
>  extern int sysrq_enabled;
>  extern int core_uses_pid;

One day we should create a header file for all these.

> @@ -718,6 +719,14 @@ static ctl_table vm_table[] = {
>  		.proc_handler	= &proc_dointvec,
>  	},
>  	{
> +		.ctl_name	= VM_OOM_DIE,
> +		.procname	= "oom_die",

I'd suggest it be called "panic_on_oom".  Like the current panic_on_oops.

> +int sysctl_oom_die = 0;

The initialisation is unneeded.

> +static void oom_die(void)
> +{
> +	panic("Panic: out of memory: oom_die is selected.");
> +}
> +
>  /**
>   * oom_kill - kill the "best" process when we run out of memory
>   *
> @@ -331,6 +337,8 @@ void out_of_memory(struct zonelist *zone
>  
>  	case CONSTRAINT_NONE:
>  retry:
> +		if (sysctl_oom_die)
> +			oom_die();

I don't think we need a separate function for this?

Please document the new sysctl in Documentation/sysctl/.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
