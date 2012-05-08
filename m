Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id AC9A76B004D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 21:34:53 -0400 (EDT)
Message-ID: <4FA87837.3050208@kernel.org>
Date: Tue, 08 May 2012 10:34:47 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] zsmalloc: zsmalloc: align cache line size
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-4-git-send-email-minchan@kernel.org> <4FA28EFD.5070002@vflare.org> <4FA33E89.6080206@kernel.org> <alpine.LFD.2.02.1205071038090.2851@tux.localdomain> <4FA7C2BC.2090400@vflare.org>
In-Reply-To: <4FA7C2BC.2090400@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org

On 05/07/2012 09:40 PM, Nitin Gupta wrote:

> On 5/7/12 3:41 AM, Pekka Enberg wrote:
>> On Fri, 4 May 2012, Minchan Kim wrote:
>>>>> It's a overkill to align pool size with PAGE_SIZE to avoid
>>>>> false-sharing. This patch aligns it with just cache line size.
>>>>>
>>>>> Signed-off-by: Minchan Kim<minchan@kernel.org>
>>>>> ---
>>>>>    drivers/staging/zsmalloc/zsmalloc-main.c |    6 +++---
>>>>>    1 file changed, 3 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c
>>>>> b/drivers/staging/zsmalloc/zsmalloc-main.c
>>>>> index 51074fa..3991b03 100644
>>>>> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
>>>>> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
>>>>> @@ -489,14 +489,14 @@ fail:
>>>>>
>>>>>    struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
>>>>>    {
>>>>> -    int i, error, ovhd_size;
>>>>> +    int i, error;
>>>>>        struct zs_pool *pool;
>>>>>
>>>>>        if (!name)
>>>>>            return NULL;
>>>>>
>>>>> -    ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
>>>>> -    pool = kzalloc(ovhd_size, GFP_KERNEL);
>>>>> +    pool = kzalloc(ALIGN(sizeof(*pool), cache_line_size()),
>>>>> +                GFP_KERNEL);
>>>>
>>>> a basic question:
>>>>   Is rounding off allocation size to cache_line_size enough to ensure
>>>> that the object is cache-line-aligned? Isn't it possible that even
>>>> though the object size is multiple of cache-line, it may still not be
>>>> properly aligned and end up sharing cache line with some other
>>>> read-mostly object?
>>>
>>> AFAIK, SLAB allocates object aligned cache-size so I think that
>>> problem cannot happen.
>>> But needs double check.
>>> Cced Pekka.
>>
>> The kmalloc(size) function only gives you the following guarantees:
>>
>>    (1) The allocated object is _at least_ 'size' bytes.
>>
>>    (2) The returned pointer is aligned to ARCH_KMALLOC_MINALIGN.
>>
>> Anything beyond that is implementation detail and probably will break if
>> you switch between SLAB/SLUB/SLOB.
>>
>>             Pekka


Pekka, Thanks.

> 
> So, we can probably leave it as is (PAGE_SIZE aligned) or use
> kmem_cache_create(...,SLAB_HWCACHE_ALIGN,...) for allocating 'struct
> zs_pool's.


3) remove aligning code totally because there isn't any report about degradation by false-sharing. 
4)
origin = pool = kzalloc(sizeof(*pool) + cache_line_size, GFP_KERNEL);
pool = round_up(pool, cache_line_size);

Which preference?
I choose 3.


> 
> zcache can potentially create a lot of pools, so the latter will save
> some memory.


Dumb question.
Why should we create pool per user? 
What's the problem if there is only one pool in system?

> 
> Thanks,
> Nitin
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
