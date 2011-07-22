Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2EC6B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 08:54:04 -0400 (EDT)
Subject: Re: [PATCH 7/8] mm: vmscan: Immediately reclaim end-of-LRU dirty
 pages when writeback completes
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1311265730-5324-8-git-send-email-mgorman@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
	 <1311265730-5324-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 22 Jul 2011 14:53:48 +0200
Message-ID: <1311339228.27400.34.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 2011-07-21 at 17:28 +0100, Mel Gorman wrote:
> When direct reclaim encounters a dirty page, it gets recycled around
> the LRU for another cycle. This patch marks the page PageReclaim
> similar to deactivate_page() so that the page gets reclaimed almost
> immediately after the page gets cleaned. This is to avoid reclaiming
> clean pages that are younger than a dirty page encountered at the
> end of the LRU that might have been something like a use-once page.
>=20

> @@ -834,7 +834,15 @@ static unsigned long shrink_page_list(struct list_he=
ad *page_list,
>  			 */
>  			if (page_is_file_cache(page) &&
>  					(!current_is_kswapd() || priority >=3D DEF_PRIORITY - 2)) {
> -				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
> +				/*
> +				 * Immediately reclaim when written back.
> +				 * Similar in principal to deactivate_page()
> +				 * except we already have the page isolated
> +				 * and know it's dirty
> +				 */
> +				inc_zone_page_state(page, NR_VMSCAN_INVALIDATE);
> +				SetPageReclaim(page);
> +

I find the invalidate name somewhat confusing. It makes me think we'll
drop the page without writeback, like invalidatepage().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
