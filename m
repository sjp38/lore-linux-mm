Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 24D026B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 02:35:46 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 20 Jun 2013 16:26:56 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id E47412CE8044
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 16:35:38 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5K6Kk8p55312592
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 16:20:46 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5K6ZbbE004547
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 16:35:37 +1000
Message-ID: <51C2A1F2.7040104@linux.vnet.ibm.com>
Date: Thu, 20 Jun 2013 12:02:18 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc: remove repetitious local_irq_save() in
 __zone_pcp_update()
References: <1371593437-30002-1-git-send-email-cody@linux.vnet.ibm.com> <51C176AC.4000709@linux.vnet.ibm.com> <alpine.DEB.2.02.1306191543070.15308@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1306191543070.15308@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 06/20/2013 04:23 AM, David Rientjes wrote:
> On Wed, 19 Jun 2013, Srivatsa S. Bhat wrote:
> 
>>> __zone_pcp_update() is called via stop_machine(), which already disables
>>> local irq.
>>>
>>> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
>>
>> Reviewed-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>>
> 
> What was reviewed?
>

See below.
 
>>> ---
>>>  mm/page_alloc.c | 4 +---
>>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index bac3107..b46b54a 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -6179,7 +6179,7 @@ static int __meminit __zone_pcp_update(void *data)
>>>  {
>>>  	struct zone *zone = data;
>>>  	int cpu;
>>> -	unsigned long batch = zone_batchsize(zone), flags;
>>> +	unsigned long batch = zone_batchsize(zone);
>>>
>>>  	for_each_possible_cpu(cpu) {
>>>  		struct per_cpu_pageset *pset;
>>> @@ -6188,12 +6188,10 @@ static int __meminit __zone_pcp_update(void *data)
>>>  		pset = per_cpu_ptr(zone->pageset, cpu);
>>>  		pcp = &pset->pcp;
>>>
>>> -		local_irq_save(flags);
>>>  		if (pcp->count > 0)
>>>  			free_pcppages_bulk(zone, pcp->count, pcp);
>>>  		drain_zonestat(zone, pset);
>>>  		setup_pageset(pset, batch);
>>> -		local_irq_restore(flags);
> 
> This seems like a fine cleanup because stop_machine() disable irqs,

I hope you are not missing the fact that stop_machine() disables irqs
on *all* CPUs.

> but it 
> appears like there is two problems with this function already:
> 
>  - it's doing for_each_possible_cpu() internally, why?  local_irq_save()
>    works on the local cpu and won't protect
>    per_cpu_ptr(zone->pageset, cpu)->pcp of some random cpu, and
> 

stop_machine() allows only _your function_ to run and nothing else, on
the entire system. All other CPUs loop with interrupts disabled until
the function is completed.

>  - setup_pageset() is what is ultimately responsible for doing 
>    pcp->count = 0 after free_pcppages_bulk(), but what happens if 
>    pcp->count is read in between the two on the cpu that has not disabled 
>    irqs?
> 

Nobody can do anything else when this function runs. That's precisely
why its named as stop-*machine*.

> You can't just do
> 
> 	for_each_possible_cpu(cpu) {
> 		unsigned long flags;
> 
> 		local_irq_save(flags);
> 		...
> 		local_irq_restore(flags);
> 	}
> 
> This is just disabling irqs locally over and over again, not on the cpu 
> you're manipulating in its per-cpu critical section.
>

stop-machine() takes care of disabling irqs on every online CPU.
 
> I don't think we hit this because onlining and offlining memory isn't a 
> very common operation, but it doesn't change the fact that it's broken.
>

If __zone_pcp_update() is called only from stop_machine() (and looking at
the current code, that's true), then there is no problem, due to the reasons
explained above.

Regards,
Srivatsa S. Bhat

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
