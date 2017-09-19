Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A69726B0253
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 17:46:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y29so1299133pff.6
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 14:46:05 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTPS id s72si1977093pgc.551.2017.09.19.14.45.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Sep 2017 14:45:56 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1505759209-102539-1-git-send-email-yang.s@alibaba-inc.com>
 <1505759209-102539-3-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.10.1709191356020.7458@chino.kir.corp.google.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <01f4cce4-d7a3-2fcb-06e0-382eff8e83e5@alibaba-inc.com>
Date: Wed, 20 Sep 2017 05:45:30 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1709191356020.7458@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/19/17 1:57 PM, David Rientjes wrote:
> On Tue, 19 Sep 2017, Yang Shi wrote:
> 
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -35,6 +35,8 @@
>>   static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
>>   		    slab_caches_to_rcu_destroy_workfn);
>>   
>> +#define K(x) ((x)/1024)
>> +
>>   /*
>>    * Set of flags that will prevent slab merging
>>    */
>> @@ -1272,6 +1274,34 @@ static int slab_show(struct seq_file *m, void *p)
>>   	return 0;
>>   }
>>   
>> +void show_unreclaimable_slab()
>> +{
>> +	struct kmem_cache *s = NULL;
>> +	struct slabinfo sinfo;
>> +
>> +	memset(&sinfo, 0, sizeof(sinfo));
>> +
>> +	printk("Unreclaimable slabs:\n");
>> +
>> +	/*
>> +	 * Here acquiring slab_mutex is unnecessary since we don't prefer to
>> +	 * get sleep in oom path right before kernel panic, and avoid race condition.
>> +	 * Since it is already oom, so there should be not any big allocation
>> +	 * which could change the statistics significantly.
>> +	 */
>> +	list_for_each_entry(s, &slab_caches, list) {
>> +		if (!is_root_cache(s))
>> +			continue;
>> +
>> +		get_slabinfo(s, &sinfo);
>> +
>> +		if (!is_reclaimable(s) && sinfo.num_objs > 0)
>> +			printk("%-17s %luKB\n", cache_name(s), K(sinfo.num_objs * s->size));
>> +	}
> 
> I like this, but could we be even more helpful by giving the user more
> information from sinfo beyond just the total size of objects allocated?

Sure, we definitely can. But, the question is what info is helpful to 
users to diagnose oom other than the size.

I think of the below:
	- the number of active objs, the number of total objs, the percentage 
of active objs per cache
	- the number of active slabs, the number of total slabs, the percentage 
of active slabs per cache

Anything else?

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
