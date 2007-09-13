Date: Thu, 13 Sep 2007 10:55:14 +0100
Subject: Re: [PATCH/RFC 3/5] Mem Policy:  MPOL_PREFERRED fixups for "local allocation"
Message-ID: <20070913095514.GD22778@skynet.ie>
References: <20070830185053.22619.96398.sendpatchset@localhost> <20070830185114.22619.61260.sendpatchset@localhost> <1189537099.32731.92.camel@localhost> <1189535671.5036.71.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1189535671.5036.71.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (11/09/07 14:34), Lee Schermerhorn didst pronounce:
> On Tue, 2007-09-11 at 19:58 +0100, Mel Gorman wrote:
> > On Thu, 2007-08-30 at 14:51 -0400, Lee Schermerhorn wrote:
> > > PATCH/RFC 03/05 - MPOL_PREFERRED cleanups for "local allocation" - V4
> > > 
> > > Against: 2.6.23-rc3-mm1
> > > 
> > > V3 -> V4:
> > > +  updated Documentation/vm/numa_memory_policy.txt to better explain
> > >    [I think] the "local allocation" feature of MPOL_PREFERRED.
> > > 
> > > V2 -> V3:
> > > +  renamed get_nodemask() to get_policy_nodemask() to more closely
> > >    match what it's doing.
> > > 
> > > V1 -> V2:
> > > +  renamed get_zonemask() to get_nodemask().  Mel Gorman suggested this
> > >    was a valid "cleanup".
> > > 
> > > Here are a couple of "cleanups" for MPOL_PREFERRED behavior
> > > when v.preferred_node < 0 -- i.e., "local allocation":
> > > 
> > > 1)  [do_]get_mempolicy() calls the now renamed get_policy_nodemask()
> > >     to fetch the nodemask associated with a policy.  Currently,
> > >     get_policy_nodemask() returns the set of nodes with memory, when
> > >     the policy 'mode' is 'PREFERRED, and the preferred_node is < 0.
> > >     Return the set of allowed nodes instead.  This will already have
> > >     been masked to include only nodes with memory.
> > > 
> > 
> > Better name all right.
> 
> :-) That's why you suggested it, right?
> 

I did? Probably why I like it then :)

> <snip>
> 
> > > Index: Linux/mm/mempolicy.c
> > > ===================================================================
> > > --- Linux.orig/mm/mempolicy.c	2007-08-30 13:20:13.000000000 -0400
> > > +++ Linux/mm/mempolicy.c	2007-08-30 13:36:04.000000000 -0400
> > > @@ -486,8 +486,10 @@ static long do_set_mempolicy(int mode, n
> > >  	return 0;
> > >  }
> > >  
> > > -/* Fill a zone bitmap for a policy */
> > > -static void get_zonemask(struct mempolicy *p, nodemask_t *nodes)
> > > +/*
> > > + * Return a node bitmap for a policy
> > > + */
> > > +static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
> > >  {
> > >  	int i;
> > >  
> > > @@ -502,9 +504,11 @@ static void get_zonemask(struct mempolic
> > >  		*nodes = p->v.nodes;
> > >  		break;
> > >  	case MPOL_PREFERRED:
> > > -		/* or use current node instead of memory_map? */
> > > +		/*
> > > +		 * for "local policy", return allowed memories
> > > +		 */
> > >  		if (p->v.preferred_node < 0)
> > > -			*nodes = node_states[N_HIGH_MEMORY];
> > > +			*nodes = cpuset_current_mems_allowed;
> > 
> > Is this change intentional? It looks like something that belongs as part
> > of the the memoryless patch set.
> > 
> 
> Absolutely intentional.  The use of 'node_states[N_HIGH_MEMORY]' was
> added by the memoryless nodes patches.  Formerly, this was
> 'node_online_map'.  However, even this results in misleading info for
> tasks running in a cpuset.  
> 

Right, because the map would contain nodes outside of the cpuset which
is very misleading.

> When a task queries its memory policy via get_mempolicy(2), and the
> policy is MPOL_PREFERRED with the '-1' policy node--i.e., local
> allocation--the memory can come from any node from which the task is
> allowed to allocate.   Initially it will try to allocate only from nodes
> containing cpus on which the task is allowed to execute.  But, the
> allocation could overflow onto some other node allowed in the cpuset.
> 
> It's a fine, point, but I think this is "more correct" that the existing
> code.  I'm hoping that this change, with a corresponding man page update
> will head off some head scratching and support calls down the road.
> 

I agree. The change just seemed out-of-context in this patchset so I
thought I would flag it in case it had creeped in from another patchset
by accident.

Thanks for the clarification

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
