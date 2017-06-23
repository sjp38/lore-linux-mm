Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9AC86B02F4
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 10:06:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p64so13081026wrc.8
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 07:06:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si4619767wrt.100.2017.06.23.07.06.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 07:06:56 -0700 (PDT)
Date: Fri, 23 Jun 2017 16:06:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: Allow slab_nomerge to be set at build time
Message-ID: <20170623140651.GD5314@dhcp22.suse.cz>
References: <20170620230911.GA25238@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170620230911.GA25238@beast>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Jonathan Corbet <corbet@lwn.net>, Daniel Micay <danielmicay@gmail.com>, David Windsor <dave@nullcore.net>, Eric Biggers <ebiggers3@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 20-06-17 16:09:11, Kees Cook wrote:
> Some hardened environments want to build kernels with slab_nomerge
> already set (so that they do not depend on remembering to set the kernel
> command line option). This is desired to reduce the risk of kernel heap
> overflows being able to overwrite objects from merged caches and changes
> the requirements for cache layout control, increasing the difficulty of
> these attacks. By keeping caches unmerged, these kinds of exploits can
> usually only damage objects in the same cache (though the risk to metadata
> exploitation is unchanged).

Do we really want to have a dedicated config for each hardening specific
kernel command line? I believe we have quite a lot of config options
already. Can we rather have a CONFIG_HARDENED_CMD_OPIONS and cover all
those defauls there instead?

> Cc: Daniel Micay <danielmicay@gmail.com>
> Cc: David Windsor <dave@nullcore.net>
> Cc: Eric Biggers <ebiggers3@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> v2: split out of slab whitelisting series
> ---
>  Documentation/admin-guide/kernel-parameters.txt | 10 ++++++++--
>  init/Kconfig                                    | 14 ++++++++++++++
>  mm/slab_common.c                                |  5 ++---
>  3 files changed, 24 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index 7737ab5d04b2..94d8b8195cb8 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -3715,8 +3715,14 @@
>  	slab_nomerge	[MM]
>  			Disable merging of slabs with similar size. May be
>  			necessary if there is some reason to distinguish
> -			allocs to different slabs. Debug options disable
> -			merging on their own.
> +			allocs to different slabs, especially in hardened
> +			environments where the risk of heap overflows and
> +			layout control by attackers can usually be
> +			frustrated by disabling merging. This will reduce
> +			most of the exposure of a heap attack to a single
> +			cache (risks via metadata attacks are mostly
> +			unchanged). Debug options disable merging on their
> +			own.
>  			For more information see Documentation/vm/slub.txt.
>  
>  	slab_max_order=	[MM, SLAB]
> diff --git a/init/Kconfig b/init/Kconfig
> index 1d3475fc9496..ce813acf2f4f 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1891,6 +1891,20 @@ config SLOB
>  
>  endchoice
>  
> +config SLAB_MERGE_DEFAULT
> +	bool "Allow slab caches to be merged"
> +	default y
> +	help
> +	  For reduced kernel memory fragmentation, slab caches can be
> +	  merged when they share the same size and other characteristics.
> +	  This carries a risk of kernel heap overflows being able to
> +	  overwrite objects from merged caches (and more easily control
> +	  cache layout), which makes such heap attacks easier to exploit
> +	  by attackers. By keeping caches unmerged, these kinds of exploits
> +	  can usually only damage objects in the same cache. To disable
> +	  merging at runtime, "slab_nomerge" can be passed on the kernel
> +	  command line.
> +
>  config SLAB_FREELIST_RANDOM
>  	default n
>  	depends on SLAB || SLUB
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 01a0fe2eb332..904a83be82de 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -47,13 +47,12 @@ static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
>  
>  /*
>   * Merge control. If this is set then no merging of slab caches will occur.
> - * (Could be removed. This was introduced to pacify the merge skeptics.)
>   */
> -static int slab_nomerge;
> +static bool slab_nomerge = !IS_ENABLED(CONFIG_SLAB_MERGE_DEFAULT);
>  
>  static int __init setup_slab_nomerge(char *str)
>  {
> -	slab_nomerge = 1;
> +	slab_nomerge = true;
>  	return 1;
>  }
>  
> -- 
> 2.7.4
> 
> 
> -- 
> Kees Cook
> Pixel Security
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
