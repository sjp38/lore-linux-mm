Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9643C6B0261
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 03:05:04 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so76756247pab.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 00:05:04 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id u5si39330397pau.218.2016.09.21.00.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 00:05:03 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id z123so16143625pfz.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 00:05:03 -0700 (PDT)
Date: Wed, 21 Sep 2016 00:04:58 -0700
From: Raymond Jennings <shentino@gmail.com>
Subject: Re: More OOM problems
Message-ID: <20160921000458.15fdd159@metalhead.dragonrealms>
In-Reply-To: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sun, 18 Sep 2016 13:03:01 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

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

Suggestions:

* Live compaction?

Have a background process that actively defragments free memory by
bubbling movable pages to one end of the zone and the free holes to the
other end?

Same spirit perhaps as khugepaged, periodically walk a zone from one
end and migrate any used movable pages into the hole closest to the
other end?

I dunno, doing this manually with /proc/sys/vm/compact_blah seems a
little hamfisted to me, and maybe a background process doing it
incrementally would be better?

Also, question (for myself but also for the curious):

If you're allocating memory, can you synchronously reclaim, or does the
memory have to be free already?  I have a hunch that if you get caught
with freeable memory that's still being used as clean pagecache, you
should be able to free it immediately if memory is scarce...but then
again it might choke because a process in userland could always touch
it through vfs or something like that.

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
> 
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
>                             unevictable:175 dirty:26 writeback:118690
> unstable:0 slab_reclaimable:220784 slab_unreclaimable:39819
>                             mapped:491617 shmem:382891
> pagetables:20439 bounce:0 free:35301 free_pcp:895 free_cma:0
> 
> And yes, CONFIG_COMPACTION was enabled.

Does this compact manually or automatically?

> So quite honestly, I *really* don't think that a 1kB allocation should
> have reasonably failed and killed anything at all (ok, it could have
> been an 8kB one, who knows - but it really looks like it *could* have
> been just 1kB).
> 
> Considering that kmalloc() pattern, I suspect that we need to consider
> order-3 allocations "small", and try a lot harder.
> 
> Because killing processes due to "out of memory" in this situation is
> unquestionably a bug.

In this case I'd wonder why the freeable-but-still-used-in-pagecache
memory isn't being reaped at alloc time.

> And no, I can't recreate this, obviously.
> 
> I think there's a series in -mm that hasn't been merged and that is
> pending (presumably for 4.9). I think Arkadiusz tested it for his
> (repeatable) workload. It may need to be considered for 4.8, because
> the above is ridiculously bad, imho.
> 
> Andrew? Vlastimil? Michal? Others?
> 
>             Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
