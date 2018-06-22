Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 502496B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 05:43:08 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w1-v6so3415963plq.8
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 02:43:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f70-v6sor1756143pgc.8.2018.06.22.02.43.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 02:43:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1529659626-12660-1-git-send-email-thunder.leizhen@huawei.com>
References: <1529659626-12660-1-git-send-email-thunder.leizhen@huawei.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 22 Jun 2018 11:42:43 +0200
Message-ID: <CACT4Y+Y3cLwVroPri8kKE+wG+YCMOynfzJcL_CjXRXn1omRF_Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] kasan: fix shadow_size calculation error in kasan_module_alloc
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhen Lei <thunder.leizhen@huawei.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>, Libin <huawei.libin@huawei.com>

On Fri, Jun 22, 2018 at 11:27 AM, Zhen Lei <thunder.leizhen@huawei.com> wrote:
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
> memset(ptr, 0, mod->core_layout.size);          //crashed
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
>         void *ret;
> +       size_t scaled_size;
>         size_t shadow_size;
>         unsigned long shadow_start;
>
>         shadow_start = (unsigned long)kasan_mem_to_shadow(addr);
> -       shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT,
> -                       PAGE_SIZE);
> +       scaled_size = (size + KASAN_SHADOW_MASK) >> KASAN_SHADOW_SCALE_SHIFT;
> +       shadow_size = round_up(scaled_size, PAGE_SIZE);
>
>         if (WARN_ON(!PAGE_ALIGNED(shadow_start)))
>                 return -EINVAL;


Hi Zhen,

Yes, this is a bug. Thanks for fixing it!

Reviewed-by: Dmitriy Vyukov <dvyukov@google.com>
