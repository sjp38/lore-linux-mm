Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 32A6F6B005C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 05:40:31 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 12 Jun 2012 15:10:28 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5C9eOXI5964182
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 15:10:24 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5CF9di8022141
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 01:09:40 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V8 10/16] hugetlb/cgroup: Add the cgroup pointer to page lru
In-Reply-To: <4FD6F530.6050603@jp.fujitsu.com>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4FD6F530.6050603@jp.fujitsu.com>
Date: Tue, 12 Jun 2012 15:10:20 +0530
Message-ID: <87mx48ool7.fsf@skywalker.in.ibm.com>
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
>> Add the hugetlb cgroup pointer to 3rd page lru.next. This limit
>> the usage to hugetlb cgroup to only hugepages with 3 or more
>> normal pages. I guess that is an acceptable limitation.
>> 
>> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>   include/linux/hugetlb_cgroup.h |   31 +++++++++++++++++++++++++++++++
>>   mm/hugetlb.c                   |    4 ++++
>>   2 files changed, 35 insertions(+)
>> 
>> diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
>> index 5794be4..ceff1d5 100644
>> --- a/include/linux/hugetlb_cgroup.h
>> +++ b/include/linux/hugetlb_cgroup.h
>> @@ -26,6 +26,26 @@ struct hugetlb_cgroup {
>>   };
>> 
>>   #ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
>> +static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
>> +{
>> +	if (!PageHuge(page))
>> +		return NULL;
>
> I'm not very sure but....
>
> 	VM_BUG_ON(!PageHuge(page)) ??
>
>
>
>> +	if (compound_order(page)<  3)
>> +		return NULL;
>> +	return (struct hugetlb_cgroup *)page[2].lru.next;
>> +}
>> +
>> +static inline
>> +int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
>> +{
>> +	if (!PageHuge(page))
>> +		return -1;
>
> ditto.
>
>> +	if (compound_order(page)<  3)
>> +		return -1;
>> +	page[2].lru.next = (void *)h_cg;
>> +	return 0;
>> +}
>> +

done

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
