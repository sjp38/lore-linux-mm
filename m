Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 77AEF6B007D
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:32:03 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o1NMVxMf017762
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:31:59 GMT
Received: from fxm10 (fxm10.prod.google.com [10.184.13.10])
	by wpaz5.hot.corp.google.com with ESMTP id o1NMVRrA011995
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 14:31:57 -0800
Received: by fxm10 with SMTP id 10so4159802fxm.30
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 14:31:57 -0800 (PST)
Date: Tue, 23 Feb 2010 14:31:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
In-Reply-To: <4B839E9D.8020604@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002231427190.8693@chino.kir.corp.google.com>
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <4B827043.3060305@cn.fujitsu.com>
 <alpine.DEB.2.00.1002221339160.14426@chino.kir.corp.google.com> <4B838490.1050908@cn.fujitsu.com> <alpine.DEB.2.00.1002230046160.12015@chino.kir.corp.google.com> <4B839E9D.8020604@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010, Miao Xie wrote:

> > Cpu hotplug sets top_cpuset's cpus_allowed to cpu_active_mask by default, 
> > regardless of what was onlined or offlined.  cpus_attach in the context of 
> > your patch (in cpuset_attach()) passes cpu_possible_mask to 
> > set_cpus_allowed_ptr() if the task is being attached to top_cpuset, my 
> > question was why don't we pass cpu_active_mask instead?  In other words, I 
> > think we should do
> > 
> > 	cpumask_copy(cpus_attach, cpu_active_mask);
> > 
> > when attached to top_cpuset like my patch did.
> 
> If we pass cpu_active_mask to set_cpus_allowed_ptr(), task->cpus_allowed just contains
> the online cpus. In this way, if we do cpu hotplug(such as: online some cpu), we must
> update cpus_allowed of all tasks in the top cpuset.
> 
> But if we pass cpu_possible_mask, we needn't update cpus_allowed of all tasks in the
> top cpuset. And when the kernel looks for a cpu for task to run, the kernel will use
> cpu_active_mask to filter out offline cpus in task->cpus_allowed. Thus, it is safe.
> 

That is terribly inconsistent between top_cpuset and all descendants; all 
other cpusets require that task->cpus_allowed be a subset of 
cpu_online_mask, including those descendants that allow all cpus (and all 
mems).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
