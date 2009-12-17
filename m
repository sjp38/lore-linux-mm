Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A89596B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 17:22:04 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id nBHMLwdW008855
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:21:58 -0800
Received: from pwj16 (pwj16.prod.google.com [10.241.219.80])
	by wpaz37.hot.corp.google.com with ESMTP id nBHMLta0005888
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:21:56 -0800
Received: by pwj16 with SMTP id 16so1793865pwj.25
        for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:21:55 -0800 (PST)
Date: Thu, 17 Dec 2009 14:21:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.2
In-Reply-To: <20091215135902.CDD6.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912171412280.4089@chino.kir.corp.google.com>
References: <20091215133546.6872fc4f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0912142046070.436@chino.kir.corp.google.com> <20091215135902.CDD6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009, KOSAKI Motohiro wrote:

> > A few requirements that I have:
> 
> Um, good analysis! really.
> 
> >
> >  - we must be able to define when a task is a memory hogger; this is
> >    currently done by /proc/pid/oom_adj relying on the overall total_vm
> >    size of the task as a baseline.  Most users should have a good sense
> >    of when their task is using more memory than expected and killing a
> >    memory leaker should always be the optimal oom killer result.  A better 
> >    set of units other than a shift on total_vm would be helpful, though.
> 
> nit: What's mean "Most users"? desktop user(one of most majority users)
> don't have any expection of memory usage.
> 
> but, if admin have memory expection, they should be able to tune
> optimal oom result.
> 
> I think you pointed right thing.
> 

This is mostly referring to production server users where memory 
consumption by particular applications can be estimated, which allows the 
kernel to determine when a task is using a wildly unexpected amount that 
happens to become egregious enough to force the oom killer into killing a 
task.

That is contrast to using rss as a baseline where we prefer on killing the 
application with the most resident RAM.  It is not always ideal to kill a 
task with 8GB of rss when we fail to allocate a single page for a low 
priority task.

> >  - we must prefer tasks that run on a cpuset or mempolicy's nodes if the 
> >    oom condition is constrained by that cpuset or mempolicy and its not a
> >    system-wide issue.
> 
> agreed. (who disagree it?)
> 

It's possible to nullify the current penalization in the badness heuristic 
(order 3 reduction) if a candidate task does not share nodes with 
current's allowed set either by way of cpusets or mempolicies.  For 
example, an oom caused by an application with an MPOL_BIND on a single 
node can easily kill a task that has no memory resident on that node if 
its usage (or rss) is 3 orders higher than any candidate that is allowed 
on my bound node.

> >  - we must be able to polarize the badness heuristic to always select a
> >    particular task is if its very low priority or disable oom killing for
> >    a task if its must-run.
> 
> Probably I haven't catch your point. What's mean "polarize"? Can you
> please describe more?
> 

We need to be able to polarize tasks so they are always killed regardless 
of any kernel heuristic (/proc/pid/oom_adj of +15, currently) or always 
chosen last (-16, currently).  We also need a way of completely disabling 
oom killing for certain tasks such as with OOM_DISABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
