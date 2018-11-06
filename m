Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07E7E6B02DE
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 03:54:53 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o42so5794370edc.13
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 00:54:52 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y24-v6si584563edv.448.2018.11.06.00.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 00:54:51 -0800 (PST)
Subject: Re: [PATCH] mm, slab: remove unnecessary unlikely()
References: <20181104125028.3572-1-tiny.windzz@gmail.com>
 <2c42ba08-f78a-36f6-5a5d-21dd00861872@suse.cz>
 <CACT4Y+a+7gqs+gdfePuVGZ-bDGvb8ieE8ugA-pK1AZ8HwfecQg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a16bb44b-5231-97fe-920d-20cd92b5f3b2@suse.cz>
Date: Tue, 6 Nov 2018 09:54:49 +0100
MIME-Version: 1.0
In-Reply-To: <CACT4Y+a+7gqs+gdfePuVGZ-bDGvb8ieE8ugA-pK1AZ8HwfecQg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Yangtao Li <tiny.windzz@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/6/18 6:38 AM, Dmitry Vyukov wrote:
> On Mon, Nov 5, 2018 at 11:18 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> +CC Dmitry
>>
>> On 11/4/18 1:50 PM, Yangtao Li wrote:
>>> WARN_ON() already contains an unlikely(), so it's not necessary to use
>>> unlikely.
>>>
>>> Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>
>>
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>>
>> Maybe also change it back to WARN_ON_ONCE? I already considered it while
>> reviewing Dmitry's patch and wasn't sure. Now I think that what can
>> happen is that either a kernel bug is introduced that _ONCE is enough to
>> catch (two separate bugs introduced to both hit this would be rare, and
>> in that case the second one will be reported after the first one is
>> fixed), or this gets called with a user-supplied value, and then we want
>> to avoid spamming dmesg with multiple warnings that the user could
>> trigger at will.
> 
> 
> If you asking me, I am fine both changes.
> I was mainly interested in removing the bogus warnings that actually fire.

OK thanks. Andrew can you update the patch to WARN_ON_ONCE?

Changelog addition:
Also change WARN_ON() back to WARN_ON_ONCE() to avoid potentially
spamming dmesg with user-triggerable large allocations.

> 
>>> ---
>>>  mm/slab_common.c | 4 +---
>>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>>
>>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>>> index 7eb8dc136c1c..4f54684f5435 100644
>>> --- a/mm/slab_common.c
>>> +++ b/mm/slab_common.c
>>> @@ -1029,10 +1029,8 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
>>>
>>>               index = size_index[size_index_elem(size)];
>>>       } else {
>>> -             if (unlikely(size > KMALLOC_MAX_CACHE_SIZE)) {
>>> -                     WARN_ON(1);
>>> +             if (WARN_ON(size > KMALLOC_MAX_CACHE_SIZE))
>>>                       return NULL;
>>> -             }
>>>               index = fls(size - 1);
>>>       }
>>>
>>>
>>
