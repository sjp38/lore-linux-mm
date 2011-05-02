Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 43A8390010C
	for <linux-mm@kvack.org>; Mon,  2 May 2011 06:36:28 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p42AaLcc010584
	for <linux-mm@kvack.org>; Mon, 2 May 2011 16:06:21 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p42AaLrP2453552
	for <linux-mm@kvack.org>; Mon, 2 May 2011 16:06:21 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p42AaKXf026309
	for <linux-mm@kvack.org>; Mon, 2 May 2011 20:36:21 +1000
Date: Mon, 2 May 2011 12:32:19 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
Message-ID: <20110502070219.GO6547@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
 <20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

* Ying Han <yinghan@google.com> [2011-04-25 15:21:21]:

> Kame:
> 
> Thank you for putting time on implementing the patch. I think it is
> definitely a good idea to have the two alternatives on the table since
> people has asked the questions. Before going down to the track, i have
> thought about the two approaches and also discussed with Greg and Hugh
> (cc-ed),  i would like to clarify some of the pros and cons on both
> approaches.  In general, I think the workqueue is not the right answer
> for this purpose.
> 
> The thread-pool model
> Pros:
> 1. there is no isolation between memcg background reclaim, since the
> memcg threads are shared. That isolation including all the resources
> that the per-memcg background reclaim will need to access, like cpu
> time. One thing we are missing for the shared worker model is the
> individual cpu scheduling ability. We need the ability to isolate and
> count the resource assumption per memcg, and including how much
> cputime and where to run the per-memcg kswapd thread.
> 

Fair enough, but I think your suggestion is very container specific. I
am not sure how binding CPU and memory resources together is a good
idea, unless proven. My concern is growth in number of kernel threads.

> 2. it is hard for visibility and debugability. We have been
> experiencing a lot when some kswapds running creazy and we need a
> stright-forward way to identify which cgroup causing the reclaim. yes,
> we can add more stats per-memcg to sort of giving that visibility, but
> I can tell they are involved w/ more overhead of the change. Why
> introduce the over-head if the per-memcg kswapd thread can offer that
> maturely.
> 
> 3. potential priority inversion for some memcgs. Let's say we have two
> memcgs A and B on a single core machine, and A has big chuck of work
> and B has small chuck of work. Now B's work is queued up after A. In
> the workqueue model, we won't process B unless we finish A's work
> since we only have one worker on the single core host. However, in the
> per-memcg kswapd model, B got chance to run when A calls
> cond_resched(). Well, we might not having the exact problem if we
> don't constrain the workers number, and the worst case we'll have the
> same number of workers as the number of memcgs. If so, it would be the
> same model as per-memcg kswapd.
> 
> 4. the kswapd threads are created and destroyed dynamically. are we
> talking about allocating 8k of stack for kswapd when we are under
> memory pressure? In the other case, all the memory are preallocated.
> 
> 5. the workqueue is scary and might introduce issues sooner or later.
> Also, why we think the background reclaim fits into the workqueue
> model, and be more specific, how that share the same logic of other
> parts of the system using workqueue.
> 
> Cons:
> 1. save SOME memory resource.
> 
> The per-memcg-per-kswapd model
> Pros:
> 1. memory overhead per thread, and The memory consumption would be
> 8k*1000 = 8M with 1k cgroup. This is NOT a problem as least we haven't
> seen it in our production. We have cases that 2k of kernel threads
> being created, and we haven't noticed it is causing resource
> consumption problem as well as performance issue. On those systems, we
> might have ~100 cgroup running at a time.
> 
> 2. we see lots of threads at 'ps -elf'. well, is that really a problem
> that we need to change the threading model?
> 
> Overall, the per-memcg-per-kswapd thread model is simple enough to
> provide better isolation (predictability & debug ability). The number
> of threads we might potentially have on the system is not a real
> problem. We already have systems running that much of threads (even
> more) and we haven't seen problem of that. Also, i can imagine it will
> make our life easier for some other extensions on memcg works.
> 
> For now, I would like to stick on the simple model. At the same time I
> am willing to looking into changes and fixes whence we have seen
> problems later.
>

On second thoughts, ksm and THP have gone their own thread way, but
the number of threads is limited. With workqueues, won't @max_active
help cover some of the issues you mentioned? I know it does not help
with per cgroup association of workqueue threads, but if they execute
in process context, we should still have some control..no?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
