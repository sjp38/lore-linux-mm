Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2B0536B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 08:56:34 -0500 (EST)
Received: by ywh9 with SMTP id 9so2428562ywh.19
        for <linux-mm@kvack.org>; Fri, 12 Feb 2010 05:56:32 -0800 (PST)
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
	 <4B73833D.5070008@redhat.com>
	 <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 12 Feb 2010 22:56:24 +0900
Message-ID: <1265982984.6207.29.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, David. 

On Thu, 2010-02-11 at 01:14 -0800, David Rientjes wrote:
> > > +/*
> > > + * Tasks that fork a very large number of children with seperate address
> > > spaces
> > > + * may be the result of a bug, user error, or a malicious application.  The
> > > oom
> > > + * killer assesses a penalty equaling
> > 
> > It could also be the result of the system getting many client
> > connections - think of overloaded mail, web or database servers.
> > 
> 
> True, that's a great example of why child tasks should be sacrificed for 
> the parent: if the oom killer is being called then we are truly overloaded 
> and there's no shame in killing excessive client connections to recover, 
> otherwise we might find the entire server becoming unresponsive.  The user 
> can easily tune to /proc/sys/vm/oom_forkbomb_thres to define what 
> "excessive" is to assess the penalty, if any.  I'll add that to the 
> comment if we require a second revision.
> 

I am worried about opposite case.

If forkbomb parent makes so many children in a short time(ex, 2000 per
second) continuously and we kill a child continuously not parent, system
is almost unresponsible, I think.  
I suffered from that case in LTP and no swap system.
It might be a corner case but might happen in real. 

I think we could have two types of forkbomb. 

Normal forkbomb : apache, DB server and so on. 
Buggy forkbomb: It's mistake of user. 

We can control normal forkbomb by oom_forkbomb_thres.
But how about handling buggy forkbomb?

If we make sure this task is buggy forkbomb, it would be better to kill
it. But it's hard to make sure it's a buggy forkbomb.

Could we solve this problem by following as?
If OOM selects victim and then the one was selected victim right before
and it's repeatable 5 times for example, then we kill the victim(buggy
forkbom) itself not child of one. It is assumed normal forkbomb is
controlled by admin who uses oom_forkbomb_thres well. So it doesn't
happen selecting victim continuously above five time.


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
