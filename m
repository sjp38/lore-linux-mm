Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83BE56B02F4
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 10:27:35 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 77so28898107wrb.11
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 07:27:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l126si244583wmd.3.2017.06.26.07.27.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 07:27:33 -0700 (PDT)
Date: Mon, 26 Jun 2017 16:27:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Error in freeing memory with zone reclaimable always returning
 true.
Message-ID: <20170626142730.GP11534@dhcp22.suse.cz>
References: <CABXF_ACjD535xtk5_1MO6O8rdT+eudCn=GG0tM1ntEb6t1JO8w@mail.gmail.com>
 <20170626080019.GC11534@dhcp22.suse.cz>
 <1498482248.5348.7.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1498482248.5348.7.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ivid Suvarna <ivid.suvarna@gmail.com>
Cc: linux-mm@kvack.org

On Mon 26-06-17 06:04:08, Ivid Suvarna wrote:
> On Mon, 2017-06-26 at 10:00 +0200, Michal Hocko wrote:
> > On Mon 26-06-17 12:59:17, Ivid Suvarna wrote:
> > > 
> > > Hi,
> > > 
> > > I have below code which tries to free memory,
> > > do
> > > {
> > > free=shrink_all_memory;
> > > }while(free>0);
> > What is the intention of such a code. It looks quite wrong to me, to
> > be
> > honest.
> > 
> 
> My case is somewhat similar to hibernation where memory is freed for
> hibernation image and I want to free as much memory as possible until
> no pages can be reclaimed. i.e., until free returns 0. 

I would just discourage you from doing something like that. Why would
you want to swap out the working set for example? Isn't something like
dropping the clean page cache sufficient?

> > > But kernel gets into infinite loop because shrink_all_memory always
> > > returns
> > > 1.
> > > When I added some debug statements to `mm/vmscan.c` and found that
> > > it is
> > > because zone_reclaimable() is always true in shrink_zones()
> > > 
> > > if (global_reclaim(sc) &&
> > >             !reclaimable && zone_reclaimable(zone))
> > >             reclaimable = true;
> > > 
> > > This issue gets solved by removing the above lines.
> > > I am using linux-kernel 4.4 and imx board.
> > The code has changed quite a bit since 4.4 but in princible
> > zone_reclaimable was a rather dubious heuristic to not fail reclaim
> > too
> > early because that would trigger the OOM in the page allocator path
> > prematurely. This has changed in 4.7 by 0a0337e0d1d1 ("mm, oom:
> > rework
> > oom detection"). zone_reclaimable later renamed to pgdat_reclaimable
> > is
> > gone from the kernel in the latests mmotm kernel.
> > 
> 
> Suppose for testing purpose say I remove these lines only and not apply
> the whole patch("mm, oom: rework oom detection") as a solution, then
> what are the possible side effects? Are we like skipping something
> (possible reclaimable pages) by doing this?
> And will this effect any other reclaim logics?

as I've said oom detection at that time relied on this check. So you
could trigger oom prematurelly.

> > > Similar Issue is seen here[1]. And it is solved through a patch
> > > removing
> > > the offending lines. But it does not explain why the zone
> > > reclaimable goes
> > > into infinite loop and what causes it? And I ran the C program from
> > > [1]
> > > which is below. And instead of OOM it went on to infinite loop.
> > Yes the previous oom detection could lock up.
> > 
> 
> Could you explain more on why zone reclaimable be returning true
> always,
> even if there are no pages in LRU list to reclaim?

It will not but the mere fact that basically any freed page would reset
the NR_PAGES_SCANNED counter then chances are that this would keep you
livelocked.

> > > #include <stdlib.h>
> > > #include <string.h>
> > > 
> > > int main(void)
> > > {
> > > for (;;) {
> > > void *p = malloc(1024 * 1024);
> > > memset(p, 0, 1024 * 1024);
> > > }
> > > }
> > > 
> > > Also can this issue be related to memcg as in here "
> > > https://lwn.net/Articles/508923/" because I see the code flow in my
> > > case
> > > enters:
> > > 
> > > if(nr_soft_reclaimed)
> > > reclaimable=true;
> > > 
> > > I dont understand memcg correctly. But in my case CONFIG_MEMCG is
> > > not set.
> > then it never reaches that path.
> > 
> 
> I did not understand. Are you saying that since MEMCG is disabled,
> above if statement should
> not be executed? If that is the case , then why I am entering the if
> block?

If the memcg is disabled then nr_soft_reclaimed will never b true.

[...]
> > >  3. I tried to unmount /dev/shm but was not possible since process
> > > was
> > > using it. Can we release shared memory by any way? I tried `munmap`
> > > but no
> > > use.
> > remove files from /dev/shm?
> > 
> 
> Since there are some files in shared memory created by process,
> I just tried to remove them and test if the issue still exists. Sadly
> it exists. 

Files will exist as long as th process keeps them open. But I still do
not understand what you are after...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
