Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7A0606B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 22:45:25 -0400 (EDT)
Message-ID: <5167752C.6010703@redhat.com>
Date: Thu, 11 Apr 2013 22:45:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
References: <1365505625-9460-1-git-send-email-mgorman@suse.de> <1365505625-9460-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1365505625-9460-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/09/2013 07:06 AM, Mel Gorman wrote:
> kswapd stops raising the scanning priority when at least SWAP_CLUSTER_MAX
> pages have been reclaimed or the pgdat is considered balanced. It then
> rechecks if it needs to restart at DEF_PRIORITY and whether high-order
> reclaim needs to be reset. This is not wrong per-se but it is confusing
> to follow and forcing kswapd to stay at DEF_PRIORITY may require several
> restarts before it has scanned enough pages to meet the high watermark even
> at 100% efficiency. This patch irons out the logic a bit by controlling
> when priority is raised and removing the "goto loop_again".
>
> This patch has kswapd raise the scanning priority until it is scanning
> enough pages that it could meet the high watermark in one shrink of the
> LRU lists if it is able to reclaim at 100% efficiency. It will not raise
> the scanning prioirty higher unless it is failing to reclaim any pages.
>
> To avoid infinite looping for high-order allocation requests kswapd will
> not reclaim for high-order allocations when it has reclaimed at least
> twice the number of pages as the allocation request.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

It looks like this patch could lead to near-infinite reclaiming when
higher-order reclaim is being done, but patch 4/10 should fix that...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
