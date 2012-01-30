Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 081D56B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 06:57:29 -0500 (EST)
Date: Mon, 30 Jan 2012 11:57:26 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05/15] mm: compaction: export some of the functions
Message-ID: <20120130115726.GI25268@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-6-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1327568457-27734-6-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Jan 26, 2012 at 10:00:47AM +0100, Marek Szyprowski wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
> 
> This commit exports some of the functions from compaction.c file
> outside of it adding their declaration into internal.h header
> file so that other mm related code can use them.
> 
> This forced compaction.c to always be compiled (as opposed to being
> compiled only if CONFIG_COMPACTION is defined) but as to avoid
> introducing code that user did not ask for, part of the compaction.c
> is now wrapped in on #ifdef.
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>  mm/Makefile     |    3 +-
>  mm/compaction.c |  314 ++++++++++++++++++++++++++-----------------------------
>  mm/internal.h   |   33 ++++++
>  3 files changed, 184 insertions(+), 166 deletions(-)
> 
> diff --git a/mm/Makefile b/mm/Makefile
> index 50ec00e..8aada89 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -13,7 +13,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
>  			   readahead.o swap.o truncate.o vmscan.o shmem.o \
>  			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
>  			   page_isolation.o mm_init.o mmu_context.o percpu.o \
> -			   $(mmu-y)
> +			   compaction.o $(mmu-y)
>  obj-y += init-mm.o
>  
>  ifdef CONFIG_NO_BOOTMEM
> @@ -32,7 +32,6 @@ obj-$(CONFIG_NUMA) 	+= mempolicy.o
>  obj-$(CONFIG_SPARSEMEM)	+= sparse.o
>  obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
>  obj-$(CONFIG_SLOB) += slob.o
> -obj-$(CONFIG_COMPACTION) += compaction.o
>  obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
>  obj-$(CONFIG_KSM) += ksm.o
>  obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 63f82be..3e21d28 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -16,30 +16,11 @@
>  #include <linux/sysfs.h>
>  #include "internal.h"
>  
> +#if defined CONFIG_COMPACTION || defined CONFIG_CMA
> +

This is pedantic but you reference CONFIG_CMA before the patch that
declares it. The only time this really matters is when it breaks
bisection but I do not think that is the case here.

Whether you fix this or not by moving the CONFIG_CMA check to the same
patch that declares it in Kconfig

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
