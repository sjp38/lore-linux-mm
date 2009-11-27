Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6159B600309
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 14:25:39 -0500 (EST)
Date: Fri, 27 Nov 2009 13:25:06 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH 4/4] vmscan: vmscan don't use pcp list
In-Reply-To: <20091127091920.A7D5.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911271322450.27110@router.home>
References: <20091127091357.A7CC.A69D9226@jp.fujitsu.com> <20091127091920.A7D5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Nov 2009, KOSAKI Motohiro wrote:

> patch series, but Christoph mentioned simple bypass pcp instead.
> I made it. I'd hear Christoph and Mel's mention.

Ah. good.

> +		kmemcheck_free_shadow(page, 0);
> +
> +		if (PageAnon(page))
> +			page->mapping = NULL;
> +		if (free_pages_check(page)) {
> +			/* orphan this page. */
> +			list_del(&page->lru);
> +			continue;
> +		}
> +		if (!PageHighMem(page)) {
> +			debug_check_no_locks_freed(page_address(page),
> +						   PAGE_SIZE);
> +			debug_check_no_obj_freed(page_address(page), PAGE_SIZE);
> +		}
> +		arch_free_page(page, 0);
> +		kernel_map_pages(page, 1, 0);
> +
> +		local_irq_save(flags);
> +		if (unlikely(wasMlocked))
> +			free_page_mlock(page);
> +		local_irq_restore(flags);

The above looks like it should be generic logic that is used elsewhere?
Create a common function?


Rest looks good to me...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
