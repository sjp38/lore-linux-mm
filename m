Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6C8F6B0006
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 17:26:44 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id k18so10051162otj.10
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 14:26:44 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i2si2306505ote.527.2018.03.12.14.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 14:26:43 -0700 (PDT)
Subject: Re: [PATCH 4/7] Protectable Memory
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-5-igor.stoppa@huawei.com>
 <20180312191314.GA29191@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <b481f817-dad4-6bed-15bb-1bda4396b6b6@huawei.com>
Date: Mon, 12 Mar 2018 23:25:54 +0200
MIME-Version: 1.0
In-Reply-To: <20180312191314.GA29191@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: david@fromorbit.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 12/03/18 21:13, Matthew Wilcox wrote:
> On Wed, Feb 28, 2018 at 10:06:17PM +0200, Igor Stoppa wrote:
>> struct gen_pool *pmalloc_create_pool(const char *name,
>> 					 int min_alloc_order);
>> int is_pmalloc_object(const void *ptr, const unsigned long n);
>> bool pmalloc_prealloc(struct gen_pool *pool, size_t size);
>> void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp);
>> static inline void *pzalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
>> static inline void *pmalloc_array(struct gen_pool *pool, size_t n,
>> 				  size_t size, gfp_t flags)
>> static inline void *pcalloc(struct gen_pool *pool, size_t n,
>> 			    size_t size, gfp_t flags)
>> static inline char *pstrdup(struct gen_pool *pool, const char *s, gfp_t gfp)
>> int pmalloc_protect_pool(struct gen_pool *pool);
>> static inline void pfree(struct gen_pool *pool, const void *addr)
>> int pmalloc_destroy_pool(struct gen_pool *pool);
> 
> Do you have users for all these functions?  I'm particularly sceptical of
> pfree().

The typical case is when rolling back allocations, on an error path.
For example, with SELinux, the userspace provides the policy, which gets
processed and converted into a policyDB, where every policy maps to
several structures allocated dynamically.

The allocation is not transactional. In case a policy turns out to be
bad/broken, while being interpreted, those structures that were
initially allocated for that policy, must be freed.

Since pmalloc is meant to be a drop in replacement for k/vmalloc, it
needs to provide also pfree.

>  To my mind, a user wants to:
> 
> pmalloc_create();
> pmalloc(); * N
> pmalloc_protect();
> ...
> pmalloc_destroy();

This is the simplest case, but also the error path must be supported.

> I don't mind the pstrdup, pcalloc, pmalloc_array, pzalloc variations, but

All those functions turned out to be necessary when converting SELinux
to pmalloc.
Yes, I haven't published this code yet, but I was hoping to first be
done with pmalloc and then move on to SELinux, which I suspect will be
harder to chew :-/

> I don't know why you need is_pmalloc_object().

Because of hardened usercopy [1]:


On 23/05/17 00:38, Kees Cook wrote:

[...]

> I'd like hardened usercopy to grow knowledge of these
> allocations so we can bounds-check objects. Right now, mm/usercopy.c
> just looks at PageSlab(page) to decide if it should do slab checks. I
> think adding a check for this type of object would be very important
> there.



[1] http://www.openwall.com/lists/kernel-hardening/2017/05/23/17


--
igor
