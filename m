Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A3C26B007B
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 03:54:38 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1H8sZYJ023926
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Feb 2010 17:54:35 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EF8445DE50
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 17:54:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4464245DE4D
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 17:54:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F8CF1DB803C
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 17:54:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA7E1E38001
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 17:54:34 +0900 (JST)
Date: Wed, 17 Feb 2010 17:51:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: handle panic_on_oom=always case
Message-Id: <20100217175103.51ce01b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100217084526.GP5723@laptop>
References: <20100217150445.1a40201d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100217084526.GP5723@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, rientjes@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Feb 2010 19:45:26 +1100
Nick Piggin <npiggin@suse.de> wrote:

> On Wed, Feb 17, 2010 at 03:04:45PM +0900, KAMEZAWA Hiroyuki wrote:
> > tested on mmotm-Feb11.
> > 
> > Balbir-san, Nishimura-san, I want review from both of you.
> > 
> > ==
> > 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, if panic_on_oom=2, the whole system panics even if the oom happend
> > in some special situation (as cpuset, mempolicy....).
> > Then, panic_on_oom=2 means painc_on_oom_always.
> > 
> > Now, memcg doesn't check panic_on_oom flag. This patch adds a check.
> > 
> > Maybe someone doubts how it's useful. kdump+panic_on_oom=2 is the
> > last tool to investigate what happens in oom-ed system. If a task is killed,
> > the sysytem recovers and used memory were freed, there will be few hint
> > to know what happnes. In mission critical system, oom should never happen.
> > Then, investigation after OOM is very important.
> > Then, panic_on_oom=2+kdump is useful to avoid next OOM by knowing
> > precise information via snapshot.
> 
> No I don't doubt it is useful, and I think this probably is the simplest
> and most useful semantic. So thanks for doing this.
> 
Thank you for review.


> I hate to pick nits in a trivial patch but I will anyway:
> 
> 
> > TODO:
> >  - For memcg, it's for isolate system's memory usage, oom-notiifer and
> >    freeze_at_oom (or rest_at_oom) should be implemented. Then, management
> >    daemon can do similar jobs (as kdump) in safer way or taking snapshot
> >    per cgroup.
> > 
> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> > CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > CC: David Rientjes <rientjes@google.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  Documentation/cgroups/memory.txt |    2 ++
> >  Documentation/sysctl/vm.txt      |    5 ++++-
> >  mm/oom_kill.c                    |    2 ++
> >  3 files changed, 8 insertions(+), 1 deletion(-)
> > 
> > Index: mmotm-2.6.33-Feb11/Documentation/cgroups/memory.txt
> > ===================================================================
> > --- mmotm-2.6.33-Feb11.orig/Documentation/cgroups/memory.txt
> > +++ mmotm-2.6.33-Feb11/Documentation/cgroups/memory.txt
> > @@ -182,6 +182,8 @@ list.
> >  NOTE: Reclaim does not work for the root cgroup, since we cannot set any
> >  limits on the root cgroup.
> >  
> > +Note2: When panic_on_oom is set to "2", the whole system will panic.
> > +
> 
> Maybe:
> 
> NOTE2: When panic_on_oom is set to "2", the whole system will panic in
> case of an oom event in any cgroup.
> 

ok.


> >  2. Locking
> >  
> >  The memory controller uses the following hierarchy
> > Index: mmotm-2.6.33-Feb11/Documentation/sysctl/vm.txt
> > ===================================================================
> > --- mmotm-2.6.33-Feb11.orig/Documentation/sysctl/vm.txt
> > +++ mmotm-2.6.33-Feb11/Documentation/sysctl/vm.txt
> > @@ -573,11 +573,14 @@ Because other nodes' memory may be free.
> >  may be not fatal yet.
> >  
> >  If this is set to 2, the kernel panics compulsorily even on the
> > -above-mentioned.
> > +above-mentioned. Even oom happens under memoyr cgroup, the whole
> > +system panics.
>                                            memory
> 
> >  
> >  The default value is 0.
> >  1 and 2 are for failover of clustering. Please select either
> >  according to your policy of failover.
> > +2 seems too strong but panic_on_oom=2+kdump gives you very strong
> > +tool to investigate a system which should never cause OOM.
> 
> I don't think you need say 2 seems too strong because as you rightfully
> say, it has real uses. The hint about using it to investigate OOM
> conditions is good though.
> 

ok. I'll update this patch.

Thanks,
-Kame

> >  
> >  =============================================================
> >  
> > Index: mmotm-2.6.33-Feb11/mm/oom_kill.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb11.orig/mm/oom_kill.c
> > +++ mmotm-2.6.33-Feb11/mm/oom_kill.c
> > @@ -471,6 +471,8 @@ void mem_cgroup_out_of_memory(struct mem
> >  	unsigned long points = 0;
> >  	struct task_struct *p;
> >  
> > +	if (sysctl_panic_on_oom == 2)
> > +		panic("out of memory(memcg). panic_on_oom is selected.\n");
> >  	read_lock(&tasklist_lock);
> >  retry:
> >  	p = select_bad_process(&points, mem);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
