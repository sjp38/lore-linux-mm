Subject: Re: [PATCH/RFC 3/5] Mem Policy:  MPOL_PREFERRED fixups for "local
	allocation"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0709121507170.3835@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <20070830185114.22619.61260.sendpatchset@localhost>
	 <1189537099.32731.92.camel@localhost> <1189535671.5036.71.camel@localhost>
	 <Pine.LNX.4.64.0709121507170.3835@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 13 Sep 2007 09:51:28 -0400
Message-Id: <1189691488.5013.36.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-12 at 15:10 -0700, Christoph Lameter wrote:
> On Tue, 11 Sep 2007, Lee Schermerhorn wrote:
> 
> > > >  	case MPOL_PREFERRED:
> > > > -		/* or use current node instead of memory_map? */
> > > > +		/*
> > > > +		 * for "local policy", return allowed memories
> > > > +		 */
> > > >  		if (p->v.preferred_node < 0)
> > > > -			*nodes = node_states[N_HIGH_MEMORY];
> > > > +			*nodes = cpuset_current_mems_allowed;
> > > 
> > > Is this change intentional? It looks like something that belongs as part
> > > of the the memoryless patch set.
> > > 
> > 
> > Absolutely intentional.  The use of 'node_states[N_HIGH_MEMORY]' was
> > added by the memoryless nodes patches.  Formerly, this was
> > 'node_online_map'.  However, even this results in misleading info for
> > tasks running in a cpuset.  
> 
> Sort of. This just means that the policy does not restrict the valid 
> nodes. The cpuset does. I think this is okay but we may be confusing users 
> as to which mechanism performs the restriction.
>  
> > It's a fine, point, but I think this is "more correct" that the existing
> > code.  I'm hoping that this change, with a corresponding man page update
> > will head off some head scratching and support calls down the road.
> 
> How does this sync with the nodemasks used by other policies? So far we 
> are using a sort of cpuset agnostic nodeset and limit it when it is 
> applied. 

Not exactly:  set_mempolicy() calls "contextualize_policy()" that
returns an error if the nodemask is not a subset of mems_allowed; and
then calls mpol_check_policy() to further vet the syscall args.

Now, I see that sys_mbind() does just AND the nodemask with
mems_allowed.  So, it won't give an error.

Should these be the same?  If so, which way:  error or silently mask off
dis-allowed nodes?  The latter doesn't let the user know what's going
on, but with my new MPOL_F_MEMS_ALLOWED flag, a user can query the
allowed nodes.  And, I can update the man pages to state exactly what
happens.  So, how about:

1) changing contextualize_policy() to mask off dis-allowed nodes rather
than giving an error  [this is a change in behavior for
set_mempolicy()], and

2) changing mbind() to use contextualize_policy() like
set_mempolicy()--no change in behavior here.

Thoughts?

> I think the integration between cpuset and memory policies could 
> use some work and this is certainly something valid to do. Is there any 
> way to describe that and have output that clarifies that distinction and 
> helps the user figure out what is going on?

Man pages can/will be updated and the ability to query allowed nodes
should provide the necessary info.  Would this satisfy your concern?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
