Date: Mon, 11 Feb 2008 18:05:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to
 allowed nodes V3
In-Reply-To: <20080212103944.29A9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.0802111757470.19213@chino.kir.corp.google.com>
References: <20080212091910.29A0.KOSAKI.MOTOHIRO@jp.fujitsu.com> <alpine.DEB.1.00.0802111649330.6119@chino.kir.corp.google.com> <20080212103944.29A9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, KOSAKI Motohiro wrote:

> > > I'm still deferring David Rientjes' suggestion to fold
> > > mpol_check_policy() into mpol_new().  We need to sort out whether
> > > mempolicies specified for tmpfs and hugetlbfs mounts always need the
> > > same "contextualization" as user/application installed policies.  I
> > > don't want to hold up this bug fix for that discussion.  This is
> > > something Paul J will need to address with his cpuset/mempolicy rework,
> > > so we can sort it out in that context.
> > > 
> > 
> > I took care of this in my patchset from this morning, so I think we can 
> > drop this disclaimer now.
> 
> Disagreed.
> 
> this patch is regression fixed patch.
> regression should fixed ASAP.
> 
> your patch is very nice patch.
> but it is feature enhancement.
> the feature enhancement should tested by many people in -mm tree for a while.
> 
> end up, timing of mainline merge is large different.
> 

I'm talking about the disclaimer that I quoted above in the changelog of 
this patch.  Lee was stating that he deferred my suggestion to move the 
logic into mpol_new(), which I did in my patchset, but I don't think that 
needs to be included in this patch's changelog.

I'm all for the merging of this patch (once my concern below is addressed) 
but the section of the changelog that is quoted above is unnecessary.

> > mpol_new() will not dynamically allocate a new mempolicy in that case 
> > anyway since it is the system default so the only reason why 
> > set_mempolicy(MPOL_DEFAULT, numa_no_nodes, ...) won't work is because of 
> > this addition to mpol_check_policy().
> > 
> > In other words, what is the influence to dismiss a MPOL_DEFAULT mempolicy 
> > request from a user as invalid simply because it includes set nodes in the 
> > nodemask?
> 
> Hmm..
> By which version are you testing?
> 

I'm talking about this section of the patch:

> @@ -116,22 +116,51 @@ static void mpol_rebind_policy(struct me
>  /* Do sanity checking on a policy */
>  static int mpol_check_policy(int mode, nodemask_t *nodes)
>  {
> -	int empty = nodes_empty(*nodes);
> +	int was_empty, is_empty;
> +
> +	if (!nodes)
> +		return 0;
> +
> +	/*
> +	 * "Contextualize" the in-coming nodemast for cpusets:
> +	 * Remember whether in-coming nodemask was empty,  If not,
> +	 * restrict the nodes to the allowed nodes in the cpuset.
> +	 * This is guaranteed to be a subset of nodes with memory.
> +	 */
> +	cpuset_update_task_memory_state();
> +	is_empty = was_empty = nodes_empty(*nodes);
> +	if (!was_empty) {
> +		nodes_and(*nodes, *nodes, cpuset_current_mems_allowed);
> +		is_empty = nodes_empty(*nodes);	/* after "contextualization" */
> +	}
>  
>  	switch (mode) {
>  	case MPOL_DEFAULT:
> -		if (!empty)
> +		/*
> +		 * require caller to specify an empty nodemask
> +		 * before "contextualization"
> +		 */
> +		if (!was_empty)
>  			return -EINVAL;

Even though it is obviously the old behavior as well, I want to know why 
we are rejecting MPOL_DEFAULT policies that are passed to either 
set_mempolicy() or mbind() with nodemasks that aren't empty.  MPOL_DEFAULT 
is a mempolicy in itself; it does not act on any passed nodemask.

So my question is why we consider this invalid:

	nodemask_t nodes;

	nodes_clear(&nodes);
	node_set(1, &nodes);
	set_mempolicy(MPOL_DEFAULT, nodes, 1 << CONFIG_NODES_SHIFT);

The nodemask doesn't matter at all with a MPOL_DEFAULT policy.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
