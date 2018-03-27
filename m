Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2182E6B0011
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 07:43:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z15so1288954wrh.10
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 04:43:28 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id m12si828177wrj.364.2018.03.27.04.43.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 04:43:26 -0700 (PDT)
Subject: Re: [PATCH 3/6] Protectable Memory
References: <20180327015524.14318-1-igor.stoppa@huawei.com>
 <20180327015524.14318-4-igor.stoppa@huawei.com>
 <20180327023110.GD10054@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <4bafdb91-307b-ff4c-5432-cf5a39dfbb8b@huawei.com>
Date: Tue, 27 Mar 2018 14:43:19 +0300
MIME-Version: 1.0
In-Reply-To: <20180327023110.GD10054@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: keescook@chromium.org, mhocko@kernel.org, david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com



On 27/03/18 05:31, Matthew Wilcox wrote:
> On Tue, Mar 27, 2018 at 04:55:21AM +0300, Igor Stoppa wrote:
>> +static inline void *pmalloc_array_align(struct pmalloc_pool *pool,
>> +					size_t n, size_t size,
>> +					short int align_order)
>> +{
> 
> You're missing:
> 
>         if (size != 0 && n > SIZE_MAX / size)
>                 return NULL;


ACK

>> +	return pmalloc_align(pool, n * size, align_order);
>> +}
> 
>> +static inline void *pcalloc_align(struct pmalloc_pool *pool, size_t n,
>> +				  size_t size, short int align_order)
>> +{
>> +	return pzalloc_align(pool, n * size, align_order);
>> +}
> 
> Ditto.

ok

>> +static inline void *pcalloc(struct pmalloc_pool *pool, size_t n,
>> +			    size_t size)
>> +{
>> +	return pzalloc_align(pool, n * size, PMALLOC_ALIGN_DEFAULT);
>> +}
> 
> If you make this one:
> 
> 	return pcalloc_align(pool, n, size, PMALLOC_ALIGN_DEFAULT)

ok

> then you don't need the check in this function.
> 
> Also, do we really need 'align' as a parameter to the allocator functions
> rather than to the pool?

I actually wrote it first without, but then I wondered how to deal if
one needs to allocate both small fry structures and then something
larger that is page aligned.

However it's just speculation, I do not have any real example.

> I'd just reuse ARCH_KMALLOC_MINALIGN from slab.h as the alignment, and
> then add the special alignment options when we have a real user for them.

ok

--
thanks, igor
