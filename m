Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7C92B6B0032
	for <linux-mm@kvack.org>; Tue, 28 May 2013 11:30:06 -0400 (EDT)
Date: Tue, 28 May 2013 11:29:57 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] drivers: staging: zcache: fix compile error
Message-ID: <20130528152957.GC4695@phenom.dumpdata.com>
References: <1369624540-21824-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369624540-21824-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org
Cc: akpm@linux-foundation.org, dan.magenheimer@oracle.com, fengguang.wu@intel.com, linux-mm@kvack.org, Bob Liu <bob.liu@oracle.com>

On Mon, May 27, 2013 at 11:15:40AM +0800, Bob Liu wrote:
> Fix below compile error:
> drivers/built-in.o: In function `zcache_pampd_free':
> >> zcache-main.c:(.text+0xb1c8a): undefined reference to `ramster_pampd_free'
> >> zcache-main.c:(.text+0xb1cbc): undefined reference to `ramster_count_foreign_pages'
> drivers/built-in.o: In function `zcache_pampd_get_data_and_free':
> >> zcache-main.c:(.text+0xb1f05): undefined reference to `ramster_count_foreign_pages'
> drivers/built-in.o: In function `zcache_cpu_notifier':
> >> zcache-main.c:(.text+0xb228d): undefined reference to `ramster_cpu_up'
> >> zcache-main.c:(.text+0xb2339): undefined reference to `ramster_cpu_down'
> drivers/built-in.o: In function `zcache_pampd_create':
> >> (.text+0xb26ce): undefined reference to `ramster_count_foreign_pages'
> drivers/built-in.o: In function `zcache_pampd_create':
> >> (.text+0xb27ef): undefined reference to `ramster_count_foreign_pages'
> drivers/built-in.o: In function `zcache_put_page':
> >> (.text+0xb299f): undefined reference to `ramster_do_preload_flnode'
> drivers/built-in.o: In function `zcache_flush_page':
> >> (.text+0xb2ea3): undefined reference to `ramster_do_preload_flnode'
> drivers/built-in.o: In function `zcache_flush_object':
> >> (.text+0xb307c): undefined reference to `ramster_do_preload_flnode'
> drivers/built-in.o: In function `zcache_init':
> >> zcache-main.c:(.text+0xb3629): undefined reference to `ramster_register_pamops'
> >> zcache-main.c:(.text+0xb3868): undefined reference to `ramster_init'
> >> drivers/built-in.o:(.rodata+0x15058): undefined reference to `ramster_foreign_eph_pages'
> >> drivers/built-in.o:(.rodata+0x15078): undefined reference to `ramster_foreign_pers_pages'
> 

Looks good, but I think you are missing two things:

Reported-by: Fengguang Wu <fengguang.wu@intel.com>

and CC:devel@driverdev.osuosl.org


> Signed-off-by: Bob Liu <bob.liu@oracle.com>

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  drivers/staging/zcache/ramster.h         |    4 ----
>  drivers/staging/zcache/ramster/debug.c   |    2 ++
>  drivers/staging/zcache/ramster/ramster.c |    6 ++++--
>  3 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/zcache/ramster.h b/drivers/staging/zcache/ramster.h
> index e1f91d5..a858666 100644
> --- a/drivers/staging/zcache/ramster.h
> +++ b/drivers/staging/zcache/ramster.h
> @@ -11,10 +11,6 @@
>  #ifndef _ZCACHE_RAMSTER_H_
>  #define _ZCACHE_RAMSTER_H_
>  
> -#ifdef CONFIG_RAMSTER_MODULE
> -#define CONFIG_RAMSTER
> -#endif
> -
>  #ifdef CONFIG_RAMSTER
>  #include "ramster/ramster.h"
>  #else
> diff --git a/drivers/staging/zcache/ramster/debug.c b/drivers/staging/zcache/ramster/debug.c
> index 327e4f0..5b26ee9 100644
> --- a/drivers/staging/zcache/ramster/debug.c
> +++ b/drivers/staging/zcache/ramster/debug.c
> @@ -1,6 +1,8 @@
>  #include <linux/atomic.h>
>  #include "debug.h"
>  
> +ssize_t ramster_foreign_eph_pages;
> +ssize_t ramster_foreign_pers_pages;
>  #ifdef CONFIG_DEBUG_FS
>  #include <linux/debugfs.h>
>  
> diff --git a/drivers/staging/zcache/ramster/ramster.c b/drivers/staging/zcache/ramster/ramster.c
> index b18b887..a937ce1 100644
> --- a/drivers/staging/zcache/ramster/ramster.c
> +++ b/drivers/staging/zcache/ramster/ramster.c
> @@ -66,8 +66,6 @@ static int ramster_remote_target_nodenum __read_mostly = -1;
>  
>  /* Used by this code. */
>  long ramster_flnodes;
> -ssize_t ramster_foreign_eph_pages;
> -ssize_t ramster_foreign_pers_pages;
>  /* FIXME frontswap selfshrinking knobs in debugfs? */
>  
>  static LIST_HEAD(ramster_rem_op_list);
> @@ -399,14 +397,18 @@ void ramster_count_foreign_pages(bool eph, int count)
>  			inc_ramster_foreign_eph_pages();
>  		} else {
>  			dec_ramster_foreign_eph_pages();
> +#ifdef CONFIG_RAMSTER_DEBUG
>  			WARN_ON_ONCE(ramster_foreign_eph_pages < 0);
> +#endif
>  		}
>  	} else {
>  		if (count > 0) {
>  			inc_ramster_foreign_pers_pages();
>  		} else {
>  			dec_ramster_foreign_pers_pages();
> +#ifdef CONFIG_RAMSTER_DEBUG
>  			WARN_ON_ONCE(ramster_foreign_pers_pages < 0);
> +#endif
>  		}
>  	}
>  }
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
