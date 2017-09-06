Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13F20280442
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 16:59:45 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r133so12783516pgr.0
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 13:59:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u8sor365316plh.137.2017.09.06.13.59.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Sep 2017 13:59:44 -0700 (PDT)
Date: Wed, 6 Sep 2017 13:59:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
In-Reply-To: <20170906174043.GA12579@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1709061355001.70553@chino.kir.corp.google.com>
References: <20170904142108.7165-1-guro@fb.com> <20170904142108.7165-6-guro@fb.com> <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz> <20170905143021.GA28599@castle.dhcp.TheFacebook.com> <20170905151251.luh4wogjd3msfqgf@dhcp22.suse.cz>
 <20170905191609.GA19687@castle.dhcp.TheFacebook.com> <20170906084242.l4rcx6n3hdzxvil6@dhcp22.suse.cz> <20170906174043.GA12579@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, Christopher Lameter <cl@linux.com>, nzimmer@sgi.com, holt@sgi.com
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 6 Sep 2017, Roman Gushchin wrote:

> From f6e2339926a07500834d86548f3f116af7335d71 Mon Sep 17 00:00:00 2001
> From: Roman Gushchin <guro@fb.com>
> Date: Wed, 6 Sep 2017 17:43:44 +0100
> Subject: [PATCH] mm, oom: first step towards oom_kill_allocating_task
>  deprecation
> 
> The oom_kill_allocating_task sysctl which causes the OOM killer
> to simple kill the allocating task is useless. Killing the random
> task is not the best idea.
> 
> Nobody likes it, and hopefully nobody uses it.
> We want to completely deprecate it at some point.
> 

SGI required it when it was introduced simply to avoid the very expensive 
tasklist scan.  Adding Christoph Lameter to the cc since he was involved 
back then.

I attempted to deprecate the old /proc/pid/oom_adj in this same manner; we 
warned about it for over a year and then finally removed it, one person 
complained of breakage, and it was reverted with a strict policy that 
Linux doesn't break userspace.

Although it would be good to do, I'm not sure that this is possible unless 
it can be shown nobody is using it.  Talking to SGI would be the first 
step.

I'm not sure what this has to do with the overall patchset though :)

> To make a first step towards deprecation, let's warn potential
> users about deprecation plans.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  kernel/sysctl.c | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 655686d546cb..9158f1980584 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -220,6 +220,17 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
>  
>  #endif
>  
> +static int proc_oom_kill_allocating_tasks(struct ctl_table *table, int write,
> +				   void __user *buffer, size_t *lenp,
> +				   loff_t *ppos)
> +{
> +	pr_warn_once("The oom_kill_allocating_task sysctl will be deprecated.\n"
> +		     "If you're using it, please, report to "
> +		     "linux-mm@kvack.kernel.org.\n");
> +
> +	return proc_dointvec(table, write, buffer, lenp, ppos);
> +}
> +
>  static struct ctl_table kern_table[];
>  static struct ctl_table vm_table[];
>  static struct ctl_table fs_table[];
> @@ -1235,7 +1246,7 @@ static struct ctl_table vm_table[] = {
>  		.data		= &sysctl_oom_kill_allocating_task,
>  		.maxlen		= sizeof(sysctl_oom_kill_allocating_task),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> +		.proc_handler	= proc_oom_kill_allocating_tasks,
>  	},
>  	{
>  		.procname	= "oom_dump_tasks",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
