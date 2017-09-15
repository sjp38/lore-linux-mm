Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE1946B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 13:40:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j16so5709812pga.6
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 10:40:39 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id 11si925357pfi.308.2017.09.15.10.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 10:40:38 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1505409289-57031-1-git-send-email-yang.s@alibaba-inc.com>
 <1505409289-57031-4-git-send-email-yang.s@alibaba-inc.com>
 <2f7b69d1-8aa2-c2b8-92bd-167998145a28@I-love.SAKURA.ne.jp>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <ade43170-d968-4bd1-bc2d-61bafc3bc88e@alibaba-inc.com>
Date: Sat, 16 Sep 2017 01:40:17 +0800
MIME-Version: 1.0
In-Reply-To: <2f7b69d1-8aa2-c2b8-92bd-167998145a28@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/15/17 5:00 AM, Tetsuo Handa wrote:
> On 2017/09/15 2:14, Yang Shi wrote:
>> @@ -1274,6 +1276,29 @@ static int slab_show(struct seq_file *m, void *p)
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
>> +	mutex_lock(&slab_mutex);
> 
> Please avoid sleeping locks which potentially depend on memory allocation.
> There are
> 
> 	mutex_lock(&slab_mutex);
> 	kmalloc(GFP_KERNEL);
> 	mutex_unlock(&slab_mutex);
> 
> users which will fail to call panic() if they hit this path
Thanks for the heads up. Since this is just called by oom in panic path, 
so it sounds safe to just discard the mutex_lock()/mutex_unlock call 
since nobody can allocate memory without GFP_ATOMIC to change the 
statistics of slab.

Even though some GFP_ATOMIC callers allocate memory successfully, it 
should not have obvious impact to the slabinfo we need capture since 
typically GFP_ATOMIC allocation is small.

I will drop the mutext in v2 if no one has objection.

Thanks,
Yang

> 
>> +	list_for_each_entry(s, &slab_caches, list) {
>> +		if (!is_root_cache(s))
>> +			continue;
>> +
>> +		get_slabinfo(s, &sinfo);
>> +
>> +		if (!is_reclaimable(s) && sinfo.num_objs > 0)
>> +			printk("%-17s %luKB\n", cache_name(s), K(sinfo.num_objs * s->size));
>> +	}
>> +	mutex_unlock(&slab_mutex);
>> +}
>> +EXPORT_SYMBOL(show_unreclaimable_slab);
>> +#undef K
>> +
>>   #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>>   void *memcg_slab_start(struct seq_file *m, loff_t *pos)
>>   {
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
