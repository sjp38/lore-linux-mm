Message-ID: <4656F7BF.8060803@redhat.com>
Date: Fri, 25 May 2007 10:50:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
 a second trip around the LRU
References: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net> <1180076565.7348.14.camel@twins>
In-Reply-To: <1180076565.7348.14.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

> -		if (page_mapped(page)) {
> -			if (!reclaim_mapped ||
> -			    (total_swap_pages == 0 && PageAnon(page)) ||
> -			    page_referenced(page, 0)) {
> -				list_add(&page->lru, &l_active);
> -				continue;

This code is problematic, too.  We essentially randomize the
LRU order of the mapped pages while !reclaim_mapped, while
clearing the referenced bits on those pages.

By the time we start swapping out mapped pages, the list has
been randomized and replacement starts getting pretty bad.


Of course, these problems are pretty small compared to how
my 2GB test system misbehaves when running AIM7.

When the system runs out of memory, everything starts swapping
all at once.  Unfortunately vmstat got stuck too, so I could
not observe the start of swapping.  Once the system had freed
up 900MB (of 2GB total RAM!), vmstat returned.  The system did
not stop swapping until 1.4GB of memory was free!

With the system behaving this badly at a macro level, I do
not think page reclaim tweaks can be usefully tested...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
