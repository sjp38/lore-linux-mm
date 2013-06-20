Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 187966B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:48:47 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 20 Jun 2013 10:48:46 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 26210C90041
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:48:40 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5KEmewv44892406
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:48:40 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5KEmUVZ010695
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 11:48:30 -0300
Date: Thu, 20 Jun 2013 09:48:26 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] zswap: update/document boot parameters
Message-ID: <20130620144826.GB9461@cerebellum>
References: <1371716949-9918-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371716949-9918-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, konrad.wilk@oracle.com, Bob Liu <bob.liu@oracle.com>

On Thu, Jun 20, 2013 at 04:29:09PM +0800, Bob Liu wrote:
> The current parameters of zswap are not straightforward.
> Changed them to start with zswap* and documented them.

Thanks for the patch!

However, I think you might be missing that using module_param(_named) allows
access on the kernel boot line with <modulename>.<moduleparam> syntax.  So
"zswap" already has to be the parameter string as it is the name of the module
to whom the parameters belong.

For example, your patch just changes the boot parameter from
zswap.max_pool_percent to zswap_maxpool_percent.  That doesn't add any clarity
IMO.

Yes, zswap isn't able to be a module right now.  But there is no harm in using
the module framework to provide standardized access to zswap parameters. Plus,
the day might come when zswap can be a module.

As far as documenting them in kernel-parameters.txt, this was mentioned before
and I it was decided to not do that since module parameters are typically not
documented there. However, since zswap is currently not buildable as a module,
I could see where I case could be made for documenting them there.

If you wanted to document them with their <modulename>.<moduleparam> syntax,
I wouldn't be opposed to it.

Seth

> 
> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> ---
>  Documentation/kernel-parameters.txt |    8 ++++++++
>  mm/zswap.c                          |   27 +++++++++++++++++++++++----
>  2 files changed, 31 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 2fe6e76..07642fd 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -3367,6 +3367,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			Format:
>  			<irq>,<irq_mask>,<io>,<full_duplex>,<do_sound>,<lockup_hack>[,<irq2>[,<irq3>[,<irq4>]]]
> 
> +	zswap 		Enable compressed cache for swap pages support which
> +			is disabled by default.
> +	zswapcompressor=
> +			Select which compressor to be used by zswap.
> +			The default compressor is lzo.
> +	zswap_maxpool_percent=
> +			Select how may percent of total memory can be used to
> +			store comprssed pages. The default percent is 20%.
>  ______________________________________________________________________
> 
>  TODO:
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 7fe2b1b..8ec1360 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -77,17 +77,13 @@ static u64 zswap_duplicate_entry;
>  **********************************/
>  /* Enable/disable zswap (disabled by default, fixed at boot for now) */
>  static bool zswap_enabled __read_mostly;
> -module_param_named(enabled, zswap_enabled, bool, 0);
> 
>  /* Compressor to be used by zswap (fixed at boot for now) */
>  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
>  static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> -module_param_named(compressor, zswap_compressor, charp, 0);
> 
>  /* The maximum percentage of memory that the compressed pool can occupy */
>  static unsigned int zswap_max_pool_percent = 20;
> -module_param_named(max_pool_percent,
> -			zswap_max_pool_percent, uint, 0644);
> 
>  /*********************************
>  * compression functions
> @@ -914,6 +910,29 @@ static int __init zswap_debugfs_init(void)
>  static void __exit zswap_debugfs_exit(void) { }
>  #endif
> 
> +static int __init enable_zswap(char *s)
> +{
> +	zswap_enabled = true;
> +	return 1;
> +}
> +__setup("zswap", enable_zswap);
> +
> +static int __init setup_zswap_compressor(char *s)
> +{
> +	strlcpy(zswap_compressor, s, sizeof(zswap_compressor));
> +	zswap_enabled = true;
> +	return 1;
> +}
> +__setup("zswapcompressor=", setup_zswap_compressor);
> +
> +static int __init setup_zswap_max_pool_percent(char *s)
> +{
> +	get_option(&s, &zswap_max_pool_percent);
> +	zswap_enabled = true;
> +	return 1;
> +}
> +__setup("zswap_maxpool_percent=", setup_zswap_max_pool_percent);
> +
>  /*********************************
>  * module init and exit
>  **********************************/
> -- 
> 1.7.10.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
