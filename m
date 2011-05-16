Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AACB290010B
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:18:02 -0400 (EDT)
Date: Mon, 16 May 2011 14:16:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
Message-Id: <20110516141654.2728f05a.akpm@linux-foundation.org>
In-Reply-To: <1305558417-24354-3-git-send-email-mgorman@suse.de>
References: <1305558417-24354-1-git-send-email-mgorman@suse.de>
	<1305558417-24354-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>

On Mon, 16 May 2011 16:06:57 +0100
Mel Gorman <mgorman@suse.de> wrote:

> Under constant allocation pressure, kswapd can be in the situation where
> sleeping_prematurely() will always return true even if kswapd has been
> running a long time. Check if kswapd needs to be scheduled.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index af24d1e..4d24828 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
>  	unsigned long balanced = 0;
>  	bool all_zones_ok = true;
>  
> +	/* If kswapd has been running too long, just sleep */
> +	if (need_resched())
> +		return false;
> +
>  	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
>  	if (remaining)
>  		return true;

I'm a bit worried by this one.

Do we really fully understand why kswapd is continuously running like
this?  The changelog makes me think "no" ;)

Given that the page-allocating process is madly reclaiming pages in
direct reclaim (yes?) and that kswapd is madly reclaiming pages on a
different CPU, we should pretty promptly get into a situation where
kswapd can suspend itself.  But that obviously isn't happening.  So
what *is* going on?

Secondly, taking an up-to-100ms sleep in response to a need_resched()
seems pretty savage and I suspect it risks undesirable side-effects.  A
plain old cond_resched() would be more cautious.  But presumably
kswapd() is already running cond_resched() pretty frequently, so why
didn't that work?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
