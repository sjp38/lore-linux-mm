Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7286B004D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 10:15:48 -0400 (EDT)
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for
 mempolicy based management.
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090914133329.GC11778@csn.ul.ie>
References: <20090908104409.GB28127@csn.ul.ie>
	 <alpine.DEB.1.00.0909081241530.10542@chino.kir.corp.google.com>
	 <20090908200451.GA6481@csn.ul.ie>
	 <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com>
	 <20090908214109.GB6481@csn.ul.ie>
	 <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com>
	 <20090909081631.GB24614@csn.ul.ie>
	 <alpine.DEB.1.00.0909091335050.7764@chino.kir.corp.google.com>
	 <20090910122641.GA31153@csn.ul.ie>
	 <alpine.DEB.1.00.0909111507540.22083@chino.kir.corp.google.com>
	 <20090914133329.GC11778@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 14 Sep 2009 10:15:48 -0400
Message-Id: <1252937748.17132.111.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-09-14 at 14:33 +0100, Mel Gorman wrote:
> On Fri, Sep 11, 2009 at 03:27:30PM -0700, David Rientjes wrote:
> > On Thu, 10 Sep 2009, Mel Gorman wrote:
> > 
> > > > Would you explain why introducing a new mempolicy flag, MPOL_F_HUGEPAGES, 
> > > > and only using the new behavior when this is set would be inconsistent or 
> > > > inadvisible?
> > > 
> > > I already explained this. The interface in numactl would look weird. There
> > > would be an --interleave switch and a --hugepages-interleave that only
> > > applies to nr_hugepages. The smarts could be in hugeadm to apply the mask
> > > when --pool-pages-min is specified but that wouldn't help scripts that are
> > > still using echo.
> > > 
> > 
> > I don't think we need to address the scripts that are currently using echo 
> > since they're (hopefully) written to the kernel implementation, i.e. no 
> > mempolicy restriction on writing to nr_hugepages.
> > 
> 
> Ok.
> 
> > > I hate to have to do this, but how about nr_hugepages which acts
> > > system-wide as it did traditionally and nr_hugepages_mempolicy that obeys
> > > policies? Something like the following untested patch. It would be fairly
> > > trivial for me to implement a --obey-mempolicies switch for hugeadm which
> > > works in conjunction with --pool--pages-min and less likely to cause confusion
> > > than --hugepages-interleave in numactl.
> > > 
> > 
> > I like it.
> > 
> 
> Ok, when I get this tested, I'll sent it as a follow-on patch to Lee's
> for proper incorporation.
> 
> > > Sorry the patch is untested. I can't hold of a NUMA machine at the moment
> > > and fake NUMA support sucks far worse than I expected it to.
> > > 
> > 
> > Hmm, I rewrote most of fake NUMA a couple years ago.  What problems are 
> > you having with it?
> > 
> 
> On PPC64, the parameters behave differently. I couldn't convince it to
> create more than one NUMA node. On x86-64, the NUMA nodes appeared to
> exist and would be visible on /proc/buddyinfo for example but the sysfs
> directories for the fake nodes were not created so nr_hugepages couldn't
> be examined on a per-node basis for example.
> 
> > > ==== BEGIN PATCH ====
> > > 
> > > [PATCH] Optionally use a memory policy when tuning the size of the static hugepage pool
> > > 
> > > Patch "derive huge pages nodes allowed from task mempolicy" brought
> > > huge page support more in line with the core VM in that tuning the size
> > > of the static huge page pool would obey memory policies. Using this,
> > > administrators could interleave allocation of huge pages from a subset
> > > of nodes. This is consistent with how dynamic hugepage pool resizing
> > > works and how hugepages get allocated to applications at run-time.
> > > 
> > > However, it was pointed out that scripts may exist that depend on being
> > > able to drain all hugepages via /proc/sys/vm/nr_hugepages from processes
> > > that are running within a memory policy. This patch adds
> > > /proc/sys/vm/nr_hugepages_mempolicy which when written to will obey
> > > memory policies. /proc/sys/vm/nr_hugepages continues then to be a
> > > system-wide tunable regardless of memory policy.
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > --- 
> > >  include/linux/hugetlb.h |    1 +
> > >  kernel/sysctl.c         |   11 +++++++++++
> > >  mm/hugetlb.c            |   35 ++++++++++++++++++++++++++++++++---
> > >  3 files changed, 44 insertions(+), 3 deletions(-)
> > > 
> > 
> > It'll need an update to Documentation/vm/hugetlb.txt, but this can 
> > probably be done in one of Lee's patches that edits the same file when he 
> > reposts.
> > 
> 
> Agreed.

So, I'm respinning V7 today.  Shall I add this in as a separate patch?

Also, see below:


> 
> > > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > > index fcb1677..fc3a659 100644
> > > --- a/include/linux/hugetlb.h
> > > +++ b/include/linux/hugetlb.h
> > > @@ -21,6 +21,7 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
> > >  
> > >  void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
> > >  int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> > > +int hugetlb_mempolicy_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> > >  int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> > >  int hugetlb_treat_movable_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> > >  int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
> > > diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> > > index 8bac3f5..0637655 100644
> > > --- a/kernel/sysctl.c
> > > +++ b/kernel/sysctl.c
> > > @@ -1171,6 +1171,17 @@ static struct ctl_table vm_table[] = {
> > >  		.extra1		= (void *)&hugetlb_zero,
> > >  		.extra2		= (void *)&hugetlb_infinity,
> > >  	 },
> > > +#ifdef CONFIG_NUMA
> > > +	 {
> > > +		.procname	= "nr_hugepages_mempolicy",
> > > +		.data		= NULL,
> > > +		.maxlen		= sizeof(unsigned long),
> > > +		.mode		= 0644,
> > > +		.proc_handler	= &hugetlb_mempolicy_sysctl_handler,
> > > +		.extra1		= (void *)&hugetlb_zero,
> > > +		.extra2		= (void *)&hugetlb_infinity,
> > > +	 },
> > > +#endif
> > >  	 {
> > >  		.ctl_name	= VM_HUGETLB_GROUP,
> > >  		.procname	= "hugetlb_shm_group",
> > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > index 83decd6..68abef0 100644
> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -1244,6 +1244,7 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
> > >  	return ret;
> > >  }
> > >  
> > > +#define NUMA_NO_NODE_OBEY_MEMPOLICY (-2)

How about defining NUMA_NO_NODE_OBEY_MEMPOLICY as (NUMA_NO_NODE - 1)
just to ensure that it's different.  Not sure it's worth an enum at this
point.  NUMA_NO_NODE_OBEY_MEMPOLICY is private to hugetlb at this time.

> > >  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> > >  static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
> > >  								int nid)
> > 
> > I think it would be possible to avoid adding NUMA_NO_NODE_OBEY_MEMPOLICY 
> > if the nodemask was allocated in the sysctl handler instead and passing it 
> > into set_max_huge_pages() instead of a nid.  Lee, what do you think?
> > 
> > Other than that, I like this approach because it avoids the potential for 
> > userspace breakage while adding the new feature in way that avoids 
> > confusion.
> > 
> 
> Indeed. While the addition of another proc tunable sucks, it seems like
> the only available compromise.

And, I supposed we need to replicate this under the global sysfs
hstates?

Lee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
