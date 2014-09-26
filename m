Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 44EA06B0039
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 13:12:10 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id cm18so6446638qab.14
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:12:10 -0700 (PDT)
Received: from mail-qc0-x22d.google.com (mail-qc0-x22d.google.com [2607:f8b0:400d:c01::22d])
        by mx.google.com with ESMTPS id 32si6595800qgc.1.2014.09.26.10.12.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 10:12:09 -0700 (PDT)
Received: by mail-qc0-f173.google.com with SMTP id r5so4845420qcx.18
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:12:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411562649-28231-13-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com> <1411562649-28231-13-git-send-email-a.ryabinin@samsung.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 26 Sep 2014 10:11:49 -0700
Message-ID: <CACT4Y+ZnTqW7=NL5YNwLV3uRw+1_8g7vvrZ=3Qv2HB=VZKuj=w@mail.gmail.com>
Subject: Re: [PATCH v3 12/13] lib: add kasan test module
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org

Looks good to me.

On Wed, Sep 24, 2014 at 5:44 AM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> This is a test module doing varios nasty things like
> out of bounds accesses, use after free. It is usefull for testing
> kernel debugging features like kernel address sanitizer.
>
> It mostly concentrates on testing of slab allocator, but we
> might want to add more different stuff here in future (like
> stack/global variables out of bounds accesses and so on).
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  lib/Kconfig.kasan |   8 ++
>  lib/Makefile      |   1 +
>  lib/test_kasan.c  | 254 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 263 insertions(+)
>  create mode 100644 lib/test_kasan.c
>
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index d16b899..faddb0e 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -19,4 +19,12 @@ config KASAN_SHADOW_OFFSET
>         hex
>         default 0xdfffe90000000000 if X86_64
>
> +config TEST_KASAN
> +       tristate "Module for testing kasan for bug detection"
> +       depends on m
> +       help
> +         This is a test module doing varios nasty things like
> +         out of bounds accesses, use after free. It is usefull for testing
> +         kernel debugging features like kernel address sanitizer.
> +
>  endif
> diff --git a/lib/Makefile b/lib/Makefile
> index 84a56f7..d620d27 100644
> --- a/lib/Makefile
> +++ b/lib/Makefile
> @@ -35,6 +35,7 @@ obj-$(CONFIG_TEST_MODULE) += test_module.o
>  obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
>  obj-$(CONFIG_TEST_BPF) += test_bpf.o
>  obj-$(CONFIG_TEST_FIRMWARE) += test_firmware.o
> +obj-$(CONFIG_TEST_KASAN) += test_kasan.o
>
>  ifeq ($(CONFIG_DEBUG_KOBJECT),y)
>  CFLAGS_kobject.o += -DDEBUG
> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> new file mode 100644
> index 0000000..66a04eb
> --- /dev/null
> +++ b/lib/test_kasan.c
> @@ -0,0 +1,254 @@
> +/*
> + *
> + * Copyright (c) 2014 Samsung Electronics Co., Ltd.
> + * Author: Andrey Ryabinin <a.ryabinin@samsung.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + */
> +
> +#define pr_fmt(fmt) "kasan test: %s " fmt, __func__
> +
> +#include <linux/kernel.h>
> +#include <linux/printk.h>
> +#include <linux/slab.h>
> +#include <linux/string.h>
> +#include <linux/module.h>
> +
> +static noinline void __init kmalloc_oob_right(void)
> +{
> +       char *ptr;
> +       size_t size = 123;
> +
> +       pr_info("out-of-bounds to right\n");
> +       ptr = kmalloc(size , GFP_KERNEL);
> +       if (!ptr) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       ptr[size] = 'x';
> +       kfree(ptr);
> +}
> +
> +static noinline void __init kmalloc_oob_left(void)
> +{
> +       char *ptr;
> +       size_t size = 15;
> +
> +       pr_info("out-of-bounds to left\n");
> +       ptr = kmalloc(size, GFP_KERNEL);
> +       if (!ptr) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       *ptr = *(ptr - 1);
> +       kfree(ptr);
> +}
> +
> +static noinline void __init kmalloc_node_oob_right(void)
> +{
> +       char *ptr;
> +       size_t size = 4096;
> +
> +       pr_info("kmalloc_node(): out-of-bounds to right\n");
> +       ptr = kmalloc_node(size , GFP_KERNEL, 0);
> +       if (!ptr) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       ptr[size] = 0;
> +       kfree(ptr);
> +}
> +
> +static noinline void __init kmalloc_large_oob_rigth(void)
> +{
> +       char *ptr;
> +       size_t size = KMALLOC_MAX_CACHE_SIZE + 10;
> +
> +       pr_info("kmalloc large allocation: out-of-bounds to right\n");
> +       ptr = kmalloc(size , GFP_KERNEL);
> +       if (!ptr) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       ptr[size] = 0;
> +       kfree(ptr);
> +}
> +
> +static noinline void __init kmalloc_oob_krealloc_more(void)
> +{
> +       char *ptr1, *ptr2;
> +       size_t size1 = 17;
> +       size_t size2 = 19;
> +
> +       pr_info("out-of-bounds after krealloc more\n");
> +       ptr1 = kmalloc(size1, GFP_KERNEL);
> +       ptr2 = krealloc(ptr1, size2, GFP_KERNEL);
> +       if (!ptr1 || !ptr2) {
> +               pr_err("Allocation failed\n");
> +               kfree(ptr1);
> +               return;
> +       }
> +
> +       ptr2[size2] = 'x';
> +       kfree(ptr2);
> +}
> +
> +static noinline void __init kmalloc_oob_krealloc_less(void)
> +{
> +       char *ptr1, *ptr2;
> +       size_t size1 = 17;
> +       size_t size2 = 15;
> +
> +       pr_info("out-of-bounds after krealloc less\n");
> +       ptr1 = kmalloc(size1, GFP_KERNEL);
> +       ptr2 = krealloc(ptr1, size2, GFP_KERNEL);
> +       if (!ptr1 || !ptr2) {
> +               pr_err("Allocation failed\n");
> +               kfree(ptr1);
> +               return;
> +       }
> +       ptr2[size1] = 'x';
> +       kfree(ptr2);
> +}
> +
> +static noinline void __init kmalloc_oob_16(void)
> +{
> +       struct {
> +               u64 words[2];
> +       } *ptr1, *ptr2;
> +
> +       pr_info("kmalloc out-of-bounds for 16-bytes access\n");
> +       ptr1 = kmalloc(sizeof(*ptr1) - 3, GFP_KERNEL);
> +       ptr2 = kmalloc(sizeof(*ptr2), GFP_KERNEL);
> +       if (!ptr1 || !ptr2) {
> +               pr_err("Allocation failed\n");
> +               kfree(ptr1);
> +               kfree(ptr2);
> +               return;
> +       }
> +       *ptr1 = *ptr2;
> +       kfree(ptr1);
> +       kfree(ptr2);
> +}
> +
> +static noinline void __init kmalloc_oob_in_memset(void)
> +{
> +       char *ptr;
> +       size_t size = 666;
> +
> +       pr_info("out-of-bounds in memset\n");
> +       ptr = kmalloc(size, GFP_KERNEL);
> +       if (!ptr) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       memset(ptr, 0, size+5);
> +       kfree(ptr);
> +}
> +
> +static noinline void __init kmalloc_uaf(void)
> +{
> +       char *ptr;
> +       size_t size = 10;
> +
> +       pr_info("use-after-free\n");
> +       ptr = kmalloc(size, GFP_KERNEL);
> +       if (!ptr) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       kfree(ptr);
> +       *(ptr + 8) = 'x';
> +}
> +
> +static noinline void __init kmalloc_uaf_memset(void)
> +{
> +       char *ptr;
> +       size_t size = 33;
> +
> +       pr_info("use-after-free in memset\n");
> +       ptr = kmalloc(size, GFP_KERNEL);
> +       if (!ptr) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       kfree(ptr);
> +       memset(ptr, 0, size);
> +}
> +
> +static noinline void __init kmalloc_uaf2(void)
> +{
> +       char *ptr1, *ptr2;
> +       size_t size = 43;
> +
> +       pr_info("use-after-free after another kmalloc\n");
> +       ptr1 = kmalloc(size, GFP_KERNEL);
> +       if (!ptr1) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       kfree(ptr1);
> +       ptr2 = kmalloc(size, GFP_KERNEL);
> +       if (!ptr2) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       ptr1[40] = 'x';
> +       kfree(ptr2);
> +}
> +
> +static noinline void __init kmem_cache_oob(void)
> +{
> +       char *p;
> +       size_t size = 200;
> +       struct kmem_cache *cache = kmem_cache_create("test_cache",
> +                                               size, 0,
> +                                               0, NULL);
> +       if (!cache) {
> +               pr_err("Cache allocation failed\n");
> +               return;
> +       }
> +       pr_info("out-of-bounds in kmem_cache_alloc\n");
> +       p = kmem_cache_alloc(cache, GFP_KERNEL);
> +       if (!p) {
> +               pr_err("Allocation failed\n");
> +               kmem_cache_destroy(cache);
> +               return;
> +       }
> +
> +       *p = p[size];
> +       kmem_cache_free(cache, p);
> +       kmem_cache_destroy(cache);
> +}
> +
> +int __init kmalloc_tests_init(void)
> +{
> +       kmalloc_oob_right();
> +       kmalloc_oob_left();
> +       kmalloc_node_oob_right();
> +       kmalloc_large_oob_rigth();
> +       kmalloc_oob_krealloc_more();
> +       kmalloc_oob_krealloc_less();
> +       kmalloc_oob_16();
> +       kmalloc_oob_in_memset();
> +       kmalloc_uaf();
> +       kmalloc_uaf_memset();
> +       kmalloc_uaf2();
> +       kmem_cache_oob();
> +       return -EAGAIN;
> +}
> +
> +module_init(kmalloc_tests_init);
> +MODULE_LICENSE("GPL");
> --
> 2.1.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
