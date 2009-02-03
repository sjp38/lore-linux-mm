Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AE11C5F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 00:34:10 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n135Y1JQ016487
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 11:04:01 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n135VhUo3588308
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 11:01:43 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n135Y0eS012090
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 16:34:01 +1100
Date: Tue, 3 Feb 2009 11:03:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM
Message-ID: <20090203053358.GO918@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202140849.GB918@balbir.in.ibm.com> <49879DE5.8030505@cn.fujitsu.com> <20090203044143.GM918@balbir.in.ibm.com> <alpine.DEB.2.00.0902022045170.27139@chino.kir.corp.google.com> <20090203045556.GN918@balbir.in.ibm.com> <alpine.DEB.2.00.0902022121150.28810@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0902022121150.28810@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2009-02-02 21:25:52]:

> On Tue, 3 Feb 2009, Balbir Singh wrote:
> 
> > > > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > > > index d3b9bac..b8e53ae 100644
> > > > > > --- a/mm/oom_kill.c
> > > > > > +++ b/mm/oom_kill.c
> > > > > > @@ -392,6 +392,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> > > > > >  			current->comm, gfp_mask, order, current->oomkilladj);
> > > > > >  		task_lock(current);
> > > > > >  		cpuset_print_task_mems_allowed(current);
> > > > > > +		mem_cgroup_print_mem_info(mem);
> > > > > 
> > > > > I think this can be put outside the task lock. The lock is used to call task_cs() safely in
> > > > > cpuset_print_task_mems_allowed().
> > > > >
> > > > 
> > > > Thanks, I'll work on that in the next version.
> > > >  
> > > 
> > > I was also wondering about this and assumed that it was necessary to 
> > > prevent the cgroup from disappearing during the oom.  If task_lock() isn't 
> > > held, is the memcg->css.cgroup->dentry->d_name.name dereference always 
> > > safe without rcu?
> > >
> > 
> > oom_kill_process is called with tasklist_lock held (read-mode). That
> > should suffice, no? The memcg cannot go away since it has other groups
> > or tasks associated with it. 
> > 
> 
> I don't see how this prevents a task from being reattached to a different 
> cgroup and then a rmdir on memcg->css.cgroup would destroy the dentry 
> without cgroup_mutex or dereferencing via rcu.

That scenario is not possible today from the memory controller
perspective.

We hold memcg_tasklist during task movement and during OOM, task
migration is held till OOM completes.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
