Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF8A8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:35:08 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3KKNxiN005013
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:23:59 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3KKZ2WF131190
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:35:02 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3KKYxr0001933
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:35:00 -0600
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104201317410.31768@chino.kir.corp.google.com>
References: <20110419094422.9375.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.2.00.1104191419470.510@chino.kir.corp.google.com>
	 <20110420093900.45F6.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.2.00.1104201317410.31768@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 13:34:55 -0700
Message-ID: <1303331695.2796.159.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2011-04-20 at 13:24 -0700, David Rientjes wrote:
> On Wed, 20 Apr 2011, KOSAKI Motohiro wrote:
> 
> > > That was true a while ago, but you now need to protect every thread's 
> > > ->comm with get_task_comm() or ensuring task_lock() is held to protect 
> > > against /proc/pid/comm which can change other thread's ->comm.  That was 
> > > different before when prctl(PR_SET_NAME) would only operate on current, so 
> > > no lock was needed when reading current->comm.
> > 
> > Right. /proc/pid/comm is evil. We have to fix it. otherwise we need change
> > all of current->comm user. It's very lots!
> > 
> 
> Fixing it in this case would be removing it and only allowing it for 
> current via the usual prctl() :)  The code was introduced in 4614a696bd1c 
> (procfs: allow threads to rename siblings via /proc/pid/tasks/tid/comm) in 
> December 2009 and seems to originally be meant for debugging.  We simply 
> can't continue to let it modify any thread's ->comm unless we change the 
> over 300 current->comm deferences in the kernel.
> 
> I'd prefer that we remove /proc/pid/comm entirely or at least prevent 
> writing to it unless CONFIG_EXPERT.

Eeeh. That's probably going to be a tough sell, as I think there is
wider interest in what it provides. Its useful for debugging
applications not kernels, so I doubt folks will want to rebuild their
kernel to try to analyze a java issue.

So I'm well aware that there is the chance that you catch the race and
read an incomplete/invalid comm (it was discussed at length when the
change went in), but somewhere I've missed how that's causing actual
problems. Other then just being "evil" and having the documented race,
could you clarify what the issue is that your hitting?

thanks
-john




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
