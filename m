Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A462F6B000C
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 12:20:09 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j8so10568921pfh.13
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 09:20:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n23-v6sor4885709plp.141.2018.03.06.09.20.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 09:20:08 -0800 (PST)
Subject: Re: [PATCH 6/7] lkdtm: crash on overwriting protected pmalloc var
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-7-igor.stoppa@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <1723ee8d-c89e-0704-c2c3-254eda39dc8b@gmail.com>
Date: Tue, 6 Mar 2018 09:20:04 -0800
MIME-Version: 1.0
In-Reply-To: <20180228200620.30026-7-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 2/28/18 12:06 PM, Igor Stoppa wrote:
> Verify that pmalloc read-only protection is in place: trying to
> overwrite a protected variable will crash the kernel.
>
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>   drivers/misc/lkdtm.h       |  1 +
>   drivers/misc/lkdtm_core.c  |  3 +++
>   drivers/misc/lkdtm_perms.c | 28 ++++++++++++++++++++++++++++
>   3 files changed, 32 insertions(+)
>
> diff --git a/drivers/misc/lkdtm.h b/drivers/misc/lkdtm.h
> index 9e513dcfd809..dcda3ae76ceb 100644
> --- a/drivers/misc/lkdtm.h
> +++ b/drivers/misc/lkdtm.h
> @@ -38,6 +38,7 @@ void lkdtm_READ_BUDDY_AFTER_FREE(void);
>   void __init lkdtm_perms_init(void);
>   void lkdtm_WRITE_RO(void);
>   void lkdtm_WRITE_RO_AFTER_INIT(void);
> +void lkdtm_WRITE_RO_PMALLOC(void);

Does this need some sort of #ifdef too?

>   void lkdtm_WRITE_KERN(void);
>   void lkdtm_EXEC_DATA(void);
>   void lkdtm_EXEC_STACK(void);
> diff --git a/drivers/misc/lkdtm_core.c b/drivers/misc/lkdtm_core.c
> index 2154d1bfd18b..c9fd42bda6ee 100644
> --- a/drivers/misc/lkdtm_core.c
> +++ b/drivers/misc/lkdtm_core.c
> @@ -155,6 +155,9 @@ static const struct crashtype crashtypes[] = {
>   	CRASHTYPE(ACCESS_USERSPACE),
>   	CRASHTYPE(WRITE_RO),
>   	CRASHTYPE(WRITE_RO_AFTER_INIT),
> +#ifdef CONFIG_PROTECTABLE_MEMORY
> +	CRASHTYPE(WRITE_RO_PMALLOC),
> +#endif
>   	CRASHTYPE(WRITE_KERN),
>   	CRASHTYPE(REFCOUNT_INC_OVERFLOW),
>   	CRASHTYPE(REFCOUNT_ADD_OVERFLOW),
> diff --git a/drivers/misc/lkdtm_perms.c b/drivers/misc/lkdtm_perms.c
> index 53b85c9d16b8..0ac9023fd2b0 100644
> --- a/drivers/misc/lkdtm_perms.c
> +++ b/drivers/misc/lkdtm_perms.c
> @@ -9,6 +9,7 @@
>   #include <linux/vmalloc.h>
>   #include <linux/mman.h>
>   #include <linux/uaccess.h>
> +#include <linux/pmalloc.h>
>   #include <asm/cacheflush.h>
>   
>   /* Whether or not to fill the target memory area with do_nothing(). */
> @@ -104,6 +105,33 @@ void lkdtm_WRITE_RO_AFTER_INIT(void)
>   	*ptr ^= 0xabcd1234;
>   }
>   
> +#ifdef CONFIG_PROTECTABLE_MEMORY
> +void lkdtm_WRITE_RO_PMALLOC(void)
> +{
> +	struct gen_pool *pool;
> +	int *i;
> +
> +	pool = pmalloc_create_pool("pool", 0);
> +	if (unlikely(!pool)) {
> +		pr_info("Failed preparing pool for pmalloc test.");
> +		return;
> +	}
> +
> +	i = (int *)pmalloc(pool, sizeof(int), GFP_KERNEL);
> +	if (unlikely(!i)) {
> +		pr_info("Failed allocating memory for pmalloc test.");
> +		pmalloc_destroy_pool(pool);
> +		return;
> +	}
> +
> +	*i = INT_MAX;
> +	pmalloc_protect_pool(pool);
> +
> +	pr_info("attempting bad pmalloc write at %p\n", i);
> +	*i = 0;

OK, now I'm on the right version of this patch series, same comment 
applies.A  I don't get the local *i assignment at the end of the 
function, but seems harmless.

Except the two minor comments, otherwise,
Reviewed-by: Jay Freyensee <why2jjj.linux@gmail.com>

> +}
> +#endif
> +
>   void lkdtm_WRITE_KERN(void)
>   {
>   	size_t size;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
