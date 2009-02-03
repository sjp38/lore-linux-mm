Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB735F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 23:47:22 -0500 (EST)
Date: Mon, 2 Feb 2009 20:47:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [-mm patch] Show memcg information during OOM
In-Reply-To: <20090203044143.GM918@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.0902022045170.27139@chino.kir.corp.google.com>
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202140849.GB918@balbir.in.ibm.com> <49879DE5.8030505@cn.fujitsu.com> <20090203044143.GM918@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009, Balbir Singh wrote:

> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index d3b9bac..b8e53ae 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -392,6 +392,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> > >  			current->comm, gfp_mask, order, current->oomkilladj);
> > >  		task_lock(current);
> > >  		cpuset_print_task_mems_allowed(current);
> > > +		mem_cgroup_print_mem_info(mem);
> > 
> > I think this can be put outside the task lock. The lock is used to call task_cs() safely in
> > cpuset_print_task_mems_allowed().
> >
> 
> Thanks, I'll work on that in the next version.
>  

I was also wondering about this and assumed that it was necessary to 
prevent the cgroup from disappearing during the oom.  If task_lock() isn't 
held, is the memcg->css.cgroup->dentry->d_name.name dereference always 
safe without rcu?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
