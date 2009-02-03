Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BCB835F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 05:29:37 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n13ATUaw022360
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Feb 2009 19:29:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CF06A45DE57
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 19:29:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FED245DE4C
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 19:29:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 810181DB8040
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 19:29:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 293491DB8061
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 19:29:29 +0900 (JST)
Date: Tue, 3 Feb 2009 19:28:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm patch] Show memcg information during OOM (v2)
Message-Id: <20090203192819.0c1e0544.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090203101921.GY918@balbir.in.ibm.com>
References: <20090203072013.GU918@balbir.in.ibm.com>
	<20090203072701.GV918@balbir.in.ibm.com>
	<20090203170427.c6070cda.kamezawa.hiroyu@jp.fujitsu.com>
	<20090203101921.GY918@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009 15:49:21 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-03 17:04:27]:
> 
> > On Tue, 3 Feb 2009 12:57:01 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Checkpatch caught an additional space, so here is the patch again
> > > 
> > > 
> > > Description: Add RSS and swap to OOM output from memcg
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > 
> > > Changelog v2..v1:
> > > 
> > > 1. Add more information about task's memcg and the memcg
> > >    over it's limit
> > > 2. Print data in KB
> > > 3. Move the print routine outside task_lock()
> > > 4. Use rcu_read_lock() around cgroup_path, strictly speaking it
> > >    is not required, but relying on the current memcg implementation
> > >    is not a good idea.
> > > 
> > > 
> > > This patch displays memcg values like failcnt, usage and limit
> > > when an OOM occurs due to memcg.
> > > 
> > > Thanks go out to Johannes Weiner, Li Zefan, David Rientjes,
> > > Kamezawa Hiroyuki, Daisuke Nishimura and KOSAKI Motohiro for
> > > review.
> > > 
> > 
> > IIUC, this oom_kill is serialized by memcg_tasklist mutex.
> > Then, you don't have to allocate buffer on stack.
> > 
> > 
> > > +void mem_cgroup_print_mem_info(struct mem_cgroup *memcg, struct task_struct *p)
> > > +{
> > > +	struct cgroup *task_cgrp;
> > > +	struct cgroup *mem_cgrp;
> > > +	/*
> > > +	 * Need a buffer on stack, can't rely on allocations.
> > > +	 */
> > > +	char task_memcg_name[MEM_CGROUP_OOM_BUF_SIZE];
> > > +	char memcg_name[MEM_CGROUP_OOM_BUF_SIZE];
> > > +	int ret;
> > > +
> > 
> > making this as
> > 
> > static char task_memcg_name[PATH_MAX];
> > static char memcg_name[PATH_MAX];
> > 
> > is ok, I think. and the patch will be more simple.
> >
> 
> I am having second thoughts about this one. It introduces a standard
> overhead of 2 pages on x86*, while the first one will work for most
> cases and all the overhead is on stack, which disappears quickly.
> That is the reason I did not do it in the first place and put it as a
> NOTE.
>  
But *128* is tooooooo short ;)
And, your patch makes "OOM Message Format" unstable.
>From system administration view, it's unacceptable.
Not printing name at all is better than "printed out sometimes you lucky"

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
