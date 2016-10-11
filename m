Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 329076B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 02:44:31 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x79so7687788lff.2
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 23:44:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1si2980961wjv.42.2016.10.10.23.44.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Oct 2016 23:44:29 -0700 (PDT)
Date: Tue, 11 Oct 2016 08:44:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20161011064426.GA31996@dhcp22.suse.cz>
References: <eafb59b5-0a2b-0e28-ca79-f044470a2851@Quantum.com>
 <20160930214448.GB28379@dhcp22.suse.cz>
 <982671bd-5733-0cd5-c15d-112648ff14c5@Quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <982671bd-5733-0cd5-c15d-112648ff14c5@Quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

[Let's restore the CC list]

On Mon 10-10-16 10:20:27, Ralf-Peter Rohbeck wrote:
> I ran my torture test overnight (after finding the last linux-next branch
> that compiled, sigh...):
> Wrote two 4TB USB3 drives, compiled a kernel and ran my btrfs dedup script
> in parallel.

Thanks for testing and good to hear that premature OOMs are gone

> There were a few allocation failures but I didn't notice anything amiss but
> the log entries.
> Logs are at
> https://filebin.net/duj4c1bv64uohm5q/OOM_4.8.0-rc7-next-20160920.tar.bz2.

Oct 10 03:35:18 fs kernel: kworker/1:202: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 03:35:18 fs kernel: kworker/1:214: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 03:35:18 fs kernel: kworker/1:236: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 03:35:18 fs kernel: kworker/1:236: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 03:35:18 fs kernel: kworker/1:224: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 03:35:18 fs kernel: kworker/1:224: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 03:35:18 fs kernel: kworker/1:172: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 03:35:18 fs kernel: kworker/1:227: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 03:35:18 fs kernel: kworker/1:226: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 03:35:18 fs kernel: kworker/1:229: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 06:45:54 fs kernel: kworker/3:91: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)
Oct 10 06:45:54 fs kernel: kworker/3:91: page allocation failure: order:0, mode:0x2204000(GFP_NOWAIT|__GFP_COMP|__GFP_NOTRACK)

So those are all atomic (aka not sleeping) 4K allocations failing
because you are running low on memory and this kind of allocation
requests cannot reclaim any memory.
: Oct 10 03:35:18 fs kernel: Node 0 active_anon:28004kB inactive_anon:532404kB active_file:5665056kB inactive_file:1290052kB unevictable:64kB isolated(anon):0kB isolated(file):128kB mapped:46196kB dirty:686200kB writeback:124196kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 17920kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
: Oct 10 03:35:18 fs kernel: Node 0 DMA free:14236kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15980kB managed:15896kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:1660kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
: Oct 10 03:35:18 fs kernel: lowmem_reserve[]: 0 1939 7939 7939 7939
: Oct 10 03:35:18 fs kernel: Node 0 DMA32 free:40476kB min:16480kB low:20600kB high:24720kB active_anon:6472kB inactive_anon:14408kB active_file:1073784kB inactive_file:740536kB unevictable:0kB writepending:470432kB present:2072256kB managed:2006688kB mlocked:0kB slab_reclaimable:60376kB slab_unreclaimable:32844kB kernel_stack:8352kB pagetables:1984kB bounce:0kB free_pcp:164kB local_pcp:0kB free_cma:0kB
: Oct 10 03:35:18 fs kernel: lowmem_reserve[]: 0 0 5999 5999 5999

These two zones are above min watermark but still under if we consider
lowmemory reserves.

: Oct 10 03:35:18 fs kernel: Node 0 Normal free:50928kB min:50968kB low:63708kB high:76448kB active_anon:21532kB inactive_anon:517996kB active_file:4591272kB inactive_file:549636kB unevictable:64kB writepending:339940kB present:6291456kB managed:6147908kB mlocked:64kB slab_reclaimable:105320kB slab_unreclaimable:146140kB kernel_stack:17664kB pagetables:43872kB bounce:0kB free_pcp:340kB local_pcp:0kB free_cma:0kB
: Oct 10 03:35:18 fs kernel: lowmem_reserve[]: 0 0 0 0 0

and this zone is below the min watermark. I haven't checked other
allocation failures but I assume a similar situation. It looks that you
have a peak memory pressure load and kswapd just cannot catch up with it
for a moment. Note that most of those failures come within a second. You
can ignore these warnings.

I will just note that all those failures come from bcache.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
