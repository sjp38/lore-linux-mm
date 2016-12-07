Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6952B6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 15:11:27 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a8so610188819pfg.0
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 12:11:27 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id a5si25262281pgh.296.2016.12.07.12.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 12:11:26 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id x23so24425618pgx.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 12:11:26 -0800 (PST)
Message-ID: <1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Dec 2016 12:10:24 -0800
In-Reply-To: <20161207194801.krhonj7yggbedpba@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
	 <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20161207194801.krhonj7yggbedpba@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, 2016-12-07 at 19:48 +0000, Mel Gorman wrote:
>  
> 
> Interesting because it didn't match what I previous measured but then
> again, when I established that netperf on localhost was slab intensive,
> it was also an older kernel. Can you tell me if SLAB or SLUB was enabled
> in your test kernel?
> 
> Either that or the baseline I used has since been changed from what you
> are testing and we're not hitting the same paths.


lpaa6:~# uname -a
Linux lpaa6 4.9.0-smp-DEV #429 SMP @1481125332 x86_64 GNU/Linux

lpaa6:~# perf record -g ./netperf -t UDP_STREAM -l 3 -- -m 16384
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
localhost () port 0 AF_INET
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   16384   3.00       654644      0    28601.04
212992           3.00       654592           28598.77

[ perf record: Woken up 5 times to write data ]
[ perf record: Captured and wrote 1.888 MB perf.data (~82481 samples) ]


perf report --stdio
...
     1.92%  netperf  [kernel.kallsyms]  [k]
cache_alloc_refill                 
            |
            --- cache_alloc_refill
               |          
               |--82.22%-- kmem_cache_alloc_node_trace
               |          __kmalloc_node_track_caller
               |          __alloc_skb
               |          alloc_skb_with_frags
               |          sock_alloc_send_pskb
               |          sock_alloc_send_skb
               |          __ip_append_data.isra.50
               |          ip_make_skb
               |          udp_sendmsg
               |          inet_sendmsg
               |          sock_sendmsg
               |          SYSC_sendto
               |          sys_sendto
               |          entry_SYSCALL_64_fastpath
               |          __sendto_nocancel
               |          |          
               |           --100.00%-- 0x0
               |          
           

Oh wait, sock_alloc_send_skb() requests for all the bytes in skb->head :

struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
                                    int noblock, int *errcode)
{
        return sock_alloc_send_pskb(sk, size, 0, noblock, errcode, 0);
}


Maybe one day we will avoid doing order-4 (or even order-5 in extreme
cases !) allocations for loopback as we did for af_unix :P

I mean, maybe some applications are sending 64KB UDP messages over
loopback right now...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
