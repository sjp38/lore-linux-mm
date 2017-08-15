Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0382A6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 06:36:47 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 6so2306518qts.7
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 03:36:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u2si7191788qkg.22.2017.08.15.03.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 03:36:45 -0700 (PDT)
Date: Tue, 15 Aug 2017 12:36:36 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Separate NUMA statistics from zone statistics
Message-ID: <20170815123636.3788230c@redhat.com>
In-Reply-To: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, brouer@redhat.com

On Tue, 15 Aug 2017 16:45:34 +0800
Kemi Wang <kemi.wang@intel.com> wrote:

> Each page allocation updates a set of per-zone statistics with a call to
> zone_statistics(). As discussed in 2017 MM submit, these are a substantial
                                             ^^^^^^ should be "summit"
> source of overhead in the page allocator and are very rarely consumed. This
> significant overhead in cache bouncing caused by zone counters (NUMA
> associated counters) update in parallel in multi-threaded page allocation
> (pointed out by Dave Hansen).

Hi Kemi

Thanks a lot for following up on this work. A link to the MM summit slides:
 http://people.netfilter.org/hawk/presentations/MM-summit2017/MM-summit2017-JesperBrouer.pdf

> To mitigate this overhead, this patchset separates NUMA statistics from
> zone statistics framework, and update NUMA counter threshold to a fixed
> size of 32765, as a small threshold greatly increases the update frequency
> of the global counter from local per cpu counter (suggested by Ying Huang).
> The rationality is that these statistics counters don't need to be read
> often, unlike other VM counters, so it's not a problem to use a large
> threshold and make readers more expensive.
> 
> With this patchset, we see 26.6% drop of CPU cycles(537-->394, see below)
> for per single page allocation and reclaim on Jesper's page_bench03
> benchmark. Meanwhile, this patchset keeps the same style of virtual memory
> statistics with little end-user-visible effects (see the first patch for
> details), except that the number of NUMA items in each cpu
> (vm_numa_stat_diff[]) is added to zone->vm_numa_stat[] when a user *reads*
> the value of NUMA counter to eliminate deviation.

I'm very happy to see that you found my kernel module for benchmarking useful :-)

> I did an experiment of single page allocation and reclaim concurrently
> using Jesper's page_bench03 benchmark on a 2-Socket Broadwell-based server
> (88 processors with 126G memory) with different size of threshold of pcp
> counter.
> 
> Benchmark provided by Jesper D Broucer(increase loop times to 10000000):
                                 ^^^^^^^
You mis-spelled my last name, it is "Brouer".

> https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/bench
> 
>    Threshold   CPU cycles    Throughput(88 threads)
>       32        799         241760478
>       64        640         301628829
>       125       537         358906028 <==> system by default
>       256       468         412397590
>       512       428         450550704
>       4096      399         482520943
>       20000     394         489009617
>       30000     395         488017817
>       32765     394(-26.6%) 488932078(+36.2%) <==> with this patchset
>       N/A       342(-36.3%) 562900157(+56.8%) <==> disable zone_statistics
> 
> Kemi Wang (2):
>   mm: Change the call sites of numa statistics items
>   mm: Update NUMA counter threshold size
> 
>  drivers/base/node.c    |  22 ++++---
>  include/linux/mmzone.h |  25 +++++---
>  include/linux/vmstat.h |  33 ++++++++++
>  mm/page_alloc.c        |  10 +--
>  mm/vmstat.c            | 162 +++++++++++++++++++++++++++++++++++++++++++++++--
>  5 files changed, 227 insertions(+), 25 deletions(-)
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
