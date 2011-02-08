Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 88C258D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 21:26:50 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 27BD83EE0BC
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:26:48 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFB9645DE4E
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:26:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C16F345DE4F
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:26:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 62ED5EF8002
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:26:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A96AEF8004
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:26:46 +0900 (JST)
Date: Tue, 8 Feb 2011 11:20:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110208112041.a9986f09.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110208111351.93c6d048.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<20110208105553.76cfe424.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1102071808280.16931@chino.kir.corp.google.com>
	<20110208111351.93c6d048.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Tue, 8 Feb 2011 11:13:51 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 7 Feb 2011 18:13:22 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Tue, 8 Feb 2011, KAMEZAWA Hiroyuki wrote:
> > 
> > > > +static int mem_cgroup_oom_delay_millisecs_write(struct cgroup *cgrp,
> > > > +					struct cftype *cft, u64 val)
> > > > +{
> > > > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > > > +	struct mem_cgroup *iter;
> > > > +
> > > > +	if (val > MAX_SCHEDULE_TIMEOUT)
> > > > +		return -EINVAL;
> > > > +
> > > > +	for_each_mem_cgroup_tree(iter, memcg) {
> > > > +		iter->oom_delay = msecs_to_jiffies(val);
> > > > +		memcg_oom_recover(iter);
> > > > +	}
> > > > +	return 0;
> > > 
> > > Seems nicer and it seems you tries to update all children cgroups.
> > > 
> > > BTW, with above code, with following heirarchy,
> > > 
> > >     A
> > >    /
> > >   B  
> > >  /
> > > C
> > > 
> > > When a user set oom_delay in order as A->B->C, A,B,C can have 'different' numbers.
> > > When a user set oom_delay in order as C->B->A, A,B,C will have the same numbers.
> > > 
> > > This intreface seems magical, or broken.
> > > 
> > 
> > It's not really magical, it just means that if you change the delay for a 
> > memcg that you do so for all of its children implicitly as well.
> > 
> But you didn't explain the bahavior in Documenation.
> 
And write this fact:

     A
    /
   B
  /
 C

When 
  A.memory_oom_delay=1sec. 
  B.memory_oom_delay=500msec
  C.memory_oom_delay=200msec

If there are OOM in group C, C's oom_kill will be delayed for 200msec and
a task in group C will be killed. 

If there are OOM in group B, B's oom_kill will be delayed for 200msec and
a task in group B or C will be killed.

If there are OOM in group A, A's oom_kill will be delayed for 1sec and
a task in group A,B or C will be killed.

oom_killer in the hierarchy is serialized by lock and happens one-by-one
for avoiding a serial kill. So, above delay can be stacked. 

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
