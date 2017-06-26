Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 525FA6B03A7
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 09:04:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d5so611927pfe.2
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 06:04:19 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id b13si44528plk.20.2017.06.26.06.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 06:04:18 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id j186so84931pge.1
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 06:04:18 -0700 (PDT)
Message-ID: <1498482248.5348.7.camel@gmail.com>
Subject: Re: Error in freeing memory with zone reclaimable always returning
 true.
From: Ivid Suvarna <ivid.suvarna@gmail.com>
Date: Mon, 26 Jun 2017 06:04:08 -0700
In-Reply-To: <20170626080019.GC11534@dhcp22.suse.cz>
References: 
	<CABXF_ACjD535xtk5_1MO6O8rdT+eudCn=GG0tM1ntEb6t1JO8w@mail.gmail.com>
	 <20170626080019.GC11534@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Mon, 2017-06-26 at 10:00 +0200, Michal Hocko wrote:
> On Mon 26-06-17 12:59:17, Ivid Suvarna wrote:
> > 
> > Hi,
> > 
> > I have below code which tries to free memory,
> > do
> > {
> > free=shrink_all_memory;
> > }while(free>0);
> What is the intention of such a code. It looks quite wrong to me, to
> be
> honest.
> 

My case is somewhat similar to hibernation where memory is freed for
hibernation image and I want to free as much memory as possible until
no pages can be reclaimed. i.e., until free returns 0.A 

> > 
> > But kernel gets into infinite loop because shrink_all_memory always
> > returns
> > 1.
> > When I added some debug statements to `mm/vmscan.c` and found that
> > it is
> > because zone_reclaimable() is always true in shrink_zones()
> > 
> > if (global_reclaim(sc) &&
> > A A A A A A A A A A A A !reclaimable && zone_reclaimable(zone))
> > A A A A A A A A A A A A reclaimable = true;
> > 
> > This issue gets solved by removing the above lines.
> > I am using linux-kernel 4.4 and imx board.
> The code has changed quite a bit since 4.4 but in princible
> zone_reclaimable was a rather dubious heuristic to not fail reclaim
> too
> early because that would trigger the OOM in the page allocator path
> prematurely. This has changed in 4.7 by 0a0337e0d1d1 ("mm, oom:
> rework
> oom detection"). zone_reclaimable later renamed to pgdat_reclaimable
> is
> gone from the kernel in the latests mmotm kernel.
> 

Suppose for testing purpose say I remove these lines only and not apply
the whole patch("mm, oom: rework oom detection") as a solution, then
what are the possible side effects? Are we like skipping something
(possible reclaimable pages) by doing this?
And will this effect any
other reclaim logics?

> > 
> > Similar Issue is seen here[1]. And it is solved through a patch
> > removing
> > the offending lines. But it does not explain why the zone
> > reclaimable goes
> > into infinite loop and what causes it? And I ran the C program from
> > [1]
> > which is below. And instead of OOM it went on to infinite loop.
> Yes the previous oom detection could lock up.
> 

Could you explain more on why zone reclaimable be returning true
always,
even if there are no pages in LRU list to reclaim?

> > 
> > 
> > #include <stdlib.h>
> > #include <string.h>
> > 
> > int main(void)
> > {
> > for (;;) {
> > void *p = malloc(1024 * 1024);
> > memset(p, 0, 1024 * 1024);
> > }
> > }
> > 
> > Also can this issue be related to memcg as in here "
> > https://lwn.net/Articles/508923/" because I see the code flow in my
> > case
> > enters:
> > 
> > if(nr_soft_reclaimed)
> > reclaimable=true;
> > 
> > I dont understand memcg correctly. But in my case CONFIG_MEMCG is
> > not set.
> then it never reaches that path.
> 

I did not understand. Are you saying that since MEMCG is disabled,
above if statement should
not be executed? If that is the case , then why I am entering the if
block?

> > 
> > After some more debugging, I found a userspace process in sleeping
> > state
> > and has three threads. This process is in pause state through
> > system_pause() and is accessing shared memory(`/dev/shm`) which is
> > created
> > with 100m size. This shared memory has some files.
> > 
> > Also this process has some anonymous private and shared mappings
> > when I saw
> > the output of `pmap -d PID` and there is no swap space in the
> > system.
> > 
> > I found that this hang situation was not present after I remove
> > that
> > userspace process. But how can that be a solution since kernel
> > should be
> > able to handle any exception.
> > 
> > "I found no issues at all if I removed this userspace process".
> I am not sure I understand what is the problem here but could you try
> with the current upstream kernel?
> 

The issue is fixed in upstream kernel with or without
userspaceA A process.
My whole point of this thread is to determine whether the userspace
process is creating this issueor not, since there is no issue found
without my userspace process.
I have a doubt whether private or shared mappings of this userspace
process is creating problem.

> > 
> > So my doubts are:
> > 
> > A 1. How can this sleeping process in pause state cause issue in
> > zone
> > reclaimable returning true always.
> It simply cannot. Sleeping process doesn't interact with the system.
> 
> > 
> > A 2. How are the pages reclaimed from sleeping process which is
> > using shared
> > memory in linux?
> There is a background reclaimer (kswapd for each NUMA node) and if
> that
> cannot catch up with the pace of allocation then the allocation
> context
> is pushed to reclaim memory (direct reclaim).
> 

Thanks for clearing my doubts.

> > 
> > A 3. I tried to unmount /dev/shm but was not possible since process
> > was
> > using it. Can we release shared memory by any way? I tried `munmap`
> > but no
> > use.
> remove files from /dev/shm?
> 

Since there are some files in shared memory created by process,
I just tried to remove them and test if the issue still exists. Sadly
it exists.A 

Cheers,
Ivid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
