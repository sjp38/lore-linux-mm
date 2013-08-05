Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id D8C546B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 03:32:35 -0400 (EDT)
Date: Mon, 5 Aug 2013 09:32:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/Kconfig: add MMU dependency for MIGRATION.
Message-ID: <20130805073233.GB10146@dhcp22.suse.cz>
References: <51F9CA7D.2070506@asianux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F9CA7D.2070506@asianux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, rientjes@google.com, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu 01-08-13 10:39:57, Chen Gang wrote:
> MIGRATION need depend on MMU, or allmodconfig for sh architecture which
> without MMU will be fail for compiling.
> 
> The related error: 
> 
>     CC      mm/migrate.o
>   mm/migrate.c: In function 'remove_migration_pte':
>   mm/migrate.c:134:3: error: implicit declaration of function 'pmd_trans_huge' [-Werror=implicit-function-declaration]
>      if (pmd_trans_huge(*pmd))
>      ^
>   mm/migrate.c:149:2: error: implicit declaration of function 'is_swap_pte' [-Werror=implicit-function-declaration]
>     if (!is_swap_pte(pte))
>     ^
>   ...
> 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  mm/Kconfig |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 256bfd0..e847f19 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -245,7 +245,7 @@ config COMPACTION
>  config MIGRATION
>  	bool "Page migration"
>  	def_bool y
> -	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA
> +	depends on (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA) && MMU
>  	help
>  	  Allows the migration of the physical location of pages of processes
>  	  while the virtual addresses are not changed. This is useful in
> @@ -522,7 +522,7 @@ config MEM_SOFT_DIRTY
>  
>  config CMA
>  	bool "Contiguous Memory Allocator"
> -	depends on HAVE_MEMBLOCK
> +	depends on HAVE_MEMBLOCK && MMU

Why CMA has to depend on MMU as well? The MIGRATION part should be
sufficient.

>  	select MIGRATION
>  	select MEMORY_ISOLATION
>  	help

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
