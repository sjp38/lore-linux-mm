Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id AF5F46B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 22:55:21 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 19 Jul 2012 03:41:32 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6J2lBl659572430
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 12:47:12 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6J2tCF0025047
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 12:55:12 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugetlb/cgroup: Simplify pre_destroy callback
In-Reply-To: <20120718142628.76bf78b3.akpm@linux-foundation.org>
References: <1342589649-15066-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120718142628.76bf78b3.akpm@linux-foundation.org>
Date: Thu, 19 Jul 2012 08:25:06 +0530
Message-ID: <87hat4794l.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kernel@vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed, 18 Jul 2012 11:04:09 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> Since we cannot fail in hugetlb_cgroup_move_parent, we don't really
>> need to check whether cgroup have any change left after that. Also skip
>> those hstates for which we don't have any charge in this cgroup.
>> 
>> ...
>>
>> +	for_each_hstate(h) {
>> +		/*
>> +		 * if we don't have any charge, skip this hstate
>> +		 */
>> +		idx = hstate_index(h);
>> +		if (res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE) == 0)
>> +			continue;
>> +		spin_lock(&hugetlb_lock);
>> +		list_for_each_entry(page, &h->hugepage_activelist, lru)
>> +			hugetlb_cgroup_move_parent(idx, cgroup, page);
>> +		spin_unlock(&hugetlb_lock);
>> +		VM_BUG_ON(res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE));
>> +	}
>>  out:
>>  	return ret;
>>  }
>
> This looks fishy.
>
> We test RES_USAGE before taking hugetlb_lock.  What prevents some other
> thread from increasing RES_USAGE after that test?
>
> After walking the list we test RES_USAGE after dropping hugetlb_lock. 
> What prevents another thread from incrementing RES_USAGE before that
> test, triggering the BUG?

IIUC core cgroup will prevent a new task getting added to the cgroup
when we are in pre_destroy. Since we already check that the cgroup doesn't
have any task, the RES_USAGE cannot increase in pre_destroy.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
