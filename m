Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3E076B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 16:20:02 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id o2so81543379wje.5
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 13:20:02 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id m139si10035079wmb.129.2016.12.07.13.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 13:20:01 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 81B181C1D1D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 21:19:59 +0000 (GMT)
Date: Wed, 7 Dec 2016 21:19:58 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161207211958.s3ymjva54wgakpkm@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
 <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207194801.krhonj7yggbedpba@techsingularity.net>
 <1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Dec 07, 2016 at 12:10:24PM -0800, Eric Dumazet wrote:
> On Wed, 2016-12-07 at 19:48 +0000, Mel Gorman wrote:
> >  
> > 
> > Interesting because it didn't match what I previous measured but then
> > again, when I established that netperf on localhost was slab intensive,
> > it was also an older kernel. Can you tell me if SLAB or SLUB was enabled
> > in your test kernel?
> > 
> > Either that or the baseline I used has since been changed from what you
> > are testing and we're not hitting the same paths.
> 
> 
> lpaa6:~# uname -a
> Linux lpaa6 4.9.0-smp-DEV #429 SMP @1481125332 x86_64 GNU/Linux
> 
> lpaa6:~# perf record -g ./netperf -t UDP_STREAM -l 3 -- -m 16384
> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> localhost () port 0 AF_INET
> Socket  Message  Elapsed      Messages                
> Size    Size     Time         Okay Errors   Throughput
> bytes   bytes    secs            #      #   10^6bits/sec
> 
> 212992   16384   3.00       654644      0    28601.04
> 212992           3.00       654592           28598.77
> 

I'm seeing parts of the disconnect. The load is slab intensive but not
necessarily page allocator intensive depending on a variety of factors. While
the motivation of the patch was initially SLUB, any path that is high-order
page allocator intensive benefits so;

1. If the workload is slab intensive and SLUB is used then it may benefit
   if SLUB happens to frequently require new pages, particularly if there
   is a pattern of growing/shrinking slabs frequently.

2. If the workload is high-order page allocator intensive but bypassing
   SLUB and SLAB, then it'll benefit anyway

So you say you don't see much slab activity for some configuration and
it's hitting the page allocator. For the purposes of this patch, that's
fine albeit useless for a SLAB vs SLUB comparison.

Anything else I saw for the moment is probably not surprising;

At small packet sizes on localhost, I see relatively low page allocator
activity except during the socket setup and other unrelated activity
(khugepaged, irqbalance, some btrfs stuff) which is curious as it's
less clear why the performance was improved in that case. I considered
the possibility that it was cache hotness of pages but that's not a
good fit. If it was true then the first test would be slow and the rest
relatively fast and I'm not seeing that. The other side-effect is that
all the high-order pages that are allocated at the start are physically
close together but that shouldn't have that big an impact. So for now,
the gain is unexplained even though it happens consistently.

At larger message sizes to localhost, it's page allocator intensive through
paths like this

         netperf-3887  [032] ....   393.246420: mm_page_alloc: page=ffffea0021272200 pfn=8690824 order=3 migratetype=0 gfp_flags=GFP_KERNEL|__GFP_NOWARN|__GFP_REPEAT|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_NOTRACK
         netperf-3887  [032] ....   393.246421: <stack trace>
 => kmalloc_large_node+0x60/0x8d <ffffffff812101c3>
 => __kmalloc_node_track_caller+0x245/0x280 <ffffffff811f0415>
 => __kmalloc_reserve.isra.35+0x31/0x90 <ffffffff81674b61>
 => __alloc_skb+0x7e/0x280 <ffffffff81676bce>
 => alloc_skb_with_frags+0x5a/0x1c0 <ffffffff81676e2a>
 => sock_alloc_send_pskb+0x19e/0x200 <ffffffff816721fe>
 => sock_alloc_send_skb+0x18/0x20 <ffffffff81672278>
 => __ip_append_data.isra.46+0x61d/0xa00 <ffffffff816cf78d>
 => ip_make_skb+0xc2/0x110 <ffffffff816d1c72>
 => udp_sendmsg+0x2c0/0xa40 <ffffffff816f9930>
 => inet_sendmsg+0x7f/0xb0 <ffffffff8170655f>
 => sock_sendmsg+0x38/0x50 <ffffffff8166d9f8>
 => SYSC_sendto+0x102/0x190 <ffffffff8166de92>
 => SyS_sendto+0xe/0x10 <ffffffff8166e94e>
 => do_syscall_64+0x5b/0xd0 <ffffffff8100293b>
 => return_from_SYSCALL_64+0x0/0x6a <ffffffff8178e7af>

It's going through the SLUB paths but finding the allocation is too large
and hitting the page allocator instead. This is using 4.9-rc5 as a baseline
so fixes might be missing.

If using small messages to a remote host, I again see intense page
allocator activity via

         netperf-4326  [047] ....   994.978387: mm_page_alloc: page=ffffea0041413400 pfn=17106128 order=2 migratetype=0 gfp_flags=__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_REPEAT|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_NOTRACK
         netperf-4326  [047] ....   994.978387: <stack trace>
 => alloc_pages_current+0x88/0x120 <ffffffff811e1678>
 => new_slab+0x33f/0x580 <ffffffff811eb77f>
 => ___slab_alloc+0x352/0x4d0 <ffffffff811ec6a2>
 => __slab_alloc.isra.73+0x43/0x5e <ffffffff812105d0>
 => __kmalloc_node_track_caller+0xba/0x280 <ffffffff811f028a>
 => __kmalloc_reserve.isra.35+0x31/0x90 <ffffffff81674b61>
 => __alloc_skb+0x7e/0x280 <ffffffff81676bce>
 => alloc_skb_with_frags+0x5a/0x1c0 <ffffffff81676e2a>
 => sock_alloc_send_pskb+0x19e/0x200 <ffffffff816721fe>
 => sock_alloc_send_skb+0x18/0x20 <ffffffff81672278>
 => __ip_append_data.isra.46+0x61d/0xa00 <ffffffff816cf78d>
 => ip_make_skb+0xc2/0x110 <ffffffff816d1c72>
 => udp_sendmsg+0x2c0/0xa40 <ffffffff816f9930>
 => inet_sendmsg+0x7f/0xb0 <ffffffff8170655f>
 => sock_sendmsg+0x38/0x50 <ffffffff8166d9f8>
 => SYSC_sendto+0x102/0x190 <ffffffff8166de92>
 => SyS_sendto+0xe/0x10 <ffffffff8166e94e>
 => do_syscall_64+0x5b/0xd0 <ffffffff8100293b>
 => return_from_SYSCALL_64+0x0/0x6a <ffffffff8178e7af>

This is a slab path, but at different orders.

So while the patch was motivated by SLUB, the fact I'm getting intense
page allocator activity still benefits.

> Maybe one day we will avoid doing order-4 (or even order-5 in extreme
> cases !) allocations for loopback as we did for af_unix :P
> 
> I mean, maybe some applications are sending 64KB UDP messages over
> loopback right now...
> 

Maybe but it's clear that even running "networking" workloads does not
necessarily mean that paths interesting to this patch are hit. Not
necessarily bad but it was always expected that the benefit of the patch
would be workload and configuration dependant.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
