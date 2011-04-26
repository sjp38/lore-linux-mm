Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 92DD79000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:27:11 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3QJ6nbo015347
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:06:49 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3QJRARR082456
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:27:10 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3QJR9RN002470
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 15:27:10 -0400
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <20110421103009.731B.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1104201317410.31768@chino.kir.corp.google.com>
	 <1303331695.2796.159.camel@work-vm>
	 <20110421103009.731B.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Apr 2011 12:27:06 -0700
Message-ID: <1303846026.2816.117.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-04-21 at 10:29 +0900, KOSAKI Motohiro wrote:
> > On Wed, 2011-04-20 at 13:24 -0700, David Rientjes wrote:
> > > On Wed, 20 Apr 2011, KOSAKI Motohiro wrote:
> > > 
> > > > > That was true a while ago, but you now need to protect every thread's 
> > > > > ->comm with get_task_comm() or ensuring task_lock() is held to protect 
> > > > > against /proc/pid/comm which can change other thread's ->comm.  That was 
> > > > > different before when prctl(PR_SET_NAME) would only operate on current, so 
> > > > > no lock was needed when reading current->comm.
> > > > 
> > > > Right. /proc/pid/comm is evil. We have to fix it. otherwise we need change
> > > > all of current->comm user. It's very lots!
> > > > 
> > > 
> > > Fixing it in this case would be removing it and only allowing it for 
> > > current via the usual prctl() :)  The code was introduced in 4614a696bd1c 
> > > (procfs: allow threads to rename siblings via /proc/pid/tasks/tid/comm) in 
> > > December 2009 and seems to originally be meant for debugging.  We simply 
> > > can't continue to let it modify any thread's ->comm unless we change the 
> > > over 300 current->comm deferences in the kernel.
> > > 
> > > I'd prefer that we remove /proc/pid/comm entirely or at least prevent 
> > > writing to it unless CONFIG_EXPERT.
> > 
> > Eeeh. That's probably going to be a tough sell, as I think there is
> > wider interest in what it provides. Its useful for debugging
> > applications not kernels, so I doubt folks will want to rebuild their
> > kernel to try to analyze a java issue.
> > 
> > So I'm well aware that there is the chance that you catch the race and
> > read an incomplete/invalid comm (it was discussed at length when the
> > change went in), but somewhere I've missed how that's causing actual
> > problems. Other then just being "evil" and having the documented race,
> > could you clarify what the issue is that your hitting?
> 
> The problem is, there is no documented as well. Okay, I recognized you
> introduced new locking rule for task->comm. But there is no documented
> it. Thus, We have no way to review current callsites are correct or not.
> Can you please do it? And, I have a question. Do you mean now task->comm
> reader don't need task_lock() even if it is another thread?
> 
> _if_ every task->comm reader have to realize it has a chance to read
> incomplete/invalid comm, task_lock() doesn't makes any help.

Sorry if this somehow got off on the wrong foot. Its just surprising to
see such passion bubble up after almost two years of quiet since the
proc patch went in.

So I'm not proposing comm be totally lock free (Dave Hansen might do
that for me, we'll see :) but when the original patch was proposed, the
idea that transient empty or incomplete comms would be possible was
brought up and didn't seem to be a big enough issue at the time to block
it from being merged.

Its just having a more specific case where these transient
null/incomplete comms causes an issue would help prioritize the need for
correctness.

In the meantime, I'll put some effort into trying to protect unlocked
current->comm acccess using get_task_comm() where possible. Won't happen
in a day, and help would be appreciated. 

When we hit the point where the remaining places are where the task_lock
can't be taken, we can either live with the possible incomplete comm or
add a new lock to protect just the comm.

thanks
-john






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
