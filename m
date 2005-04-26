Date: Mon, 25 Apr 2005 20:51:41 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 4/8 dont-rotate-active-list
Message-Id: <20050425205141.0b756263.akpm@osdl.org>
In-Reply-To: <16994.40620.892220.121182@gargle.gargle.HOWL>
References: <16994.40620.892220.121182@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> Currently, if zone is short on free pages, refill_inactive_zone() starts
>  moving pages from active_list to inactive_list, rotating active_list as it
>  goes. That is, pages from the tail of active_list are transferred to its head,
>  thus destroying lru ordering, exactly when we need it most --- when system is
>  low on free memory and page replacement has to be performed.
> 
>  This patch modifies refill_inactive_zone() so that it scans active_list
>  without rotating it. To achieve this, special dummy page zone->scan_page
>  is maintained for each zone. This page marks a place in the active_list
>  reached during scanning.
> 
>  As an additional bonus, if memory pressure is not so big as to start swapping
>  mapped pages (reclaim_mapped == 0 in refill_inactive_zone()), then not
>  referenced mapped pages can be left behind zone->scan_page instead of moving
>  them to the head of active_list. When reclaim_mapped mode is activated,
>  zone->scan_page is reset back to the tail of active_list so that these pages
>  can be re-scanned.

I'll plop this into -mm to see what happens.  That should give us decent
stability testing, but someone is going to have to do a ton of performance
testing to justify an upstream merge, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
