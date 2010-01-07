Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 49FDE60021B
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 16:46:16 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id o07Lk8Vb029056
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 21:46:09 GMT
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by spaceape10.eur.corp.google.com with ESMTP id o07LjPrA003124
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 13:46:07 -0800
Received: by pzk1 with SMTP id 1so3250597pzk.33
        for <linux-mm@kvack.org>; Thu, 07 Jan 2010 13:46:07 -0800 (PST)
Date: Thu, 7 Jan 2010 13:46:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/7] Allow CONFIG_MIGRATION to be set without
 CONFIG_NUMA
In-Reply-To: <1262795169-9095-2-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1001071331520.23894@chino.kir.corp.google.com>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jan 2010, Mel Gorman wrote:

> CONFIG_MIGRATION currently depends on CONFIG_NUMA. The current users of
> page migration such as sys_move_pages(), sys_migrate_pages() and cpuset
> process migration are ordinarily only beneficial on NUMA.
> 
> As memory compaction will operate within a zone and is useful on both NUMA
> and non-NUMA systems, this patch allows CONFIG_MIGRATION to be set if the
> user selects CONFIG_COMPACTION as an option.
> 
> TODO
>   o After this patch is applied, the migration core is available but it
>     also makes NUMA-specific features available. This is too much
>     exposure so revisit this.
> 

CONFIG_MIGRATION is no longer strictly dependent on CONFIG_NUMA since 
ARCH_ENABLE_MEMORY_HOTREMOVE has allowed it to be configured for UMA 
machines.  All strictly NUMA features in the migration core should be 
isolated under its #ifdef CONFIG_NUMA (sys_move_pages()) in mm/migrate.c 
or by simply not compiling mm/mempolicy.c (sys_migrate_pages()), so this 
patch looks fine as is (although the "help" text for CONFIG_MIGRATION 
could be updated to reflect that it's useful for both memory hot-remove 
and now compaction).

> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/Kconfig |   12 +++++++++++-
>  1 files changed, 11 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 17b8947..1d8e2b2 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -168,12 +168,22 @@ config SPLIT_PTLOCK_CPUS
>  	default "4"
>  
>  #
> +# support for memory compaction
> +config COMPACTION
> +	bool "Allow for memory compaction"
> +	def_bool y
> +	select MIGRATION
> +	depends on EXPERIMENTAL && HUGETLBFS
> +	help
> +	  Allows the compaction of memory for the allocation of huge pages.
> +
> +#
>  # support for page migration
>  #
>  config MIGRATION
>  	bool "Page migration"
>  	def_bool y
> -	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE
> +	depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE || COMPACTION
>  	help
>  	  Allows the migration of the physical location of pages of processes
>  	  while the virtual addresses are not changed. This is useful for

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
