Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 48089900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 16:19:18 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p3IKJGZR017138
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:19:16 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by kpbe20.cbf.corp.google.com with ESMTP id p3IKJCBm002206
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:19:14 -0700
Received: by pzk3 with SMTP id 3so3434258pzk.40
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:19:12 -0700 (PDT)
Date: Mon, 18 Apr 2011 13:19:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH incremental] cpusets: initialize spread rotor lazily
In-Reply-To: <20110418084248.GB8925@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1104181316110.31186@chino.kir.corp.google.com>
References: <20110414065146.GA19685@tiehlicka.suse.cz> <20110414160145.0830.A69D9226@jp.fujitsu.com> <20110415161831.12F8.A69D9226@jp.fujitsu.com> <20110415082051.GB8828@tiehlicka.suse.cz> <alpine.DEB.2.00.1104151639080.3967@chino.kir.corp.google.com>
 <20110418084248.GB8925@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Mon, 18 Apr 2011, Michal Hocko wrote:

> > It'd probably be better to just make an incremental patch on top of 
> > mmotm-2011-04-14-15-08 with a new changelog and then propose with with 
> > your list of reviewed-by lines.
> 
> Sure, no problems. Maybe it will be easier for Andrew as well.
> 
> > Andrew could easily drop the earlier version and merge this v2, but I'm 
> > asking for selfish reasons:
> 
> Just out of curiosity. What is the reason? Don't want to wait for new mmotm?
> 

Because lazy initialization is another feature on top of the existing 
patch so it should be done incrementally instead of proposing an entirely 
new patch which is already mostly in -mm.

> > please use NUMA_NO_NODE instead of -1.
> 
> Good idea. I have updated the patch.
> 

Thanks.

> Changes from v2:
>  - use NUMA_NO_NODE rather than hardcoded -1
>  - make the patch incremental to the original one because that one is in
>    -mm tree already.
> Changes from v1:
>  - initialize cpuset_{mem,slab}_spread_rotor lazily}
> 
> [Here is the follow-up patch based on top of
> http://userweb.kernel.org/~akpm/mmotm/broken-out/cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node.patch]
> ---
> From: Michal Hocko <mhocko@suse.cz>
> Subject: cpusets: initialize spread mem/slab rotor lazily
> 
> Kosaki Motohiro raised a concern that copy_process is hot path and we do
> not want to initialize cpuset_{mem,slab}_spread_rotor if they are not
> used most of the time.
> 
> I think that we should rather intialize it lazily when rotors are used
> for the first time.
> This will also catch the case when we set up spread mem/slab later.
> 
> Also do not use -1 for unitialized nodes and rather use NUMA_NO_NODE
> instead.
> 

Don't need to refer to a previous version that used -1 since it will never 
be committed and nobody will know what you're talking about in the git 
log.

> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  cpuset.c |    8 ++++++++
>  fork.c   |    4 ++--
>  2 files changed, 10 insertions(+), 2 deletions(-)
> Index: linus_tree/kernel/cpuset.c
> ===================================================================
> --- linus_tree.orig/kernel/cpuset.c	2011-04-18 10:33:15.000000000 +0200
> +++ linus_tree/kernel/cpuset.c	2011-04-18 10:33:56.000000000 +0200
> @@ -2460,11 +2460,19 @@ static int cpuset_spread_node(int *rotor
>  
>  int cpuset_mem_spread_node(void)
>  {
> +	if (current->cpuset_mem_spread_rotor == NUMA_NO_NODE)
> +		current->cpuset_mem_spread_rotor =
> +			node_random(&current->mems_allowed);
> +
>  	return cpuset_spread_node(&current->cpuset_mem_spread_rotor);
>  }
>  
>  int cpuset_slab_spread_node(void)
>  {
> +	if (current->cpuset_slab_spread_rotor == NUMA_NO_NODE)
> +		current->cpuset_slab_spread_rotor
> +			= node_random(&current->mems_allowed);
> +

So one function has the `=' on the line with the assignment (preferred) 
and the other has it on the new value?

>  	return cpuset_spread_node(&current->cpuset_slab_spread_rotor);
>  }
>  
> Index: linus_tree/kernel/fork.c
> ===================================================================
> --- linus_tree.orig/kernel/fork.c	2011-04-18 10:33:15.000000000 +0200
> +++ linus_tree/kernel/fork.c	2011-04-18 10:33:56.000000000 +0200
> @@ -1126,8 +1126,8 @@ static struct task_struct *copy_process(
>  	mpol_fix_fork_child_flag(p);
>  #endif
>  #ifdef CONFIG_CPUSETS
> -	p->cpuset_mem_spread_rotor = node_random(&p->mems_allowed);
> -	p->cpuset_slab_spread_rotor = node_random(&p->mems_allowed);
> +	p->cpuset_mem_spread_rotor = NUMA_NO_NODE;
> +	p->cpuset_slab_spread_rotor = NUMA_NO_NODE;
>  #endif
>  #ifdef CONFIG_TRACE_IRQFLAGS
>  	p->irq_events = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
