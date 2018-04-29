Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA776B0005
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 23:36:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b64so4986587pfl.13
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 20:36:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b68si4884414pfg.94.2018.04.28.20.36.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 28 Apr 2018 20:36:26 -0700 (PDT)
Subject: Re: [PATCH 3/3] genalloc: selftest
References: <20180429024542.19475-1-igor.stoppa@huawei.com>
 <20180429024542.19475-4-igor.stoppa@huawei.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <01ec5680-b1de-5473-f32b-89729d9fcc70@infradead.org>
Date: Sat, 28 Apr 2018 20:36:20 -0700
MIME-Version: 1.0
In-Reply-To: <20180429024542.19475-4-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>, mhocko@kernel.org, akpm@linux-foundation.org, keescook@chromium.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org
Cc: willy@infradead.org, labbott@redhat.com, linux-kernel@vger.kernel.org, igor.stoppa@huawei.com

On 04/28/2018 07:45 PM, Igor Stoppa wrote:
> Introduce a set of macros for writing concise test cases for genalloc.
> 
> The test cases are meant to provide regression testing, when working on
> new functionality for genalloc.
> 
> Primarily they are meant to confirm that the various allocation strategy
> will continue to work as expected.
> 
> The execution of the self testing is controlled through a Kconfig option.
> 
> The testing takes place in the very early stages of main.c, to ensure
> that failures in genalloc are caught before they can cause unexplained
> erratic behavior in any of genalloc users.
> 
> Therefore, it would not be advisable to implement it as module.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

Hi,

> ---
>  init/main.c         |   2 +
>  lib/Kconfig         |  15 ++
>  lib/Makefile        |   1 +
>  lib/test_genalloc.c | 410 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 428 insertions(+)
>  create mode 100644 lib/test_genalloc.c
> 
> diff --git a/init/main.c b/init/main.c
> index b795aa341a3a..b3b319d91b0e 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -91,6 +91,7 @@
>  #include <linux/cache.h>
>  #include <linux/rodata_test.h>
>  #include <linux/jump_label.h>
> +#include <linux/test_genalloc.h>
>  
>  #include <asm/io.h>
>  #include <asm/bugs.h>
> @@ -679,6 +680,7 @@ asmlinkage __visible void __init start_kernel(void)
>  	 */
>  	mem_encrypt_init();
>  
> +	test_genalloc();

Is there a stub for test_genalloc() when its config option is not enabled?
I don't see it.

>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (initrd_start && !initrd_below_start_ok &&
>  	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
> diff --git a/lib/Kconfig b/lib/Kconfig
> index 09565d779324..2bf89af50728 100644
> --- a/lib/Kconfig
> +++ b/lib/Kconfig
> @@ -303,6 +303,21 @@ config DECOMPRESS_LZ4
>  config GENERIC_ALLOCATOR
>  	bool
>  

These TEST_ kconfig symbols should be in lib/Kconfig.debug, not lib/Kconfig.


> +config TEST_GENERIC_ALLOCATOR
> +	bool "genalloc tester"
> +	default n
> +	select GENERIC_ALLOCATOR

This should depend on GENERIC_ALLOCATOR, not select it.

See TEST_PARMAN, TEST_BPF, TEST_FIRMWARE, TEST_SYSCTL, TEST_DEBUG_VIRTUAL
in lib/Kconfig.debug.


> +	help
> +	  Enable automated testing of the generic allocator.
> +	  The testing is primarily for the tracking of allocated space.
> +
> +config TEST_GENERIC_ALLOCATOR_VERBOSE
> +	bool "make the genalloc tester more verbose"
> +	default n
> +	select TEST_GENERIC_ALLOCATOR

	depends on TEST_GENERIC_ALLOCATOR

> +	help
> +	  More information will be displayed during the self-testing.
> +
>  #
>  # reed solomon support is select'ed if needed
>  #

> diff --git a/lib/test_genalloc.c b/lib/test_genalloc.c
> new file mode 100644
> index 000000000000..ab9984861517
> --- /dev/null
> +++ b/lib/test_genalloc.c
> @@ -0,0 +1,410 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * test_genalloc.c
> + *
> + * (C) Copyright 2017 Huawei Technologies Co. Ltd.
> + * Author: Igor Stoppa <igor.stoppa@...wei.com>
> + */
> +
> +#include <linux/module.h>
> +#include <linux/printk.h>
> +#include <linux/init.h>
> +#include <linux/vmalloc.h>
> +#include <linux/string.h>
> +#include <linux/debugfs.h>
> +#include <linux/atomic.h>
> +#include <linux/genalloc.h>
> +
> +#include <linux/test_genalloc.h>
> +
> +
> +/*
> + * In case of failure of any of these tests, memory corruption is almost
> + * guarranteed; allowing the boot to continue means risking to corrupt

      guaranteed;

> + * also any filesystem/block device accessed write mode.
> + * Therefore, BUG_ON() is used, when testing.
> + */


-- 
~Randy
