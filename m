Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A87526B02F4
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 05:26:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p138so895288wmg.3
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 02:26:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7si2658235wmz.168.2017.04.27.02.26.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 02:26:38 -0700 (PDT)
Date: Thu, 27 Apr 2017 11:26:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.11.0-rc8+/x86_64 desktop lockup until applications closed
Message-ID: <20170427092636.GD4706@dhcp22.suse.cz>
References: <md5:RQiZYAYNN/yJzTrY48XZ7w==>
 <ccd5aac8-b24a-713a-db54-c35688905595@internode.on.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ccd5aac8-b24a-713a-db54-c35688905595@internode.on.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arthur Marsh <arthur.marsh@internode.on.net>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu 27-04-17 18:36:38, Arthur Marsh wrote:
[...]
> [55363.482931] QXcbEventReader: page allocation stalls for 10048ms, order:0,
> mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)

Are there more of these stalls?

[...]
> [55363.483040] Mem-Info:
> [55363.483044] active_anon:1479559 inactive_anon:281161 isolated_anon:299
>                 active_file:49213 inactive_file:42134 isolated_file:0
>                 unevictable:4651 dirty:108 writeback:188 unstable:0
>                 slab_reclaimable:11225 slab_unreclaimable:20186
>                 mapped:204768 shmem:145888 pagetables:39859 bounce:0
>                 free:25470 free_pcp:0 free_cma:0

There is still quite some page cache to reclaim on the inactive list. So
a progress should have been made. Maybe there was a peak memory
consumption which holded this request back?

[...]
> [55363.483059] Node 0 DMA32 free:45556kB min:26948kB low:33684kB
> high:40420kB active_anon:2273532kB inactive_anon:542768kB
> active_file:99788kB inactive_file:89940kB unevictable:32kB
> writepending:440kB present:3391168kB managed:3314260kB mlocked:32kB
> slab_reclaimable:8800kB slab_unreclaimable:25976kB kernel_stack:7992kB
> pagetables:68028kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [55363.483063] lowmem_reserve[]: 0 0 4734 4734

This zone is not usable due to lowmem_reserve

> [55363.483066] Node 0 Normal free:40420kB min:40500kB low:50624kB
> high:60748kB active_anon:3644668kB inactive_anon:581672kB
> active_file:97068kB inactive_file:78784kB unevictable:18572kB
> writepending:0kB present:4980736kB managed:4848692kB mlocked:18572kB
> slab_reclaimable:36100kB slab_unreclaimable:54768kB kernel_stack:13544kB
> pagetables:91408kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [55363.483069] lowmem_reserve[]: 0 0 0 0

and this one is below min watermark already.

> [55363.483106] Free swap  = 498568kB
> [55363.483107] Total swap = 4194288kB

Still ~10% of swap is free so not entirely bad.

The question is whether this is reproducible. If yes then I would
suggest watching /proc/vmstat (every second) and if this doesn't show
anything then try to collect vmscan tracepoints

$ mount -t tracefs none /debug/trace/
$ echo 1 > /debug/trace/events/vmscan/enable
$ cat /debug/trace/trace_pipe > log

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
