Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B0B796B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 09:41:15 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id c46so19524280otd.0
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 06:41:15 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l124-v6si8370096oig.143.2018.10.17.06.41.14
        for <linux-mm@kvack.org>;
        Wed, 17 Oct 2018 06:41:14 -0700 (PDT)
Date: Wed, 17 Oct 2018 14:41:09 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: Add config to select auto scan
Message-ID: <20181017134109.GA223677@arrakis.emea.arm.com>
References: <1539763408-22085-1-git-send-email-prpatel@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1539763408-22085-1-git-send-email-prpatel@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prateek Patel <prpatel@nvidia.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-tegra@vger.kernel.org, snikam@nvidia.com, vdumpa@nvidia.com, talho@nvidia.com, swarren@nvidia.com, Sri Krishna chowdary <schowdary@nvidia.com>

On Wed, Oct 17, 2018 at 01:33:28PM +0530, Prateek Patel wrote:
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index e5e7c03..9542852 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -593,6 +593,17 @@ config DEBUG_KMEMLEAK_DEFAULT_OFF
>  	  Say Y here to disable kmemleak by default. It can then be enabled
>  	  on the command line via kmemleak=on.
>  
> +config DEBUG_KMEMLEAK_SCAN_ON

Nitpick: DEBUG_KMEMLEAK_AUTO_SCAN may be a better name since you don't
aim to disable scanning altogether.

> +	bool "Enable kmemleak auto scan thread on boot up"
> +	default y
> +	depends on DEBUG_KMEMLEAK
> +	help
> +	  Kmemleak scan is cpu intensive and can stall user tasks at times.

I guess that depends on the CPU.

> +	  This option enables/disables automatic kmemleak scan at boot up.
> +
> +	  Say N here to disable kmemleak auto scan thread to stop automatic
> +	  scanning.

You should also mention that disabling this option also disables
automatic reporting of memory leaks. And I'd add a "if unsure, say Y".

> +
>  config DEBUG_STACK_USAGE
>  	bool "Stack utilization instrumentation"
>  	depends on DEBUG_KERNEL && !IA64
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 877de4f..ac53678 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -1647,11 +1647,14 @@ static void kmemleak_scan(void)
>   */
>  static int kmemleak_scan_thread(void *arg)
>  {
> +#ifdef CONFIG_DEBUG_KMEMLEAK_SCAN_ON
>  	static int first_run = 1;
> +#endif

	static int first_run = IS_ENABLED(CONFIG_DEBUG_KMEMLEAK_AUTO_SCAN);

>  
>  	pr_info("Automatic memory scanning thread started\n");
>  	set_user_nice(current, 10);
>  
> +#ifdef CONFIG_DEBUG_KMEMLEAK_SCAN_ON
>  	/*
>  	 * Wait before the first scan to allow the system to fully initialize.
>  	 */
> @@ -1661,6 +1664,7 @@ static int kmemleak_scan_thread(void *arg)
>  		while (timeout && !kthread_should_stop())
>  			timeout = schedule_timeout_interruptible(timeout);
>  	}
> +#endif

With the first_run change above, this #ifdef is no longer needed.

>  
>  	while (!kthread_should_stop()) {
>  		signed long timeout = jiffies_scan_wait;
> @@ -2141,9 +2145,11 @@ static int __init kmemleak_late_init(void)
>  		return -ENOMEM;
>  	}
>  
> +#ifdef CONFIG_DEBUG_KMEMLEAK_SCAN_ON
>  	mutex_lock(&scan_mutex);
>  	start_scan_thread();
>  	mutex_unlock(&scan_mutex);
> +#endif

Please use:

	if (IS_ENABLED(CONFIG_DEBUG_KMEMLEAK_AUTO_SCAN)) {
		...
	}

-- 
Catalin
