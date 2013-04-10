Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 5ED6B6B007B
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:32:36 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 14:32:33 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1588E38C81A9
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:31:50 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIVdjb247020
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:31:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AIVaOn024606
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:31:39 -0400
Message-ID: <5165B004.3080100@linux.vnet.ibm.com>
Date: Wed, 10 Apr 2013 11:31:32 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 03/10] mm/page_alloc: insert memory barriers to allow
 async update of pcp batch and high
References: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com> <1365550099-6795-4-git-send-email-cody@linux.vnet.ibm.com> <CAOtvUMdXJSzV5V3WQpDrU1DqzFk4G4RtBLdrgJyGR-AZhY6RNw@mail.gmail.com> <CAOtvUMe8zZwZaUYDiGeLskkdPzPZGXYh6Wm0MKt0St0OSqDExg@mail.gmail.com>
In-Reply-To: <CAOtvUMe8zZwZaUYDiGeLskkdPzPZGXYh6Wm0MKt0St0OSqDExg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/09/2013 11:22 PM, Gilad Ben-Yossef wrote:
> On Wed, Apr 10, 2013 at 9:19 AM, Gilad Ben-Yossef <gilad@benyossef.com> wrote:
>> On Wed, Apr 10, 2013 at 2:28 AM, Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
>>> In pageset_set_batch() and setup_pagelist_highmark(), ensure that batch
>>> is always set to a safe value (1) prior to updating high, and ensure
>>> that high is fully updated before setting the real value of batch.
>>>
>>> Suggested by Gilad Ben-Yossef <gilad@benyossef.com> in this thread:
>>>
>>>          https://lkml.org/lkml/2013/4/9/23
>>>
>>> Also reproduces his proposed comment.
>>>
>>> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
>>> ---
>>>   mm/page_alloc.c | 19 +++++++++++++++++++
>>>   1 file changed, 19 insertions(+)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index d259599..a07bd4c 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -4007,11 +4007,26 @@ static int __meminit zone_batchsize(struct zone *zone)
>>>   #endif
>>>   }
>>>
>>> +static void pageset_update_prep(struct per_cpu_pages *pcp)
>>> +{
>>> +       /*
>>> +        * We're about to mess with PCP in an non atomic fashion.  Put an
>>> +        * intermediate safe value of batch and make sure it is visible before
>>> +        * any other change
>>> +        */
>>> +       pcp->batch = 1;
>>> +       smp_wmb();
>>> +}
>>> +
>>>   /* a companion to setup_pagelist_highmark() */
>>>   static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
>>>   {
>>>          struct per_cpu_pages *pcp = &p->pcp;
>>> +       pageset_update_prep(pcp);
>>> +
>>>          pcp->high = 6 * batch;
>>> +       smp_wmb();
>>> +
>>>          pcp->batch = max(1UL, 1 * batch);
>>>   }
>>>
>>> @@ -4039,7 +4054,11 @@ static void setup_pagelist_highmark(struct per_cpu_pageset *p,
>>>          struct per_cpu_pages *pcp;
>>>
>>>          pcp = &p->pcp;
>>> +       pageset_update_prep(pcp);
>>> +
>>>          pcp->high = high;
>>> +       smp_wmb();
>>> +
>>>          pcp->batch = max(1UL, high/4);
>>>          if ((high/4) > (PAGE_SHIFT * 8))
>>>                  pcp->batch = PAGE_SHIFT * 8;
>>> --
>>> 1.8.2
>>>
>>
>> That is very good.
>> However, now we've created a "protocol" for updating ->high and ->batch:
>>
>> 1. Call pageset_update_prep(pcp)
>> 2. Update ->high
>> 3. smp_wmb()
>> 4. Update ->batch
>>
>> But that protocol is not documented anywhere and someone  that reads
>> the code two
>> years from now will not be aware of it or why it is done like that.
>>
>> How about if we create:
>>
>> /*
>> * pcp->high and pcp->batch values are related and dependent on one another:
>> * ->batch must never be higher then ->high.
>> * The following function updates them in a safe manner without a
>> costly atomic transaction.
>> */
>> static void pageset_update(struct per_cpu_pages *pcp, unsigned int
>> high, unsigned int batch)
>> {
>>         /* start with a fail safe value for batch */
>>         pcp->batch = 1;
>>         smp_wmb();
>>
>>         /* Update high, then batch, in order */
>>         pcp->high = high;
>>         smp_wmb();
>>         pcp->batch = batch;
>> }
>>
>> And use that at the update sites? then the protocol becomes explicit.

Yep, this looks like exactly the right thing.

>
> Oh, and other then that it looks good to me, so assuming you do that -
>
> Reviewed-By: Gilad Ben-Yossef <gilad@benyossef.com>

I've added it only to the patch with pageset_update() in it, if you 
meant to apply it to more patches, feel free to reply to the v3 posting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
