Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id ABAEF6B0140
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:12:08 -0400 (EDT)
Message-ID: <4FE96024.5030907@parallels.com>
Date: Tue, 26 Jun 2012 11:09:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/11] kmem slab accounting basic infrastructure
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252121140.26640@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206252121140.26640@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic
 Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal
 Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph
 Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On 06/26/2012 08:22 AM, David Rientjes wrote:
> On Mon, 25 Jun 2012, Glauber Costa wrote:
>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 9352d40..6f34b77 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -265,6 +265,10 @@ struct mem_cgroup {
>>   	};
>>
>>   	/*
>> +	 * the counter to account for kernel memory usage.
>> +	 */
>> +	struct res_counter kmem;
>> +	/*
>>   	 * Per cgroup active and inactive list, similar to the
>>   	 * per zone LRU lists.
>>   	 */
>> @@ -279,6 +283,7 @@ struct mem_cgroup {
>>   	 * Should the accounting and control be hierarchical, per subtree?
>>   	 */
>>   	bool use_hierarchy;
>> +	bool kmem_accounted;
>>
>>   	bool		oom_lock;
>>   	atomic_t	under_oom;
>> @@ -391,6 +396,7 @@ enum res_type {
>>   	_MEM,
>>   	_MEMSWAP,
>>   	_OOM_TYPE,
>> +	_KMEM,
>>   };
>>
>>   #define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
>> @@ -1438,6 +1444,10 @@ done:
>>   		res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
>>   		res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
>>   		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
>> +	printk(KERN_INFO "kmem: usage %llukB, limit %llukB, failcnt %llu\n",
>> +		res_counter_read_u64(&memcg->kmem, RES_USAGE) >> 10,
>> +		res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
>> +		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
>>   }
>>
>>   /*
>> @@ -3879,6 +3889,11 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
>>   		else
>>   			val = res_counter_read_u64(&memcg->memsw, name);
>>   		break;
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +	case _KMEM:
>> +		val = res_counter_read_u64(&memcg->kmem, name);
>> +		break;
>> +#endif
>
> This shouldn't need an #ifdef, ->kmem is available on all
> CONFIG_CGROUP_MEM_RES_CTLR kernels.  Same with several of the other
> instances in this patch.
>
> Can't these instances be addressed by not adding kmem_cgroup_files without
> CONFIG_CGROUP_MEM_RES_CTLR_KMEM?

Yes, it can.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
