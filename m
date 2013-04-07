Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 15DFE6B0005
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 21:14:21 -0400 (EDT)
Received: by mail-ia0-f181.google.com with SMTP id o25so4171962iad.26
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 18:14:20 -0700 (PDT)
Message-ID: <5160C865.7020500@gmail.com>
Date: Sun, 07 Apr 2013 09:14:13 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zcache: fix compile error
References: <1364788247-30657-1-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1364788247-30657-1-git-send-email-bob.liu@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: gregkh@linuxfoundation.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, fengguang.wu@intel.com, linux-mm@kvack.org, Bob Liu <bob.liu@oracle.com>

Hi Bob,
On 04/01/2013 11:50 AM, Bob Liu wrote:
> Because 'ramster_debugfs_init' is not defined if !CONFIG_DEBUG_FS, there is

How you configure ramster? I can't find "Cross-machine RAM capacity 
sharing, aka peer-to-peer tmem" option in Device Drivers->Staging drivers->

  a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a?? 
Search Results 
a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??
   a?? Symbol: RAMSTER [=n] a??
   a?? Type  : boolean a??
   a?? Prompt: Cross-machine RAM capacity sharing, aka peer-to-peer tmem a??
   a??   Defined at drivers/staging/zcache/Kconfig:13 a??
   a??   Depends on: STAGING [=y] && CONFIGFS_FS [=m]=y && SYSFS [=y] && 
!HIGHMEM [=n] && ZCACHE [=y] && NET [=y] a??
   a?? Location: a??
   a??     -> Device Drivers a??
   a??       -> Staging drivers (STAGING [=y]) a??
   a?? (1)     -> Dynamic compression of swap pages and clean pagecache 
pages (ZCACHE [=y]) a??
   a??   Selects: HAVE_ALIGNED_STRUCT_PAGE [=y]

> compile error like:
>
> $ make drivers/staging/zcache/
>
> staging/zcache/zbud.c:291:16: warning: a??zbud_pers_evicted_pageframesa?? defined
> but not used [-Wunused-variable]
> staging/zcache/ramster/ramster.c: In function a??ramster_inita??:
> staging/zcache/ramster/ramster.c:981:2: error: implicit declaration of
> function a??ramster_debugfs_inita?? [-Werror=implicit-function-declaration]
>
> This patch fix it and reduce some #ifdef CONFIG_DEBUG_FS in .c files with the
> same way.
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> ---
>   drivers/staging/zcache/ramster/ramster.c |    4 ++++
>   drivers/staging/zcache/zbud.c            |    6 ++++--
>   drivers/staging/zcache/zcache-main.c     |    2 --
>   3 files changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/staging/zcache/ramster/ramster.c b/drivers/staging/zcache/ramster/ramster.c
> index 4f715c7..e562c14 100644
> --- a/drivers/staging/zcache/ramster/ramster.c
> +++ b/drivers/staging/zcache/ramster/ramster.c
> @@ -134,6 +134,10 @@ static int ramster_debugfs_init(void)
>   }
>   #undef	zdebugfs
>   #undef	zdfs64
> +#else
> +static int ramster_debugfs_init(void)
> +{
> +}
>   #endif
>   
>   static LIST_HEAD(ramster_rem_op_list);
> diff --git a/drivers/staging/zcache/zbud.c b/drivers/staging/zcache/zbud.c
> index fdff5c6..2d38c96 100644
> --- a/drivers/staging/zcache/zbud.c
> +++ b/drivers/staging/zcache/zbud.c
> @@ -342,6 +342,10 @@ static int zbud_debugfs_init(void)
>   }
>   #undef	zdfs
>   #undef	zdfs64
> +#else
> +static int zbud_debugfs_init(void)
> +{
> +}
>   #endif
>   
>   /* protects the buddied list and all unbuddied lists */
> @@ -1051,9 +1055,7 @@ void zbud_init(void)
>   {
>   	int i;
>   
> -#ifdef CONFIG_DEBUG_FS
>   	zbud_debugfs_init();
> -#endif
>   	BUG_ON((sizeof(struct tmem_handle) * 2 > CHUNK_SIZE));
>   	BUG_ON(sizeof(struct zbudpage) > sizeof(struct page));
>   	for (i = 0; i < NCHUNKS; i++) {
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 4e52a94..ac75670 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1753,9 +1753,7 @@ static int zcache_init(void)
>   		namestr = "ramster";
>   		ramster_register_pamops(&zcache_pamops);
>   	}
> -#ifdef CONFIG_DEBUG_FS
>   	zcache_debugfs_init();
> -#endif
>   	if (zcache_enabled) {
>   		unsigned int cpu;
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
