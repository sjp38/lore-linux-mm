Date: Thu, 13 Sep 2007 10:48:44 +0100
Subject: Re: [PATCH/RFC 2/5] Mem Policy:  Use MPOL_PREFERRED for system-wide default policy
Message-ID: <20070913094844.GC22778@skynet.ie>
References: <20070830185053.22619.96398.sendpatchset@localhost> <20070830185107.22619.43577.sendpatchset@localhost> <1189536857.32731.90.camel@localhost> <1189534923.5036.58.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1189534923.5036.58.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (11/09/07 14:22), Lee Schermerhorn didst pronounce:
> On Tue, 2007-09-11 at 19:54 +0100, Mel Gorman wrote:
> > On Thu, 2007-08-30 at 14:51 -0400, Lee Schermerhorn wrote:
> > > PATCH/RFC 2/5 Use MPOL_PREFERRED for system-wide default policy
> > > 
> > > Against:  2.6.23-rc3-mm1
> > > 
> > > V1 -> V2:
> > > + restore BUG()s in switch(policy) default cases -- per
> > >   Christoph
> > > + eliminate unneeded re-init of struct mempolicy policy member
> > >   before freeing
> > > 
> > > Currently, when one specifies MPOL_DEFAULT via a NUMA memory
> > > policy API [set_mempolicy(), mbind() and internal versions],
> > > the kernel simply installs a NULL struct mempolicy pointer in
> > > the appropriate context:  task policy, vma policy, or shared
> > > policy.  This causes any use of that policy to "fall back" to
> > > the next most specific policy scope.  The only use of MPOL_DEFAULT
> > > to mean "local allocation" is in the system default policy.
> > > 
> > 
> > In general, this seems like a good idea. It's certainly simplier to
> > always assume a policy exists because it discourages "bah, I don't care
> > about policies" style of thinking.
> 
> More importantly, IMO, it eliminates 2 meanings for MPOL_DEFAULT in
> different contexts and promotes the use 0f [MPOL_PREFERRED,
> -1/null-nodemask] for local allocation.  I think this makes the
> resulting documentation clearer.
> 

That's a fair point.

> <snip>
> > > 
> > > Index: Linux/mm/mempolicy.c
> > > ===================================================================
> > > --- Linux.orig/mm/mempolicy.c	2007-08-29 11:43:06.000000000 -0400
> > > +++ Linux/mm/mempolicy.c	2007-08-29 11:44:03.000000000 -0400
> > > @@ -105,9 +105,13 @@ static struct kmem_cache *sn_cache;
> > >     policied. */
> > >  enum zone_type policy_zone = 0;
> > >  
> > > +/*
> > > + * run-time system-wide default policy => local allocation
> > > + */
> > >  struct mempolicy default_policy = {
> > >  	.refcnt = ATOMIC_INIT(1), /* never free it */
> > > -	.policy = MPOL_DEFAULT,
> > > +	.policy = MPOL_PREFERRED,
> > > +	.v =  { .preferred_node =  -1 },
> > >  };
> > >  
> > 
> > fairly clear.
> > 
> > >  static void mpol_rebind_policy(struct mempolicy *pol,
> > > @@ -180,7 +184,8 @@ static struct mempolicy *mpol_new(int mo
> > >  		 mode, nodes ? nodes_addr(*nodes)[0] : -1);
> > >  
> > >  	if (mode == MPOL_DEFAULT)
> > > -		return NULL;
> > > +		return NULL;	/* simply delete any existing policy */
> > > +
> > 
> > Why do we not return default_policy and insert that into the VMA or
> > whatever?
> > 
> 
> Because then, if we're installing a shared policy [shmem], we'll go
> ahead and create an rb-node and insert the [default] policy in the tree
> in the shared policy struct, instead of just deleting any policy ranges
> that the new policy covers.  Andi already implemented the code to delete
> shared policy ranges covered by a subsequent null/default policy.  I
> like this approach.
> 

Right, thanks for clearing this up.

> I have additional patches, to come later, that dynamically allocate the
> shared policy structure when a non-null [non-default] policy is
> installed.  At some point, I plan on enhancing this to to use a single
> policy pointer, instead of the shared policy struct, when the policy
> covers the entire object range, and delete any existing shared policy
> struct when/if a default policy covers the entire range.
> 

It sounds reasonable. I don't know the policy code well enough to say if
it's a good idea but it certainly seems like one.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
