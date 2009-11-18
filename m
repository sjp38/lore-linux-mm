Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D53096B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 20:48:57 -0500 (EST)
Date: Wed, 18 Nov 2009 10:41:59 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with
 nodemask v4.2
Message-Id: <20091118104159.a754414f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com>
	<20091110162445.c6db7521.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110163419.361E.A69D9226@jp.fujitsu.com>
	<20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp>
	<20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com>
	<20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com>
	<20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com>
	<20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

On Tue, 17 Nov 2009 16:11:58 -0800 (PST), David Rientjes <rientjes@google.com> wrote:
> On Wed, 11 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Fixing node-oriented allocation handling in oom-kill.c
> > I myself think this as bugfix not as ehnancement.
> > 
> > In these days, things are changed as
> >   - alloc_pages() eats nodemask as its arguments, __alloc_pages_nodemask().
> >   - mempolicy don't maintain its own private zonelists.
> >   (And cpuset doesn't use nodemask for __alloc_pages_nodemask())
> > 
> > So, current oom-killer's check function is wrong.
> > 
> > This patch does
> >   - check nodemask, if nodemask && nodemask doesn't cover all
> >     node_states[N_HIGH_MEMORY], this is CONSTRAINT_MEMORY_POLICY.
> >   - Scan all zonelist under nodemask, if it hits cpuset's wall
> >     this faiulre is from cpuset.
> > And
> >   - modifies the caller of out_of_memory not to call oom if __GFP_THISNODE.
> >     This doesn't change "current" behavior. If callers use __GFP_THISNODE
> >     it should handle "page allocation failure" by itself.
> > 
> >   - handle __GFP_NOFAIL+__GFP_THISNODE path.
> >     This is something like a FIXME but this gfpmask is not used now.
> > 
> 
> Now that we're passing the nodemask into the oom killer, we should be able 
> to do more intelligent CONSTRAINT_MEMORY_POLICY selection.  current is not 
> always the ideal task to kill, so it's better to scan the tasklist and 
> determine the best task depending on our heuristics, similiar to how we 
> penalize candidates if they do not share the same cpuset.
> 
> Something like the following (untested) patch.  Comments?
I agree to this direction.

Taking into account the usage per node which is included in nodemask might be useful,
but we don't have per node rss counter per task now and it would add some overhead,
so I think this would be enough(at leaset for now).

Just a minor nitpick:

> @@ -472,7 +491,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  
>  	read_lock(&tasklist_lock);
>  retry:
> -	p = select_bad_process(&points, mem);
> +	p = select_bad_process(&points, mem, NULL);
>  	if (PTR_ERR(p) == -1UL)
>  		goto out;
>  
need to pass "CONSTRAINT_NONE" too.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
