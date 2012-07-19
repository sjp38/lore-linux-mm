Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 488946B005C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 02:31:12 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Jul 2012 12:01:06 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6J6UvFN12059020
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 12:00:58 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6JC1ZeC029540
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 22:01:36 +1000
Date: Thu, 19 Jul 2012 14:30:52 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] mm/memcg: calculate max hierarchy limit number
 instead of min
Message-ID: <20120719063051.GA18422@kernel>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <a>
 <1342013081-4096-1-git-send-email-liwp.linux@gmail.com>
 <5007A418.10801@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5007A418.10801@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 19, 2012 at 03:07:20PM +0900, Kamezawa Hiroyuki wrote:
>(2012/07/11 22:24), Wanpeng Li wrote:
>> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>> 
>> Since hierachical_memory_limit shows "of bytes of memory limit with
>> regard to hierarchy under which the memory cgroup is", the count should
>> calculate max hierarchy limit when use_hierarchy in order to show hierarchy
>> subtree limit. hierachical_memsw_limit is the same case.
>> 
>> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
>
>Hm ? What is the hierarchical limit for 'C' in following tree ?
>
>A  ---  limit=1G 
> \
>  B --  limit=500M
>   \
>    C - unlimtied
>
Hmm, thank you Kame. :-)

Regards,
Wanpeng Li 

>Thanks,
>-Kame
>
>
>> ---
>>   mm/memcontrol.c |   14 +++++++-------
>>   1 files changed, 7 insertions(+), 7 deletions(-)
>> 
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 69a7d45..6392c0a 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3929,10 +3929,10 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
>>   		unsigned long long *mem_limit, unsigned long long *memsw_limit)
>>   {
>>   	struct cgroup *cgroup;
>> -	unsigned long long min_limit, min_memsw_limit, tmp;
>> +	unsigned long long max_limit, max_memsw_limit, tmp;
>>   
>> -	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
>> -	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
>> +	max_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
>> +	max_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
>>   	cgroup = memcg->css.cgroup;
>>   	if (!memcg->use_hierarchy)
>>   		goto out;
>> @@ -3943,13 +3943,13 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
>>   		if (!memcg->use_hierarchy)
>>   			break;
>>   		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
>> -		min_limit = min(min_limit, tmp);
>> +		max_limit = max(max_limit, tmp);
>>   		tmp = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
>> -		min_memsw_limit = min(min_memsw_limit, tmp);
>> +		max_memsw_limit = max(max_memsw_limit, tmp);
>>   	}
>>   out:
>> -	*mem_limit = min_limit;
>> -	*memsw_limit = min_memsw_limit;
>> +	*mem_limit = max_limit;
>> +	*memsw_limit = max_memsw_limit;
>>   }
>>   
>>   static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
>> 
>
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
