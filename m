Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 1/8 migrate task
	memory with default policy
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <Pine.LNX.4.64.0603131547020.13713@schroedinger.engr.sgi.com>
References: <1142019479.5204.15.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0603131547020.13713@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 14 Mar 2006 09:46:07 -0500
Message-Id: <1142347567.5235.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-03-13 at 15:52 -0800, Christoph Lameter wrote:
> On Fri, 10 Mar 2006, Lee Schermerhorn wrote:
> 
> > +/*
> > + * Migrate all eligible pages mapped in vma NOT on destination node to
> > + * the destination node.
> > + * Returns error or the number of pages not migrated.
> > + */
> > +static int migrate_vma_to_node(struct vm_area_struct *vma, int dest, int flags)
> > +{
> 
> This duplicates code in migrate_to_node().

Yes.  At this point, this is intentional.  I wanted to be able to see
what I'm doing.
More below...

> 
> > +/*
> > + * for filtering 'no access' segments
> > +TODO:  what are these?
> 
> ??
> 
> > +	down_read(&mm->mmap_sem);
> > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +		struct mempolicy *pol = get_vma_policy(current, vma,
> > +							 vma->vm_start);
> > +		int err;
> > +
> > +		if (pol->policy != MPOL_DEFAULT)
> > +			continue;
> > +		if (vma_no_access(vma))
> > +			continue;
> > +
> > +		// TODO:  more eligibility filtering?
> > +
> > +		// TODO:  more agressive migration ['MOVE_ALL] ?
> > +		//        via sysctl?
> > +		err = migrate_vma_to_node(vma, dest, MPOL_MF_MOVE);
> > +
> > +	}
> 
> Duplicates code in migrate_to_node().

Again, yes...  
> 
> Could you add some special casing instead to migrate_to_node and/or 
> check_range?

I think this could be done.  Don't know whether the results would be
"pretty" or not.

Currently, you'll note that I'm calling check_range for one vma at a
time.  I'm not sure this is a good idea.  It probably adds overhead
revisiting upper level page table pages many times.  But, I want to
compare different approaches.  If I use migrate_to_node() and it's call
to check_range(), I would have to have something like the above logic to
do the per vma stuff.   But, why per vma?  I agree it doesn't make a lot
of sense for the kernel build workload.  I find very few eligible pages
to migrate, so even if I scanned the entire mm at once, the resulting
page list would be very small.  However, I was concerned about tying up
a large number of pages, isolated from the LRU, for applications with
larger footprints.  I'm also going to experiment with more agressive
migration--i.e., selecting pages with >1 map counts.  This may result in
larger numbers of pages migrating.

But, I have thought about adding internal flags to steer different paths
through migrate_to_node() and check_range().  If we ever get serious
about including an automigration mechanism like this, I'll go ahead and
take a look at it.

Lee

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
