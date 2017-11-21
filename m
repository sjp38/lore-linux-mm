Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 349FC6B0280
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 02:24:21 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 4so7289963wrt.8
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 23:24:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10si859184eda.449.2017.11.20.23.24.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 23:24:20 -0800 (PST)
Date: Tue, 21 Nov 2017 08:24:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: relax deferred struct page requirements
Message-ID: <20171121072416.v77vu4osm2s4o5sq@dhcp22.suse.cz>
References: <20171117014601.31606-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171117014601.31606-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, arbab@linux.vnet.ibm.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, mgorman@techsingularity.net

On Thu 16-11-17 20:46:01, Pavel Tatashin wrote:
> There is no need to have ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT,
> as all the page initialization code is in common code.
> 
> Also, there is no need to depend on MEMORY_HOTPLUG, as initialization code
> does not really use hotplug memory functionality. So, we can remove this
> requirement as well.
> 
> This patch allows to use deferred struct page initialization on all
> platforms with memblock allocator.
> 
> Tested on x86, arm64, and sparc. Also, verified that code compiles on
> PPC with CONFIG_MEMORY_HOTPLUG disabled.

There is slight risk that we will encounter corner cases on some
architectures with weird memory layout/topology but we should better
explicitly disable this code rather than make it opt-in so this looks
like an improvement to me.
 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/powerpc/Kconfig | 1 -
>  arch/s390/Kconfig    | 1 -
>  arch/x86/Kconfig     | 1 -
>  mm/Kconfig           | 7 +------
>  4 files changed, 1 insertion(+), 9 deletions(-)
> 
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index cb782ac1c35d..1540348691c9 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -148,7 +148,6 @@ config PPC
>  	select ARCH_MIGHT_HAVE_PC_PARPORT
>  	select ARCH_MIGHT_HAVE_PC_SERIO
>  	select ARCH_SUPPORTS_ATOMIC_RMW
> -	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>  	select ARCH_USE_BUILTIN_BSWAP
>  	select ARCH_USE_CMPXCHG_LOCKREF		if PPC64
>  	select ARCH_WANT_IPC_PARSE_VERSION
> diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
> index 863a62a6de3c..525c2e3df6f5 100644
> --- a/arch/s390/Kconfig
> +++ b/arch/s390/Kconfig
> @@ -108,7 +108,6 @@ config S390
>  	select ARCH_INLINE_WRITE_UNLOCK_IRQRESTORE
>  	select ARCH_SAVE_PAGE_KEYS if HIBERNATION
>  	select ARCH_SUPPORTS_ATOMIC_RMW
> -	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>  	select ARCH_SUPPORTS_NUMA_BALANCING
>  	select ARCH_USE_BUILTIN_BSWAP
>  	select ARCH_USE_CMPXCHG_LOCKREF
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index df3276d6bfe3..00a5446de394 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -69,7 +69,6 @@ config X86
>  	select ARCH_MIGHT_HAVE_PC_PARPORT
>  	select ARCH_MIGHT_HAVE_PC_SERIO
>  	select ARCH_SUPPORTS_ATOMIC_RMW
> -	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>  	select ARCH_SUPPORTS_NUMA_BALANCING	if X86_64
>  	select ARCH_USE_BUILTIN_BSWAP
>  	select ARCH_USE_QUEUED_RWLOCKS
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 9c4bdddd80c2..c6bd0309ce7a 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -639,15 +639,10 @@ config MAX_STACK_SIZE_MB
>  
>  	  A sane initial value is 80 MB.
>  
> -# For architectures that support deferred memory initialisation
> -config ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
> -	bool
> -
>  config DEFERRED_STRUCT_PAGE_INIT
>  	bool "Defer initialisation of struct pages to kthreads"
>  	default n
> -	depends on ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
> -	depends on NO_BOOTMEM && MEMORY_HOTPLUG
> +	depends on NO_BOOTMEM
>  	depends on !FLATMEM
>  	help
>  	  Ordinarily all struct pages are initialised during early boot in a
> -- 
> 2.15.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
