Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 20472900117
	for <linux-mm@kvack.org>; Sat, 25 Jun 2011 17:33:56 -0400 (EDT)
Message-ID: <4E065433.3020502@redhat.com>
Date: Sat, 25 Jun 2011 17:33:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] mm: vmscan: Correct check for kswapd sleeping in
 sleeping_prematurely
References: <1308926697-22475-1-git-send-email-mgorman@suse.de> <1308926697-22475-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1308926697-22475-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?UMOhZHJhaWcgQnJh?= =?UTF-8?B?ZHk=?= <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 06/24/2011 10:44 AM, Mel Gorman wrote:
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.
>
> A problem occurs if the highest zone is small.  balance_pgdat()
> only considers unreclaimable zones when priority is DEF_PRIORITY
> but sleeping_prematurely considers all zones. It's possible for this
> sequence to occur
>
>    1. kswapd wakes up and enters balance_pgdat()
>    2. At DEF_PRIORITY, marks highest zone unreclaimable
>    3. At DEF_PRIORITY-1, ignores highest zone setting end_zone
>    4. At DEF_PRIORITY-1, calls shrink_slab freeing memory from
>          highest zone, clearing all_unreclaimable. Highest zone
>          is still unbalanced
>    5. kswapd returns and calls sleeping_prematurely
>    6. sleeping_prematurely looks at *all* zones, not just the ones
>       being considered by balance_pgdat. The highest small zone
>       has all_unreclaimable cleared but but the zone is not
>       balanced. all_zones_ok is false so kswapd stays awake
>
> This patch corrects the behaviour of sleeping_prematurely to check
> the zones balance_pgdat() checked.
>
> Reported-and-tested-by: PA!draig Brady<P@draigBrady.com>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
