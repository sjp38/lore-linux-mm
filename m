Subject: Re: [PATCH/RFC] 2.6.23-rc1-mm1:  MPOL_PREFERRED fixups for
	preferred_node < 0
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070731153227.GB18506@skynet.ie>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <1185831537.5492.109.camel@localhost> <1185832846.5492.116.camel@localhost>
	 <20070731153227.GB18506@skynet.ie>
Content-Type: text/plain
Date: Tue, 31 Jul 2007 11:58:07 -0400
Message-Id: <1185897487.6240.29.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-31 at 16:32 +0100, Mel Gorman wrote:
> On (30/07/07 18:00), Lee Schermerhorn didst pronounce:
> > On Mon, 2007-07-30 at 17:38 -0400, Lee Schermerhorn wrote:
> > > These are some "issues" that I came across working on the Memoryless
> > > Node series.  I'm using the same cc: list as that series as the issues
> > > are somewhat related.
> > > 
> > > Only boot tested at this point.
> > 
> > I sent the wrong patch--forgot to refresh before posting :-(.  Bogus
> > code in mpol_to_str() in previous patch.
> > 
> > Try this one.
> > 
> > Lee
> > 
> > > ---------------------------
> > 
> > PATCH/RFC - MPOL_PREFERRED fixups for "local allocation"
> > 
> > Here are a couple of potential "fixups" for MPOL_PREFERRED behavior
> > when v.preferred_node < 0 -- i.e., "local allocation":
> > 
> > 1)  [do_]get_mempolicy() calls the misnamed get_zonemask() to fetch the
> >     nodemask associated with a policy.  Currently, get_zonemask() returns
> >     the set of nodes with memory, when the policy 'mode' is 'PREFERRED,
> 
> Consider a cleanup that renames get_zonemask because the naming is
> misleading.

I can do that.  Wanted to hear from others, such as yourself first.

> 
> >     and the preferred_node is < 0.  Return the set of allowed nodes
> >     instead.  This will already have been masked to include only nodes
> >     with memory.
> > 
> > 2)  When a task is moved into a [new] cpuset, mpol_rebind_policy() is
> >     called to adjust any task and vma policy nodes to be valid in the
> >     new cpuset.  However, when the policy is MPOL_PREFERRED, and the
> >     preferred_node is <0, no rebind is necessary.  The "local allocation"
> >     indication is valid in any cpuset.
> > 
> > 3)  mpol_to_str() produces a printable, "human readable" string from a
> >     struct mempolicy.  For MPOL_PREFERRED with preferred_node <0,  show
> >     the entire set of valid nodes.  Although, technically, MPOL_PREFERRED
> >     takes only a single node, preferred_node <0 is a local allocation policy,
> >     with the preferred node determined by the context where the task
> >     is executing.  All of the allowed nodes are possible, as the task
> >     migrates amoung the nodes in the cpuset.
> > 
> > Comments?
> > 
> > Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  mm/mempolicy.c |   31 ++++++++++++++++++++++++-------
> >  1 file changed, 24 insertions(+), 7 deletions(-)
> > 
> > Index: Linux/mm/mempolicy.c
> > ===================================================================
> > --- Linux.orig/mm/mempolicy.c	2007-07-30 17:32:06.000000000 -0400
> > +++ Linux/mm/mempolicy.c	2007-07-30 17:38:17.000000000 -0400
> > @@ -494,9 +494,11 @@ static void get_zonemask(struct mempolic
> >  		*nodes = p->v.nodes;
> >  		break;
> >  	case MPOL_PREFERRED:
> > -		/* or use current node instead of memory_map? */
> > +		/*
> > +		 * for "local policy", return allowed memories
> > +		 */
> >  		if (p->v.preferred_node < 0)
> > -			*nodes = node_states[N_MEMORY];
> > +			*nodes = cpuset_current_mems_allowed;
> >  		else
> 
> Is this actually a bugfix? From this context, it looks like memory
> policies using MPOL_PREFERRED can ignore cpusets.

Not a serious bug, if it is one.  More of a cleanup.   All this does is
return a node mask in the case where the application has a task memory
policy of 'PREFERRED with a node id of -1 [which happens when you
specify an empty nodemask to set_mempolicy() or mbind()].  This means
"local allocation"--the actual "current node id" is fetched at
allocation time.  This is a little know "feature" of get_mempolicy().
The results is misleading, but there isn't much the application can do
with it.  Node masks are ANDed with cpuset_current_mems_allowed when
installed via a syscall.

> 
> >  			node_set(p->v.preferred_node, *nodes);
> >  		break;
> > @@ -1650,6 +1652,7 @@ void mpol_rebind_policy(struct mempolicy
> >  {
> >  	nodemask_t *mpolmask;
> >  	nodemask_t tmp;
> > +	int nid;
> >  
> >  	if (!pol)
> >  		return;
> > @@ -1668,9 +1671,15 @@ void mpol_rebind_policy(struct mempolicy
> >  						*mpolmask, *newmask);
> >  		break;
> >  	case MPOL_PREFERRED:
> > -		pol->v.preferred_node = node_remap(pol->v.preferred_node,

Ultimately, node_remap() [the bitmap functions it calls] will return the
old value of "-1" because it's outside the valid range for a the node
bitmasks.  However, it doesn't seem right to be calling node_remap()
with an invalid node id.  I think it's clearer this way:

> > +		/*
> > +		 * no need to remap "local policy"
> > +		 */
> > +		nid = pol->v.preferred_node;
> > +		if (nid >= 0) {
> > +			pol->v.preferred_node = node_remap(nid,
> >  						*mpolmask, *newmask);
> > -		*mpolmask = *newmask;
> > +			*mpolmask = *newmask;
> > +		}
> >  		break;
> >  	case MPOL_BIND: {
> >  		nodemask_t nodes;
> > @@ -1745,7 +1754,7 @@ static const char * const policy_types[]
> >  static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
> >  {
> >  	char *p = buffer;
> > -	int l;
> > +	int nid, l;
> >  	nodemask_t nodes;
> >  	int mode = pol ? pol->policy : MPOL_DEFAULT;
> >  
> > @@ -1755,8 +1764,16 @@ static inline int mpol_to_str(char *buff
> >  		break;
> >  
> >  	case MPOL_PREFERRED:
> > -		nodes_clear(nodes);
> > -		node_set(pol->v.preferred_node, nodes);

Here, I think set_bit() will set bit 31.  Again, misleading, IMO.

> > +		nid = pol->v.preferred_node;
> > +		/*
> > +		 * local interleave, show all valid nodes
> > +		 */
> > +		if (nid < 0 )
> > +			nodes = cpuset_current_mems_allowed;
> > +		else {
> > +			nodes_clear(nodes);
> > +			node_set(nid, nodes);
> > +		}
> >  		break;
> >  
> >  	case MPOL_BIND:
> > 
> 
> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
