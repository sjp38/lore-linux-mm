Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 72B486B0007
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 12:05:06 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id t12-v6so10099685plo.9
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 09:05:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d19sor4764137pfm.66.2018.03.06.09.05.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 09:05:05 -0800 (PST)
Subject: Re: [PATCH 6/7] lkdtm: crash on overwriting protected pmalloc var
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-7-igor.stoppa@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <1120e8fd-2f48-5b1f-7072-9bd8e2b82fbf@gmail.com>
Date: Tue, 6 Mar 2018 09:05:00 -0800
MIME-Version: 1.0
In-Reply-To: <20180223144807.1180-7-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com


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

Seems harmless, but I don't get why *i local variable needs to be set to 
0 at the end of this function.


Otherwise,

Reviewed-by: Jay Freyensee <why2jjj.linux@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
