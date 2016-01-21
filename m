Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id A138D6B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 16:35:14 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id w75so35192588oie.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 13:35:14 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i5si2925602obh.19.2016.01.21.13.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 13:35:07 -0800 (PST)
Date: Thu, 21 Jan 2016 16:35:00 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v2] cleancache: constify cleancache_ops
 structure
Message-ID: <20160121213500.GF15622@localhost.localdomain>
References: <1450904784-17139-1-git-send-email-Julia.Lawall@lip6.fr>
 <56A0B6E7.9040201@citrix.com>
 <alpine.DEB.2.10.1601211646580.2530@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601211646580.2530@hadrien>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

On Thu, Jan 21, 2016 at 04:47:29PM +0100, Julia Lawall wrote:
> The cleancache_ops structure is never modified, so declare it as const.
> 
> Done with the help of Coccinelle.

I will pull it in my tree and sent it to Linus.

Thanks!
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> 
> v2: put back the read mostly
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
> +static const struct cleancache_ops *cleancache_ops __read_mostly;
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
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
