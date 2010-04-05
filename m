Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3406B01EE
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 18:49:55 -0400 (EDT)
Date: Mon, 5 Apr 2010 15:49:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-Id: <20100405154923.23228529.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1004051533170.20683@chino.kir.corp.google.com>
References: <20100328145528.GA14622@desktop>
	<20100328162821.GA16765@redhat.com>
	<alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com>
	<20100329140633.GA26464@desktop>
	<alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
	<20100330142923.GA10099@desktop>
	<alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com>
	<20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003302302420.22316@chino.kir.corp.google.com>
	<20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com>
	<20100331063007.GN3308@balbir.in.ibm.com>
	<alpine.DEB.2.00.1003302331001.839@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1003310007450.9287@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1004041627100.7198@chino.kir.corp.google.com>
	<20100405143059.3b56862f.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1004051533170.20683@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 2010 15:40:27 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 5 Apr 2010, Andrew Morton wrote:
> 
> > > > It's pointless to try to kill current if select_bad_process() did not
> > > > find an eligible task to kill in mem_cgroup_out_of_memory() since it's
> > > > guaranteed that current is a member of the memcg that is oom and it is,
> > > > by definition, unkillable.
> > > > 
> > > > Signed-off-by: David Rientjes <rientjes@google.com>
> > > > ---
> > > >  mm/oom_kill.c |    5 +----
> > > >  1 files changed, 1 insertions(+), 4 deletions(-)
> > > > 
> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -500,12 +500,9 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
> > > >  	read_lock(&tasklist_lock);
> > > >  retry:
> > > >  	p = select_bad_process(&points, limit, mem, CONSTRAINT_NONE, NULL);
> > > > -	if (PTR_ERR(p) == -1UL)
> > > > +	if (!p || PTR_ERR(p) == -1UL)
> > > >  		goto out;
> > > >  
> > > > -	if (!p)
> > > > -		p = current;
> > > > -
> > > >  	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
> > > >  				"Memory cgroup out of memory"))
> > > >  		goto retry;
> > > > 
> > > 
> > > Are there any objections to merging this?  It's pretty straight-forward 
> > > given the fact that oom_kill_process() would fail if select_bad_process() 
> > > returns NULL even if p is set to current since it was not found to be 
> > > eligible during the tasklist scan.
> > 
> > I've lost the plot on the oom-killer patches.  Half the things I'm
> > seeing don't even apply.
> > 
> 
> This patch applies cleanly on mmotm-2010-03-24-14-48 and I don't see 
> anything that has been added since then that touches 
> mem_cgroup_out_of_memory().

I'm working on another mmotm at present.

> > Perhaps I should drop the lot and we start again.  We still haven't
> > resolved the procfs back-compat issue, either.
> 
> I haven't seen any outstanding compatibility issues raised.  The only 
> thing that isn't backwards compatible is consolidating 
> /proc/sys/vm/oom_kill_allocating_task and /proc/sys/vm/oom_dump_tasks into 
> /proc/sys/vm/oom_kill_quick.  We can do that because we've enabled 
> oom_dump_tasks by default so that systems that use both of these tunables 
> need to now disable oom_dump_tasks to avoid the costly tasklist scan.  

This can break stuff, as I've already described - if a startup tool is
correctly checking its syscall return values and a /procfs file
vanishes, the app may bail out and not work.

Others had other objections, iirc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
