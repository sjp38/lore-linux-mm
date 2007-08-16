Subject: Re: [PATCH] Use MPOL_PREFERRED for system default policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708161337520.18094@schroedinger.engr.sgi.com>
References: <1187120671.6281.67.camel@localhost>
	 <Pine.LNX.4.64.0708161337520.18094@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 16 Aug 2007 17:05:49 -0400
Message-Id: <1187298350.5900.59.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-16 at 13:49 -0700, Christoph Lameter wrote:
> On Tue, 14 Aug 2007, Lee Schermerhorn wrote:
> 
> > There is another, "preferred" way to specify local allocation via
> > the APIs.  That is using the MPOL_PREFERRED policy mode with an
> > empty nodemask.  Internally, the empty nodemask gets converted to
> > a preferred_node id of '-1'.  All internal usage of MPOL_PREFERRED
> > will convert the '-1' to the local node id.
> 
> But the comparison with an MPOL_PREFERRED policy is different from
> comparing with a MPOL_DEFAULT policy. MPOL_DEFAULT matches any other
> policy. MPOL_PREFERRED only matches other MPOL_DEFERRED policies.

MPOL_DEFAULT doesn't match anything but itself.  Everywhere but in the
system default policy, specifying MPOL_DEFAULT means "delete the current
policy [task or vma] and replace it with a null pointer.  Again, the
only place that MPOL_DEFAULT actually occurs in a struct mempolicy is in
the system default policy.  By changing that, I can eliminate the
MPOL_DEFAULT checks in the run time [allocation path] use of mempolicy.

> 
> > Now, system default policy, except during boot, is "local 
> > allocation".  By using the MPOL_PREFERRED mode with a negative
> > value of preferred node for system default policy, MPOL_DEFAULT
> > will never occur in the 'policy' member of a struct mempolicy.
> > Thus, we can remove all checks for MPOL_DEFAULT when converting
> > policy to a node id/zonelist in the allocation paths.
> 
> So we can also avoid having to check for NULL pointers?

No, we still check for them, just as we always have been.  Look at
get_vma_policy().  I removed the check for MPOL_DEFAULT because it never
occured in vma policies.  But, NULL vma policy means fall back to task
policy.  NULL task policy means fall back to system default.  Just as it
always has

> 
> > Note:  in slab_node() I kept the use of MPOL_DEFAULT when the
> > policy pointer is NULL to force the switch to take the default:
> > case.  This seemed more efficient than pointing policy at the
> > system default, and having to deref that.  Any value not covered
> > by one of the existing case's would have served, but MPOL_DEFAULT
> > is guaranteed to be a different value from any of the other MPOL_*
> > handled explicitly by the switch.
> 
> >  static void mpol_rebind_policy(struct mempolicy *pol,
> > @@ -492,8 +496,6 @@ static void get_zonemask(struct mempolic
> >  			node_set(zone_to_nid(p->v.zonelist->zones[i]),
> >  				*nodes);
> >  		break;
> > -	case MPOL_DEFAULT:
> > -		break;
> >  	case MPOL_INTERLEAVE:
> >  		*nodes = p->v.nodes;
> >  		break;
> > @@ -505,7 +507,11 @@ static void get_zonemask(struct mempolic
> >  			node_set(p->v.preferred_node, *nodes);
> >  		break;
> >  	default:
> > -		BUG();
> > +		/*
> > +		 * shouldn't happen
> > +		 */
> > +		WARN_ON_ONCE(1);
> > +		node_set(numa_node_id(), *nodes);
> 
> Safety features? Are these triggered? Could we leave the BUG() in?

I haven't seen them triggered.  I'm hoping that testing in -mm will not
hit them either.  I suppose we could leave the BUG.  Seems a bit drastic
for this case, where we have a reasonable fallback.  But, the BUG will
more likely get someone's attention, I suppose :-).

> 
> > @@ -1087,8 +1093,7 @@ static struct mempolicy * get_vma_policy
> >  	if (vma) {
> >  		if (vma->vm_ops && vma->vm_ops->get_policy)
> >  			pol = vma->vm_ops->get_policy(vma, addr);
> > -		else if (vma->vm_policy &&
> > -				vma->vm_policy->policy != MPOL_DEFAULT)
> > +		else if (vma->vm_policy)
> >  			pol = vma->vm_policy;
> >  	}
> >  	if (!pol)
> 
> Good

Yeah.  Eliminates the extra check in the case of a non-NULL vma policy.
I'm convinced that check was never true.

> 
> > @@ -1115,12 +1120,11 @@ static struct zonelist *zonelist_policy(
> >  				return policy->v.zonelist;
> >  		/*FALL THROUGH*/
> >  	case MPOL_INTERLEAVE: /* should not happen */
> 
> Hmmmm does the MPOL_INTERLEAVE happen at all? Does it also need a WARN_ON?
> 
> > @@ -1376,7 +1378,8 @@ void __mpol_free(struct mempolicy *p)
> >  		return;
> >  	if (p->policy == MPOL_BIND)
> >  		kfree(p->v.zonelist);
> > -	p->policy = MPOL_DEFAULT;
> > +	p->policy = MPOL_PREFERRED;
> > +	p->v.preferred_node = -1;
> 
> Why are we initializing values here in an object that is then freed?

I wondered that myself.  I think Andi was stuffing MPOL_DEFAULT "just in
case" or to NULL out the policy member.  I just replaced it so that I
was sure that MPOL_DEFAULT never occurs in a struct mempolicy.  We
always initialize the policy member when we alloc one, so I guess we can
drop the reinit here.

> 
> Otherwise looks okay.

Thanks.  I'll clean it up.  Next week.  Won't be on-line for a few days.

Later,
Lee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
