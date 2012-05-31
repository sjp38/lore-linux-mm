Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 5FB1B6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 01:40:29 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 31 May 2012 05:21:19 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4V5X58N34930844
	for <linux-mm@kvack.org>; Thu, 31 May 2012 15:33:05 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4V5e7qK003830
	for <linux-mm@kvack.org>; Thu, 31 May 2012 15:40:08 +1000
Date: Thu, 31 May 2012 11:09:52 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 11/14] hugetlbfs: add hugetlb cgroup control files
Message-ID: <20120531053952.GC24855@skywalker.linux.vnet.ibm.com>
References: <1338388739-22919-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1338388739-22919-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120531013225.GF401@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120531013225.GF401@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed, May 30, 2012 at 09:32:25PM -0400, Konrad Rzeszutek Wilk wrote:
> On Wed, May 30, 2012 at 08:08:56PM +0530, Aneesh Kumar K.V wrote:
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > Add the control files for hugetlb controller
> > 
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > ---
> >  include/linux/hugetlb.h        |    5 ++
> >  include/linux/hugetlb_cgroup.h |    6 ++
> >  mm/hugetlb.c                   |    2 +
> >  mm/hugetlb_cgroup.c            |  130 ++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 143 insertions(+)
> > 
> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index dcd55c7..92f75a5 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -4,6 +4,7 @@
> >  #include <linux/mm_types.h>
> >  #include <linux/fs.h>
> >  #include <linux/hugetlb_inline.h>
> > +#include <linux/cgroup.h>
> >  
> >  struct ctl_table;
> >  struct user_struct;
> > @@ -221,6 +222,10 @@ struct hstate {
> >  	unsigned int nr_huge_pages_node[MAX_NUMNODES];
> >  	unsigned int free_huge_pages_node[MAX_NUMNODES];
> >  	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> > +#ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
> > +	/* cgroup control files */
> > +	struct cftype cgroup_files[5];
> 
> Why five? Should there be a #define for this magic value?
> 

Because we have 4 control files. Was not sure whether that should be a #define because
we are not going to use that #define anywhere else. Also the same patch index them
in hugetlb_file_init. That is the only place it is used.

> > +#endif
> >  	char name[HSTATE_NAME_LEN];
> >  };
> >  
> > diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
> > index 5794be4..fbf8c5f 100644
> > --- a/include/linux/hugetlb_cgroup.h
> > +++ b/include/linux/hugetlb_cgroup.h
> > @@ -42,6 +42,7 @@ extern void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
> >  					 struct page *page);
> >  extern void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
> >  					   struct hugetlb_cgroup *h_cg);
> > +extern int hugetlb_cgroup_file_init(int idx) __init;
> >  #else
> >  static inline bool hugetlb_cgroup_disabled(void)
> >  {
> > @@ -75,5 +76,10 @@ hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
> >  {
> >  	return;
> >  }
> > +
> > +static inline int __init hugetlb_cgroup_file_init(int idx)
> > +{
> > +	return 0;
> > +}
> >  #endif  /* CONFIG_MEM_RES_CTLR_HUGETLB */
> >  #endif
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 53840dd..6330de2 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -29,6 +29,7 @@
> >  #include <linux/io.h>
> >  #include <linux/hugetlb.h>
> >  #include <linux/node.h>
> > +#include <linux/hugetlb_cgroup.h>
> >  #include "internal.h"
> >  
> >  const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
> > @@ -1912,6 +1913,7 @@ void __init hugetlb_add_hstate(unsigned order)
> >  	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
> >  	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
> >  					huge_page_size(h)/1024);
> > +	hugetlb_cgroup_file_init(hugetlb_max_hstate - 1);
> >  
> >  	parsed_hstate = h;
> >  }
> > diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> > index 3a288f7..49a3f20 100644
> > --- a/mm/hugetlb_cgroup.c
> > +++ b/mm/hugetlb_cgroup.c
> > @@ -19,6 +19,11 @@
> >  #include <linux/page_cgroup.h>
> >  #include <linux/hugetlb_cgroup.h>
> >  
> > +/* lifted from mem control */
> 
> Might also include the comment from said file explaining the
> purpose of these #define.
> 
> > +#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
> > +#define MEMFILE_IDX(val)	(((val) >> 16) & 0xffff)
> > +#define MEMFILE_ATTR(val)	((val) & 0xffff)
> > +
> >  struct cgroup_subsys hugetlb_subsys __read_mostly;
> >  struct hugetlb_cgroup *root_h_cgroup __read_mostly;
> >  
> > @@ -271,6 +276,131 @@ void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
> >  	return;
> >  }
> >  
> > +static ssize_t hugetlb_cgroup_read(struct cgroup *cgroup, struct cftype *cft,
> > +				   struct file *file, char __user *buf,
> > +				   size_t nbytes, loff_t *ppos)
> > +{
> > +	u64 val;
> > +	char str[64];
> 
> I would think there would be a define for this somewhere?

lifted from mem_cgroup_read. Number is big enough to find the return for usage_in_bytes,
limit_in_bytes etc

> 
> > +	int idx, name, len;
> > +	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_cgroup(cgroup);
> > +
> > +	idx = MEMFILE_IDX(cft->private);
> > +	name = MEMFILE_ATTR(cft->private);
> > +
> > +	val = res_counter_read_u64(&h_cg->hugepage[idx], name);
> > +	len = scnprintf(str, sizeof(str), "%llu\n", (unsigned long long)val);
> > +	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
> > +}
> > +

......
......

> > +	cft->private = MEMFILE_PRIVATE(idx, RES_USAGE);
> > +	cft->read = hugetlb_cgroup_read;
> > +
> > +	/* Add the MAX usage file */
> > +	cft = &h->cgroup_files[2];
> > +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.max_usage_in_bytes", buf);
> > +	cft->private = MEMFILE_PRIVATE(idx, RES_MAX_USAGE);
> > +	cft->trigger = hugetlb_cgroup_reset;
> > +	cft->read = hugetlb_cgroup_read;
> > +
> > +	/* Add the failcntfile */
> > +	cft = &h->cgroup_files[3];
> > +	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.failcnt", buf);
> > +	cft->private  = MEMFILE_PRIVATE(idx, RES_FAILCNT);
> > +	cft->trigger  = hugetlb_cgroup_reset;
> > +	cft->read = hugetlb_cgroup_read;
> > +
> > +	/* NULL terminate the last cft */
> > +	cft = &h->cgroup_files[4];
> > +	memset(cft, 0, sizeof(*cft));
> > +
> > +	WARN_ON(cgroup_add_cftypes(&hugetlb_subsys, h->cgroup_files));
> > +
> 
> Wouldn't doing:
> 	return cgroup_add_cftypes(&hugetlb_subsys, h->cgroup_files);
> 
> be more appropiate?


cgroup wanted a WARN_ON around that IIUC. I guess we will drop all of the later.

> > +	return 0;
> > +}
> > +
> >  struct cgroup_subsys hugetlb_subsys = {
> >  	.name = "hugetlb",
> >  	.create     = hugetlb_cgroup_create,
> > -- 
> > 1.7.10
> > 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
