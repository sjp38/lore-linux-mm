Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 566D86B0145
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:15:04 -0400 (EDT)
Message-ID: <4FE960D6.4040409@parallels.com>
Date: Tue, 26 Jun 2012 11:12:22 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] memcg: Reclaim when more than one page needed.
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-3-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252106430.26640@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206252106430.26640@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Suleiman Souhlal <suleiman@google.com>


>
>> + * retries
>> + */
>> +#define NR_PAGES_TO_RETRY 2
>> +
>
> Should be 1 << PAGE_ALLOC_COSTLY_ORDER?  Where does this number come from?
> The changelog doesn't specify.

Hocko complained about that, and I changed. Where the number comes from, 
is stated in the comments: it is a number small enough to have high 
changes of had been freed by the previous reclaim, and yet around the 
number of pages of a kernel allocation.

Of course there are allocations for nr_pages > 2. But 2 will already 
service the stack most of the time, and most of the slab caches.

>>   static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>> -				unsigned int nr_pages, bool oom_check)
>> +				unsigned int nr_pages, unsigned int min_pages,
>> +				bool oom_check)
>>   {
>>   	unsigned long csize = nr_pages * PAGE_SIZE;
>>   	struct mem_cgroup *mem_over_limit;
>> @@ -2182,18 +2190,18 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>>   	} else
>>   		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
>>   	/*
>> -	 * nr_pages can be either a huge page (HPAGE_PMD_NR), a batch
>> -	 * of regular pages (CHARGE_BATCH), or a single regular page (1).
>> -	 *
>>   	 * Never reclaim on behalf of optional batching, retry with a
>>   	 * single page instead.
>>   	 */
>> -	if (nr_pages == CHARGE_BATCH)
>> +	if (nr_pages > min_pages)
>>   		return CHARGE_RETRY;
>>
>>   	if (!(gfp_mask & __GFP_WAIT))
>>   		return CHARGE_WOULDBLOCK;
>>
>> +	if (gfp_mask & __GFP_NORETRY)
>> +		return CHARGE_NOMEM;
>> +
>>   	ret = mem_cgroup_reclaim(mem_over_limit, gfp_mask, flags);
>>   	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
>>   		return CHARGE_RETRY;
>> @@ -2206,7 +2214,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>>   	 * unlikely to succeed so close to the limit, and we fall back
>>   	 * to regular pages anyway in case of failure.
>>   	 */
>> -	if (nr_pages == 1 && ret)
>> +	if (nr_pages <= NR_PAGES_TO_RETRY && ret)
>>   		return CHARGE_RETRY;
>>
>>   	/*
>> @@ -2341,7 +2349,8 @@ again:
>>   			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
>>   		}
>>
>> -		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, oom_check);
>> +		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, nr_pages,
>> +		    oom_check);
>>   		switch (ret) {
>>   		case CHARGE_OK:
>>   			break;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
