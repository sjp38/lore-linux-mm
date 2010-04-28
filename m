Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 075806B01F2
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 21:01:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3S11ZN0005773
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Apr 2010 10:01:35 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED08D45DE51
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:01:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C3D1445DE4D
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:01:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AB7B61DB803F
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:01:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5490C1DB804C
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 10:01:34 +0900 (JST)
Date: Wed, 28 Apr 2010 09:57:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm] oom: reintroduce and deprecate
 oom_kill_allocating_task
Message-Id: <20100428095734.c4d98055.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1004271557590.19364@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
	<20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100407205418.FB90.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
	<20100421121758.af52f6e0.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1004211502430.25558@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1004271557590.19364@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 Apr 2010 15:58:41 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> There's a concern that removing /proc/sys/vm/oom_kill_allocating_task
> will unnecessarily break the userspace API as the result of the oom
> killer rewrite.
> 
> This patch reintroduces the sysctl and deprecates it by adding an entry
> to Documentation/feature-removal-schedule.txt with a suggested removal
> date of December 2011 and emitting a warning the first time it is written
> including the writing task's name and pid.
> 
> /proc/sys/vm/oom_kill_allocating task mirrors the value of
> /proc/sys/vm/oom_kill_quick.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  Documentation/feature-removal-schedule.txt |   19 +++++++++++++++++++
>  include/linux/oom.h                        |    2 ++
>  kernel/sysctl.c                            |    7 +++++++
>  mm/oom_kill.c                              |   14 ++++++++++++++
>  4 files changed, 42 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
> --- a/Documentation/feature-removal-schedule.txt
> +++ b/Documentation/feature-removal-schedule.txt
> @@ -204,6 +204,25 @@ Who:	David Rientjes <rientjes@google.com>
>  
>  ---------------------------
>  
> +What:	/proc/sys/vm/oom_kill_allocating_task
> +When:	December 2011
> +Why:	/proc/sys/vm/oom_kill_allocating_task is equivalent to
> +	/proc/sys/vm/oom_kill_quick.  The two sysctls will mirror each other's
> +	value when set.
> +
> +	Existing users of /proc/sys/vm/oom_kill_allocating_task should simply
> +	write a non-zero value to /proc/sys/vm/oom_kill_quick.  This will also
> +	suppress a costly tasklist scan when dumping VM information for all
> +	oom kill candidates.
> +
> +	A warning will be emitted to the kernel log if an application uses this
> +	deprecated interface.  After it is printed once, future warning will be
> +	suppressed until the kernel is rebooted.
> +
> +Who:	David Rientjes <rientjes@google.com>
> +
> +---------------------------
> +
>  What:	remove EXPORT_SYMBOL(kernel_thread)
>  When:	August 2006
>  Files:	arch/*/kernel/*_ksyms.c
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -67,5 +67,7 @@ extern int sysctl_panic_on_oom;
>  extern int sysctl_oom_forkbomb_thres;
>  extern int sysctl_oom_kill_quick;
>  
> +extern int oom_kill_allocating_task_handler(struct ctl_table *table, int write,
> +			void __user *buffer, size_t *lenp, loff_t *ppos);
>  #endif /* __KERNEL__*/
>  #endif /* _INCLUDE_LINUX_OOM_H */
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -983,6 +983,13 @@ static struct ctl_table vm_table[] = {
>  		.proc_handler	= proc_dointvec,
>  	},
>  	{
> +		.procname	= "oom_kill_allocating_task",
> +		.data		= &sysctl_oom_kill_quick,
> +		.maxlen		= sizeof(sysctl_oom_kill_quick),
> +		.mode		= 0644,
> +		.proc_handler	= oom_kill_allocating_task_handler,
> +	},
> +	{
>  		.procname	= "oom_forkbomb_thres",
>  		.data		= &sysctl_oom_forkbomb_thres,
>  		.maxlen		= sizeof(sysctl_oom_forkbomb_thres),
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -37,6 +37,20 @@ int sysctl_oom_forkbomb_thres = DEFAULT_OOM_FORKBOMB_THRES;
>  int sysctl_oom_kill_quick;
>  static DEFINE_SPINLOCK(zone_scan_lock);
>  
> +int oom_kill_allocating_task_handler(struct ctl_table *table, int write,
> +			void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	int ret;
> +
> +	ret = proc_dointvec(table, write, buffer, lenp, ppos);
> +	if (!ret && write)
> +		printk_once(KERN_WARNING "%s (%d): "
> +			"/proc/sys/vm/oom_kill_allocating_task is deprecated, "
> +			"please use /proc/sys/vm/oom_kill_quick instead.\n",
> +			current->comm, task_pid_nr(current));
> +	return ret;
> +}
> +
>  /*
>   * Do all threads of the target process overlap our allowed nodes?
>   * @tsk: task struct of which task to consider
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
