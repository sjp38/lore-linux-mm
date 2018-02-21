Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93A826B0008
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 07:39:00 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id o61so731205pld.5
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 04:39:00 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0101.outbound.protection.outlook.com. [104.47.1.101])
        by mx.google.com with ESMTPS id n68si6086952pga.524.2018.02.21.04.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Feb 2018 04:38:59 -0800 (PST)
Subject: Re: [PATCH 1/4] vmalloc: add vm_flags argument to internal
 __vmalloc_node()
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <20180221122444.GA11791@bombadil.infradead.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <6e4ab6e1-7ba5-4b18-9399-75eb593050ac@virtuozzo.com>
Date: Wed, 21 Feb 2018 15:39:26 +0300
MIME-Version: 1.0
In-Reply-To: <20180221122444.GA11791@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com



On 02/21/2018 03:24 PM, Matthew Wilcox wrote:
> On Tue, Jan 23, 2018 at 01:55:22PM +0300, Konstantin Khlebnikov wrote:
>> This allows to set VM_USERMAP in vmalloc_user() and vmalloc_32_user()
>> directly at allocation and avoid find_vm_area() call.
> 
> While reviewing this patch, I came across this infelicity ...
> 
> have I understood correctly?
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index e13d911251e7..9060f80b4a41 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -631,11 +631,10 @@ int kasan_module_alloc(void *addr, size_t size)
>  	ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
>  			shadow_start + shadow_size,
>  			GFP_KERNEL | __GFP_ZERO,
> -			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
> +			PAGE_KERNEL, VM_NO_GUARD | VM_KASAN, NUMA_NO_NODE,
>  			__builtin_return_address(0));
>  
>  	if (ret) {
> -		find_vm_area(addr)->flags |= VM_KASAN;

addr != ret
That's different vm areas.

>  		kmemleak_ignore(ret);
>  		return 0;
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
