Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 30A836B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 19:02:57 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so20725936pac.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 16:02:56 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id r20si459259pfa.51.2015.12.01.16.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 16:02:56 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so21443953pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 16:02:56 -0800 (PST)
Date: Tue, 1 Dec 2015 16:02:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
In-Reply-To: <20151201154353.87e2200b5cd1a99289ce6653@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1512011602170.15908@chino.kir.corp.google.com>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com> <20151201154353.87e2200b5cd1a99289ce6653@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aristeu Rozanski <arozansk@redhat.com>, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 1 Dec 2015, Andrew Morton wrote:

> > --- a/include/linux/oom.h
> > +++ b/include/linux/oom.h
> > @@ -115,6 +115,7 @@ static inline bool task_will_free_mem(struct task_struct *task)
> >  
> >  /* sysctls */
> >  extern int sysctl_oom_dump_tasks;
> > +extern int sysctl_oom_dump_stack;
> >  extern int sysctl_oom_kill_allocating_task;
> >  extern int sysctl_panic_on_oom;
> >  #endif /* _INCLUDE_LINUX_OOM_H */
> > diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> > index e69201d..c812523 100644
> > --- a/kernel/sysctl.c
> > +++ b/kernel/sysctl.c
> > @@ -1176,6 +1176,13 @@ static struct ctl_table vm_table[] = {
> >  		.proc_handler	= proc_dointvec,
> >  	},
> >  	{
> > +		.procname	= "oom_dump_stack",
> > +		.data		= &sysctl_oom_dump_stack,
> > +		.maxlen		= sizeof(sysctl_oom_dump_stack),
> > +		.mode		= 0644,
> > +		.proc_handler	= proc_dointvec,
> > +	},
> > +	{
> >  		.procname	= "overcommit_ratio",
> >  		.data		= &sysctl_overcommit_ratio,
> >  		.maxlen		= sizeof(sysctl_overcommit_ratio),
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 1ecc0bc..bdbf83b 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -42,6 +42,7 @@
> >  int sysctl_panic_on_oom;
> >  int sysctl_oom_kill_allocating_task;
> >  int sysctl_oom_dump_tasks = 1;
> > +int sysctl_oom_dump_stack = 1;
> >  
> >  DEFINE_MUTEX(oom_lock);
> >  
> > @@ -384,7 +385,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p,
> >  		current->signal->oom_score_adj);
> >  	cpuset_print_task_mems_allowed(current);
> >  	task_unlock(current);
> > -	dump_stack();
> > +	if (sysctl_oom_dump_stack)
> > +		dump_stack();
> >  	if (memcg)
> >  		mem_cgroup_print_oom_info(memcg, p);
> >  	else
> 
> The patch seems reasonable to me, but it's missing the required update
> to Documentation/sysctl/vm.txt.
> 

Not sure why we'd want yet-another-sysctl for something that can trivially 
filtered from the log, but owell.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
