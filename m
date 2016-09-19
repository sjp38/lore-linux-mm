Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 040166B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 04:32:20 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l132so56514548wmf.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 01:32:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o9si21100012wji.282.2016.09.19.01.32.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 01:32:18 -0700 (PDT)
Date: Mon, 19 Sep 2016 10:32:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20160919083215.GF10785@dhcp22.suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160918202614.GB31286@lucifer>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160918202614.GB31286@lucifer>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sun 18-09-16 21:26:14, Lorenzo Stoakes wrote:
> Hi all,
> 
> In case it's helpful - I have experienced these OOM issues invoked
> in my case via the nvidia driver and similarly to Linus an order
> 3 allocation resulted in killed chromium tabs. I encountered this
> even after applying the patch discussed in the original thread at
> https://lkml.org/lkml/2016/8/22/184. It's not easily reproducible
> but it is happening enough that I could probably check some specific
> state when it next occurs or test out a patch to see if it stops it if
> that'd be useful.
>
> I saved a couple OOM's from the last time it occurred, this is on a
> 8GiB system with plenty of reclaimable memory:

Just for the reference
 
> [350085.038693] Xorg invoked oom-killer: gfp_mask=0x24040c0(GFP_KERNEL|__GFP_COMP), order=3, oom_score_adj=0
> [350085.038696] Xorg cpuset=/ mems_allowed=0
> [350085.038699] CPU: 0 PID: 2119 Comm: Xorg Tainted: P           O    4.7.2-1-custom #1
[...]
> [350085.039048] Mem-Info:
> [350085.039051] active_anon:861397 inactive_anon:23397 isolated_anon:0
>                  active_file:146274 inactive_file:144248 isolated_file:0
>                  unevictable:8 dirty:14587 writeback:0 unstable:0
>                  slab_reclaimable:697630 slab_unreclaimable:24397
>                  mapped:79655 shmem:26548 pagetables:7211 bounce:0
>                  free:25159 free_pcp:235 free_cma:0
> [350085.039054] Node 0 DMA free:15516kB min:136kB low:168kB high:200kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> [350085.039058] lowmem_reserve[]: 0 3196 7658 7658
> [350085.039060] Node 0 DMA32 free:45980kB min:28148kB low:35184kB high:42220kB active_anon:1466208kB inactive_anon:43120kB active_file:239740kB inactive_file:234920kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3617864kB managed:3280092kB mlocked:0kB dirty:21692kB writeback:0kB mapped:131184kB shmem:47588kB slab_reclaimable:1147984kB slab_unreclaimable:37484kB kernel_stack:2976kB pagetables:11512kB unstable:0kB bounce:0kB free_pcp:188kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [350085.039064] lowmem_reserve[]: 0 0 4462 4462

45980-(4462*4) = 28132

> [350085.039065] Node 0 Normal free:39140kB min:39296kB low:49120kB high:58944kB active_anon:1979380kB inactive_anon:50468kB active_file:345356kB inactive_file:342072kB unevictable:32kB isolated(anon):0kB isolated(file):0kB present:4702208kB managed:4569312kB mlocked:32kB dirty:36656kB writeback:0kB mapped:187436kB shmem:58604kB slab_reclaimable:1642536kB slab_unreclaimable:60104kB kernel_stack:5040kB pagetables:17332kB unstable:0kB bounce:0kB free_pcp:752kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:136 all_unreclaimable? no

so this is the same thing as in Linus case. All the zones are hitting
min wmark so the should_compact_retry() gave up. As mentioned in other
email [1] this is inherent limitation of the workaround. Your system is
swapless but there is a lot of the reclaimable page cache so Vlastimil's
patches should help.

[1] http://lkml.kernel.org/r/20160919075230.GE10785@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
