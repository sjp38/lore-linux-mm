Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ED3CE6B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 16:01:04 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o1CL0E4f003591
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 21:00:14 GMT
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by kpbe19.cbf.corp.google.com with ESMTP id o1CL0CIK024499
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 13:00:13 -0800
Received: by pzk37 with SMTP id 37so2131675pzk.10
        for <linux-mm@kvack.org>; Fri, 12 Feb 2010 13:00:12 -0800 (PST)
Date: Fri, 12 Feb 2010 13:00:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
In-Reply-To: <1265982984.6207.29.camel@barrios-desktop>
Message-ID: <alpine.DEB.2.00.1002121251130.7972@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com> <4B73833D.5070008@redhat.com> <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
 <1265982984.6207.29.camel@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010, Minchan Kim wrote:

> > True, that's a great example of why child tasks should be sacrificed for 
> > the parent: if the oom killer is being called then we are truly overloaded 
> > and there's no shame in killing excessive client connections to recover, 
> > otherwise we might find the entire server becoming unresponsive.  The user 
> > can easily tune to /proc/sys/vm/oom_forkbomb_thres to define what 
> > "excessive" is to assess the penalty, if any.  I'll add that to the 
> > comment if we require a second revision.
> > 
> 
> I am worried about opposite case.
> 
> If forkbomb parent makes so many children in a short time(ex, 2000 per
> second) continuously and we kill a child continuously not parent, system
> is almost unresponsible, I think.  

The oom killer is not the appropriate place for a kernel forkbomb policy 
to be implemented, you'd need to address that concern in the scheduler.  
When I've brought that up in the past, the response is that if we aren't 
out of memory, then it isn't a problem.  It is a problem for buggy 
applications because their timeslice is now spread across an egregious 
amount of tasks that they are perhaps leaking and is detrimental to their 
server's performance.  I'm not saying that we need to enforce a hard limit 
on how many tasks a server forks, for instance, but the scheduler can 
detect forkbombs much easier than the oom killer's tasklist scan by at 
least indicating to us with a process flag that it is a likely forkbomb.

> I suffered from that case in LTP and no swap system.
> It might be a corner case but might happen in real. 
> 

If you look at the patchset overall and not just this one patch, you'll 
notice that we now kill the child with the highest badness() score first, 
i.e. generally the one consuming the most memory.  That is radically 
different than the previous behavior and should prevent the system from 
becoming unresponsive.  The goal is to allow the user to react to the 
forkbomb rather than implement a strict detection and handling heuristic 
that kills innocent servers and system daemons.

> If we make sure this task is buggy forkbomb, it would be better to kill
> it. But it's hard to make sure it's a buggy forkbomb.
> 
> Could we solve this problem by following as?
> If OOM selects victim and then the one was selected victim right before
> and it's repeatable 5 times for example, then we kill the victim(buggy
> forkbom) itself not child of one. It is assumed normal forkbomb is
> controlled by admin who uses oom_forkbomb_thres well. So it doesn't
> happen selecting victim continuously above five time.
> 

That doesn't work with Rik's example of a webserver that forks a large 
number of threads to handle client connections.  It is _always_ better to 
kill a child instead of making the entire webserver unresponsive.

In other words, doing anything in the oom killer other than slightly 
penalizing these tasks and killing a child is really a non-starter because 
there are too many critical use cases (we have many) that would be 
unfairly biased against.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
