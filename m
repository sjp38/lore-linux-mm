Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 50472900117
	for <linux-mm@kvack.org>; Sat, 25 Jun 2011 19:18:12 -0400 (EDT)
Message-ID: <4E066CA0.7060802@redhat.com>
Date: Sat, 25 Jun 2011 19:17:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: vmscan: Only read new_classzone_idx from pgdat
 when reclaiming successfully
References: <1308926697-22475-1-git-send-email-mgorman@suse.de> <1308926697-22475-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1308926697-22475-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?UMOhZHJhaWcgQnJh?= =?UTF-8?B?ZHk=?= <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 06/24/2011 10:44 AM, Mel Gorman wrote:
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.  Unfortunately, if the highest zone is
> small, a problem occurs.
>
> When balance_pgdat() returns, it may be at a lower classzone_idx than
> it started because the highest zone was unreclaimable. Before checking
> if it should go to sleep though, it checks pgdat->classzone_idx which
> when there is no other activity will be MAX_NR_ZONES-1. It interprets
> this as it has been woken up while reclaiming, skips scheduling and
> reclaims again. As there is no useful reclaim work to do, it enters
> into a loop of shrinking slab consuming loads of CPU until the highest
> zone becomes reclaimable for a long period of time.
>
> There are two problems here. 1) If the returned classzone or order is
> lower, it'll continue reclaiming without scheduling. 2) if the highest
> zone was marked unreclaimable but balance_pgdat() returns immediately
> at DEF_PRIORITY, the new lower classzone is not communicated back to
> kswapd() for sleeping.
>
> This patch does two things that are related. If the end_zone is
> unreclaimable, this information is communicated back. Second, if
> the classzone or order was reduced due to failing to reclaim, new
> information is not read from pgdat and instead an attempt is made to go
> to sleep. Due to this, it is also necessary that pgdat->classzone_idx
> be initialised each time to pgdat->nr_zones - 1 to avoid re-reads
> being interpreted as wakeups.
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
