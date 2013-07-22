Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 9F02A6B0032
	for <linux-mm@kvack.org>; Sun, 21 Jul 2013 21:20:47 -0400 (EDT)
Message-ID: <51EC88B3.7080506@asianux.com>
Date: Mon, 22 Jul 2013 09:19:47 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: use 'unsigned long' instead of 'int' for variable
 'slub_debug'
References: <51DF5F43.3080408@asianux.com> <0000013fd3283b9c-b5fe217c-fff3-47fd-be0b-31b00faba1f3-000000@email.amazonses.com> <51E33FFE.3010200@asianux.com> <0000013fe2b1bd10-efcc76b5-f75b-4a45-a278-a318e87b2571-000000@email.amazonses.com> <51E49982.30402@asianux.com> <0000013fed18f0f2-cb1afad0-560e-4da5-b865-29e854ce5813-000000@email.amazonses.com> <51E73340.5020703@asianux.com> <0000013ff204c901-636c5864-ec23-4c31-a308-d7fd58016364-000000@email.amazonses.com> <51E88D6F.3000905@gmail.com> <0000013ff73b8090-4aef0610-aff7-420a-8a7d-e1120607c382-000000@email.amazonses.com>
In-Reply-To: <0000013ff73b8090-4aef0610-aff7-420a-8a7d-e1120607c382-000000@email.amazonses.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Chen Gang F T <chen.gang.flying.transformer@gmail.com>, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org

On 07/19/2013 10:00 PM, Christoph Lameter wrote:
> On Fri, 19 Jul 2013, Chen Gang F T wrote:
> 
>>> The fundamental issue is that typically ints are used for flags and I
>>> would like to keep it that way. Changing the constants in slab.h and the
>>> allocator code to be unsigned int instead of unsigned long wont be that
>>> much of a deal.
>>>
>>
>> At least, we need use 'unsigned' instead of 'signed'.
> 
> Ok.
> 
>> Hmm... Things maybe seem more complex, please see bellow:
>>
>> For 'SLAB_RED_ZONE' (or the other constants), they also can be assigned
>> to "struct kmem_cache" member variable 'flags'.
>>
>> But for "struct kmem_cache", it has 2 different definitions, they share
>> with the 'SLAB_RED_ZONE' (or the other constants).
>>
>> One defines 'flags' as 'unsigned int' in "include/linux/slab_def.h"
>>
>>  16 /*
>>  17  * struct kmem_cache
>>  18  *
>>  19  * manages a cache.
>>  20  */
>>  21
>>  22 struct kmem_cache {
>>  23 /* 1) Cache tunables. Protected by cache_chain_mutex */
>>  24         unsigned int batchcount;
>>  25         unsigned int limit;
>>  26         unsigned int shared;
>>  27
>>  28         unsigned int size;
>>  29         u32 reciprocal_buffer_size;
>>  30 /* 2) touched by every alloc & free from the backend */
>>  31
>>  32         unsigned int flags;             /* constant flags */
>>  33         unsigned int num;               /* # of objs per slab */
>> ...
>>
>> The other defines 'flags' as 'unsigned long' in "include/linux/slub_def.h"
>> (but from its comments, it even says it is for 'Slab' cache management !!)
> 
> SLUB is slab allocator so there is nothing wrong with that.
> 

OK, thanks.

>> Maybe it is also related with our discussion ('unsigned int' or 'unsigned long') ?
> 
> Well we can make this uniformly unsigned int or long I guess. What would
> be the benefits of one vs the other?
> 

Yeah, need let the 2 'flags' with the same type: "make this uniformly
unsigned int or long".


Hmm... Flags variable is always the solid length variable, so it is not
suitable to use 'unsigned long' which length depends on 32/64 machine
automatically.

If the 'unsigned int' is not enough, we need use 'unsigned long long'
instead of. Else (it's enough), better to still use 'unsigned int' to
save memory usage.

'unsigned long' is useful(necessary) for some variables (e.g. address
related variables), but is not suitable for the always solid length
variable.


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
