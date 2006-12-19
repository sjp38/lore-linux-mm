Message-ID: <458760B0.7090803@yahoo.com.au>
Date: Tue, 19 Dec 2006 14:46:56 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Fix area->nr_free-- went (-1) issue in buddy system
References: <6d6a94c50612181901m1bfd9d1bsc2d9496ab24eb3f8@mail.gmail.com>
In-Reply-To: <6d6a94c50612181901m1bfd9d1bsc2d9496ab24eb3f8@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey <aubreylee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Aubrey wrote:
> Hi all,
> 
> When I setup two zones (NORMAL and DMA) in my system, I got the
> following wired result from /proc/buddyinfo.
> ----------------------------------------------------------------------------------------- 
> 
> root:~> cat /proc/buddyinfo
> Node 0, zone      DMA      2      1      2      1      1      0      0
>     1      1      2      2      0      0      0
> Node 0, zone   Normal      1      1      1      1      1      1      0
>     0 4294967295      0 4294967295      2      0      0
> ----------------------------------------------------------------------------------------- 
> 
> 
> As you see, two area->nr_free went -1.
> 
> After dig into the code, I found the problem is in the fun
> __free_one_page() when the kernel boot up call free_all_bootmem(). If
> two zones setup, it's possible NORMAL zone merged a block whose order
> =8 at the first time(this time zone[NORMA]->free_area[8].nr_free = 0)
> and found its buddy in the DMA zone. So the two blocks will be merged
> and area->nr_free went to -1.

This should not happen because the pages are checked to ensure they are
from the same zone before merging.

What kind of system do you have? What is the dmesg and the .config? It
could be that the zones are not properly aligned and CONFIG_HOLES_IN_ZONE
is not set.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
