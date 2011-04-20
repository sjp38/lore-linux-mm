Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7468D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 16:24:37 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3KKOWJ3009100
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 13:24:32 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz5.hot.corp.google.com with ESMTP id p3KKOHuc027890
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 13:24:30 -0700
Received: by pvg7 with SMTP id 7so743853pvg.23
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 13:24:28 -0700 (PDT)
Date: Wed, 20 Apr 2011 13:24:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <20110420093900.45F6.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104201317410.31768@chino.kir.corp.google.com>
References: <20110419094422.9375.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104191419470.510@chino.kir.corp.google.com> <20110420093900.45F6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <johnstul@us.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 20 Apr 2011, KOSAKI Motohiro wrote:

> > That was true a while ago, but you now need to protect every thread's 
> > ->comm with get_task_comm() or ensuring task_lock() is held to protect 
> > against /proc/pid/comm which can change other thread's ->comm.  That was 
> > different before when prctl(PR_SET_NAME) would only operate on current, so 
> > no lock was needed when reading current->comm.
> 
> Right. /proc/pid/comm is evil. We have to fix it. otherwise we need change
> all of current->comm user. It's very lots!
> 

Fixing it in this case would be removing it and only allowing it for 
current via the usual prctl() :)  The code was introduced in 4614a696bd1c 
(procfs: allow threads to rename siblings via /proc/pid/tasks/tid/comm) in 
December 2009 and seems to originally be meant for debugging.  We simply 
can't continue to let it modify any thread's ->comm unless we change the 
over 300 current->comm deferences in the kernel.

I'd prefer that we remove /proc/pid/comm entirely or at least prevent 
writing to it unless CONFIG_EXPERT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
