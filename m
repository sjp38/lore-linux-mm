Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 791376B01AC
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 17:56:31 -0400 (EDT)
Message-ID: <4C16A567.4080000@redhat.com>
Date: Mon, 14 Jun 2010 17:55:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-13-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-13-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 06/14/2010 07:17 AM, Mel Gorman wrote:

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4856a2a..574e816 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -372,6 +372,12 @@ int write_reclaim_page(struct page *page, struct address_space *mapping,
>   	return PAGE_SUCCESS;
>   }
>
> +/* kswapd and memcg can writeback as they are unlikely to overflow stack */
> +static inline bool reclaim_can_writeback(struct scan_control *sc)
> +{
> +	return current_is_kswapd() || sc->mem_cgroup != NULL;
> +}
> +

I'm not entirely convinced on this bit, but am willing to
be convinced by the data.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
