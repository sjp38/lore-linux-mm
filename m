Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 945F36B03A4
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 06:30:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v16so6038187oia.19
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 03:30:04 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0099.outbound.protection.outlook.com. [104.47.2.99])
        by mx.google.com with ESMTPS id 6si3239801oic.240.2017.04.05.03.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 03:30:03 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <2cfc601e-3093-143e-b93d-402f330a748a@vmware.com>
 <a28cc48d-3d6f-b4dd-10c2-a75d2e83ef14@virtuozzo.com>
 <20170404094148.GJ15132@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <d28bc808-0aab-d36a-f401-9925680fd131@virtuozzo.com>
Date: Wed, 5 Apr 2017 13:31:23 +0300
MIME-Version: 1.0
In-Reply-To: <20170404094148.GJ15132@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Hellstrom <thellstrom@vmware.com>, akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, stable@vger.kernel.org

On 04/04/2017 12:41 PM, Michal Hocko wrote:
> On Thu 30-03-17 17:48:39, Andrey Ryabinin wrote:
>> From: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Subject: mm/vmalloc: allow to call vfree() in atomic context fix
>>
>> Don't spawn worker if we already purging.
>>
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> 
> I would rather put this into a separate patch. Ideally with some numners
> as this is an optimization...
> 

It's quite simple optimization and don't think that this deserves to be a separate patch.

But I did some measurements though. With enabled VMAP_STACK=y and NR_CACHED_STACK changed to 0
running fork() 100000 times gives this:

With optimization:

~ # grep try_purge /proc/kallsyms 
ffffffff811d0dd0 t try_purge_vmap_area_lazy
~ # perf stat --repeat 10 -ae workqueue:workqueue_queue_work --filter 'function == 0xffffffff811d0dd0' ./fork

 Performance counter stats for 'system wide' (10 runs):

                15      workqueue:workqueue_queue_work                                     ( +-  0.88% )

       1.615368474 seconds time elapsed                                          ( +-  0.41% )


Without optimization:
~ # grep try_purge /proc/kallsyms 
ffffffff811d0dd0 t try_purge_vmap_area_lazy
~ # perf stat --repeat 10 -ae workqueue:workqueue_queue_work --filter 'function == 0xffffffff811d0dd0' ./fork

 Performance counter stats for 'system wide' (10 runs):

                30      workqueue:workqueue_queue_work                                     ( +-  1.31% )

       1.613231060 seconds time elapsed                                          ( +-  0.38% )


So there is no measurable difference on the test itself, but we queue twice more jobs without this optimization.
It should decrease load of kworkers.



>> ---
>>  mm/vmalloc.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index ea1b4ab..88168b8 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -737,7 +737,8 @@ static void free_vmap_area_noflush(struct vmap_area *va)
>>  	/* After this point, we may free va at any time */
>>  	llist_add(&va->purge_list, &vmap_purge_list);
>>  
>> -	if (unlikely(nr_lazy > lazy_max_pages()))
>> +	if (unlikely(nr_lazy > lazy_max_pages()) &&
>> +	    !mutex_is_locked(&vmap_purge_lock))
>>  		schedule_work(&purge_vmap_work);
>>  }
>>  
>> -- 
>> 2.10.2
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
