Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C4ED66B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 06:23:14 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Mar 2012 15:53:08 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2EAM4OP1433686
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 15:52:05 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2EFpAUo032420
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 02:51:12 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V3 2/8] memcg: Add HugeTLB extension
In-Reply-To: <20120313143316.0ef74d0e.akpm@linux-foundation.org>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331622432-24683-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120313143316.0ef74d0e.akpm@linux-foundation.org>
Date: Wed, 14 Mar 2012 15:51:50 +0530
Message-ID: <87zkbj8ou9.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, 13 Mar 2012 14:33:16 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 13 Mar 2012 12:37:06 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > +static int mem_cgroup_hugetlb_usage(struct mem_cgroup *memcg)
> > +{
> > +	int idx;
> > +	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
> > +		if (memcg->hugepage[idx].usage > 0)
> > +			return memcg->hugepage[idx].usage;
> > +	}
> > +	return 0;
> > +}
> 
> Please document the function?  Had you done this, I might have been
> able to work out why the function bales out on the first used hugepage
> size, but I can't :(

I guess the function is named wrongly. I will rename it to
mem_cgroup_have_hugetlb_usage() in the next iteration ? The function
will return (bool) 1 if it has any hugetlb resource usage.

> 
> This could have used for_each_hstate(), had that macro been better
> designed (or updated).
> 

Can you explain this ?. for_each_hstate allows to iterate over
different hstates. But here we need to look at different hugepage
rescounter in memcg. I can still use for_each_hstate() and find the
hstate index (h - hstates) and use that to index memcg rescounter
array. But that would make it more complex ?

> Upon return this function coerces an unsigned long long into an "int". 
> We decided last week that more than 2^32 hugepages was not
> inconceivable, so I guess that's a bug.
> 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
