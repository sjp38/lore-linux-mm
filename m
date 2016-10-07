Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC86D280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 05:16:29 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hm5so22488099pac.4
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 02:16:29 -0700 (PDT)
Received: from mail-pf0-f193.google.com (mail-pf0-f193.google.com. [209.85.192.193])
        by mx.google.com with ESMTPS id d11si7849974pfb.98.2016.10.07.02.16.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 02:16:29 -0700 (PDT)
Received: by mail-pf0-f193.google.com with SMTP id 190so2571606pfv.1
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 02:16:29 -0700 (PDT)
Date: Fri, 7 Oct 2016 11:16:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/4] use up highorder free pages before OOM
Message-ID: <20161007091625.GB18447@dhcp22.suse.cz>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475819136-24358-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Fri 07-10-16 14:45:32, Minchan Kim wrote:
> I got OOM report from production team with v4.4 kernel.
> It has enough free memory but failed to allocate order-0 page and
> finally encounter OOM kill.
> I could reproduce it with my test easily. Look at below.
> The reason is free pages(19M) of DMA32 zone are reserved for
> HIGHORDERATOMIC and doesn't unreserved before the OOM.

Is this really reproducible?

[...]
> active_anon:383949 inactive_anon:106724 isolated_anon:0
>  active_file:15 inactive_file:44 isolated_file:0
>  unevictable:0 dirty:0 writeback:24 unstable:0
>  slab_reclaimable:2483 slab_unreclaimable:3326
>  mapped:0 shmem:0 pagetables:1906 bounce:0
>  free:6898 free_pcp:291 free_cma:0
[...]
> Free swap  = 8kB
> Total swap = 255996kB
> 524158 pages RAM
> 0 pages HighMem/MovableOnly
> 12658 pages reserved
> 0 pages cma reserved
> 0 pages hwpoisoned

>From the above you can see that you are pretty much out of memory. There
is basically no pagecache to reclaim and your anon memory is not 
reclaimable either because the swap is basically full. It is true that 
the high atomic reserves consume 19MB which could be reused but this 
less than 1%, especially when you compare that to the amount of reserved
memory.

So while I do agree that potential issues - misaccounting and others you
are addressing in the follow up patch - are good to fix but I believe that
draining last 19M is not something that would reliably get you over the
edge. Your workload (93% of memory sitting on anon LRU with swap full)
simply doesn't fit into the amount of memory you have available.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
