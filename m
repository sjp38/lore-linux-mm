Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4336B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 17:00:53 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n4so107404202lfb.3
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 14:00:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fz2si14675022wjb.206.2016.09.18.14.00.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 14:00:52 -0700 (PDT)
Subject: Re: More OOM problems
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
Date: Sun, 18 Sep 2016 23:00:29 +0200
MIME-Version: 1.0
In-Reply-To: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On 09/18/2016 10:03 PM, Linus Torvalds wrote:
> [ More or less random collection of people from previous oom patches
> and/or discussions, if you feel you shouldn't have been cc'd, blame me
> for just picking things from earlier threads and/or commits ]
> 
> I'm afraid that the oom situation is still not fixed, and the "let's
> die quickly" patches are still a nasty regression.
> 
> I have a 16GB desktop that I just noticed killed one of the chrome
> tabs yesterday. Tha machine had *tons* of freeable memory, with
> something like 7GB of page cache at the time, if I read this right.
> 
> The trigger is a kcalloc() in the i915 driver:
> 
>     Xorg invoked oom-killer:
> gfp_mask=0x240c0d0(GFP_TEMPORARY|__GFP_COMP|__GFP_ZERO), order=3,
> oom_score_adj=0
> 
>       __kmalloc+0x1cd/0x1f0
>       alloc_gen8_temp_bitmaps+0x47/0x80 [i915]
> 
> which looks like it is one of these:
> 
>   slabinfo - version: 2.1
>   # name            <active_objs> <num_objs> <objsize> <objperslab>
> <pagesperslab>
>   kmalloc-8192         268    268   8192    4    8
>   kmalloc-4096         732    786   4096    8    8
>   kmalloc-2048        1402   1456   2048   16    8
>   kmalloc-1024        2505   2976   1024   32    8
> 
> so even just a 1kB allocation can cause an order-3 page allocation.

Sounds like SLUB. SLAB would use order-0 as long as things fit. I would
hope for SLUB to fallback to order-0 (or order-1 for 8kB) instead of
OOM, though. Guess not...

> And yeah, I had what, 137MB free memory, it's just that it's all
> fairly fragmented. There's actually even order-4 pages, but they are
> in low DMA memory and the system tries to protect them:
> 
>   Node 0 DMA: 0*4kB 1*8kB (U) 2*16kB (U) 1*32kB (U) 3*64kB (U) 2*128kB
> (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15880kB
>   Node 0 DMA32: 11110*4kB (UMEH) 2929*8kB (UMEH) 44*16kB (MH) 1*32kB
> (H) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
> 68608kB
>   Node 0 Normal: 14031*4kB (UMEH) 49*8kB (UMEH) 18*16kB (UH) 0*32kB
> 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 56804kB
>   Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=1048576kB
>   Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
>   2084682 total pagecache pages
>   11 pages in swap cache
>   Swap cache stats: add 35, delete 24, find 2/3
>   Free swap  = 8191868kB
>   Total swap = 8191996kB
>   4168499 pages RAM
> 
> And it looks like there's a fair amount of memory busy under writeback
> (470MB or so)
> 
>   active_anon:1539159 inactive_anon:374915 isolated_anon:0
>                             active_file:1251771 inactive_file:450068
> isolated_file:0
>                             unevictable:175 dirty:26 writeback:118690 unstable:0
>                             slab_reclaimable:220784 slab_unreclaimable:39819
>                             mapped:491617 shmem:382891 pagetables:20439 bounce:0
>                             free:35301 free_pcp:895 free_cma:0
> 
> And yes, CONFIG_COMPACTION was enabled.
> 
> So quite honestly, I *really* don't think that a 1kB allocation should
> have reasonably failed and killed anything at all (ok, it could have
> been an 8kB one, who knows - but it really looks like it *could* have
> been just 1kB).
> 
> Considering that kmalloc() pattern, I suspect that we need to consider
> order-3 allocations "small", and try a lot harder.

Well, order-3 is actually PAGE_ALLOC_COSTLY_ORDER, and costly orders
have to be strictly larger in all the tests. So order-3 is in fact still
considered "small", and thus it actually results in OOM instead of
allocation failure.

> Because killing processes due to "out of memory" in this situation is
> unquestionably a bug.
> 
> And no, I can't recreate this, obviously.
> 
> I think there's a series in -mm that hasn't been merged and that is
> pending (presumably for 4.9). I think Arkadiusz tested it for his
> (repeatable) workload. It may need to be considered for 4.8, because
> the above is ridiculously bad, imho.

So this series will make compaction ignore most of its heuristics
intended for reducing latency, when we keep repeating reclaim/compaction
long enough without success. This should help. But it also restores the
feedback from compaction to the retry loop (that Michal disabled for 4.8
and 4.7.x stable due to the earlier reports). So the result might not be
a clear win and that's why I hoped for more testing (thanks Arkadiusz,
though).

> Andrew? Vlastimil? Michal? Others?
> 
>             Linus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
