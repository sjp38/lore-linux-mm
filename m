Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A579D6001DA
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 03:55:16 -0500 (EST)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id o1N8t9M2008239
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 00:55:09 -0800
Received: from yxe33 (yxe33.prod.google.com [10.190.2.33])
	by spaceape7.eur.corp.google.com with ESMTP id o1N8t7im031883
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 00:55:08 -0800
Received: by yxe33 with SMTP id 33so180117yxe.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 00:55:07 -0800 (PST)
Date: Tue, 23 Feb 2010 00:55:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
In-Reply-To: <4B838490.1050908@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002230046160.12015@chino.kir.corp.google.com>
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <4B827043.3060305@cn.fujitsu.com>
 <alpine.DEB.2.00.1002221339160.14426@chino.kir.corp.google.com> <4B838490.1050908@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010, Miao Xie wrote:

> >>  /*
> >> @@ -1391,11 +1393,10 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
> >>  
> >>  	if (cs == &top_cpuset) {
> >>  		cpumask_copy(cpus_attach, cpu_possible_mask);
> >> -		to = node_possible_map;
> >>  	} else {
> >>  		guarantee_online_cpus(cs, cpus_attach);
> >> -		guarantee_online_mems(cs, &to);
> >>  	}
> >> +	guarantee_online_mems(cs, &to);
> >>  
> >>  	/* do per-task migration stuff possibly for each in the threadgroup */
> >>  	cpuset_attach_task(tsk, &to, cs);
> > 
> > Do we need to set cpus_attach to cpu_possible_mask?  Why won't 
> > cpu_active_mask suffice?
> 
> If we set cpus_attach to cpu_possible_mask, we needn't do anything for tasks in the top_cpuset when
> doing cpu hotplug. If not, we will update cpus_allowed of all tasks in the top_cpuset.
> 

Cpu hotplug sets top_cpuset's cpus_allowed to cpu_active_mask by default, 
regardless of what was onlined or offlined.  cpus_attach in the context of 
your patch (in cpuset_attach()) passes cpu_possible_mask to 
set_cpus_allowed_ptr() if the task is being attached to top_cpuset, my 
question was why don't we pass cpu_active_mask instead?  In other words, I 
think we should do

	cpumask_copy(cpus_attach, cpu_active_mask);

when attached to top_cpuset like my patch did.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
