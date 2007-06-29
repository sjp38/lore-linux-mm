Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706281835270.9573@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <1182968078.4948.30.camel@localhost>
	 <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
	 <200706280001.16383.ak@suse.de> <1183038137.5697.16.camel@localhost>
	 <Pine.LNX.4.64.0706281835270.9573@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 09:22:27 -0400
Message-Id: <1183123347.5037.17.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-28 at 18:39 -0700, Christoph Lameter wrote:
> On Thu, 28 Jun 2007, Lee Schermerhorn wrote:
> 
> > Avoid the taking the reference count on the system default policy or the
> > current task's task policy.  Note that if show_numa_map() is called from
> > the context of a relative of the target task with the same task mempolicy,
> > we won't take an extra reference either.  This is safe, because the policy
> > remains referenced by the calling task during the mpol_to_str() processing.
> 
> I still do not see the rationale for this patchset. This adds more special 
> casing. So if we have a vma policy then we suck again?

I'm not sure what you mean by "rationale for this patchset" in the
context of this reference counting patch.  We've already gone over the
rationale for shared policy on shared file mappings--over and over...

Here, I'm just trying to show how we could handle the reference counting
problem in the context of my patch series where I've factored out the
"allocate a page given a policy and offset [for interleaving]" where
it's convenient to release the reference.  I'm trying to help ;-).

Will referencing a vma policy suck?  Maybe for a while, on a
multi-threaded program with a huge anon area with vma policy and
multiple tasks/threads all faulting different pages at the same time.
But, this activity HAS to die out when the entire region has been
faulted in--UNLESS the entire region won't fit in memory.  Then, you'll
be swapping your brains out and the reference count on the policy will
be the least of your problems performance-wise.

> 
> This all still falls under the category of messing up a bad situation even 
> more. Its first necessary to come up with way to consistently handle 
> memory policies and improve the interaction with other methods to 
> constrain allocations (cpusets, node restrictions for hugetlb etc etc). It 
> should improve the situation and not increase special casing or make the 
> system more unpreditable.

I understand that this is your opinion.  It does seem orthogonal to
corrently reference counting shared data structures, tho'.  In that
respect, I think it is "improving the situation".  As far as special
casing:  I was just trying to minimize the effect of reference counting
on the common case of system default and task policy.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
