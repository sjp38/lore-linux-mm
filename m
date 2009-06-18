Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0030D6B006A
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 05:18:55 -0400 (EDT)
Date: Thu, 18 Jun 2009 10:19:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] Add sysctl for default hstate nodes_allowed.
Message-ID: <20090618091921.GC14903@csn.ul.ie>
References: <20090616135228.25248.22018.sendpatchset@lts-notebook> <20090616135308.25248.57593.sendpatchset@lts-notebook> <20090617134107.GJ28529@csn.ul.ie> <1245261122.6235.96.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1245261122.6235.96.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 01:52:02PM -0400, Lee Schermerhorn wrote:
> On Wed, 2009-06-17 at 14:41 +0100, Mel Gorman wrote:
> > On Tue, Jun 16, 2009 at 09:53:08AM -0400, Lee Schermerhorn wrote:
> > > [PATCH 4/5] add sysctl for default hstate nodes_allowed.
> > > 
> > > Against:  17may09 mmotm
> > > 
> > > This patch adds a sysctl -- /proc/sys/vm/hugepages_nodes_allowed --
> > > to set/query the default hstate's nodes_allowed.  I don't know
> > > that this patch is required, given that we have the per hstate
> > > controls in /sys/kernel/mm/hugepages/*. However, we've added sysctls
> > > for other recent hugepages controls, like nr_overcommit_hugepages,
> > > so I've followed that convention.
> > > 
> > 
> > Yeah, it's somewhat expected that what is in /proc/sys/vm is information
> > on the default hugepage size.
> > 
> > > Factor the formatting of the nodes_allowed mask out of nodes_allowed_show()
> > > for use by both that function and the hugetlb_nodes_allowed_handler().
> > > 
> > > Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp>
> > > 
> > >  include/linux/hugetlb.h |    1 +
> > >  kernel/sysctl.c         |    8 ++++++++
> > >  mm/hugetlb.c            |   43 ++++++++++++++++++++++++++++++++++++++-----
> > >  3 files changed, 47 insertions(+), 5 deletions(-)
> > > 
> > > Index: linux-2.6.30-rc8-mmotm-090603-1633/include/linux/hugetlb.h
> > > ===================================================================
> > > --- linux-2.6.30-rc8-mmotm-090603-1633.orig/include/linux/hugetlb.h	2009-06-04 12:59:32.000000000 -0400
> > > +++ linux-2.6.30-rc8-mmotm-090603-1633/include/linux/hugetlb.h	2009-06-04 12:59:35.000000000 -0400
> > > @@ -22,6 +22,7 @@ void reset_vma_resv_huge_pages(struct vm
> > >  int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
> > >  int hugetlb_overcommit_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
> > >  int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
> > > +int hugetlb_nodes_allowed_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
> > >  int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
> > >  int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int, int);
> > >  void unmap_hugepage_range(struct vm_area_struct *,
> > > Index: linux-2.6.30-rc8-mmotm-090603-1633/kernel/sysctl.c
> > > ===================================================================
> > > --- linux-2.6.30-rc8-mmotm-090603-1633.orig/kernel/sysctl.c	2009-06-04 12:59:26.000000000 -0400
> > > +++ linux-2.6.30-rc8-mmotm-090603-1633/kernel/sysctl.c	2009-06-04 12:59:35.000000000 -0400
> > > @@ -1108,6 +1108,14 @@ static struct ctl_table vm_table[] = {
> > >  		.extra1		= (void *)&hugetlb_zero,
> > >  		.extra2		= (void *)&hugetlb_infinity,
> > >  	},
> > > +	{
> > > +		.ctl_name	= CTL_UNNUMBERED,
> > > +		.procname	= "hugepages_nodes_allowed",
> > > +		.data		= NULL,
> > > +		.maxlen		= sizeof(unsigned long),
> > > +		.mode		= 0644,
> > > +		.proc_handler	= &hugetlb_nodes_allowed_handler,
> > > +	},
> > >  #endif
> > >  	{
> > >  		.ctl_name	= VM_LOWMEM_RESERVE_RATIO,
> > > Index: linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c
> > > ===================================================================
> > > --- linux-2.6.30-rc8-mmotm-090603-1633.orig/mm/hugetlb.c	2009-06-04 12:59:33.000000000 -0400
> > > +++ linux-2.6.30-rc8-mmotm-090603-1633/mm/hugetlb.c	2009-06-04 12:59:35.000000000 -0400
> > > @@ -1354,19 +1354,27 @@ static ssize_t nr_overcommit_hugepages_s
> > >  }
> > >  HSTATE_ATTR(nr_overcommit_hugepages);
> > >  
> > > -static ssize_t nodes_allowed_show(struct kobject *kobj,
> > > -					struct kobj_attribute *attr, char *buf)
> > > +static int format_hstate_nodes_allowed(struct hstate *h, char *buf,
> > > +					size_t buflen)
> > >  {
> > > -	struct hstate *h = kobj_to_hstate(kobj);
> > >  	int len = 3;
> > >  
> > >  	if (h->nodes_allowed == &node_online_map)
> > >  		strcpy(buf, "all");
> > >  	else
> > > -		len = nodelist_scnprintf(buf, PAGE_SIZE,
> > > +		len = nodelist_scnprintf(buf, buflen,
> > >  					*h->nodes_allowed);
> > > +	return len;
> > > +
> > > +}
> > 
> > This looks like unnecessary churn and could have been done in the earlier
> > patch introducing nodes_allowed_show()
> 
> Yes.  I couldn't see creating the separate function if we weren't going
> to have the sysctl also formatting the nodes_allowed.  If all agree that
> we want the sysctl, I can fold this patch in with patch 2/5.
> 

I think we want the sysctl to be consistent with nr_hugepages and the
other hugepages parameters.

> > 
> > > +
> > > +static ssize_t nodes_allowed_show(struct kobject *kobj,
> > > +					struct kobj_attribute *attr, char *buf)
> > > +{
> > > +	struct hstate *h = kobj_to_hstate(kobj);
> > > +	int len =  format_hstate_nodes_allowed(h, buf, PAGE_SIZE);
> > >  
> > > -	if (len)
> > > +	if (len && (len +1) < PAGE_SIZE)
> > >  		buf[len++] = '\n';
> > >  
> > >  	return len;
> > > @@ -1684,6 +1692,31 @@ int hugetlb_overcommit_handler(struct ct
> > >  	return 0;
> > >  }
> > >  
> > > +#define NODES_ALLOWED_MAX 64
> > > +int hugetlb_nodes_allowed_handler(struct ctl_table *table, int write,
> > > +			struct file *file, void __user *buffer,
> > > +			size_t *length, loff_t *ppos)
> > > +{
> > > +	struct hstate *h = &default_hstate;
> > > +	int ret = 0;
> > > +
> > > +	if (write) {
> > > +		(void)set_hstate_nodes_allowed(h, buffer, 1);
> > > +	} else {
> > > +		char buf[NODES_ALLOWED_MAX];
> > > +		struct ctl_table tbl = {
> > > +			.data = buf,
> > > +			.maxlen = NODES_ALLOWED_MAX,
> > > +		};
> > > +		int len =  format_hstate_nodes_allowed(h, buf, sizeof(buf));
> > > +
> > > +		if (len)
> > > +			ret = proc_dostring(&tbl, write, file, buffer,
> > > +						 length, ppos);
> > > +	}
> > > +	return ret;
> > > +}
> > > +
> > >  #endif /* CONFIG_SYSCTL */
> > >  
> > >  void hugetlb_report_meminfo(struct seq_file *m)
> > > 
> > 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
