Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8726B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 17:20:12 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id uo6so11650449pac.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 14:20:12 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f7si57714552pfd.188.2016.01.20.14.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 14:20:11 -0800 (PST)
Date: Wed, 20 Jan 2016 17:20:00 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] cleancache: constify cleancache_ops structure
Message-ID: <20160120222000.GA6765@char.us.oracle.com>
References: <1450904784-17139-1-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450904784-17139-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org

On Wed, Dec 23, 2015 at 10:06:24PM +0100, Julia Lawall wrote:
> The cleancache_ops structure is never modified, so declare it as const.
> 
> This also removes the __read_mostly declaration on the cleancache_ops
> variable declaration, since it seems redundant with const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> 
> Not sure that the __read_mostly change is correct.  Does it apply to the
> variable, or to what the variable points to?

It should just put the structure in the right section (.rodata).

Thanks for the patch!
> 
>  drivers/xen/tmem.c         |    2 +-
>  include/linux/cleancache.h |    2 +-
>  mm/cleancache.c            |    4 ++--
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
> index bda5ec0b4..cb3e142 100644
> --- a/include/linux/cleancache.h
> +++ b/include/linux/cleancache.h
> @@ -37,7 +37,7 @@ struct cleancache_ops {
>  	void (*invalidate_fs)(int);
>  };
>  
> -extern int cleancache_register_ops(struct cleancache_ops *ops);
> +extern int cleancache_register_ops(const struct cleancache_ops *ops);
>  extern void __cleancache_init_fs(struct super_block *);
>  extern void __cleancache_init_shared_fs(struct super_block *);
>  extern int  __cleancache_get_page(struct page *);
> diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
> index 945fc43..4ac2ca8 100644
> --- a/drivers/xen/tmem.c
> +++ b/drivers/xen/tmem.c
> @@ -242,7 +242,7 @@ static int tmem_cleancache_init_shared_fs(char *uuid, size_t pagesize)
>  	return xen_tmem_new_pool(shared_uuid, TMEM_POOL_SHARED, pagesize);
>  }
>  
> -static struct cleancache_ops tmem_cleancache_ops = {
> +static const struct cleancache_ops tmem_cleancache_ops = {
>  	.put_page = tmem_cleancache_put_page,
>  	.get_page = tmem_cleancache_get_page,
>  	.invalidate_page = tmem_cleancache_flush_page,
> diff --git a/mm/cleancache.c b/mm/cleancache.c
> index 8fc5081..c6356d6 100644
> --- a/mm/cleancache.c
> +++ b/mm/cleancache.c
> @@ -22,7 +22,7 @@
>   * cleancache_ops is set by cleancache_register_ops to contain the pointers
>   * to the cleancache "backend" implementation functions.
>   */
> -static struct cleancache_ops *cleancache_ops __read_mostly;
> +static const struct cleancache_ops *cleancache_ops;
>  
>  /*
>   * Counters available via /sys/kernel/debug/cleancache (if debugfs is
> @@ -49,7 +49,7 @@ static void cleancache_register_ops_sb(struct super_block *sb, void *unused)
>  /*
>   * Register operations for cleancache. Returns 0 on success.
>   */
> -int cleancache_register_ops(struct cleancache_ops *ops)
> +int cleancache_register_ops(const struct cleancache_ops *ops)
>  {
>  	if (cmpxchg(&cleancache_ops, NULL, ops))
>  		return -EBUSY;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
