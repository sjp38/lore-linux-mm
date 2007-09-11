Subject: Re: [PATCH/RFC 5/5] Mem Policy:  add MPOL_F_MEMS_ALLOWED
	get_mempolicy() flag
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1189537679.32731.97.camel@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <20070830185130.22619.93436.sendpatchset@localhost>
	 <1189537679.32731.97.camel@localhost>
Content-Type: text/plain
Date: Tue, 11 Sep 2007 14:42:59 -0400
Message-Id: <1189536179.5036.76.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-09-11 at 20:07 +0100, Mel Gorman wrote:
> On Thu, 2007-08-30 at 14:51 -0400, Lee Schermerhorn wrote:
> > PATCH/RFC 05/05 -  add MPOL_F_MEMS_ALLOWED get_mempolicy() flag
> > 
> > Against:  2.6.23-rc3-mm1
> > 
> > Allow an application to query the memories allowed by its context.
> > 
> 
> I think you may be underplaying the significance of this patch here.
> >From what understand, an application that is only policy aware can run
> inside a cpuset and think it can use nodes it's not allowed. If that is
> right, then the language here implies that a policy-aware application
> can now get useful information without going through complicated hoops.
> That is pretty important.

I thought so.  In my memtoy test program, I tried to find a way to get
this info with just the existing APIs--i.e., without diving into the
cpuset file system [even with library wrappers]--and couldn't.  Having
convinced myself that this can't break existing apps--they can't use
undefined flags w/o getting an error--it seemed like the way to go.

> 
> > Updated numa_memory_policy.txt to mention that applications can use this
> > to obtain allowed memories for constructing valid policies.
> >
> > TODO:  update out-of-tree libnuma wrapper[s], or maybe add a new 
> > wrapper--e.g.,  numa_get_mems_allowed() ?
> > 
> > Tested with memtoy V>=0.13.
> > 
> > Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  Documentation/vm/numa_memory_policy.txt |   28 +++++++++++-----------------
> >  include/linux/mempolicy.h               |    1 +
> >  mm/mempolicy.c                          |   14 +++++++++++++-
> >  3 files changed, 25 insertions(+), 18 deletions(-)
> > 
> > Index: Linux/include/linux/mempolicy.h
> > ===================================================================
> > --- Linux.orig/include/linux/mempolicy.h	2007-08-29 11:44:18.000000000 -0400
> > +++ Linux/include/linux/mempolicy.h	2007-08-29 11:45:23.000000000 -0400
> > @@ -26,6 +26,7 @@
> >  /* Flags for get_mem_policy */
> >  #define MPOL_F_NODE	(1<<0)	/* return next IL mode instead of node mask */
> >  #define MPOL_F_ADDR	(1<<1)	/* look up vma using address */
> > +#define MPOL_F_MEMS_ALLOWED (1<<2) /* return allowed memories */
> >  
> >  /* Flags for mbind */
> >  #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
> > Index: Linux/mm/mempolicy.c
> > ===================================================================
> > --- Linux.orig/mm/mempolicy.c	2007-08-29 11:45:09.000000000 -0400
> > +++ Linux/mm/mempolicy.c	2007-08-29 11:45:23.000000000 -0400
> > @@ -560,8 +560,20 @@ static long do_get_mempolicy(int *policy
> >  	struct mempolicy *pol = current->mempolicy;
> >  
> >  	cpuset_update_task_memory_state();
> > -	if (flags & ~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR))
> > +	if (flags &
> > +		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
> >  		return -EINVAL;
> > +
> > +	if (flags & MPOL_F_MEMS_ALLOWED) {
> > +		if (flags & (MPOL_F_NODE|MPOL_F_ADDR))
> > +			return -EINVAL;
> > +		*policy = 0;	/* just so it's initialized */
> > +		if (!nmask)
> > +			return -EFAULT;
> > +		*nmask  = cpuset_current_mems_allowed;
> > +		return 0;
> > +	}
> > +
> 
> Seems a fair implementation.

Except that I don't need the test of nmask.  This is a lower level
function.  sys_get_mempolicy() always passes a non-NULL pointer to an
on-stack nodemask.  I realized this mistake after I'd sent the patches.
Fixed in my tree.

Thanks, again,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
