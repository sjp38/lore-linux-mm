Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 835F46B000C
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 20:05:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a9so3760288pff.0
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 17:05:17 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id h61-v6si1665287pld.816.2018.02.10.17.05.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 17:05:16 -0800 (PST)
Subject: Re: [PATCH 4/6] Protectable Memory
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-5-igor.stoppa@huawei.com>
 <921d4c76-703f-dd41-0451-599441d23c1d@infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <b355e37e-4bc1-526b-8853-5401588f177f@huawei.com>
Date: Sun, 11 Feb 2018 03:04:57 +0200
MIME-Version: 1.0
In-Reply-To: <921d4c76-703f-dd41-0451-599441d23c1d@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 05/02/18 00:06, Randy Dunlap wrote:
> On 02/04/2018 08:47 AM, Igor Stoppa wrote:

[...]

>> + * pmalloc_create_pool - create a new protectable memory pool -
> 
> Drop trailing " -".

yes

>> + * @name: the name of the pool, must be unique
> 
> Is that enforced?  Will return NULL if @name is duplicated?

ok, I'll state it more clearly that it's enforced

[...]

>> + * @pool: handler to the pool to be used for memory allocation
> 
>              handle (I think)

yes, also for all the other ones

[...]

>> + * avoid sleping during allocation.
> 
>             sleeping

yes

[...]

>> + * opposite to what is allocated on-demand when pmalloc runs out of free
> 
>       opposed to

yes

>> + * space already existing in the pool and has to invoke vmalloc.
>> + *
>> + * Returns true if the vmalloc call was successful, false otherwise.
> 
> Where is the allocated memory (pointer)?  I.e., how does the caller know
> where that memory is?
> Oh, that memory isn't yet available to the caller until it calls pmalloc(), right?

yes, it's a way to:
- preemptively beef up the pool, before entering atomic context
(unlikely that it will be needed, but possible), so that there is no
need to allocate extra pages (assuming one can estimate the max memory
that will be requested)
- avoid fragmentation caused by allocating smaller groups of pages


I'll add explanation for this.

[...]

>> + * @size: amount of memory (in bytes) requested
>> + * @gfp: flags for page allocation
>> + *
>> + * Allocates memory from an unprotected pool. If the pool doesn't have
>> + * enough memory, and the request did not include GFP_ATOMIC, an attempt
>> + * is made to add a new chunk of memory to the pool
>> + * (a multiple of PAGE_SIZE), in order to fit the new request.
> 
>                                              fill
> What if @size is > PAGE_SIZE?

Nothing special, it gets rounded up to the nearest multiple of
PAGE_SIZE. vmalloc doesn't have only drawbacks ;-)

[...]

>> + * Returns the pointer to the memory requested upon success,
>> + * NULL otherwise (either no memory available or pool already read-only).
> 
> It would be good to use the
>     * Return:
> kernel-doc notation for return values.

yes, good point, I'm fixing it everywhere in the patchset

[...]

>> + * will be availabel for further allocations.
> 
>               available

yes

[...]

>> +/**
> 
> /** means that the following comments are kernel-doc notation, but these
> comments are not, so just use /* there, please.

yes, also to the others

[...]

>> +	/* is_pmalloc_object gets called pretty late, so chances are high
>> +	 * that the object is indeed of vmalloc type
>> +	 */
> 
> Multi-line comment style is
> 	/*
> 	 * comment1
> 	 * comment..N
> 	 */

yes, also to the others

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
