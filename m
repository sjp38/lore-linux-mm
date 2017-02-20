Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD5AA6B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 12:09:51 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id z13so25387764oig.0
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 09:09:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p197si13302462wmg.0.2017.02.20.09.09.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 09:09:51 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1KH8bhT098753
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 12:09:49 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28r4dt0jkf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 12:09:49 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 20 Feb 2017 17:09:47 -0000
Subject: Re: [PATCH] mm/cgroup: avoid panic when init with low memory
References: <1487154969-6704-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170220130123.GI2431@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 20 Feb 2017 18:09:43 +0100
MIME-Version: 1.0
In-Reply-To: <20170220130123.GI2431@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <934d40ec-060b-4794-2fdc-35a7ea1dc9e2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 20/02/2017 14:01, Michal Hocko wrote:
> On Wed 15-02-17 11:36:09, Laurent Dufour wrote:
>> The system may panic when initialisation is done when almost all the
>> memory is assigned to the huge pages using the kernel command line
>> parameter hugepage=xxxx. Panic may occur like this:
> 
> I am pretty sure the system might blow up in many other ways when you
> misconfigure it and pull basically all the memory out. Anyway...
> 
> [...]
> 
>> This is a chicken and egg issue where the kernel try to get free
>> memory when allocating per node data in mem_cgroup_init(), but in that
>> path mem_cgroup_soft_limit_reclaim() is called which assumes that
>> these data are allocated.
>>
>> As mem_cgroup_soft_limit_reclaim() is best effort, it should return
>> when these data are not yet allocated.
> 
> ... this makes some sense. Especially when there is no soft limit
> configured. So this is a good step. I would just like to ask you to go
> one step further. Can we make the whole soft reclaim thing uninitialized
> until the soft limit is actually set? Soft limit is not used in cgroup
> v2 at all and I would strongly discourage it in v1 as well. We will save
> few bytes as a bonus.

Hi Michal, and thanks for the review.

I'm not familiar with that part of the kernel, so to be sure we are on
the same line, are you suggesting to set soft_limit_tree at the first
time mem_cgroup_write() is called to set a soft_limit field ?

Obviously, all callers to soft_limit_tree_node() and
soft_limit_tree_from_page() will have to check for the return pointer to
be NULL.

Cheers,
Laurent.


>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  mm/memcontrol.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 1fd6affcdde7..213f96b2f601 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2556,7 +2556,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
>>  	 * is empty. Do it lockless to prevent lock bouncing. Races
>>  	 * are acceptable as soft limit is best effort anyway.
>>  	 */
>> -	if (RB_EMPTY_ROOT(&mctz->rb_root))
>> +	if (!mctz || RB_EMPTY_ROOT(&mctz->rb_root))
>>  		return 0;
>>  
>>  	/*
>> -- 
>> 2.7.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
