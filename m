Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CBC3562012A
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 16:32:53 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o73KhLoC016612
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 13:43:23 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by kpbe20.cbf.corp.google.com with ESMTP id o73KguBK005293
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 13:43:20 -0700
Received: by pxi2 with SMTP id 2so2158432pxi.38
        for <linux-mm@kvack.org>; Tue, 03 Aug 2010 13:43:20 -0700 (PDT)
Date: Tue, 3 Aug 2010 13:43:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100803162738.52858530.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008031337110.12365@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com> <20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com> <20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com> <20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com> <20100803102423.82415a17.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021850400.19184@chino.kir.corp.google.com>
 <20100803110534.e3e7a697.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021953520.27231@chino.kir.corp.google.com> <20100803121146.cf35b7ed.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008022117200.4146@chino.kir.corp.google.com>
 <20100803133255.deb5c208.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008030016590.20849@chino.kir.corp.google.com> <20100803162111.2f8dfded.kamezawa.hiroyu@jp.fujitsu.com> <20100803162738.52858530.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:

> > > Not at all, the user knows what tasks are attached to the memcg and can 
> > > easily determine which task is going to be killed when it ooms: simply 
> > > iterate through the memcg tasklist, check /proc/pid/oom_score, and sort.
> > > 
> > 
> > And finds 
> > 	at system oom,  process A is killed.
> > 	at memcg oom, process B is killed.
> > 
> > funny non-deteministic interace, aha.
> > 
> 
> I said
> 	- you have beutiful legs. (new logic of oom calculation)
> 	- but your face is ugly	  (new oom_score_adj)
> 	then
> 	- I bought a mask for you (oom_disable for memcg.)
> 
> Then, please don't use your time for convince me your face is beutiful.
> It's waste of time.
> 

Haha, I love the analogy :)

The difference in selection of tasks depending on whether its a memcg or 
system oom isn't really concerning since /proc/pid/oom_score_adj would 
have been assigned in a way that reflects its prioritization for kill only 
in the memcg oom kill scenario.  It would reflect the prioritization 
system wide if memcg were not used.

The same thing would happen if several tasks in different memcgs were 
given oom_score_adj of +1000.  This would yield a badness score of 1000 
for each of those tasks, which translates to "always kill."  Only one 
would actually be selected for kill in the system wide case, however, to 
prevent needless killing.  Which one that is happens to be the one that 
appears in the tasklist first.

The end result is that when using memcg, we don't really care about the 
prioritization of killing of tasks when the entire system is oom.  That's 
true because no memcg happens to be oom itself, we've simply run out of 
RAM.  The same is true of cpusets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
