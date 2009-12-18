Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C7476B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 23:30:45 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBI4Ufhk005782
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 18 Dec 2009 13:30:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 599DA45DE50
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:30:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3442245DE4F
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:30:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1657C1DB803A
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:30:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B3D461DB8037
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:30:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask v4.2
In-Reply-To: <alpine.DEB.2.00.0912171412280.4089@chino.kir.corp.google.com>
References: <20091215135902.CDD6.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0912171412280.4089@chino.kir.corp.google.com>
Message-Id: <20091218094359.652F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 18 Dec 2009 13:30:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 15 Dec 2009, KOSAKI Motohiro wrote:
> 
> > > A few requirements that I have:
> > 
> > Um, good analysis! really.
> > 
> > >
> > >  - we must be able to define when a task is a memory hogger; this is
> > >    currently done by /proc/pid/oom_adj relying on the overall total_vm
> > >    size of the task as a baseline.  Most users should have a good sense
> > >    of when their task is using more memory than expected and killing a
> > >    memory leaker should always be the optimal oom killer result.  A better 
> > >    set of units other than a shift on total_vm would be helpful, though.
> > 
> > nit: What's mean "Most users"? desktop user(one of most majority users)
> > don't have any expection of memory usage.
> > 
> > but, if admin have memory expection, they should be able to tune
> > optimal oom result.
> > 
> > I think you pointed right thing.
> > 
> 
> This is mostly referring to production server users where memory 
> consumption by particular applications can be estimated, which allows the 
> kernel to determine when a task is using a wildly unexpected amount that 
> happens to become egregious enough to force the oom killer into killing a 
> task.
> 
> That is contrast to using rss as a baseline where we prefer on killing the 
> application with the most resident RAM.  It is not always ideal to kill a 
> task with 8GB of rss when we fail to allocate a single page for a low 
> priority task.

VSZ has the same problem if low priority task allocate last single page.


> > >  - we must prefer tasks that run on a cpuset or mempolicy's nodes if the 
> > >    oom condition is constrained by that cpuset or mempolicy and its not a
> > >    system-wide issue.
> > 
> > agreed. (who disagree it?)
> > 
> 
> It's possible to nullify the current penalization in the badness heuristic 
> (order 3 reduction) if a candidate task does not share nodes with 
> current's allowed set either by way of cpusets or mempolicies.  For 
> example, an oom caused by an application with an MPOL_BIND on a single 
> node can easily kill a task that has no memory resident on that node if 
> its usage (or rss) is 3 orders higher than any candidate that is allowed 
> on my bound node.

yes, possible. however its heuristic is intensional. the code comment says:

        /*
         * If p's nodes don't overlap ours, it may still help to kill p
         * because p may have allocated or otherwise mapped memory on
         * this node before. However it will be less likely.
         */

do you have alternative plan? How do we know the task don't have any
page in memory busted node? we can't add any statistics for oom because
almost systems never ever use oom. thus, many developer oppose such slowdown.


> > >  - we must be able to polarize the badness heuristic to always select a
> > >    particular task is if its very low priority or disable oom killing for
> > >    a task if its must-run.
> > 
> > Probably I haven't catch your point. What's mean "polarize"? Can you
> > please describe more?
> 
> We need to be able to polarize tasks so they are always killed regardless 
> of any kernel heuristic (/proc/pid/oom_adj of +15, currently) or always 
> chosen last (-16, currently).  We also need a way of completely disabling 
> oom killing for certain tasks such as with OOM_DISABLE.

afaik, when admin use +15 or -16 adjustment, usually they hope to don't use
kernel heuristic. This is the reason that I proposed /proc/pid/oom_priority
new tunable knob.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
