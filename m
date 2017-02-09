Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB3F6B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 08:50:04 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z67so5498524pgb.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:50:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a21si10091154pfh.246.2017.02.09.05.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 05:50:03 -0800 (PST)
Date: Thu, 9 Feb 2017 14:50:02 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3 staging-next] android: Collect statistics from
 lowmemorykiller
Message-ID: <20170209135002.GA22952@kroah.com>
References: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9febd4f7-a0a7-5f52-e67b-df3163814ac5@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Thu, Feb 09, 2017 at 02:21:45PM +0100, peter enderborg wrote:
> This collects stats for shrinker calls and how much
> waste work we do within the lowmemorykiller.
> 
> Signed-off-by: Peter Enderborg <peter.enderborg@sonymobile.com>
> ---
>  drivers/staging/android/Kconfig                 | 11 ++++
>  drivers/staging/android/Makefile                |  1 +
>  drivers/staging/android/lowmemorykiller.c       |  9 ++-
>  drivers/staging/android/lowmemorykiller_stats.c | 85 +++++++++++++++++++++++++
>  drivers/staging/android/lowmemorykiller_stats.h | 29 +++++++++
>  5 files changed, 134 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/staging/android/lowmemorykiller_stats.c
>  create mode 100644 drivers/staging/android/lowmemorykiller_stats.h
> 
> diff --git a/drivers/staging/android/Kconfig b/drivers/staging/android/Kconfig
> index 6c00d6f..96e86c7 100644
> --- a/drivers/staging/android/Kconfig
> +++ b/drivers/staging/android/Kconfig
> @@ -24,6 +24,17 @@ config ANDROID_LOW_MEMORY_KILLER
>        scripts (/init.rc), and it defines priority values with minimum free memory size
>        for each priority.
> 
> +config ANDROID_LOW_MEMORY_KILLER_STATS
> +    bool "Android Low Memory Killer: collect statistics"
> +    depends on ANDROID_LOW_MEMORY_KILLER
> +    default n
> +    help
> +      Create a file in /proc/lmkstats that includes
> +      collected statistics about kills, scans and counts
> +      and  interaction with the shrinker. Its content
> +      will be different depeding on lmk implementation used.
> +
> +
>  source "drivers/staging/android/ion/Kconfig"
> 
>  endif # if ANDROID
> diff --git a/drivers/staging/android/Makefile b/drivers/staging/android/Makefile
> index 7ed1be7..d710eb2 100644
> --- a/drivers/staging/android/Makefile
> +++ b/drivers/staging/android/Makefile
> @@ -4,3 +4,4 @@ obj-y                    += ion/
> 
>  obj-$(CONFIG_ASHMEM)            += ashmem.o
>  obj-$(CONFIG_ANDROID_LOW_MEMORY_KILLER)    += lowmemorykiller.o
> +obj-$(CONFIG_ANDROID_LOW_MEMORY_KILLER_STATS)    += lowmemorykiller_stats.o
> diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
> index ec3b665..15c1b38 100644
> --- a/drivers/staging/android/lowmemorykiller.c
> +++ b/drivers/staging/android/lowmemorykiller.c
> @@ -42,6 +42,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/profile.h>
>  #include <linux/notifier.h>
> +#include "lowmemorykiller_stats.h"
> 
>  static u32 lowmem_debug_level = 1;
>  static short lowmem_adj[6] = {
> @@ -72,6 +73,7 @@ static unsigned long lowmem_deathpending_timeout;
>  static unsigned long lowmem_count(struct shrinker *s,
>                    struct shrink_control *sc)
>  {
> +    lmk_inc_stats(LMK_COUNT);
>      return global_node_page_state(NR_ACTIVE_ANON) +
>          global_node_page_state(NR_ACTIVE_FILE) +
>          global_node_page_state(NR_INACTIVE_ANON) +

Your patch is corrupted and can not be applied :(

all of them are like this.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
