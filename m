Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 200A86B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 13:44:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p87so221265pfj.21
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 10:44:56 -0700 (PDT)
Received: from out0-250.mail.aliyun.com (out0-250.mail.aliyun.com. [140.205.0.250])
        by mx.google.com with ESMTPS id f19si2826493plr.675.2017.11.02.10.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 10:44:54 -0700 (PDT)
Subject: Re: [PATCH] mm: use in_atomic() in print_vma_addr()
References: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
 <20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
Date: Fri, 03 Nov 2017 01:44:44 +0800
MIME-Version: 1.0
In-Reply-To: <20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, mingo@redhat.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 11/2/17 12:57 AM, Michal Hocko wrote:
> On Thu 02-11-17 05:38:33, Yang Shi wrote:
>> commit 3e51f3c4004c9b01f66da03214a3e206f5ed627b
>> ("sched/preempt: Remove PREEMPT_ACTIVE unmasking off in_atomic()") makes
>> in_atomic() just check the preempt count, so it is not necessary to use
>> preempt_count() in print_vma_addr() any more. Replace preempt_count() to
>> in_atomic() which is a generic API for checking atomic context.
> 
> But why? Is there some general work to get rid of the direct preempt_count
> usage outside of the generic API?

I may not articulate it in the commit log, I would say "in_atomic" is 
*preferred* API for checking atomic context instead of preempt_count() 
which should be used for retrieving the preemption count value.

I would say there is not such general elimination work undergoing right 
now, but if we go through the kernel code, almost everywhere "in_atomic" 
is used for such use case already, except two places:

- print_vma_addr()
- debug_smp_processor_id()

Both came from Ingo long time ago before commit 
3e51f3c4004c9b01f66da03214a3e206f5ed627b ("sched/preempt: Remove 
PREEMPT_ACTIVE unmasking off in_atomic()"). But, after this commit was 
merged, I don't see why *not* use in_atomic() to follow the convention.

Thanks,
Yang

> 
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> ---
>>   mm/memory.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index a728bed..19b684e 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -4460,7 +4460,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
>>   	 * Do not print if we are in atomic
>>   	 * contexts (in exception stacks, etc.):
>>   	 */
>> -	if (preempt_count())
>> +	if (in_atomic())
>>   		return;
>>   
>>   	down_read(&mm->mmap_sem);
>> -- 
>> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
