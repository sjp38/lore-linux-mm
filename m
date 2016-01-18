Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 74A0B6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 07:18:38 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id r129so48922846wmr.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 04:18:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lq9si3194169wjb.51.2016.01.18.04.18.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Jan 2016 04:18:37 -0800 (PST)
Subject: Re: [PATCH v3] zsmalloc: fix migrate_zspage-zs_free race condition
References: <1453095596-44055-1-git-send-email-junil0814.lee@lge.com>
 <20160118063611.GC7453@bbox> <20160118065434.GB459@swordfish>
 <20160118071157.GD7453@bbox> <20160118073939.GA30668@swordfish>
 <569C9A1F.2020303@suse.cz> <20160118082000.GA20244@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <569CD817.7090309@suse.cz>
Date: Mon, 18 Jan 2016 13:18:31 +0100
MIME-Version: 1.0
In-Reply-To: <20160118082000.GA20244@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/18/2016 09:20 AM, Minchan Kim wrote:
> On Mon, Jan 18, 2016 at 08:54:07AM +0100, Vlastimil Babka wrote:
>> On 18.1.2016 8:39, Sergey Senozhatsky wrote:
>>> On (01/18/16 16:11), Minchan Kim wrote:
>>> [..]
>>>>> so, even if clear_bit_unlock/test_and_set_bit_lock do smp_mb or
>>>>> barrier(), there is no corresponding barrier from record_obj()->WRITE_ONCE().
>>>>> so I don't think WRITE_ONCE() will help the compiler, or am I missing
>>>>> something?
>>>>
>>>> We need two things
>>>> 2. memory barrier.
>>>>
>>>> As compiler barrier, WRITE_ONCE works to prevent store tearing here
>>>> by compiler.
>>>> However, if we omit unpin_tag here, we lose memory barrier(e,g, smp_mb)
>>>> so another CPU could see stale data caused CPU memory reordering.
>>>
>>> oh... good find! lost release semantic of unpin_tag()...
>>
>> Ah, release semantic, good point indeed. OK then we need the v2 approach again,
>> with WRITE_ONCE() in record_obj(). Or some kind of record_obj_release() with
>> release semantic, which would be a bit more effective, but I guess migration is
>> not that critical path to be worth introducing it.
>
> WRITE_ONCE in record_obj would add more memory operations in obj_malloc

A simple WRITE_ONCE would just add a compiler barrier. What you suggests 
below does indeed add more operations, which are actually needed just in 
the migration. What I suggested is the v2 approach of adding the PIN bit 
before calling record_obj, *and* simply doing a WRITE_ONCE in 
record_obj() to make sure the PIN bit is indeed applied *before* writing 
to the handle, and not as two separate writes.

> but I don't feel it's too heavy in this phase so,

I'm afraid it's dangerous for the usage of record_obj() in zs_malloc() 
where the handle is freshly allocated by alloc_handle(). Are we sure the 
bit is not set?

The code in alloc_handle() is:
         return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
                 pool->flags & ~__GFP_HIGHMEM);

There's no explicit __GFP_ZERO, so the handles are not guaranteed to be 
allocated empty? And expecting all zpool users to include __GFP_ZERO in 
flags would be too subtle and error prone.

> How about this? Junil, Could you resend patch if others agree this?
> Thanks.
>
> +/*
> + * record_obj updates handle's value to free_obj and it shouldn't
> + * invalidate lock bit(ie, HANDLE_PIN_BIT) of handle, otherwise
> + * it breaks synchronization using pin_tag(e,g, zs_free) so let's
> + * keep the lock bit.
> + */
>   static void record_obj(unsigned long handle, unsigned long obj)
>   {
> -	*(unsigned long *)handle = obj;
> +	int locked = (*(unsigned long *)handle) & (1<<HANDLE_PIN_BIT);
> +	unsigned long val = obj | locked;
> +
> +	/*
> +	 * WRITE_ONCE could prevent store tearing like below
> +	 * *(unsigned long *)handle = free_obj
> +	 * *(unsigned long *)handle |= locked;
> +	 */
> +	WRITE_ONCE(*(unsigned long *)handle, val);
>   }
>
>
>
>>
>> Thanks,
>> Vlastimil
>>
>>>
>>> 	-ss
>>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
