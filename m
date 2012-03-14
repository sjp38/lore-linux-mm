Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 5A73A6B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 07:13:29 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Mar 2012 16:41:23 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2EBB1T33125378
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 16:41:01 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2EGfaFg000866
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 03:41:37 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 5/8] hugetlbfs: Add memcg control files for hugetlbfs
In-Reply-To: <20120313144233.49026e6a.akpm@linux-foundation.org>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120313144233.49026e6a.akpm@linux-foundation.org>
Date: Wed, 14 Mar 2012 16:40:58 +0530
Message-ID: <87lin38mkd.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 14:42:33 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 13 Mar 2012 12:37:09 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > This add control files for hugetlbfs in memcg
> > 
> > ...
> >
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -220,6 +221,10 @@ struct hstate {
> >  	unsigned int nr_huge_pages_node[MAX_NUMNODES];
> >  	unsigned int free_huge_pages_node[MAX_NUMNODES];
> >  	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> > +	/* cgroup control files */
> > +	struct cftype cgroup_limit_file;
> > +	struct cftype cgroup_usage_file;
> > +	struct cftype cgroup_max_usage_file;
> >  	char name[HSTATE_NAME_LEN];
> >  };
> 
> We don't need all these in here if, for example, cgroups is disabled?

Will fix.

> 
> > ...
> >
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1817,6 +1817,36 @@ static int __init hugetlb_init(void)
> >  }
> >  module_init(hugetlb_init);
> >  
> > +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
> > +int register_hugetlb_memcg_files(struct cgroup *cgroup,
> > +				 struct cgroup_subsys *ss)
> > +{
> > +	int ret = 0;
> > +	struct hstate *h;
> > +
> > +	for_each_hstate(h) {
> > +		ret = cgroup_add_file(cgroup, ss, &h->cgroup_limit_file);
> > +		if (ret)
> > +			return ret;
> > +		ret = cgroup_add_file(cgroup, ss, &h->cgroup_usage_file);
> > +		if (ret)
> > +			return ret;
> > +		ret = cgroup_add_file(cgroup, ss, &h->cgroup_max_usage_file);
> > +		if (ret)
> > +			return ret;
> > +
> > +	}
> > +	return ret;
> > +}
> > +/* mm/memcontrol.c because mem_cgroup_read/write is not availabel outside */
> 
> Comment has a spelling mistake.

Will fix

> 
> > +int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx);
> 
> 
> No, please put it in a header file.  Always.  Where both callers and
> the implementation see the same propotype.
> 
> > +#else
> > +static int mem_cgroup_hugetlb_file_init(struct hstate *h, int idx)
> > +{
> > +	return 0;
> > +}
> > +#endif
> 
> So this will go into the same header file.
> 

I was not sure whether i want to put mem_cgroup_hugetlb_file_init in
linux/memcontrol.h . Ideally i want to have that in mm/hugetlb.c and in
linux/hugetlb.h. That would require me to make mem_cgroup_read and
others non static and move few #defines to memcontrol.h. That would
involve larger code movement which i didn't want to do. ? What do you
suggest ? Just move mem_cgroup_hugetlb_file_init to memcontrol.h ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
