Message-ID: <466C32F2.9000306@redhat.com>
Date: Sun, 10 Jun 2007 13:20:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15 of 16] limit reclaim if enough pages have been freed
References: <31ef5d0bf924fb47da14.1181332993@v2.random>
In-Reply-To: <31ef5d0bf924fb47da14.1181332993@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> No need to wipe out an huge chunk of the cache.

I've seen recent upstream kernels free up to 75% of memory
on my test system, when pushed hard enough.

It is not hard to get hundreds of tasks into the pageout
code simultaneously, all starting out at priority 12 and
not freeing anything until they all get to much lower
priorities.

A workload that is dominated by anonymous memory will
trigger this.  All anonymous memory starts out on the
active list and tasks will not even try to shrink the
inactive list because nr_inactive >> priority is 0.

This patch is a step in the right direction.

However, I believe that your [PATCH 01 of 16] is a
step in the wrong direction for these workloads...

> Signed-off-by: Andrea Arcangeli <andrea@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -938,6 +938,8 @@ static unsigned long shrink_zone(int pri
>  			nr_inactive -= nr_to_scan;
>  			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
>  								sc);
> +			if (nr_reclaimed >= sc->swap_cluster_max)
> +				break;
>  		}
>  	}

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
