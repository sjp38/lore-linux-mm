Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 185F96B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 05:05:10 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id nBIA54lr028706
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 02:05:05 -0800
Received: from pxi33 (pxi33.prod.google.com [10.243.27.33])
	by spaceape14.eur.corp.google.com with ESMTP id nBIA4lf0019850
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 02:05:01 -0800
Received: by pxi33 with SMTP id 33so1910381pxi.10
        for <linux-mm@kvack.org>; Fri, 18 Dec 2009 02:04:59 -0800 (PST)
Date: Fri, 18 Dec 2009 02:04:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.2
In-Reply-To: <20091218094359.652F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912180158040.26019@chino.kir.corp.google.com>
References: <20091215135902.CDD6.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0912171412280.4089@chino.kir.corp.google.com> <20091218094359.652F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Dec 2009, KOSAKI Motohiro wrote:

> > That is contrast to using rss as a baseline where we prefer on killing the 
> > application with the most resident RAM.  It is not always ideal to kill a 
> > task with 8GB of rss when we fail to allocate a single page for a low 
> > priority task.
> 
> VSZ has the same problem if low priority task allocate last single page.
> 

I don't understand what you're trying to say, sorry.  Why, in your mind, 
do we always want to prefer to kill the application with the largest 
amount of memory present in physical RAM for a single, failed order-0 
allocation attempt from a lower priority task?

Additionally, when would it be sufficient to simply fail a ~__GFP_NOFAIL 
allocation instead of killing anything?

> yes, possible. however its heuristic is intensional. the code comment says:
> 
>         /*
>          * If p's nodes don't overlap ours, it may still help to kill p
>          * because p may have allocated or otherwise mapped memory on
>          * this node before. However it will be less likely.
>          */
> 
> do you have alternative plan? How do we know the task don't have any
> page in memory busted node? we can't add any statistics for oom because
> almost systems never ever use oom. thus, many developer oppose such slowdown.
> 

There's nothing wrong with that currently (except it doesn't work for 
mempolicies), I'm stating that it is a requirement that we keep such a 
penalization in our heuristic if we plan on rewriting it.  I was 
attempting to get a list of requirements for oom killing decisions so that 
we can write a sane heuristic and you're simply defending the status quo 
which you insist we should change.

> > We need to be able to polarize tasks so they are always killed regardless 
> > of any kernel heuristic (/proc/pid/oom_adj of +15, currently) or always 
> > chosen last (-16, currently).  We also need a way of completely disabling 
> > oom killing for certain tasks such as with OOM_DISABLE.
> 
> afaik, when admin use +15 or -16 adjustment, usually they hope to don't use
> kernel heuristic.

That's exactly what I said above.

> This is the reason that I proposed /proc/pid/oom_priority
> new tunable knob.
> 

In addition to /proc/pid/oom_adj??  oom_priority on it's own does not 
allow us to define when a task is a memory leaker based on the expected 
memory consumption of a single application.  That should be the single 
biggest consideration in the new badness heuristic: to define when a task 
should be killed because it is rogue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
