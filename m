Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 930446B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 06:52:08 -0400 (EDT)
Received: by wiun10 with SMTP id n10so92197455wiu.1
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 03:52:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ck4si15167080wib.31.2015.04.16.03.52.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 03:52:07 -0700 (PDT)
Date: Thu, 16 Apr 2015 11:51:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: migrate: Batch TLB flushing when unmapping pages
 for migration
Message-ID: <20150416105157.GO14842@suse.de>
References: <1429179766-26711-1-git-send-email-mgorman@suse.de>
 <1429179766-26711-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1429179766-26711-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 16, 2015 at 11:22:46AM +0100, Mel Gorman wrote:
> Page reclaim batches multiple TLB flushes into one IPI and this patch teaches
> page migration to also batch any necessary flushes. MMtests has a THP scale
> microbenchmark that deliberately fragments memory and then allocates THPs
> to stress compaction. It's not a page reclaim benchmark and recent kernels
> avoid excessive compaction but this patch reduced system CPU usage
> 
>                4.0.0       4.0.0
>             baseline batchmigrate-v1
> User          970.70     1012.24
> System       2067.48     1840.00
> Elapsed      1520.63     1529.66
> 
> Note that this particular workload was not TLB flush intensive with peaks
> in interrupts during the compaction phase. The 4.0 kernel peaked at 345K
> interrupts/second, the kernel that batches reclaim TLB entries peaked at
> 13K interrupts/second and this patch peaked at 10K interrupts/second.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

The following is needed on !x86 although it's pointless to test on !x86
at the moment.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 361bf59e0594..548c94834112 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2784,10 +2784,6 @@ void alloc_tlb_ubc(void)
 	cpumask_clear(&current->tlb_ubc->cpumask);
 	current->tlb_ubc->nr_pages = 0;
 }
-#else
-static inline void alloc_tlb_ubc(void)
-{
-}
 #endif /* CONFIG_ARCH_SUPPORTS_LOCAL_TLB_PFN_FLUSH */
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
