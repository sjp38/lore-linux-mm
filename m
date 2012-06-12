Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 19ABC6B0069
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 06:53:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 12 Jun 2012 10:47:01 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5CAjcCA43450622
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 20:45:38 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5CAr4D8017277
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 20:53:05 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V8 12/16] hugetlb/cgroup: Add support for cgroup removal
In-Reply-To: <4FD6FC76.8040203@jp.fujitsu.com>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4FD6FC76.8040203@jp.fujitsu.com>
Date: Tue, 12 Jun 2012 16:22:57 +0530
Message-ID: <87fwa0ol86.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> (2012/06/09 17:59), Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
>> 
>> This patch add support for cgroup removal. If we don't have parent
>> cgroup, the charges are moved to root cgroup.
>> 
>> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
>
> I'm sorry if already pointed out....
>
>> ---
>>   mm/hugetlb_cgroup.c |   81 +++++++++++++++++++++++++++++++++++++++++++++++++--
>>   1 file changed, 79 insertions(+), 2 deletions(-)
>> 
>> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
>> index 48efd5a..9458fe3 100644
>> --- a/mm/hugetlb_cgroup.c
>> +++ b/mm/hugetlb_cgroup.c
>> @@ -99,10 +99,87 @@ static void hugetlb_cgroup_destroy(struct cgroup *cgroup)
>>   	kfree(h_cgroup);
>>   }
>> 
>> +
>> +static int hugetlb_cgroup_move_parent(int idx, struct cgroup *cgroup,
>> +				      struct page *page)
>> +{
>> +	int csize;
>> +	struct res_counter *counter;
>> +	struct res_counter *fail_res;
>> +	struct hugetlb_cgroup *page_hcg;
>> +	struct hugetlb_cgroup *h_cg   = hugetlb_cgroup_from_cgroup(cgroup);
>> +	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(cgroup);
>> +
>> +	if (!get_page_unless_zero(page))
>> +		goto out;
>
> It seems this doesn't necessary...this is under hugetlb_lock().

already updated.

>
>> +
>> +	page_hcg = hugetlb_cgroup_from_page(page);
>> +	/*
>> +	 * We can have pages in active list without any cgroup
>> +	 * ie, hugepage with less than 3 pages. We can safely
>> +	 * ignore those pages.
>> +	 */
>> +	if (!page_hcg || page_hcg != h_cg)
>> +		goto err_out;
>> +
>> +	csize = PAGE_SIZE<<  compound_order(page);
>> +	if (!parent) {
>> +		parent = root_h_cgroup;
>> +		/* root has no limit */
>> +		res_counter_charge_nofail(&parent->hugepage[idx],
>> +					  csize,&fail_res);
>                                               ^^^
> space ?

I don't have code this way locally, may be a mail client error ?

>
>> +	}
>> +	counter =&h_cg->hugepage[idx];
>> +	res_counter_uncharge_until(counter, counter->parent, csize);
>> +
>> +	set_hugetlb_cgroup(page, parent);
>> +err_out:
>> +	put_page(page);
>> +out:
>> +	return 0;
>> +}
>> +
>> +/*
>> + * Force the hugetlb cgroup to empty the hugetlb resources by moving them to
>> + * the parent cgroup.
>> + */
>>   static int hugetlb_cgroup_pre_destroy(struct cgroup *cgroup)
>>   {
>> -	/* We will add the cgroup removal support in later patches */
>> -	   return -EBUSY;
>> +	struct hstate *h;
>> +	struct page *page;
>> +	int ret = 0, idx = 0;
>> +
>> +	do {
>> +		if (cgroup_task_count(cgroup) ||
>> +		    !list_empty(&cgroup->children)) {
>> +			ret = -EBUSY;
>> +			goto out;
>> +		}

Is this check  going to moved to higher levels ? Do we still need
this. Or will that happen when pred_destroy becomes void ?

>
>> +		/*
>> +		 * If the task doing the cgroup_rmdir got a signal
>> +		 * we don't really need to loop till the hugetlb resource
>> +		 * usage become zero.
>> +		 */
>> +		if (signal_pending(current)) {
>> +			ret = -EINTR;
>> +			goto out;
>> +		}
>
> I'll post a patch to remove this check from memcg because memcg's rmdir
> always succeed now. So, could you remove this ?

Will drop this 

>
>
>> +		for_each_hstate(h) {
>> +			spin_lock(&hugetlb_lock);
>> +			list_for_each_entry(page,&h->hugepage_activelist, lru) {
>> +				ret = hugetlb_cgroup_move_parent(idx, cgroup, page);
>> +				if (ret) {
>
> When 'ret' should be !0 ?
> If hugetlb_cgroup_move_parent() always returns 0, the check will not be necessary.
>

I will make this void funciton.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
