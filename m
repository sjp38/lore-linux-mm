Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFAA6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 18:31:23 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so11767677pdb.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 15:31:22 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id x4si346503pdc.112.2015.08.12.15.31.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 15:31:22 -0700 (PDT)
Received: by pacrr5 with SMTP id rr5so23275280pac.3
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 15:31:22 -0700 (PDT)
Date: Wed, 12 Aug 2015 15:31:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/slub: don't wait for high-order page allocation
In-Reply-To: <1438913403-3682-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1508121529400.11921@chino.kir.corp.google.com>
References: <1438913403-3682-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Shaohua Li <shli@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Eric Dumazet <edumazet@google.com>

On Fri, 7 Aug 2015, Joonsoo Kim wrote:

> Almost description is copied from commit fb05e7a89f50
> ("net: don't wait for order-3 page allocation").
> 
> I saw excessive direct memory reclaim/compaction triggered by slub.
> This causes performance issues and add latency. Slub uses high-order
> allocation to reduce internal fragmentation and management overhead. But,
> direct memory reclaim/compaction has high overhead and the benefit of
> high-order allocation can't compensate the overhead of both work.
> 
> This patch makes auxiliary high-order allocation atomic. If there is
> no memory pressure and memory isn't fragmented, the alloction will still
> success, so we don't sacrifice high-order allocation's benefit here.
> If the atomic allocation fails, direct memory reclaim/compaction will not
> be triggered, allocation fallback to low-order immediately, hence
> the direct memory reclaim/compaction overhead is avoided. In the
> allocation failure case, kswapd is waken up and trying to make high-order
> freepages, so allocation could success next time.
> 
> Following is the test to measure effect of this patch.
> 
> System: QEMU, CPU 8, 512 MB
> Mem: 25% memory is allocated at random position to make fragmentation.
>  Memory-hogger occupies 150 MB memory.
> Workload: hackbench -g 20 -l 1000
> 
> Average result by 10 runs (Base va Patched)
> 
> elapsed_time(s): 4.3468 vs 2.9838
> compact_stall: 461.7 vs 73.6
> pgmigrate_success: 28315.9 vs 7256.1
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
