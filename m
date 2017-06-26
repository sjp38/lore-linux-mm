Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 062F36B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 04:00:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f49so27862055wrf.5
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 01:00:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j43si13347758wra.339.2017.06.26.01.00.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 01:00:22 -0700 (PDT)
Date: Mon, 26 Jun 2017 10:00:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Error in freeing memory with zone reclaimable always returning
 true.
Message-ID: <20170626080019.GC11534@dhcp22.suse.cz>
References: <CABXF_ACjD535xtk5_1MO6O8rdT+eudCn=GG0tM1ntEb6t1JO8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXF_ACjD535xtk5_1MO6O8rdT+eudCn=GG0tM1ntEb6t1JO8w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ivid Suvarna <ivid.suvarna@gmail.com>
Cc: linux-mm@kvack.org

On Mon 26-06-17 12:59:17, Ivid Suvarna wrote:
> Hi,
> 
> I have below code which tries to free memory,
> do
> {
> free=shrink_all_memory;
> }while(free>0);

What is the intention of such a code. It looks quite wrong to me, to be
honest.

> But kernel gets into infinite loop because shrink_all_memory always returns
> 1.
> When I added some debug statements to `mm/vmscan.c` and found that it is
> because zone_reclaimable() is always true in shrink_zones()
> 
> if (global_reclaim(sc) &&
>             !reclaimable && zone_reclaimable(zone))
>             reclaimable = true;
> 
> This issue gets solved by removing the above lines.
> I am using linux-kernel 4.4 and imx board.

The code has changed quite a bit since 4.4 but in princible
zone_reclaimable was a rather dubious heuristic to not fail reclaim too
early because that would trigger the OOM in the page allocator path
prematurely. This has changed in 4.7 by 0a0337e0d1d1 ("mm, oom: rework
oom detection"). zone_reclaimable later renamed to pgdat_reclaimable is
gone from the kernel in the latests mmotm kernel.

> Similar Issue is seen here[1]. And it is solved through a patch removing
> the offending lines. But it does not explain why the zone reclaimable goes
> into infinite loop and what causes it? And I ran the C program from [1]
> which is below. And instead of OOM it went on to infinite loop.

Yes the previous oom detection could lock up.

> 
> #include <stdlib.h>
> #include <string.h>
> 
> int main(void)
> {
> for (;;) {
> void *p = malloc(1024 * 1024);
> memset(p, 0, 1024 * 1024);
> }
> }
> 
> Also can this issue be related to memcg as in here "
> https://lwn.net/Articles/508923/" because I see the code flow in my case
> enters:
> 
> if(nr_soft_reclaimed)
> reclaimable=true;
> 
> I dont understand memcg correctly. But in my case CONFIG_MEMCG is not set.

then it never reaches that path.

> After some more debugging, I found a userspace process in sleeping state
> and has three threads. This process is in pause state through
> system_pause() and is accessing shared memory(`/dev/shm`) which is created
> with 100m size. This shared memory has some files.
> 
> Also this process has some anonymous private and shared mappings when I saw
> the output of `pmap -d PID` and there is no swap space in the system.
> 
> I found that this hang situation was not present after I remove that
> userspace process. But how can that be a solution since kernel should be
> able to handle any exception.
> 
> "I found no issues at all if I removed this userspace process".

I am not sure I understand what is the problem here but could you try
with the current upstream kernel?

> So my doubts are:
> 
>  1. How can this sleeping process in pause state cause issue in zone
> reclaimable returning true always.

It simply cannot. Sleeping process doesn't interact with the system.

>  2. How are the pages reclaimed from sleeping process which is using shared
> memory in linux?

There is a background reclaimer (kswapd for each NUMA node) and if that
cannot catch up with the pace of allocation then the allocation context
is pushed to reclaim memory (direct reclaim).

>  3. I tried to unmount /dev/shm but was not possible since process was
> using it. Can we release shared memory by any way? I tried `munmap` but no
> use.

remove files from /dev/shm?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
