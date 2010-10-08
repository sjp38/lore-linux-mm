Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1506B009C
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 11:30:20 -0400 (EDT)
Date: Fri, 8 Oct 2010 16:29:53 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20101008152953.GB3315@csn.ul.ie>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100928050801.GA29021@sli10-conroe.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm@kvack.org, cl@linux.com
List-ID: <linux-mm.kvack.org>

On Tue, Sep 28, 2010 at 01:08:01PM +0800, Shaohua Li wrote:
> In a 4 socket 64 CPU system, zone_nr_free_pages() takes about 5% ~ 10% cpu time
> according to perf when memory pressure is high. The workload does something
> like:
> for i in `seq 1 $nr_cpu`
> do
>         create_sparse_file $SPARSE_FILE-$i $((10 * mem / nr_cpu))
>         $USEMEM -f $SPARSE_FILE-$i -j 4096 --readonly $((10 * mem / nr_cpu)) &
> done
> this simply reads a sparse file for each CPU. Apparently the
> zone->percpu_drift_mark is too big, and guess zone_page_state_snapshot() makes
> a lot of cache bounce for ->vm_stat_diff[]. below is the zoneinfo for reference.

Would it be possible for you to post the oprofile report? I'm in the
early stages of trying to reproduce this locally based on your test
description. The first machine I tried showed that zone_nr_page_state
was consuming 0.26% of profile time with the vast bulk occupied by
do_mpage_readahead. See as follows

1599339  53.3463  vmlinux-2.6.36-rc7-pcpudrift do_mpage_readpage
131713    4.3933  vmlinux-2.6.36-rc7-pcpudrift __isolate_lru_page
103958    3.4675  vmlinux-2.6.36-rc7-pcpudrift free_pcppages_bulk
85024     2.8360  vmlinux-2.6.36-rc7-pcpudrift __rmqueue
78697     2.6250  vmlinux-2.6.36-rc7-pcpudrift native_flush_tlb_others
75678     2.5243  vmlinux-2.6.36-rc7-pcpudrift unlock_page
68741     2.2929  vmlinux-2.6.36-rc7-pcpudrift get_page_from_freelist
56043     1.8693  vmlinux-2.6.36-rc7-pcpudrift __alloc_pages_nodemask
55863     1.8633  vmlinux-2.6.36-rc7-pcpudrift ____pagevec_lru_add
46044     1.5358  vmlinux-2.6.36-rc7-pcpudrift radix_tree_delete
44543     1.4857  vmlinux-2.6.36-rc7-pcpudrift shrink_page_list
33636     1.1219  vmlinux-2.6.36-rc7-pcpudrift zone_watermark_ok
.....
7855      0.2620  vmlinux-2.6.36-rc7-pcpudrift zone_nr_free_pages

The machine I am testing on is non-NUMA 4-core single socket and totally
different characteristics but I want to be sure I'm going more or less the
right direction with the reproduction case before trying to find a larger
machine.

Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
