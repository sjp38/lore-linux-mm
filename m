Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 89E0C6B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 03:43:01 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id oBM8gw9a023729
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 00:42:58 -0800
Received: from pxi4 (pxi4.prod.google.com [10.243.27.4])
	by kpbe13.cbf.corp.google.com with ESMTP id oBM8guGb006730
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 00:42:57 -0800
Received: by pxi4 with SMTP id 4so1051662pxi.2
        for <linux-mm@kvack.org>; Wed, 22 Dec 2010 00:42:56 -0800 (PST)
Date: Wed, 22 Dec 2010 00:42:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20101221235924.b5c1aecc.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1012220031010.24462@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com> <20101221235924.b5c1aecc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 2010, Andrew Morton wrote:

> > Completely disabling the oom killer for a memcg is problematic if
> > userspace is unable to address the condition itself, usually because
> > userspace is unresponsive.  This scenario creates a memcg livelock:
> > tasks are continuously trying to allocate memory and nothing is getting
> > killed, so memory freeing is impossible since reclaim has failed, and
> > all work stalls with no remedy in sight.
> 
> Userspace was buggy, surely.  If userspace has elected to disable the
> oom-killer then it should ensure that it can cope with the ensuing result.
> 

I think it would be argued that no such guarantee can ever be made.

> One approach might be to run a mlockall()ed watchdog which monitors the
> worker tasks via shared memory.  Another approach would be to run that
> watchdog in a different memcg, without mlockall().  There are surely
> plenty of other ways of doing it.
> 

Yeah, we considered a simple and perfect userspace implementation that 
would be as fault tolerant unless it ends up getting killed (not by the 
oom killer) or dies itself, but there was a concern that setting every 
memcg to have oom_control of 0 could render the entire kernel useless 
without the help of userspace and that is a bad policy.

In our particular use case, we _always_ want to defer using the kernel oom 
killer unless userspace chooses not to act (because the limit is already 
high enough) or cannot act (because of a bug).  The former is accomplished 
by setting memory.oom_control to 0 originally and then setting it to 1 for 
that particular memcg to allow the oom kill, but it is not possible for 
the latter.

> Minutea:
> 
> - changelog and docs forgot to mention that oom_delay=0 disables.
> 

I thought it would be intuitive that an oom_delay of 0 would mean there 
was no delay :)

> - it's called oom_kill_delay in the kernel and oom_delay in userspace.
> 

Right, this was because of the symmetry to the oom_kill_disable naming in 
the struct itself.  I'd be happy to change it if we're to go ahead in this 
direction.

> - oom_delay_millisecs would be a better name for the pseudo file.
> 

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
