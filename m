Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 441D36B0010
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 11:02:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v26-v6so5033691eds.9
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 08:02:53 -0700 (PDT)
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60045.outbound.protection.outlook.com. [40.107.6.45])
        by mx.google.com with ESMTPS id h17-v6si3049216edr.245.2018.07.12.08.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 12 Jul 2018 08:02:51 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, page_alloc: double zone's batchsize
References: <20180711055855.29072-1-aaron.lu@intel.com>
 <20180712125408.GL32648@dhcp22.suse.cz> <20180712155536.20023cc4@redhat.com>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <2b51fa24-5fc7-f328-1bf3-a78f28eb742f@mellanox.com>
Date: Thu, 12 Jul 2018 18:01:12 +0300
MIME-Version: 1.0
In-Reply-To: <20180712155536.20023cc4@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, Michal Hocko <mhocko@kernel.org>, Tariq Toukan <tariqt@mellanox.com>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Saeed Mahameed <saeedm@mellanox.com>



On 12/07/2018 4:55 PM, Jesper Dangaard Brouer wrote:
> On Thu, 12 Jul 2018 14:54:08 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
>> [CC Jesper - I remember he was really concerned about the worst case
>>   latencies for highspeed network workloads.]
> 
> Cc. Tariq as he have hit some networking benchmarks (around 100Gbit/s),
> where we are contenting on the page allocator lock, in a CPU scaling
> netperf test AFAIK.  I also have some special-case micro-benchmarks
> where I can hit it, but it a micro-bench...
> 

Thanks! Looks good.

Indeed, I simulated the page allocation rate of a 200Gbps NIC, and hit a 
major PCP/buddy bottleneck, where spinning the zonelock took up to 80% 
CPU, with dramatic BW degradation.

Test ran relatively small number of TCP streams (4-16) with unpinned 
application (iperf).

Larger batching reduces the contention on the zone lock and improves the 
CPU util. I also considered increasing the percpu_pagelist_fraction to a 
larger value (thought of 512, see patch below), which also affects the 
batch size (in pageset_set_high_and_batch).

As far as I see it, to totally solve the page allocation bottleneck for 
the increasing networking speeds, the following is still required:
1) optimize order-0 allocations (even on the cost of higher-order 
allocations).
2) bulking API for page allocations.
3) do SKB remote-release (on the originating core).

Regards,
Tariq

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 697ef8c225df..88763bd716a5 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -741,9 +741,9 @@ of hot per cpu pagelists.  User can specify a number 
like 100 to allocate
  The batch value of each per cpu pagelist is also updated as a result. 
It is
  set to pcp->high/4.  The upper limit of batch is (PAGE_SHIFT * 8)

-The initial value is zero.  Kernel does not use this value at boot time 
to set
+The initial value is 512.  Kernel uses this value at boot time to set
  the high water marks for each per cpu page list.  If the user writes 
'0' to this
-sysctl, it will revert to this default behavior.
+sysctl, it will revert to a behavior based on batchsize calculation.

  ==============================================================

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100f1e63..c88e8eb50bcb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -129,7 +129,7 @@
  unsigned long totalreserve_pages __read_mostly;
  unsigned long totalcma_pages __read_mostly;

-int percpu_pagelist_fraction;
+int percpu_pagelist_fraction = 512;
  gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;

  /*
