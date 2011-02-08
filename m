Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C7CBF8D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 21:20:00 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2B35A3EE0B3
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:19:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1189A45DE4E
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:19:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EED4145DE4D
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:19:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5492E08002
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:19:57 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70A8D1DB803A
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 11:19:57 +0900 (JST)
Date: Tue, 8 Feb 2011 11:13:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110208111351.93c6d048.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1102071808280.16931@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<20110208105553.76cfe424.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1102071808280.16931@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Feb 2011 18:13:22 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 8 Feb 2011, KAMEZAWA Hiroyuki wrote:
> 
> > > +static int mem_cgroup_oom_delay_millisecs_write(struct cgroup *cgrp,
> > > +					struct cftype *cft, u64 val)
> > > +{
> > > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > > +	struct mem_cgroup *iter;
> > > +
> > > +	if (val > MAX_SCHEDULE_TIMEOUT)
> > > +		return -EINVAL;
> > > +
> > > +	for_each_mem_cgroup_tree(iter, memcg) {
> > > +		iter->oom_delay = msecs_to_jiffies(val);
> > > +		memcg_oom_recover(iter);
> > > +	}
> > > +	return 0;
> > 
> > Seems nicer and it seems you tries to update all children cgroups.
> > 
> > BTW, with above code, with following heirarchy,
> > 
> >     A
> >    /
> >   B  
> >  /
> > C
> > 
> > When a user set oom_delay in order as A->B->C, A,B,C can have 'different' numbers.
> > When a user set oom_delay in order as C->B->A, A,B,C will have the same numbers.
> > 
> > This intreface seems magical, or broken.
> > 
> 
> It's not really magical, it just means that if you change the delay for a 
> memcg that you do so for all of its children implicitly as well.
> 
But you didn't explain the bahavior in Documenation.

> An alternative would be to ensure that a child memcg may never have a 
> delay greater than the delay of its parent.  Would you prefer that 
> instead?
> 
I don't think such limitation makes sense.

My point is just that the behavior is very special in current memcg interfaces. 
They do
 - It's not allowed to set attribute to no-children, no-parent cgroup

So, please explain above behavior in Documenation.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
