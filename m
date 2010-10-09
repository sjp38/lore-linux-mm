Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5A06E6B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 20:58:10 -0400 (EDT)
Date: Sat, 9 Oct 2010 08:58:07 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: zone state overhead
Message-ID: <20101009005807.GA28793@sli10-conroe.sh.intel.com>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com>
 <20101008152953.GB3315@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101008152953.GB3315@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 08, 2010 at 11:29:53PM +0800, Mel Gorman wrote:
> On Tue, Sep 28, 2010 at 01:08:01PM +0800, Shaohua Li wrote:
> > In a 4 socket 64 CPU system, zone_nr_free_pages() takes about 5% ~ 10% cpu time
> > according to perf when memory pressure is high. The workload does something
> > like:
> > for i in `seq 1 $nr_cpu`
> > do
> >         create_sparse_file $SPARSE_FILE-$i $((10 * mem / nr_cpu))
> >         $USEMEM -f $SPARSE_FILE-$i -j 4096 --readonly $((10 * mem / nr_cpu)) &
> > done
> > this simply reads a sparse file for each CPU. Apparently the
> > zone->percpu_drift_mark is too big, and guess zone_page_state_snapshot() makes
> > a lot of cache bounce for ->vm_stat_diff[]. below is the zoneinfo for reference.
> 
> Would it be possible for you to post the oprofile report? I'm in the
> early stages of trying to reproduce this locally based on your test
> description. The first machine I tried showed that zone_nr_page_state
> was consuming 0.26% of profile time with the vast bulk occupied by
> do_mpage_readahead. See as follows
> 
> 1599339  53.3463  vmlinux-2.6.36-rc7-pcpudrift do_mpage_readpage
> 131713    4.3933  vmlinux-2.6.36-rc7-pcpudrift __isolate_lru_page
> 103958    3.4675  vmlinux-2.6.36-rc7-pcpudrift free_pcppages_bulk
> 85024     2.8360  vmlinux-2.6.36-rc7-pcpudrift __rmqueue
> 78697     2.6250  vmlinux-2.6.36-rc7-pcpudrift native_flush_tlb_others
> 75678     2.5243  vmlinux-2.6.36-rc7-pcpudrift unlock_page
> 68741     2.2929  vmlinux-2.6.36-rc7-pcpudrift get_page_from_freelist
> 56043     1.8693  vmlinux-2.6.36-rc7-pcpudrift __alloc_pages_nodemask
> 55863     1.8633  vmlinux-2.6.36-rc7-pcpudrift ____pagevec_lru_add
> 46044     1.5358  vmlinux-2.6.36-rc7-pcpudrift radix_tree_delete
> 44543     1.4857  vmlinux-2.6.36-rc7-pcpudrift shrink_page_list
> 33636     1.1219  vmlinux-2.6.36-rc7-pcpudrift zone_watermark_ok
> .....
> 7855      0.2620  vmlinux-2.6.36-rc7-pcpudrift zone_nr_free_pages
> 
> The machine I am testing on is non-NUMA 4-core single socket and totally
> different characteristics but I want to be sure I'm going more or less the
> right direction with the reproduction case before trying to find a larger
> machine.
Here it is. this is a 4 socket nahalem machine.
           268160.00 57.2% _raw_spin_lock                      /lib/modules/2.6.36-rc5-shli+/build/vmlinux
            40302.00  8.6% zone_nr_free_pages                  /lib/modules/2.6.36-rc5-shli+/build/vmlinux
            36827.00  7.9% do_mpage_readpage                   /lib/modules/2.6.36-rc5-shli+/build/vmlinux
            28011.00  6.0% _raw_spin_lock_irq                  /lib/modules/2.6.36-rc5-shli+/build/vmlinux
            22973.00  4.9% flush_tlb_others_ipi                /lib/modules/2.6.36-rc5-shli+/build/vmlinux
            10713.00  2.3% smp_invalidate_interrupt            /lib/modules/2.6.36-rc5-shli+/build/vmlinux
             7342.00  1.6% find_next_bit                       /lib/modules/2.6.36-rc5-shli+/build/vmlinux
             4571.00  1.0% try_to_unmap_one                    /lib/modules/2.6.36-rc5-shli+/build/vmlinux
             4094.00  0.9% default_send_IPI_mask_sequence_phys /lib/modules/2.6.36-rc5-shli+/build/vmlinux
             3497.00  0.7% get_page_from_freelist              /lib/modules/2.6.36-rc5-shli+/build/vmlinux
             3032.00  0.6% _raw_spin_lock_irqsave              /lib/modules/2.6.36-rc5-shli+/build/vmlinux
             3029.00  0.6% shrink_page_list                    /lib/modules/2.6.36-rc5-shli+/build/vmlinux
             2318.00  0.5% __inc_zone_state                    /lib/modules/2.6.36-rc5-shli+/build/vmlinux
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
