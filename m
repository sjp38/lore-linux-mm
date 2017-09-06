Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED7AE280449
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 13:59:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l19so6684181wmi.1
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 10:59:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a14si286250wrh.466.2017.09.06.10.59.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 10:59:22 -0700 (PDT)
Date: Wed, 6 Sep 2017 19:59:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170906175919.e5hshqjjto2wb63b@dhcp22.suse.cz>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-6-guro@fb.com>
 <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz>
 <20170905143021.GA28599@castle.dhcp.TheFacebook.com>
 <20170905151251.luh4wogjd3msfqgf@dhcp22.suse.cz>
 <20170905191609.GA19687@castle.dhcp.TheFacebook.com>
 <20170906084242.l4rcx6n3hdzxvil6@dhcp22.suse.cz>
 <20170906174043.GA12579@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170906174043.GA12579@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 06-09-17 18:40:43, Roman Gushchin wrote:
[...]
> >From f6e2339926a07500834d86548f3f116af7335d71 Mon Sep 17 00:00:00 2001
> From: Roman Gushchin <guro@fb.com>
> Date: Wed, 6 Sep 2017 17:43:44 +0100
> Subject: [PATCH] mm, oom: first step towards oom_kill_allocating_task
>  deprecation
> 
> The oom_kill_allocating_task sysctl which causes the OOM killer
> to simple kill the allocating task is useless. Killing the random

useless is quite strong ;) I would say dubious.

> task is not the best idea.
> 
> Nobody likes it, and hopefully nobody uses it.
> We want to completely deprecate it at some point.
> 
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

Other than that
Acked-by: Michal Hocko <mhocko@suse.com>

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
> -- 
> 2.13.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
