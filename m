Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 62DDA6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 05:16:22 -0400 (EDT)
Message-ID: <51EE49D7.4060501@oracle.com>
Date: Tue, 23 Jul 2013 17:16:07 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: zswap: add runtime enable/disable
References: <1374521642-25478-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1374521642-25478-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Bob Liu <lliubbo@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/23/2013 03:34 AM, Seth Jennings wrote:
> Right now, zswap can only be enabled at boot time.  This patch
> modifies zswap so that it can be dynamically enabled or disabled
> at runtime.
> 
> In order to allow this ability, zswap unconditionally registers as a
> frontswap backend regardless of whether or not zswap.enabled=1 is passed
> in the boot parameters or not.  This introduces a very small overhead
> for systems that have zswap disabled as calls to frontswap_store() will
> call zswap_frontswap_store(), but there is a fast path to immediately
> return if zswap is disabled.

There is also overhead in frontswap_load() after all pages are faulted
back into memory.

> 
> Disabling zswap does not unregister zswap from frontswap.  It simply
> blocks all future stores.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  Documentation/vm/zswap.txt | 18 ++++++++++++++++--
>  mm/zswap.c                 |  9 +++------
>  2 files changed, 19 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
> index 7e492d8..d588477 100644
> --- a/Documentation/vm/zswap.txt
> +++ b/Documentation/vm/zswap.txt
> @@ -26,8 +26,22 @@ Zswap evicts pages from compressed cache on an LRU basis to the backing swap
>  device when the compressed pool reaches it size limit.  This requirement had
>  been identified in prior community discussions.
>  
> -To enabled zswap, the "enabled" attribute must be set to 1 at boot time.  e.g.
> -zswap.enabled=1
> +Zswap is disabled by default but can be enabled at boot time by setting
> +the "enabled" attribute to 1 at boot time. e.g. zswap.enabled=1.  Zswap
> +can also be enabled and disabled at runtime using the sysfs interface.
> +An exmaple command to enable zswap at runtime, assuming sysfs is mounted
> +at /sys, is:
> +
> +echo 1 > /sys/modules/zswap/parameters/enabled
> +
> +When zswap is disabled at runtime, it will stop storing pages that are
> +being swapped out.  However, it will _not_ immediately write out or
> +fault back into memory all of the pages stored in the compressed pool.

I don't know what's you use case of adding this feature.
In my opinion I'd perfer to flush all the pages stored in zswap when
disabled it, so that I can run testing without rebooting the machine.

> +The pages stored in zswap will continue to remain in the compressed pool
> +until they are either invalidated or faulted back into memory.  In order
> +to force all pages out of the compressed pool, a swapoff on the swap
> +device(s) will fault all swapped out pages, included those in the
> +compressed pool, back into memory.
>  
>  Design:
>  
> diff --git a/mm/zswap.c b/mm/zswap.c
> index deda2b6..199b1b0 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -75,9 +75,9 @@ static u64 zswap_duplicate_entry;
>  /*********************************
>  * tunables
>  **********************************/
> -/* Enable/disable zswap (disabled by default, fixed at boot for now) */
> +/* Enable/disable zswap (disabled by default) */
>  static bool zswap_enabled __read_mostly;
> -module_param_named(enabled, zswap_enabled, bool, 0);
> +module_param_named(enabled, zswap_enabled, bool, 0644);
>  
>  /* Compressor to be used by zswap (fixed at boot for now) */
>  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> @@ -612,7 +612,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>  	u8 *src, *dst;
>  	struct zswap_header *zhdr;
>  
> -	if (!tree) {
> +	if (!zswap_enabled || !tree) {
>  		ret = -ENODEV;
>  		goto reject;
>  	}
> @@ -908,9 +908,6 @@ static void __exit zswap_debugfs_exit(void) { }
>  **********************************/
>  static int __init init_zswap(void)
>  {
> -	if (!zswap_enabled)
> -		return 0;
> -
>  	pr_info("loading zswap\n");
>  	if (zswap_entry_cache_create()) {
>  		pr_err("entry cache creation failed\n");
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
