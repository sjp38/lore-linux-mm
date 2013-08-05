Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 544AC6B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 05:05:41 -0400 (EDT)
Date: Mon, 5 Aug 2013 11:05:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/Kconfig: add MMU dependency for MIGRATION.
Message-ID: <20130805090539.GH10146@dhcp22.suse.cz>
References: <51F9CA7D.2070506@asianux.com>
 <20130805073233.GB10146@dhcp22.suse.cz>
 <51FF6656.4070809@gmail.com>
 <20130805090301.GF10146@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130805090301.GF10146@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang F T <chen.gang.flying.transformer@gmail.com>
Cc: Chen Gang <gang.chen@asianux.com>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, rientjes@google.com, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon 05-08-13 11:03:01, Michal Hocko wrote:
> On Mon 05-08-13 16:46:14, Chen Gang F T wrote:
> > On 08/05/2013 03:32 PM, Michal Hocko wrote:
> > > On Thu 01-08-13 10:39:57, Chen Gang wrote:
> > >> MIGRATION need depend on MMU, or allmodconfig for sh architecture which
> > >> without MMU will be fail for compiling.
> > >>
> > >> The related error: 
> > >>
> > >>     CC      mm/migrate.o
> > >>   mm/migrate.c: In function 'remove_migration_pte':
> > >>   mm/migrate.c:134:3: error: implicit declaration of function 'pmd_trans_huge' [-Werror=implicit-function-declaration]
> > >>      if (pmd_trans_huge(*pmd))
> > >>      ^
> > >>   mm/migrate.c:149:2: error: implicit declaration of function 'is_swap_pte' [-Werror=implicit-function-declaration]
> > >>     if (!is_swap_pte(pte))
> > >>     ^
> > >>   ...
> > >>
> > >>
> > >> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> > >> ---
> > >>  mm/Kconfig |    4 ++--
> > >>  1 files changed, 2 insertions(+), 2 deletions(-)
> > >>
> > >> diff --git a/mm/Kconfig b/mm/Kconfig
> > >> index 256bfd0..e847f19 100644
> > >> --- a/mm/Kconfig
> > >> +++ b/mm/Kconfig
> > >> @@ -245,7 +245,7 @@ config COMPACTION
> > >>  config MIGRATION
> > >>  	bool "Page migration"
> > >>  	def_bool y
> > >> -	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA
> > >> +	depends on (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA) && MMU
> > >>  	help
> > >>  	  Allows the migration of the physical location of pages of processes
> > >>  	  while the virtual addresses are not changed. This is useful in
> > >> @@ -522,7 +522,7 @@ config MEM_SOFT_DIRTY
> > >>  
> > >>  config CMA
> > >>  	bool "Contiguous Memory Allocator"
> > >> -	depends on HAVE_MEMBLOCK
> > >> +	depends on HAVE_MEMBLOCK && MMU
> > > 
> > > Why CMA has to depend on MMU as well? The MIGRATION part should be
> > > sufficient.
> > > 
> > 
> > MIGRATION need depend on MMU, when NOMMU, if select CMA, it will select
> > MIGRATION by force.
> 
> Ohh, I wasn't aware of this Kcofing limitation. You are right then and
> CMA needs a dependency as well.

Could you mention this in the changelog please.
Feel free to add
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> > e.g. for allmodconfig with sh architecture, if we only let MIGRATION
> > depend on MMU, not let CMA depend on MMU, it will report the warning
> > below:
> > 
> >   scripts/kconfig/conf --allmodconfig Kconfig
> >   warning: (COMPACTION && CMA) selects MIGRATION which has unmet direct dependencies ((NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION || CMA) && MMU)
> > 
> > And for the final config file, MIGRATION is still enabled, although MMU
> > is not defined.
> > 
> > 
> > >>  	select MIGRATION
> > >>  	select MEMORY_ISOLATION
> > >>  	help
> > > 
> > 
> > Thanks.
> > -- 
> > Chen Gang
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Michal Hocko
> SUSE Labs
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
