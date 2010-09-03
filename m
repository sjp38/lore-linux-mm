Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 356B46B004D
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 10:10:07 -0400 (EDT)
Date: Fri, 3 Sep 2010 09:10:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 04/10] hugetlb: hugepage migration core
In-Reply-To: <1283488658-23137-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.00.1009030907080.5633@router.home>
References: <1283488658-23137-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1283488658-23137-5-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Sep 2010, Naoya Horiguchi wrote:

> diff --git v2.6.36-rc2/mm/vmscan.c v2.6.36-rc2/mm/vmscan.c
> index c391c32..69ce2a3 100644
> --- v2.6.36-rc2/mm/vmscan.c
> +++ v2.6.36-rc2/mm/vmscan.c
> @@ -40,6 +40,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/delayacct.h>
>  #include <linux/sysctl.h>
> +#include <linux/hugetlb.h>
>
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -508,6 +509,10 @@ void putback_lru_page(struct page *page)
>
>  	VM_BUG_ON(PageLRU(page));
>
> +	if (PageHuge(page)) {
> +		put_page(page);
> +		return;
> +	}
>  redo:
>  	ClearPageUnevictable(page);
>
> @@ -1112,7 +1117,9 @@ int isolate_lru_page(struct page *page)
>  {
>  	int ret = -EBUSY;
>
> -	if (PageLRU(page)) {
> +	if (PageHuge(page) && get_page_unless_zero(compound_head(page)))
> +		ret = 0;
> +	else if (PageLRU(page)) {
>  		struct zone *zone = page_zone(page);
>
>  		spin_lock_irq(&zone->lru_lock);
>

Huge pages are not on the LRU right? So why use the lru functions for
them and then not use the lru? Its a bit stranger. The caller must aware
of the different handling of huge pages since there is no toying around
with the lru. So just have the caller do a put or get page instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
