Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF9F6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 12:55:22 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w74-v6so14220722qka.4
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:55:22 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0133.outbound.protection.outlook.com. [104.47.0.133])
        by mx.google.com with ESMTPS id h18-v6si4327985qtb.333.2018.06.25.09.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 09:55:20 -0700 (PDT)
Subject: Re: [PATCH 1/1] kasan: fix shadow_size calculation error in
 kasan_module_alloc
References: <1529659626-12660-1-git-send-email-thunder.leizhen@huawei.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4a19c76c-54b5-1a1c-0576-8222957d3873@virtuozzo.com>
Date: Mon, 25 Jun 2018 19:56:48 +0300
MIME-Version: 1.0
In-Reply-To: <1529659626-12660-1-git-send-email-thunder.leizhen@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhen Lei <thunder.leizhen@huawei.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: Hanjun Guo <guohanjun@huawei.com>, Libin <huawei.libin@huawei.com>, Andrew Morton <akpm@linux-foundation.org>

On 06/22/2018 12:27 PM, Zhen Lei wrote:
> There is a special case that the size is "(N << KASAN_SHADOW_SCALE_SHIFT)
> Pages plus X", the value of X is [1, KASAN_SHADOW_SCALE_SIZE-1]. The
> operation "size >> KASAN_SHADOW_SCALE_SHIFT" will drop X, and the roundup
> operation can not retrieve the missed one page. For example: size=0x28006,
> PAGE_SIZE=0x1000, KASAN_SHADOW_SCALE_SHIFT=3, we will get
> shadow_size=0x5000, but actually we need 6 pages.
> 
> shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT, PAGE_SIZE);
> 
> This can lead kernel to be crashed, when kasan is enabled and the value
> of mod->core_layout.size or mod->init_layout.size is like above. Because
> the shadow memory of X has not been allocated and mapped.
> 
> move_module:
> ptr = module_alloc(mod->core_layout.size);
> ...
> memset(ptr, 0, mod->core_layout.size);		//crashed
> 
> Unable to handle kernel paging request at virtual address ffff0fffff97b000
> ......
> Call trace:
> [<ffff8000004694d4>] __asan_storeN+0x174/0x1a8
> [<ffff800000469844>] memset+0x24/0x48
> [<ffff80000025cf28>] layout_and_allocate+0xcd8/0x1800
> [<ffff80000025dbe0>] load_module+0x190/0x23e8
> [<ffff8000002601e8>] SyS_finit_module+0x148/0x180
> 
> Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>


>  mm/kasan/kasan.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 81a2f45..f5ac4ac 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -427,12 +427,13 @@ void kasan_kfree_large(const void *ptr)
>  int kasan_module_alloc(void *addr, size_t size)
>  {
>  	void *ret;
> +	size_t scaled_size;
>  	size_t shadow_size;
>  	unsigned long shadow_start;
> 
>  	shadow_start = (unsigned long)kasan_mem_to_shadow(addr);
> -	shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT,
> -			PAGE_SIZE);
> +	scaled_size = (size + KASAN_SHADOW_MASK) >> KASAN_SHADOW_SCALE_SHIFT;
> +	shadow_size = round_up(scaled_size, PAGE_SIZE);
> 
>  	if (WARN_ON(!PAGE_ALIGNED(shadow_start)))
>  		return -EINVAL;
> --
> 1.8.3
> 
> 
