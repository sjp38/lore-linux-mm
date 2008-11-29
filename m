Message-ID: <4931BD2C.3010706@redhat.com>
Date: Sat, 29 Nov 2008 17:07:40 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
References: <20081128060803.73cd59bd@bree.surriel.com>	<20081128231933.8daef193.akpm@linux-foundation.org>	<4931721D.7010001@redhat.com>	<20081129094537.a224098a.akpm@linux-foundation.org>	<493182C8.1080303@redhat.com>	<20081129102608.f8228afd.akpm@linux-foundation.org>	<49318CDE.4020505@redhat.com>	<20081129105120.cfb8c035.akpm@linux-foundation.org>	<49319109.7030904@redhat.com>	<20081129122901.6243d2fa.akpm@linux-foundation.org>	<4931B5B1.8030601@redhat.com> <20081129135712.817e912c.akpm@linux-foundation.org>
In-Reply-To: <20081129135712.817e912c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> The bottom line here is that we don't fully understand the problem
> which 265b2b8cac1774f5f30c88e0ab8d0bcf794ef7b3 fixed, hence we cannot
> say whether this proposed change will reintroduce it.
> 
> Why did it matter that "much more reclaim happens against highmem than
> against lowmem"?  What were the observeable effects of this?

On a 1GB system, with 892MB lowmem and 128MB highmem, it could
lead to the page cache coming mostly from highmem.  This in turn
would mean that lowmem could have hundreds of megabytes of unused
memory, while large files would not get cached in memory.

Baling out early and not putting any memory pressure on a zone
can lead to problems.

It is important that zones with easily freeable memory get some
extra memory freed, so more allocations go to that zone.

However, we also do not want to go overboard.  Kicking potentially
useful data out of memory or causing unnecessary pageout IO is
harmful too.

By doing some amount of extra reclaim in zones with easily
freeable memory means more memory will get allocated from that
zone.  Over time this equalizes pressure between zones.

The patch I sent in limits that extra reclaim (extra allocation
space) in easily freeable zones to 4 * zone->pages_high.  That
gives the zone extra free space for alloc_pages, while limiting
unnecessary pageout IO and evicting of useful data.

I am pretty sure that we do understand the differences between
that 2004 patch and the code we have today.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
