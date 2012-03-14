Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 899A26B004D
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 08:42:11 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Mar 2012 17:55:42 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2ECMVUG3031252
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 17:52:31 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2EHr66G015905
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 04:53:07 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 7/8] memcg: move HugeTLB resource count to parent cgroup on memcg removal
In-Reply-To: <20120313144705.020b6dde.akpm@linux-foundation.org>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120313144705.020b6dde.akpm@linux-foundation.org>
Date: Wed, 14 Mar 2012 17:52:28 +0530
Message-ID: <87ipi78j97.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 14:47:05 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 13 Mar 2012 12:37:11 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > 
> > This add support for memcg removal with HugeTLB resource usage.
> > 
> > ...
> >
> > +int hugetlb_force_memcg_empty(struct cgroup *cgroup)
> 
> It's useful to document things, you know.  For a major function like
> this, a nice little description of why it exists, what its role is,
> etc.  Programming is not just an act of telling a computer what to do:
> it is also an act of telling other programmers what you wished the
> computer to do.  Both are important, and the latter deserves care.
> 


Will do.

> > +{
> > +	struct hstate *h;
> > +	struct page *page;
> > +	int ret = 0, idx = 0;
> > +
> > +	do {
> > +		if (cgroup_task_count(cgroup) || !list_empty(&cgroup->children))
> > +			goto out;
> > +		if (signal_pending(current)) {
> > +			ret = -EINTR;
> > +			goto out;
> > +		}
> 
> Why is its behaviour altered by signal_pending()?  This seems broken.

If the task that is doing a cgroup_rmdir got a signal we don't really
need to loop till the hugetlb resource usage become zero. 


> 
> > +		for_each_hstate(h) {
> > +			spin_lock(&hugetlb_lock);
> > +			list_for_each_entry(page, &h->hugepage_activelist, lru) {
> > +				ret = mem_cgroup_move_hugetlb_parent(idx, cgroup, page);
> > +				if (ret) {
> > +					spin_unlock(&hugetlb_lock);
> > +					goto out;
> > +				}
> > +			}
> > +			spin_unlock(&hugetlb_lock);
> > +			idx++;
> > +		}
> > +		cond_resched();
> > +	} while (mem_cgroup_hugetlb_usage(cgroup) > 0);
> > +out:
> > +	return ret;
> > +}

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
