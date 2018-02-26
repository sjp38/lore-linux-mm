Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCABA6B0006
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:45:07 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u65so8593107wrc.8
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:45:07 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id s12si1262172wrg.395.2018.02.26.10.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 10:45:06 -0800 (PST)
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-2-igor.stoppa@huawei.com>
 <0897d235-db55-3d3c-12be-34a97debb921@gmail.com>
 <4f77b269-c2eb-a8d2-1326-900d00229268@huawei.com>
 <14be8222-766f-50e6-83ec-bcbefa04ba44@gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <9f242f90-0d6b-4647-1a9e-242e03674079@huawei.com>
Date: Mon, 26 Feb 2018 20:44:32 +0200
MIME-Version: 1.0
In-Reply-To: <14be8222-766f-50e6-83ec-bcbefa04ba44@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J Freyensee <why2jjj.linux@gmail.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 26/02/18 19:32, J Freyensee wrote:
> My replies also inlined.
> 
> On 2/26/18 4:09 AM, Igor Stoppa wrote:

[...]

> But some of the code looks API'like to me, partly because of 
> all the function header documentation, which thank you for that, but I 
> wasn't sure where you drew your "API line" where the checks would be.

static and, even more, inlined static functions are not API, if found in
the .c file.


>> Is it assuming too much that the function will be used correctly, inside
>> the module it belongs to?
>>
>> And even at API level, I'd tend to say that if there are chances that
>> the data received is corrupted, then it should be sanitized, but otherwise,
>> why adding overhead?
> 
> It's good secure coding practice to check your parameters, you are 
> adding code to a security module after all ;-).

genalloc is not a security module :-P

it seems to be used in various places and for different purposes, also
depending on the architecture

For this reason I'm reluctant to add overhead.

> If it's brand-new code entering the kernel, it's better to err on the 
> side of having the extra checks and have a maintainer tell you to remove 
> it than the other way around- especially since this code is part of the 
> LSM solution.A  What's worse- a tad bit of overhead catching a 
> corner-case scenario that can be more easily fixed or something not 
> caught that makes the kernel unstable?

ok, fair enough

[...]

>> If I really have to pick a place where to do the test, it's at API
>> level,
> 
> I agree, and if that is the case, I'm fine.

so I'll make sue that the API does sanitation

>> where the user of the API might fail to notice that the creation
>> of a pool failed and try to get memory from a non-existing pool.
>> That is the only scenario I can think of, where bogus data would be
>> received.
>>
>>>>    	return chunk->end_addr - chunk->start_addr + 1;
>>>>    }
>>>>    
>>>> -static int set_bits_ll(unsigned long *addr, unsigned long mask_to_set)
>>>> +
>>>> +/**
>>>> + * set_bits_ll() - based on value and mask, sets bits at address
>>>> + * @addr: where to write
>>>> + * @mask: filter to apply for the bits to alter
>>>> + * @value: actual configuration of bits to store
>>>> + *
>>>> + * Return:
>>>> + * * 0		- success
>>>> + * * -EBUSY	- otherwise
>>>> + */
>>>> +static int set_bits_ll(unsigned long *addr,
>>>> +		       unsigned long mask, unsigned long value)
>>>>    {
>>>> -	unsigned long val, nval;
>>>> +	unsigned long nval;
>>>> +	unsigned long present;
>>>> +	unsigned long target;
>>>>    
>>>>    	nval = *addr;
>>> Same issue here with addr.
>> Again, I am more leaning toward believing that the user of the API might
>> forget to check for errors,
> 
> Same in agreement, so if that is the case, I'm ok.A  It was a little hard 
> to tell what is exactly your API is.A  I'm used to reviewing kernel code 
> where important API-like functions were heavily documented, and inner 
> routines were not...so seeing the function documentation (which is a 
> good thing :-)) made me think this was some sort of new API code I was 
> looking at.
it's static, therefore no API

> 
>> and pass a NULL pointer as pool, than to
>> believe something like this would happen.
>>
>> This is an address obtained from data managed automatically by the library.
>>
>> Can you please explain why you think it would be NULL?
> 
> Why would it be NULL?A  I don't know, I'm not intimately familiar with 
> the code; but I default to implementing code defensively.A  But I'll turn 
> the question around on you- why would it NOT be NULL?A  Are you sure this 
> will never be NULL?A  Are you going to trust the library that it always 
> provides a good address?A  You should add to your function header 
> documentation why addr will NOT be NULL.

ok, I can add the explanation
which is: the corresponding memory is allocated when a pool is created.
should the allocation fail, the pool creation will fail consequently

The only cases which can cause this to be NULL within a pool are:
* accidental corruption
* attacker tampering with kernel memory

However they are both quite unlikely:
* accidental corruption should not happen so easily and, in case it
happens, it's likely to plow also some surrounding memory.
* this is just metadata, supposed to be useful mostly before the pool is
write-protected. If an attacker is capable of altering arbitrary kernel
data memory, there are far better targets.

[...]

>>>> +	/*
>>>> +	 * Prepare for writing the initial part of the allocation, from
>>>> +	 * starting entry, to the end of the UL bitmap element which
>>>> +	 * contains it. It might be larger than the actual allocation.
>>>> +	 */
>>>> +	start_bit = ENTRIES_TO_BITS(start_entry);
>>>> +	end_bit = ENTRIES_TO_BITS(start_entry + nentries);
>>>> +	nbits = ENTRIES_TO_BITS(nentries);
>>> these statements won't make any sense if start_entry and nentries are
>>> negative values, which is possible based on the function definition
>>> alter_bitmap_ll().A  Am I missing something that it's ok for these
>>> parameters to be negative?
>> This patch is extending the handling of the bitmap, it's not trying to
>> rewrite genalloc, thus it tries to not alter parts which are unrelated.
>> Like the type of parameters passed.
>>
>> What you are suggesting is a further cleanup of genalloc.
>> I'm not against it, but it's unrelated to this patchset.
> 
> OK, very reasonable.A  Then I would think this would be a case to add a 
> check for negative values in the function parameters start_entry and 
> nentries as it's possible (though maybe not realistic) to have negative 
> values supplied, especially if there is currently no active maintainer 
> for genalloc().A  Since you are fitting new code to genalloc's behavior 
> and this is a security module, I'll err on the side of checking the 
> parameters for bad values, or document in your function header comments 
> why it is expected for these parameters to never have negative values.

I'll figure out which alternative I dislike the least :-)

Probably just fix the data types in a separate patch.
This patch for genalloc has generated various comments which are
actually more about the original implementation than what I'm adding.


--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
