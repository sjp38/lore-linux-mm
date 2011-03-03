Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 357448D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 15:11:34 -0500 (EST)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p23KBVpo015624
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 12:11:31 -0800
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by kpbe15.cbf.corp.google.com with ESMTP id p23KAA4Z019174
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 12:11:30 -0800
Received: by pzk36 with SMTP id 36so278074pzk.16
        for <linux-mm@kvack.org>; Thu, 03 Mar 2011 12:11:29 -0800 (PST)
Date: Thu, 3 Mar 2011 12:11:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1103031211130.9993@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com> <20110223150850.8b52f244.akpm@linux-foundation.org> <alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Wed, 23 Feb 2011, David Rientjes wrote:

> On Wed, 23 Feb 2011, Andrew Morton wrote:
> 
> > Your patch still stinks!
> > 
> > If userspace can't handle a disabled oom-killer then userspace
> > shouldn't have disabled the oom-killer.
> > 
> 
> I agree, but userspace may not always be perfect especially on large 
> scale; we, in kernel land, can easily choose to ignore that but it's only 
> a problem because we're providing an interface where the memcg will 
> livelock without userspace intervention.  The global oom killer doesn't 
> have this problem and for years it has even radically panicked the machine 
> instead of livelocking EVEN THOUGH other threads, those that are 
> OOM_DISABLE, may be getting work done.
> 
> This is a memcg-specific issue because memory.oom_control has opened the 
> possibility up to livelock that userspace may have no way of correcting on 
> its own especially when it may be oom itself.  The natural conclusion is 
> that you should never set memory.oom_control unless you can guarantee a 
> perfect userspace implementation that will never be unresponsive.  At our 
> scale, we can't make that guarantee so memory.oom_control is not helpful 
> at all.
> 
> If that's the case, then what else do we have at our disposal other than 
> memory.oom_delay_millisecs that allows us to increase a hard limit or kill 
> a job of lower priority other than setting memory thresholds and hoping 
> userspace will schedule and respond before the memcg is completely oom?
> 
> > How do we fix this properly?
> > 
> > A little birdie tells me that the offending userspace oom handler is
> > running in a separate memcg and is not itself running out of memory. 
> 
> It depends on how you configure your memory controllers, but even if it is 
> running in a separate memcg how can you make the conclusion it isn't oom 
> in parallel?
> 
> > The problem is that the userspace oom handler is also taking peeks into
> > processes which are in the stressed memcg and is getting stuck on
> > mmap_sem in the procfs reads.  Correct?
> > 
> 
> That's outside the scope of this feature and is a separate discussion; 
> this patch specifically addresses an issue where a userspace job scheduler 
> wants to take action when a memcg is oom before deferring to the kernel 
> and happens to become unresponsive for whatever reason.
> 
> > It seems to me that such a userspace oom handler is correctly designed,
> > and that we should be looking into the reasons why it is unreliable,
> > and fixing them.  Please tell us about this?
> > 
> 
> The problem isn't specific to any one cause or implementation, we know 
> that userspace programs have bugs, they can stall forever in D-state, they 
> can be oom themselves, they get stuck waiting on a lock, etc etc.
> 

Was there a response to this, or can this patch be merged?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
