Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 394358E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:57:52 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e12so8641151edd.16
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 04:57:52 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f27-v6si223956ejh.100.2018.12.17.04.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 04:57:50 -0800 (PST)
Date: Mon, 17 Dec 2018 13:57:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181217125748.GK30879@dhcp22.suse.cz>
References: <CAFgQCTsFBUcOE9UKQ2vz=hg2FWp_QurZMQmJZ2wYLBqXkFHKHQ@mail.gmail.com>
 <20181207113044.GB1286@dhcp22.suse.cz>
 <CAFgQCTuf95pJSWDc1BNQ=gN76aJ_dtxMRbAV9a28X6w8vapdMQ@mail.gmail.com>
 <20181207142240.GC1286@dhcp22.suse.cz>
 <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
 <20181207155627.GG1286@dhcp22.suse.cz>
 <20181210123738.GN1286@dhcp22.suse.cz>
 <CAFgQCTupPc1rKv2SrmWD+eJ0H6PRaizPBw3+AG67_PuLA2SKFw@mail.gmail.com>
 <20181212115340.GQ1286@dhcp22.suse.cz>
 <CAFgQCTuhW6sPtCNFmnz13p30v3owE3Rty5WJNgtqgz8XaZT-aQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTuhW6sPtCNFmnz13p30v3owE3Rty5WJNgtqgz8XaZT-aQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Thu 13-12-18 16:37:35, Pingfan Liu wrote:
[...]
> [    0.409667] NUMA: Node 1 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0x7fffffff] -> [mem 0x00000000-0x7fffffff]
> [    0.419885] NUMA: Node 1 [mem 0x00000000-0x7fffffff] + [mem 0x100000000-0x47fffffff] -> [mem 0x00000000-0x47fffffff]
> [    0.430386] NODE_DATA(0) allocated [mem 0x87efd4000-0x87effefff]
> [    0.436352]     NODE_DATA(0) on node 5
> [    0.440124] Initmem setup node 0 [mem 0x0000000000000000-0x0000000000000000]
> [    0.447104] NODE_DATA(1) allocated [mem 0x47ffd5000-0x47fffffff]
> [    0.453110] NODE_DATA(2) allocated [mem 0x87efa9000-0x87efd3fff]
> [    0.459060]     NODE_DATA(2) on node 5
> [    0.462855] Initmem setup node 2 [mem 0x0000000000000000-0x0000000000000000]
> [    0.469809] NODE_DATA(3) allocated [mem 0x87ef7e000-0x87efa8fff]
> [    0.475788]     NODE_DATA(3) on node 5
> [    0.479554] Initmem setup node 3 [mem 0x0000000000000000-0x0000000000000000]
> [    0.486536] NODE_DATA(4) allocated [mem 0x87ef53000-0x87ef7dfff]
> [    0.492518]     NODE_DATA(4) on node 5
> [    0.496280] Initmem setup node 4 [mem 0x0000000000000000-0x0000000000000000]
> [    0.503266] NODE_DATA(5) allocated [mem 0x87ef28000-0x87ef52fff]
> [    0.509281] NODE_DATA(6) allocated [mem 0x87eefd000-0x87ef27fff]
> [    0.515224]     NODE_DATA(6) on node 5
> [    0.518987] Initmem setup node 6 [mem 0x0000000000000000-0x0000000000000000]
> [    0.525974] NODE_DATA(7) allocated [mem 0x87eed2000-0x87eefcfff]
> [    0.531953]     NODE_DATA(7) on node 5
> [    0.535716] Initmem setup node 7 [mem 0x0000000000000000-0x0000000000000000]

OK, so we have allocated node_data for all NUMA nodes. Good!

> [    0.542839] Reserving 500MB of memory at 384MB for crashkernel (System RAM: 32314MB)
> [    0.550465] Zone ranges:
> [    0.552927]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [    0.559081]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
> [    0.565235]   Normal   [mem 0x0000000100000000-0x000000087effffff]
> [    0.571388]   Device   empty
> [    0.574249] Movable zone start for each node
> [    0.578498] Early memory node ranges
> [    0.582049]   node   1: [mem 0x0000000000001000-0x000000000008efff]
> [    0.588291]   node   1: [mem 0x0000000000090000-0x000000000009ffff]
> [    0.594530]   node   1: [mem 0x0000000000100000-0x000000005c3d6fff]
> [    0.600772]   node   1: [mem 0x00000000643df000-0x0000000068ff7fff]
> [    0.607011]   node   1: [mem 0x000000006c528000-0x000000006fffffff]
> [    0.613251]   node   1: [mem 0x0000000100000000-0x000000047fffffff]
> [    0.619493]   node   5: [mem 0x0000000480000000-0x000000087effffff]
> [    0.626479] Zeroed struct page in unavailable ranges: 46490 pages
> [    0.626480] Initmem setup node 1 [mem 0x0000000000001000-0x000000047fffffff]
> [    0.655261] Initmem setup node 5 [mem 0x0000000480000000-0x000000087effffff]
[...]
> [    1.066324] Built 2 zonelists, mobility grouping off.  Total pages: 0

There are 2 zonelists built, but for some reason vm_total_pages is 0 and
that is clearly wrong.

Because the allocation failure (which later leads to NULL ptr) tells
there is quite a lot of memory.  One reason might be that the zonelist
for memory less nodes is initialized incorrectly. nr_free_zone_pages
relies on the local Node zonelist so if the code happened to run on a
cpu associated with Node2 then we could indeed got vm_total_pages=0.

> [    1.439440] Node 1 DMA: 2*4kB (U) 2*8kB (U) 2*16kB (U) 3*32kB (U) 2*64kB (U) 2*128kB (U) 2*256kB (U) 1*512kB (U) 0*1024kB 1*2048kB (M) 3*4096kB (M) = 15896kB
> [    1.453482] Node 1 DMA32: 2*4kB (M) 1*8kB (M) 1*16kB (M) 2*32kB (M) 3*64kB (M) 2*128kB (M) 3*256kB (M) 3*512kB (M) 2*1024kB (M) 3*2048kB (M) 255*4096kB (M) = 1055520kB
> [    1.468388] Node 1 Normal: 1*4kB (U) 1*8kB (U) 1*16kB (U) 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 1*512kB (U) 1*1024kB (U) 1*2048kB (U) 31*4096kB (M) = 131068kB
> [    1.483211] Node 5 Normal: 1*4kB (U) 1*8kB (U) 1*16kB (U) 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 1*512kB (U) 1*1024kB (U) 1*2048kB (U) 31*4096kB (M) = 131068kB

I am investigating what the hell is going on here. Maybe the former hack
to re-initialize memory-less nodes is working around some ordering
issues.
-- 
Michal Hocko
SUSE Labs
