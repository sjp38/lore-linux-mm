Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1696B0069
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 13:21:57 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m30so28782862pgn.2
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 10:21:57 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTPS id p13si7989163pll.156.2017.09.27.10.21.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Sep 2017 10:21:55 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com>
 <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.20.1709270211010.30111@nuc-kabylake>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <c7459b93-4197-6968-6735-a97a06325d04@alibaba-inc.com>
Date: Thu, 28 Sep 2017 01:21:27 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1709270211010.30111@nuc-kabylake>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/27/17 12:14 AM, Christopher Lameter wrote:
> On Wed, 27 Sep 2017, Yang Shi wrote:
> 
>> Print out unreclaimable slab info (used size and total size) which
>> actual memory usage is not zero (num_objs * size != 0) when:
>>    - unreclaimable slabs : all user memory > unreclaim_slabs_oom_ratio
>>    - panic_on_oom is set or no killable process
> 
> Ok. I like this much more than the earlier releases.
> 
>> diff --git a/mm/slab.h b/mm/slab.h
>> index 0733628..b0496d1 100644
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -505,6 +505,14 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
>>   void memcg_slab_stop(struct seq_file *m, void *p);
>>   int memcg_slab_show(struct seq_file *m, void *p);
>>
>> +#ifdef CONFIG_SLABINFO
>> +void dump_unreclaimable_slab(void);
>> +#else
>> +static inline void dump_unreclaimable_slab(void)
>> +{
>> +}
>> +#endif
> 
> CONFIG_SLABINFO? How does this relate to the oom info? /proc/slabinfo
> support is optional. Oom info could be included even if CONFIG_SLABINFO
> goes away. Remove the #ifdef?

Because we want to dump the unreclaimable slab info in oom info.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
