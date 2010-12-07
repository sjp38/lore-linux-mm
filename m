Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE0B56B0089
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 09:49:40 -0500 (EST)
Date: Tue, 7 Dec 2010 15:49:24 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4 2/7] deactivate invalidated pages
Message-ID: <20101207144923.GB2356@cmpxchg.org>
References: <cover.1291568905.git.minchan.kim@gmail.com>
 <d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 06, 2010 at 02:29:10AM +0900, Minchan Kim wrote:
> Changelog since v3:
>  - Change function comments - suggested by Johannes
>  - Change function name - suggested by Johannes
>  - add only dirty/writeback pages to deactive pagevec

Why the extra check?

> @@ -359,8 +360,16 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  			if (lock_failed)
>  				continue;
>  
> -			ret += invalidate_inode_page(page);
> -
> +			ret = invalidate_inode_page(page);
> +			/*
> +			 * If the page is dirty or under writeback, we can not
> +			 * invalidate it now.  But we assume that attempted
> +			 * invalidation is a hint that the page is no longer
> +			 * of interest and try to speed up its reclaim.
> +			 */
> +			if (!ret && (PageDirty(page) || PageWriteback(page)))
> +				deactivate_page(page);

The writeback completion handler does not take the page lock, so you
can still miss pages that finish writeback before this test, no?

Can you explain why you felt the need to add these checks?

Thanks!

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
