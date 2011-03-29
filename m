Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A3C168D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:42:26 -0400 (EDT)
Date: Tue, 29 Mar 2011 15:42:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-ID: <20110329134223.GB3361@tiehlicka.suse.cz>
References: <20110328093957.089007035@suse.cz>
 <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
 <20110328114430.GE5693@tiehlicka.suse.cz>
 <20110329090924.6a565ef3.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329073232.GB30671@tiehlicka.suse.cz>
 <20110329165117.179d87f9.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329085942.GD30671@tiehlicka.suse.cz>
 <20110329184119.219f7d7b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329111858.GF30671@tiehlicka.suse.cz>
 <AANLkTi=1WA-oF1kraTMMcSgwqvaXqrEiROVGeDfejO45@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=1WA-oF1kraTMMcSgwqvaXqrEiROVGeDfejO45@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 29-03-11 21:15:59, Zhu Yanhai wrote:
> Michal,

Hi,

> Maybe what we need here is some kind of trade-off?
> Let's say a new configuable parameter reserve_limit, for the cgroups
> which want to
> have some guarantee in the memory resource, we have:
> 
> limit_in_bytes > soft_limit > reserve_limit
> 
> MEM[limit_in_bytes..soft_limit] are the bytes that I'm willing to contribute
> to the others if they are short of memory.
> 
> MEM[soft_limit..reserve_limit] are the bytes that I can afford if the others
> are still eager for memory after I gave them MEM[limit_in_bytes..soft_limit].
> 
> MEM[reserve_limit..0] are the bytes which is a must for me to guarantee QoS.
> Nobody is allowed to steal them.
> 
> And reserve_limit is 0 by default for the cgroups who don't care about Qos.
> 
> Then the reclaim path also needs some changes, i.e, balance_pgdat():
> 1) call mem_cgroup_soft_limit_reclaim(), if nr_reclaimed is meet, goto finish.
> 2) shrink the global LRU list, and skip the pages which belong to the cgroup
> who have set a reserve_limit. if nr_reclaimed is meet, goto finish.

Isn't this an overhead that would slow the whole thing down. Consider
that you would need to lookup page_cgroup for every page and touch
mem_cgroup to get the limit.
The point of the isolation is to not touch the global reclaim path at
all.

> 3) shrink the cgroups who have set a reserve_limit, and leave them with only
> the reserve_limit bytes they need. if nr_reclaimed is meet, goto finish.
> 4) OOM
> 
> Does it make sense?

It sounds like a good thing - in that regard it is more generic than
a simple flag - but I am afraid that the implementation wouldn't be
that easy to preserve the performance and keep the balance between
groups. But maybe it can be done without too much cost.

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
