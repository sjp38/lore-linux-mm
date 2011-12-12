Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 0EFA86B0179
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:29:11 -0500 (EST)
Date: Mon, 12 Dec 2011 14:29:07 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/11] mm: compaction: export some of the functions
Message-ID: <20111212142906.GE3277@csn.ul.ie>
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-5-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1321634598-16859-5-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Fri, Nov 18, 2011 at 05:43:11PM +0100, Marek Szyprowski wrote:
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
>  mm/compaction.c |  112 +++++++++++++++++++++++--------------------------------
>  mm/internal.h   |   35 +++++++++++++++++
>  3 files changed, 83 insertions(+), 67 deletions(-)
> 
> diff --git a/mm/Makefile b/mm/Makefile
> index 50ec00e..24ed801 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -13,7 +13,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
>  			   readahead.o swap.o truncate.o vmscan.o shmem.o \
>  			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
>  			   page_isolation.o mm_init.o mmu_context.o percpu.o \
> -			   $(mmu-y)
> +			   $(mmu-y) compaction.o

That should be

compaction.o $(mmu-y)

for consistency.

Overall, this patch implies that CMA is always compiled in. Why
not just make CMA depend on COMPACTION to keep things simplier? For
example, if you enable CMA and do not enable COMPACTION, you lose
things like the vmstat counters that can aid debugging. In fact, as
parts of compaction.c are using defines like COMPACTBLOCKS, I'm not
even sure compaction.c can compile without CONFIG_COMPACTION because
of the vmstat stuff.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
