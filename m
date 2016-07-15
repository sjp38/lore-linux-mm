Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id A18E56B025E
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 11:54:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id q2so192195292pap.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 08:54:09 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id x5si1362659pax.157.2016.07.15.08.54.07
        for <linux-mm@kvack.org>;
        Fri, 15 Jul 2016 08:54:08 -0700 (PDT)
Date: Sat, 16 Jul 2016 00:54:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/5] mm, vmscan: Update all zone LRU sizes before
 updating memcg
Message-ID: <20160715155408.GE8644@bbox>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
 <1468588165-12461-6-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1468588165-12461-6-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 02:09:25PM +0100, Mel Gorman wrote:
> Minchan Kim reported setting the following warning on a 32-bit system
> although it can affect 64-bit systems.
> 
>   WARNING: CPU: 4 PID: 1322 at mm/memcontrol.c:998 mem_cgroup_update_lru_size+0x103/0x110
>   mem_cgroup_update_lru_size(f44b4000, 1, -7): zid 1 lru_size 1 but empty
>   Modules linked in:
>   CPU: 4 PID: 1322 Comm: cp Not tainted 4.7.0-rc4-mm1+ #143
>   Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>    00000086 00000086 c2bc5a10 db3e4a97 c2bc5a54 db9d4025 c2bc5a40 db07b82a
>    db9d0594 c2bc5a70 0000052a db9d4025 000003e6 db208463 000003e6 00000001
>    f44b4000 00000001 c2bc5a5c db07b88b 00000009 00000000 c2bc5a54 db9d0594
>   Call Trace:
>    [<db3e4a97>] dump_stack+0x76/0xaf
>    [<db07b82a>] __warn+0xea/0x110
>    [<db208463>] ? mem_cgroup_update_lru_size+0x103/0x110
>    [<db07b88b>] warn_slowpath_fmt+0x3b/0x40
>    [<db208463>] mem_cgroup_update_lru_size+0x103/0x110
>    [<db1b52a2>] isolate_lru_pages.isra.61+0x2e2/0x360
>    [<db1b6ffc>] shrink_active_list+0xac/0x2a0
>    [<db3f136e>] ? __delay+0xe/0x10
>    [<db1b772c>] shrink_node_memcg+0x53c/0x7a0
>    [<db1b7a3b>] shrink_node+0xab/0x2a0
>    [<db1b7cf6>] do_try_to_free_pages+0xc6/0x390
>    [<db1b8205>] try_to_free_pages+0x245/0x590
> 
> LRU list contents and counts are updated separately. Counts are updated
> before pages are added to the LRU and updated after pages are removed.
> The warning above is from a check in mem_cgroup_update_lru_size that
> ensures that list sizes of zero are empty.
> 
> The problem is that node-lru needs to account for highmem pages if
> CONFIG_HIGHMEM is set. One impact of the implementation is that the
> sizes are updated in multiple passes when pages from multiple zones were
> isolated. This happens whether HIGHMEM is set or not. When multiple zones
> are isolated, it's possible for a debugging check in memcg to be tripped.
> 
> This patch forces all the zone counts to be updated before the memcg
> function is called.
> 
> Reported-and-tested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
