Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 82FEC6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 06:38:42 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [10.3.21.3])
	by smtp-out.google.com with ESMTP id o2VAcbwj007970
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 03:38:37 -0700
Received: from pzk31 (pzk31.prod.google.com [10.243.19.159])
	by hpaq3.eem.corp.google.com with ESMTP id o2VAcBrQ027876
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:38:35 +0200
Received: by pzk31 with SMTP id 31so2525985pzk.8
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 03:38:35 -0700 (PDT)
Date: Wed, 31 Mar 2010 03:38:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100331080414.GO3308@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1003310335110.17661@chino.kir.corp.google.com>
References: <20100329140633.GA26464@desktop> <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com> <20100330142923.GA10099@desktop> <alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com> <20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1003302302420.22316@chino.kir.corp.google.com> <20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com> <20100331063007.GN3308@balbir.in.ibm.com> <alpine.DEB.2.00.1003302331001.839@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1003310007450.9287@chino.kir.corp.google.com> <20100331080414.GO3308@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, Balbir Singh wrote:

> > It's pointless to try to kill current if select_bad_process() did not
> > find an eligible task to kill in mem_cgroup_out_of_memory() since it's
> > guaranteed that current is a member of the memcg that is oom and it is,
> > by definition, unkillable.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/oom_kill.c |    5 +----
> >  1 files changed, 1 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -500,12 +500,9 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
> >  	read_lock(&tasklist_lock);
> >  retry:
> >  	p = select_bad_process(&points, limit, mem, CONSTRAINT_NONE, NULL);
> > -	if (PTR_ERR(p) == -1UL)
> > +	if (!p || PTR_ERR(p) == -1UL)
> >  		goto out;
> 
> Should we have a bit fat WAR_ON_ONCE() here?
> 

I'm not sure a WARN_ON_ONCE() is going to be too helpful to a sysadmin who 
has misconfigured the memcg here since all it will do is emit the stack 
trace and line number, it's not going to be immediately obvious that this 
is because all tasks in the cgroup are unkillable so he or she should do
echo 1 > /dev/cgroup/blah/memory.oom_control as a remedy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
