Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id CDACA900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 16:11:22 -0400 (EDT)
Received: by qgdy38 with SMTP id y38so38757422qgd.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 13:11:22 -0700 (PDT)
Received: from smtp.variantweb.net (smtp.variantweb.net. [104.131.104.118])
        by mx.google.com with ESMTPS id o90si13503092qga.43.2015.06.02.13.11.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 13:11:21 -0700 (PDT)
Date: Tue, 2 Jun 2015 15:11:18 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 3/5] zswap: runtime enable/disable
Message-ID: <20150602201118.GA14741@cerebellum.local.variantweb.net>
References: <1433257917-13090-1-git-send-email-ddstreet@ieee.org>
 <1433257917-13090-4-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433257917-13090-4-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 02, 2015 at 11:11:55AM -0400, Dan Streetman wrote:
> Change the "enabled" parameter to be configurable at runtime.  Remove
> the enabled check from init(), and move it to the frontswap store()
> function; when enabled, pages will be stored, and when disabled, pages
> won't be stored.

I like this one. So much so I wrote it about 2 years ago :)

http://lkml.iu.edu/hypermail/linux/kernel/1307.2/04289.html

It didn't go in though and I forgot about it.

We need to update the documentation too (see my patch).

Thanks,
Seth

> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  mm/zswap.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 4249e82..e070b10 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -75,9 +75,10 @@ static u64 zswap_duplicate_entry;
>  /*********************************
>  * tunables
>  **********************************/
> -/* Enable/disable zswap (disabled by default, fixed at boot for now) */
> -static bool zswap_enabled __read_mostly;
> -module_param_named(enabled, zswap_enabled, bool, 0444);
> +
> +/* Enable/disable zswap (disabled by default) */
> +static bool zswap_enabled;
> +module_param_named(enabled, zswap_enabled, bool, 0644);
>  
>  /* Compressor to be used by zswap (fixed at boot for now) */
>  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> @@ -648,6 +649,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  	u8 *src, *dst;
>  	struct zswap_header *zhdr;
>  
> +	if (!zswap_enabled)
> +		return -EPERM;
> +
>  	if (!tree) {
>  		ret = -ENODEV;
>  		goto reject;
> @@ -901,9 +905,6 @@ static int __init init_zswap(void)
>  {
>  	gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN;
>  
> -	if (!zswap_enabled)
> -		return 0;
> -
>  	pr_info("loading zswap\n");
>  
>  	zswap_pool = zpool_create_pool(zswap_zpool_type, "zswap", gfp,
> -- 
> 2.1.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
