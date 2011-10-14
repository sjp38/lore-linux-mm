Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C5F776B0174
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 19:23:24 -0400 (EDT)
Received: by yxs7 with SMTP id 7so1854160yxs.14
        for <linux-mm@kvack.org>; Fri, 14 Oct 2011 16:23:22 -0700 (PDT)
Date: Fri, 14 Oct 2011 16:23:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/9] mm: move some functions from memory_hotplug.c to
 page_isolation.c
Message-Id: <20111014162319.825896dc.akpm@linux-foundation.org>
In-Reply-To: <1317909290-29832-2-git-send-email-m.szyprowski@samsung.com>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
	<1317909290-29832-2-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Thu, 06 Oct 2011 15:54:41 +0200
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Memory hotplug is a logic for making pages unused in the specified
> range of pfn. So, some of core logics can be used for other purpose
> as allocating a very large contigous memory block.
> 
> This patch moves some functions from mm/memory_hotplug.c to
> mm/page_isolation.c. This helps adding a function for large-alloc in
> page_isolation.c with memory-unplug technique.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> [m.nazarewicz: reworded commit message]
> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> [m.szyprowski: rebased and updated to Linux v3.0-rc1]
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>
>
> ...
>
> +/*
> + * For migration.
> + */
> +
> +int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn);

This is a rather poor function name.  Given that we're now making it a
global identifier, perhaps we should give it a better name. 
pages_in_single_zone()?

> +unsigned long scan_lru_pages(unsigned long start, unsigned long end);
> +int do_migrate_range(unsigned long start_pfn, unsigned long end_pfn);
>  
>
> ...
>
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -5,6 +5,9 @@
>  #include <linux/mm.h>
>  #include <linux/page-isolation.h>
>  #include <linux/pageblock-flags.h>
> +#include <linux/memcontrol.h>
> +#include <linux/migrate.h>
> +#include <linux/mm_inline.h>
>  #include "internal.h"
>  
>  static inline struct page *
> @@ -139,3 +142,114 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  	return ret ? 0 : -EBUSY;
>  }
> +
> +
> +/*
> + * Confirm all pages in a range [start, end) is belongs to the same zone.

It would be good to fix up that sentence while we're touching it. 
"Confirm that all pages ...  belong to the same zone".

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
