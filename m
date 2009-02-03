Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 92C325F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 23:41:49 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n134fiOQ016079
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 10:11:44 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n134fnFw4473042
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 10:11:49 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n134fia2021273
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 15:41:44 +1100
Date: Tue, 3 Feb 2009 10:11:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM
Message-ID: <20090203044143.GM918@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202140849.GB918@balbir.in.ibm.com> <49879DE5.8030505@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <49879DE5.8030505@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Li Zefan <lizf@cn.fujitsu.com> [2009-02-03 09:29:09]:

> > +void mem_cgroup_print_mem_info(struct mem_cgroup *memcg)
> > +{
> > +	printk(KERN_WARNING "Memory cgroups's name %s\n",
> > +		memcg->css.cgroup->dentry->d_name.name);
> > +	printk(KERN_WARNING "Memory cgroup RSS : usage %llu, limit %llu"
> > +		" failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
> 
> ", failcnt %llu\n" ?
> 
> > +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> > +		res_counter_read_u64(&memcg->res, RES_FAILCNT));
> > +	printk(KERN_WARNING "Memory cgroup swap: usage %llu, limit %llu "
> > +		"failcnt %llu\n",
> 
> ", failcnt %llu\n" ?
> 
> > +		res_counter_read_u64(&memcg->memsw, RES_USAGE),
> > +		res_counter_read_u64(&memcg->memsw, RES_LIMIT),
> > +		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
> > +}
> > +
> >  /*
> >   * Unlike exported interface, "oom" parameter is added. if oom==true,
> >   * oom-killer can be invoked.
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index d3b9bac..b8e53ae 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -392,6 +392,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  			current->comm, gfp_mask, order, current->oomkilladj);
> >  		task_lock(current);
> >  		cpuset_print_task_mems_allowed(current);
> > +		mem_cgroup_print_mem_info(mem);
> 
> I think this can be put outside the task lock. The lock is used to call task_cs() safely in
> cpuset_print_task_mems_allowed().
>

Thanks, I'll work on that in the next version.
 
> >  		task_unlock(current);
> >  		dump_stack();
> >  		show_mem();
> > 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
