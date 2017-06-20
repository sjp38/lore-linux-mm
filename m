Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9546B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 19:16:55 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m68so25837716ith.1
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:16:55 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m31si98465iod.246.2017.06.20.16.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 16:16:54 -0700 (PDT)
Subject: Re: [PATCH v2] mm: Allow slab_nomerge to be set at build time
References: <20170620230911.GA25238@beast>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <1eb1cfff-14f0-8fa9-1b48-679865339646@infradead.org>
Date: Tue, 20 Jun 2017 16:16:36 -0700
MIME-Version: 1.0
In-Reply-To: <20170620230911.GA25238@beast>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Daniel Micay <danielmicay@gmail.com>, David Windsor <dave@nullcore.net>, Eric Biggers <ebiggers3@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Rik van Riel <riel@redhat.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/20/2017 04:09 PM, Kees Cook wrote:
> Some hardened environments want to build kernels with slab_nomerge
> already set (so that they do not depend on remembering to set the kernel
> command line option). This is desired to reduce the risk of kernel heap
> overflows being able to overwrite objects from merged caches and changes
> the requirements for cache layout control, increasing the difficulty of
> these attacks. By keeping caches unmerged, these kinds of exploits can
> usually only damage objects in the same cache (though the risk to metadata
> exploitation is unchanged).
> 
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

          command line or this option can be disabled in the kernel config.

> +
>  config SLAB_FREELIST_RANDOM
>  	default n
>  	depends on SLAB || SLUB

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
