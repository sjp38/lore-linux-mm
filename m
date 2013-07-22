Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 02F096B0034
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 15:47:09 -0400 (EDT)
Message-ID: <51ED8C37.5020306@redhat.com>
Date: Mon, 22 Jul 2013 15:47:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/3] mm: vmscan: fix numa reclaim balance problem in kswapd
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org> <1374267325-22865-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374267325-22865-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/19/2013 04:55 PM, Johannes Weiner wrote:
> When the page allocator fails to get a page from all zones in its
> given zonelist, it wakes up the per-node kswapds for all zones that
> are at their low watermark.
>
> However, with a system under load and the free page counters being
> per-cpu approximations, the observed counter value in a zone can
> fluctuate enough that the allocation fails but the kswapd wakeup is
> also skipped while the zone is still really close to the low
> watermark.
>
> When one node misses a wakeup like this, it won't be aged before all
> the other node's zones are down to their low watermarks again.  And
> skipping a full aging cycle is an obvious fairness problem.
>
> Kswapd runs until the high watermarks are restored, so it should also
> be woken when the high watermarks are not met.  This ages nodes more
> equally and creates a safety margin for the page counter fluctuation.
>
> By using zone_balanced(), it will now check, in addition to the
> watermark, if compaction requires more order-0 pages to create a
> higher order page.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

This patch alone looks like it could have the effect of increasing
the pressure on the first zone in the zonelist, keeping its free
memory above the low watermark essentially forever, without having
the allocator fall back to other zones.

However, your third patch fixes that problem, and missed wakeups
would still hurt, so...

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
