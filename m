Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A305E8E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 12:19:07 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so7276202edd.16
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 09:19:07 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y32si789665ede.115.2019.01.12.09.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Jan 2019 09:19:05 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Sat, 12 Jan 2019 18:19:03 +0100
From: Roman Penyaev <rpenyaev@suse.de>
Subject: Re: [PATCH 2/3] mm/vmalloc: do not call kmemleak_free() on not yet
 accounted memory
In-Reply-To: <b761b165-9892-0761-cd33-14300e39e36f@virtuozzo.com>
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-3-rpenyaev@suse.de>
 <b761b165-9892-0761-cd33-14300e39e36f@virtuozzo.com>
Message-ID: <6557efeadcb4fdedbd9c36947e644e2f@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2019-01-11 20:26, Andrey Ryabinin wrote:
> On 1/3/19 5:59 PM, Roman Penyaev wrote:
>> __vmalloc_area_node() calls vfree() on error path, which in turn calls
>> kmemleak_free(), but area is not yet accounted by kmemleak_vmalloc().
>> 
>> Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Joe Perches <joe@perches.com>
>> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>  mm/vmalloc.c | 16 +++++++++++-----
>>  1 file changed, 11 insertions(+), 5 deletions(-)
>> 
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 2cd24186ba84..dc6a62bca503 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1565,6 +1565,14 @@ void vfree_atomic(const void *addr)
>>  	__vfree_deferred(addr);
>>  }
>> 
>> +static void __vfree(const void *addr)
>> +{
>> +	if (unlikely(in_interrupt()))
>> +		__vfree_deferred(addr);
>> +	else
>> +		__vunmap(addr, 1);
>> +}
>> +
>>  /**
>>   *	vfree  -  release memory allocated by vmalloc()
>>   *	@addr:		memory base address
>> @@ -1591,10 +1599,8 @@ void vfree(const void *addr)
>> 
>>  	if (!addr)
>>  		return;
>> -	if (unlikely(in_interrupt()))
>> -		__vfree_deferred(addr);
>> -	else
>> -		__vunmap(addr, 1);
>> +
>> +	__vfree(addr);
>>  }
>>  EXPORT_SYMBOL(vfree);
>> 
>> @@ -1709,7 +1715,7 @@ static void *__vmalloc_area_node(struct 
>> vm_struct *area, gfp_t gfp_mask,
>>  	warn_alloc(gfp_mask, NULL,
>>  			  "vmalloc: allocation failure, allocated %ld of %ld bytes",
>>  			  (area->nr_pages*PAGE_SIZE), area->size);
>> -	vfree(area->addr);
>> +	__vfree(area->addr);
> 
> This can't be an interrupt context for a several reasons. One of them
> is BUG_ON(in_interrupt()) in __get_vm_area_node()
> which is called right before __vmalloc_are_node().
> 
> So you can just do __vunmap(area->addr, 1); instead of __vfree().

Thanks, I missed that BUG_ON and could not prove, that we can call only
from a task context, thus decided not to make it strict.  Of course
simple __vunmap() is much better.  The other reason is that we call a
spin_lock without disabling the interrupts.  Now I see.

Andrew, may I resend just an updated version of this patch?

--
Roman
