Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6165D6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:51:06 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d136so56217404qkg.11
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 11:51:06 -0700 (PDT)
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com. [209.85.220.181])
        by mx.google.com with ESMTPS id g40si7332222qte.12.2017.08.14.11.51.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 11:51:05 -0700 (PDT)
Received: by mail-qk0-f181.google.com with SMTP id x191so55125484qka.5
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 11:51:05 -0700 (PDT)
Subject: Re: [PATCH v5 02/10] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-3-tycho@docker.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <bab02094-0c58-fe8f-855c-d67a03d7003a@redhat.com>
Date: Mon, 14 Aug 2017 11:51:02 -0700
MIME-Version: 1.0
In-Reply-To: <20170809200755.11234-3-tycho@docker.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> diff --git a/mm/xpfo.c b/mm/xpfo.c
> new file mode 100644
> index 000000000000..3cd45f68b5ad
> --- /dev/null
> +++ b/mm/xpfo.c
> @@ -0,0 +1,208 @@
> +/*
> + * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
> + * Copyright (C) 2016 Brown University. All rights reserved.
> + *
> + * Authors:
> + *   Juerg Haefliger <juerg.haefliger@hpe.com>
> + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published by
> + * the Free Software Foundation.
> + */
> +
> +#include <linux/mm.h>
> +#include <linux/module.h>
> +#include <linux/page_ext.h>
> +#include <linux/xpfo.h>
> +
> +#include <asm/tlbflush.h>
> +
> +/* XPFO page state flags */
> +enum xpfo_flags {
> +	XPFO_PAGE_USER,		/* Page is allocated to user-space */
> +	XPFO_PAGE_UNMAPPED,	/* Page is unmapped from the linear map */
> +};
> +
> +/* Per-page XPFO house-keeping data */
> +struct xpfo {
> +	unsigned long flags;	/* Page state */
> +	bool inited;		/* Map counter and lock initialized */
> +	atomic_t mapcount;	/* Counter for balancing map/unmap requests */
> +	spinlock_t maplock;	/* Lock to serialize map/unmap requests */
> +};
> +
> +DEFINE_STATIC_KEY_FALSE(xpfo_inited);
> +
> +static bool xpfo_disabled __initdata;
> +
> +static int __init noxpfo_param(char *str)
> +{
> +	xpfo_disabled = true;
> +
> +	return 0;
> +}
> +
> +early_param("noxpfo", noxpfo_param);
> +
> +static bool __init need_xpfo(void)
> +{
> +	if (xpfo_disabled) {
> +		printk(KERN_INFO "XPFO disabled\n");
> +		return false;
> +	}
> +
> +	return true;
> +}
> +
> +static void init_xpfo(void)
> +{
> +	printk(KERN_INFO "XPFO enabled\n");
> +	static_branch_enable(&xpfo_inited);
> +}
> +
> +struct page_ext_operations page_xpfo_ops = {
> +	.size = sizeof(struct xpfo),
> +	.need = need_xpfo,
> +	.init = init_xpfo,
> +};
> +
> +static inline struct xpfo *lookup_xpfo(struct page *page)
> +{
> +	return (void *)lookup_page_ext(page) + page_xpfo_ops.offset;
> +}

lookup_page_ext can return NULL so this function and its callers
need to account for that.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
