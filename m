Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 890DC8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:13:35 -0400 (EDT)
Date: Thu, 31 Mar 2011 15:13:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <20110331144145.0ECA.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103311451530.28364@router.home>
References: <20110330052819.8212.1359.stgit@localhost6.localdomain6> <20110331144145.0ECA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 31 Mar 2011, KOSAKI Motohiro wrote:

> 1) zone reclaim doesn't work if the system has multiple node and the
>    workload is file cache oriented (eg file server, web server, mail server, et al).
>    because zone recliam make some much free pages than zone->pages_min and
>    then new page cache request consume nearest node memory and then it
>    bring next zone reclaim. Then, memory utilization is reduced and
>    unnecessary LRU discard is increased dramatically.

That is only true if the webserver only allocates from a single node. If
the allocation load is balanced then it will be fine. It is useful to
reclaim pages from the node where we allocate memory since that keeps the
dataset node local.

>    SGI folks added CPUSET specific solution in past. (cpuset.memory_spread_page)
>    But global recliam still have its issue. zone recliam is HPC workload specific
>    feature and HPC folks has no motivation to don't use CPUSET.

The spreading can also be done via memory policies. But that is only
required if the application has an unbalanced allocation behavior.

> 2) Before 2.6.27, VM has only one LRU and calc_reclaim_mapped() is used to
>    decide to filter out mapped pages. It made a lot of problems for DB servers
>    and large application servers. Because, if the system has a lot of mapped
>    pages, 1) LRU was churned and then reclaim algorithm become lotree one. 2)
>    reclaim latency become terribly slow and hangup detectors misdetect its
>    state and start to force reboot. That was big problem of RHEL5 based banking
>    system.
>    So, sc->may_unmap should be killed in future. Don't increase uses.

Because a bank could not configure its system properly we need to get rid
of may_unmap? Maybe raise min_unmapped_ratio instead and take care that
either the allocation load is balanced or a round robin scheme is
used by the app?

> And, this patch introduce new allocator fast path overhead. I haven't seen
> any justification for it.

We could do the triggering differently.

> In other words, you have to kill following three for getting ack 1) zone
> reclaim oriented reclaim 2) filter based LRU scanning (eg sc->may_unmap)
> 3) fastpath overhead. In other words, If you want a feature for vm guest,
> Any hardcoded machine configration assumption and/or workload assumption
> are wrong.

It would be good if you could come up with a new reclaim scheme that
avoids the need for zone reclaim and still allows one to take advantage of
memory distances. I agree that the current scheme sometimes requires
tuning too many esoteric knobs to get useful behavior.

> But, I agree that now we have to concern slightly large VM change parhaps
> (or parhaps not). Ok, it's good opportunity to fill out some thing.
> Historically, Linux MM has "free memory are waste memory" policy, and It
> worked completely fine. But now we have a few exceptions.
>
> 1) RT, embedded and finance systems. They really hope to avoid reclaim
>    latency (ie avoid foreground reclaim completely) and they can accept
>    to make slightly much free pages before memory shortage.

In general we need a mechanism to ensure we can avoid reclaim during
critical sections of application. So some way to give some hints to the
machine to free up lots of memory (/proc/sys/vm/dropcaches is far too
drastic) may be useful.

> And, now we have four proposal of utilization related issues.
>
> 1) cleancache (from Oracle)
> 2) VirtFS (from IBM)
> 3) kstaled (from Google)
> 4) unmapped page reclaim (from you)
>
> Probably, we can't merge all of them and we need to consolidate some
> requirement and implementations.

Well all these approaches show that we have major issues with reclaim and
large memory. Things get overly complicated. Time for a new approach that
integrates all the goals that these try to accomplish?

> Personally I think cleancache or other multi level page cache framework
> looks promising. but another solution is also acceptable. Anyway, I hope
> to everyone back 1000feet bird eye at once and sorting out all requiremnt
> with all related person.

Would be good if you could takle that problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
