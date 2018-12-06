Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FABC6B7967
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 05:14:02 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id k133so299705ite.4
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 02:14:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c30sor16004627jak.4.2018.12.06.02.14.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 02:14:00 -0800 (PST)
MIME-Version: 1.0
References: <201812051256.eEMKJAdG%fengguang.wu@intel.com>
In-Reply-To: <201812051256.eEMKJAdG%fengguang.wu@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 6 Dec 2018 11:13:48 +0100
Message-ID: <CAAeHK+yGVq7YdLKtgaqD1fDLSo_4ziZtftVr8L9+KUhVqYnnGg@mail.gmail.com>
Subject: Re: [mmotm:master 48/283] mm/kasan/common.c:481:17: error:
 'KASAN_SHADOW_INIT' undeclared; did you mean 'KASAN_SHADOW_END'?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Dec 5, 2018 at 5:52 AM kbuild test robot <lkp@intel.com> wrote:
>
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   1b1ce5151f3dd9a5bc989207ac56e96dcb84bef4
> commit: e76ec930bbe0906735fa147736ab051a8e256b1b [48/283] kasan: initialize shadow to 0xff for tag-based mode
> config: x86_64-randconfig-x013-12041647 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         git checkout e76ec930bbe0906735fa147736ab051a8e256b1b
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>    mm/kasan/common.c: In function 'kasan_module_alloc':
> >> mm/kasan/common.c:481:17: error: 'KASAN_SHADOW_INIT' undeclared (first use in this function); did you mean 'KASAN_SHADOW_END'?
>       __memset(ret, KASAN_SHADOW_INIT, shadow_size);
>                     ^~~~~~~~~~~~~~~~~
>                     KASAN_SHADOW_END
>    mm/kasan/common.c:481:17: note: each undeclared identifier is reported only once for each function it appears in
>
> vim +481 mm/kasan/common.c

Will fix in v13.

>
>    459
>    460  int kasan_module_alloc(void *addr, size_t size)
>    461  {
>    462          void *ret;
>    463          size_t scaled_size;
>    464          size_t shadow_size;
>    465          unsigned long shadow_start;
>    466
>    467          shadow_start = (unsigned long)kasan_mem_to_shadow(addr);
>    468          scaled_size = (size + KASAN_SHADOW_MASK) >> KASAN_SHADOW_SCALE_SHIFT;
>    469          shadow_size = round_up(scaled_size, PAGE_SIZE);
>    470
>    471          if (WARN_ON(!PAGE_ALIGNED(shadow_start)))
>    472                  return -EINVAL;
>    473
>    474          ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
>    475                          shadow_start + shadow_size,
>    476                          GFP_KERNEL,
>    477                          PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
>    478                          __builtin_return_address(0));
>    479
>    480          if (ret) {
>  > 481                  __memset(ret, KASAN_SHADOW_INIT, shadow_size);
>    482                  find_vm_area(addr)->flags |= VM_KASAN;
>    483                  kmemleak_ignore(ret);
>    484                  return 0;
>    485          }
>    486
>    487          return -ENOMEM;
>    488  }
>    489
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
