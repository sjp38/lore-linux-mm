Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C799A8D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 21:13:32 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p182DSPW008090
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 18:13:29 -0800
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by kpbe11.cbf.corp.google.com with ESMTP id p182DNDA012768
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 18:13:27 -0800
Received: by pwj9 with SMTP id 9so1638815pwj.7
        for <linux-mm@kvack.org>; Mon, 07 Feb 2011 18:13:27 -0800 (PST)
Date: Mon, 7 Feb 2011 18:13:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110208105553.76cfe424.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102071808280.16931@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <20110208105553.76cfe424.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Tue, 8 Feb 2011, KAMEZAWA Hiroyuki wrote:

> > +static int mem_cgroup_oom_delay_millisecs_write(struct cgroup *cgrp,
> > +					struct cftype *cft, u64 val)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +	struct mem_cgroup *iter;
> > +
> > +	if (val > MAX_SCHEDULE_TIMEOUT)
> > +		return -EINVAL;
> > +
> > +	for_each_mem_cgroup_tree(iter, memcg) {
> > +		iter->oom_delay = msecs_to_jiffies(val);
> > +		memcg_oom_recover(iter);
> > +	}
> > +	return 0;
> 
> Seems nicer and it seems you tries to update all children cgroups.
> 
> BTW, with above code, with following heirarchy,
> 
>     A
>    /
>   B  
>  /
> C
> 
> When a user set oom_delay in order as A->B->C, A,B,C can have 'different' numbers.
> When a user set oom_delay in order as C->B->A, A,B,C will have the same numbers.
> 
> This intreface seems magical, or broken.
> 

It's not really magical, it just means that if you change the delay for a 
memcg that you do so for all of its children implicitly as well.

An alternative would be to ensure that a child memcg may never have a 
delay greater than the delay of its parent.  Would you prefer that 
instead?

> So, my recomendation is 'just allow to set value a cgroup which has no children/parent'.
> Or 'just allo to se value a cgroup which is a root of a hierarchy'.
> Could you add a check ? Inheritance at mkdir() is okay to me.
> 

I'm trying to get away from this only because it doesn't seem very logical 
that creating a child memcg within a parent means that the parent is now 
locked out of setting memory.oom_delay_millisecs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
