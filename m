Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 11C1D5F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 04:00:47 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n1390bUC012174
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 14:30:37 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n138wIbG3629184
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 14:28:19 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n1390aat013600
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 20:00:36 +1100
Date: Tue, 3 Feb 2009 14:30:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM (v2)
Message-ID: <20090203090034.GW918@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090203072013.GU918@balbir.in.ibm.com> <20090203072701.GV918@balbir.in.ibm.com> <20090203170427.c6070cda.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090203170427.c6070cda.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-03 17:04:27]:

> On Tue, 3 Feb 2009 12:57:01 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Checkpatch caught an additional space, so here is the patch again
> > 
> > 
> > Description: Add RSS and swap to OOM output from memcg
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Changelog v2..v1:
> > 
> > 1. Add more information about task's memcg and the memcg
> >    over it's limit
> > 2. Print data in KB
> > 3. Move the print routine outside task_lock()
> > 4. Use rcu_read_lock() around cgroup_path, strictly speaking it
> >    is not required, but relying on the current memcg implementation
> >    is not a good idea.
> > 
> > 
> > This patch displays memcg values like failcnt, usage and limit
> > when an OOM occurs due to memcg.
> > 
> > Thanks go out to Johannes Weiner, Li Zefan, David Rientjes,
> > Kamezawa Hiroyuki, Daisuke Nishimura and KOSAKI Motohiro for
> > review.
> > 
> 
> IIUC, this oom_kill is serialized by memcg_tasklist mutex.
> Then, you don't have to allocate buffer on stack.
> 
> 
> > +void mem_cgroup_print_mem_info(struct mem_cgroup *memcg, struct task_struct *p)
> > +{
> > +	struct cgroup *task_cgrp;
> > +	struct cgroup *mem_cgrp;
> > +	/*
> > +	 * Need a buffer on stack, can't rely on allocations.
> > +	 */
> > +	char task_memcg_name[MEM_CGROUP_OOM_BUF_SIZE];
> > +	char memcg_name[MEM_CGROUP_OOM_BUF_SIZE];
> > +	int ret;
> > +
> 
> making this as
> 
> static char task_memcg_name[PATH_MAX];
> static char memcg_name[PATH_MAX];
> 
> is ok, I think. and the patch will be more simple.
>

I've mentioned it in the NOTE section as well, I wanted more opinions
before going that route. I'll resend v3. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
