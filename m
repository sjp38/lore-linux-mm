Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DACB6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:16:52 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z82so63032763qkb.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:16:52 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id m62si8112229qtd.126.2016.10.13.17.16.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 17:16:51 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: Re: [RFC v2 PATCH] mm/percpu.c: fix panic triggered by BUG_ON()
 falsely
References: <57FCF07C.2020103@zoho.com>
 <20161013232902.GD32534@mtj.duckdns.org>
Message-ID: <10d149b0-e436-730d-2050-f9e1a6fed39e@zoho.com>
Date: Fri, 14 Oct 2016 08:15:56 +0800
MIME-Version: 1.0
In-Reply-To: <20161013232902.GD32534@mtj.duckdns.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, cl@linux.com

On 2016/10/14 7:29, Tejun Heo wrote:
> On Tue, Oct 11, 2016 at 10:00:28PM +0800, zijun_hu wrote:
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> as shown by pcpu_build_alloc_info(), the number of units within a percpu
>> group is educed by rounding up the number of CPUs within the group to
>> @upa boundary, therefore, the number of CPUs isn't equal to the units's
>> if it isn't aligned to @upa normally. however, pcpu_page_first_chunk()
>> uses BUG_ON() to assert one number is equal the other roughly, so a panic
>> is maybe triggered by the BUG_ON() falsely.
>>
>> in order to fix this issue, the number of CPUs is rounded up then compared
>> with units's, the BUG_ON() is replaced by warning and returning error code
>> as well to keep system alive as much as possible.
> 
> I really can't decode what the actual issue is here.  Can you please
> give an example of a concrete case?
> 
the right relationship between the number of CPUs @nr_cpus within a percpu group
and the number of unites @nr_units within the same group is that
@nr_units == roundup(@nr_cpus, @upa);

the process of consideration is shown as follows:

1i 1/4 ? current code segments:

BUG_ON(ai->nr_groups != 1);
BUG_ON(ai->groups[0].nr_units != num_possible_cpus());

2i 1/4 ? changes for considering the right relationship between the number of CPUs and units 

BUG_ON(ai->nr_groups != 1);
BUG_ON(ai->groups[0].nr_units != roundup(num_possible_cpus(), @upa));

3) replace BUG_ON() by warning and returning error code since it seems BUG_ON() isn't
   nice as shown by linus recent LKML mail

BUG_ON(ai->nr_groups != 1);
if (ai->groups[0].nr_units != roundup(num_possible_cpus(), @upa))
   return -EINVAL;

so 3) is my finial changes;
for the relationship of both numbers : see the reply for andrew

>> @@ -2113,21 +2120,22 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
>>  
>>  	/* allocate pages */
>>  	j = 0;
>> -	for (unit = 0; unit < num_possible_cpus(); unit++)
>> +	for (unit = 0; unit < num_possible_cpus(); unit++) {
>> +		unsigned int cpu = ai->groups[0].cpu_map[unit];
>>  		for (i = 0; i < unit_pages; i++) {
>> -			unsigned int cpu = ai->groups[0].cpu_map[unit];
>>  			void *ptr;
>>  
>>  			ptr = alloc_fn(cpu, PAGE_SIZE, PAGE_SIZE);
>>  			if (!ptr) {
>>  				pr_warn("failed to allocate %s page for cpu%u\n",
>> -					psize_str, cpu);
>> +						psize_str, cpu);
> 
> And stop making gratuitous changes?
>

this changes is just for looking nicer instinctively
@cpu can be determined in the first outer loop.

> Thanks.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
