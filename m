Date: Thu, 16 Aug 2007 14:10:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Use MPOL_PREFERRED for system default policy
In-Reply-To: <1187298350.5900.59.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708161407590.18404@schroedinger.engr.sgi.com>
References: <1187120671.6281.67.camel@localhost>
 <Pine.LNX.4.64.0708161337520.18094@schroedinger.engr.sgi.com>
 <1187298350.5900.59.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Aug 2007, Lee Schermerhorn wrote:

> > But the comparison with an MPOL_PREFERRED policy is different from
> > comparing with a MPOL_DEFAULT policy. MPOL_DEFAULT matches any other
> > policy. MPOL_PREFERRED only matches other MPOL_DEFERRED policies.
> 
> MPOL_DEFAULT doesn't match anything but itself.  Everywhere but in the
> system default policy, specifying MPOL_DEFAULT means "delete the current
> policy [task or vma] and replace it with a null pointer.  Again, the
> only place that MPOL_DEFAULT actually occurs in a struct mempolicy is in
> the system default policy.  By changing that, I can eliminate the
> MPOL_DEFAULT checks in the run time [allocation path] use of mempolicy.

Look at mpol_equal(). If the policy to compare it MPOL_DEFAULT then it 
returns true. If its MPOL_PREFERRED then it requires a matching on the 
node. Wont your change break this?

> > Safety features? Are these triggered? Could we leave the BUG() in?
> 
> I haven't seen them triggered.  I'm hoping that testing in -mm will not
> hit them either.  I suppose we could leave the BUG.  Seems a bit drastic
> for this case, where we have a reasonable fallback.  But, the BUG will
> more likely get someone's attention, I suppose :-).

So you have never seen warnings in testing and there should not be any? 
Then leave the BUG() in. WARN is useful if there is something that another
developer could fix.

> > > @@ -1376,7 +1378,8 @@ void __mpol_free(struct mempolicy *p)
> > >  		return;
> > >  	if (p->policy == MPOL_BIND)
> > >  		kfree(p->v.zonelist);
> > > -	p->policy = MPOL_DEFAULT;
> > > +	p->policy = MPOL_PREFERRED;
> > > +	p->v.preferred_node = -1;
> > 
> > Why are we initializing values here in an object that is then freed?
> 
> I wondered that myself.  I think Andi was stuffing MPOL_DEFAULT "just in
> case" or to NULL out the policy member.  I just replaced it so that I
> was sure that MPOL_DEFAULT never occurs in a struct mempolicy.  We
> always initialize the policy member when we alloc one, so I guess we can
> drop the reinit here.

I'd say remove the useless assignements. They are confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
