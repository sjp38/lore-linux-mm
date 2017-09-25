Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 135BE6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:18:30 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x85so8728784oix.3
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 09:18:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2sor162085otq.495.2017.09.25.09.18.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 09:18:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170925145932.GA17029@bombadil.infradead.org>
References: <20170921231818.10271-1-nefelim4ag@gmail.com> <20170921231818.10271-2-nefelim4ag@gmail.com>
 <20170925145932.GA17029@bombadil.infradead.org>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Mon, 25 Sep 2017 19:17:48 +0300
Message-ID: <CAGqmi77wkSyHQiVj23Gfqw1drYi52f72LXVP6Do4Aje+Rq0apg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] xxHash: create arch dependent 32/64-bit xxhash()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

2017-09-25 17:59 GMT+03:00 Matthew Wilcox <willy@infradead.org>:
> On Fri, Sep 22, 2017 at 02:18:17AM +0300, Timofey Titovets wrote:
>> diff --git a/include/linux/xxhash.h b/include/linux/xxhash.h
>> index 9e1f42cb57e9..195a0ae10e9b 100644
>> --- a/include/linux/xxhash.h
>> +++ b/include/linux/xxhash.h
>> @@ -76,6 +76,7 @@
>>  #define XXHASH_H
>>
>>  #include <linux/types.h>
>> +#include <linux/bitops.h> /* BITS_PER_LONG */
>>
>>  /*-****************************
>>   * Simple Hash Functions
>
> Huh?  linux/types.h already brings in BITS_PER_LONG.  Look:
>
> linux/types.h
>   uapi/linux/types.h
>   uapi/asm/types.h
>   uapi/asm-generic/types.h
>   uapi/asm-generic/int-ll64.h
>   asm/bitsperlong.h

Will fix that, thanks.

>> @@ -107,6 +108,29 @@ uint32_t xxh32(const void *input, size_t length, uint32_t seed);
>>   */
>>  uint64_t xxh64(const void *input, size_t length, uint64_t seed);
>>
>> +#if BITS_PER_LONG == 64
>> +typedef      u64     xxhash_t;
>> +#else
>> +typedef      u32     xxhash_t;
>> +#endif
>
> This is a funny way to spell 'unsigned long' ...

i'm just want some strict and obvious types for in memory hashing.
And that just looks pretty for my eye (IMHO),
I will replace that with 'unsigned long' of course and drop xxhash_t completely,
as you find that unacceptable.

>> +/**
>> + * xxhash() - calculate 32/64-bit hash based on cpu word size
>> + *
>> + * @input:  The data to hash.
>> + * @length: The length of the data to hash.
>> + * @seed:   The seed can be used to alter the result predictably.
>> + *
>> + * This function always work as xxh32() for 32-bit systems
>> + * and as xxh64() for 64-bit systems.
>> + * Because result depends on cpu work size,
>> + * the main proporse of that function is for  in memory hashing.
>> + *
>> + * Return:  32/64-bit hash of the data.
>> + */
>> +
>
>> +xxhash_t xxhash(const void *input, size_t length, uint64_t seed)
>> +{
>> +#if BITS_PER_LONG == 64
>> +     return xxh64(input, length, seed);
>> +#else
>> +     return xxh32(input, length, seed);
>> +#endif
>> +}
>
> Let's move that to the header file and make it a static inline.  That way
> it doesn't need to be an EXPORT_SYMBOL.

Agreed, thanks.

> Also, I think the kerneldoc could do with a bit of work.  Try this:
>
> /**
>  * xxhash() - calculate wordsize hash of the input with a given seed
>  * @input:  The data to hash.
>  * @length: The length of the data to hash.
>  * @seed:   The seed can be used to alter the result predictably.
>  *
>  * If the hash does not need to be comparable between machines with
>  * different word sizes, this function will call whichever of xxh32()
>  * or xxh64() is faster.
>  *
>  * Return:  wordsize hash of the data.
>  */

Replace with your version, thanks.

> static inline
> unsigned long xxhash(const void *input, size_t length, unsigned long seed)
> {
> #if BITS_PER_LONG == 64
>         return xxh64(input, length, seed);
> #else
>         return xxh32(input, length, seed);
> #endif
> }


-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
