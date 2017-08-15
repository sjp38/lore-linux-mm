Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57ED16B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 13:30:53 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k71so2063554wrc.15
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 10:30:53 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id e24si1558030wmi.197.2017.08.15.10.30.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 10:30:51 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 3C57D991E3
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 17:30:51 +0000 (UTC)
Date: Tue, 15 Aug 2017 18:30:50 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: Update NUMA counter threshold size
Message-ID: <20170815173050.xn5ffrsvdj4myoam@techsingularity.net>
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
 <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
 <a258ea24-6830-4907-0165-fec17ccb7f9f@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a258ea24-6830-4907-0165-fec17ccb7f9f@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Kemi Wang <kemi.wang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, Aug 15, 2017 at 09:55:39AM -0700, Tim Chen wrote:
> On 08/15/2017 02:58 AM, Mel Gorman wrote:
> > On Tue, Aug 15, 2017 at 04:45:36PM +0800, Kemi Wang wrote:
> >>  Threshold   CPU cycles    Throughput(88 threads)
> >>      32          799         241760478
> >>      64          640         301628829
> >>      125         537         358906028 <==> system by default (base)
> >>      256         468         412397590
> >>      512         428         450550704
> >>      4096        399         482520943
> >>      20000       394         489009617
> >>      30000       395         488017817
> >>      32765       394(-26.6%) 488932078(+36.2%) <==> with this patchset
> >>      N/A         342(-36.3%) 562900157(+56.8%) <==> disable zone_statistics
> >>
> >> Signed-off-by: Kemi Wang <kemi.wang@intel.com>
> >> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> >> Suggested-by: Ying Huang <ying.huang@intel.com>
> >> ---
> >>  include/linux/mmzone.h |  4 ++--
> >>  include/linux/vmstat.h |  6 +++++-
> >>  mm/vmstat.c            | 23 ++++++++++-------------
> >>  3 files changed, 17 insertions(+), 16 deletions(-)
> >>
> >> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >> index 0b11ba7..7eaf0e8 100644
> >> --- a/include/linux/mmzone.h
> >> +++ b/include/linux/mmzone.h
> >> @@ -282,8 +282,8 @@ struct per_cpu_pageset {
> >>  	struct per_cpu_pages pcp;
> >>  #ifdef CONFIG_NUMA
> >>  	s8 expire;
> >> -	s8 numa_stat_threshold;
> >> -	s8 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
> >> +	s16 numa_stat_threshold;
> >> +	s16 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
> > 
> > I'm fairly sure this pushes the size of that structure into the next
> > cache line which is not welcome.
> > 
> > vm_numa_stat_diff is an always incrementing field. How much do you gain
> > if this becomes a u8 code and remove any code that deals with negative
> > values? That would double the threshold without consuming another cache line.
> 
> Doubling the threshold and counter size will help, but not as much
> as making them above u8 limit as seen in Kemi's data:
> 
>       125         537         358906028 <==> system by default (base)
>       256         468         412397590
>       32765       394(-26.6%) 488932078(+36.2%) <==> with this patchset
> 
> For small system making them u8 makes sense.  For larger ones the
> frequent local counter overflow into the global counter still
> causes a lot of cache bounce.  Kemi can perhaps collect some data
> to see what is the gain from making the counters u8. 
> 

The same comments hold. The increase of a cache line is undesirable but
there are other places where the overall cost can be reduced by special
casing based on how this counter is used (always incrementing by one).
It would be preferred if those were addressed to see how close that gets
to the same performance of doubling the necessary storage for a counter.
doubling the storage 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
