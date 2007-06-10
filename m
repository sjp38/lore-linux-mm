Message-ID: <466C36AE.3000101@redhat.com>
Date: Sun, 10 Jun 2007 13:36:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random>
In-Reply-To: <8e38f7656968417dfee0.1181332979@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> -	else
> +	nr_inactive = zone_page_state(zone, NR_INACTIVE) >> priority;
> +	if (nr_inactive < sc->swap_cluster_max)
>  		nr_inactive = 0;

This is a problem.

On workloads with lots of anonymous memory, for example
running a very large JVM or simply stressing the system
with AIM7, the inactive list can be very small.

If dozens (or even hundreds) of tasks get into the
pageout code simultaneously, they will all spend a lot
of time moving pages from the active to the inactive
list, but they will not even try to free any of the
(few) inactive pages the system has!

We have observed systems in stress tests that spent
well over 10 minutes in shrink_active_list before
the first call to shrink_inactive_list was made.

Your code looks like it could exacerbate that situation,
by not having zone->nr_scan_inactive increment between
calls.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
