Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id A2E016B009F
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 07:35:37 -0500 (EST)
Message-ID: <50B8A8E7.4030108@leemhuis.info>
Date: Fri, 30 Nov 2012 13:39:03 +0100
From: Thorsten Leemhuis <fedora@leemhuis.info>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com> <50B52DC4.5000109@redhat.com> <20121127214928.GA20253@cmpxchg.org> <50B5387C.1030005@redhat.com> <20121127222637.GG2301@cmpxchg.org> <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com> <20121128101359.GT8218@suse.de> <20121128145215.d23aeb1b.akpm@linux-foundation.org> <20121128235412.GW8218@suse.de> <50B77F84.1030907@leemhuis.info> <20121129170512.GI2301@cmpxchg.org>
In-Reply-To: <20121129170512.GI2301@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Johannes Weiner wrote on 29.11.2012 18:05:
> On Thu, Nov 29, 2012 at 04:30:12PM +0100, Thorsten Leemhuis wrote:
>> Mel Gorman wrote on 29.11.2012 00:54:
>> > On Wed, Nov 28, 2012 at 02:52:15PM -0800, Andrew Morton wrote:
>> >> On Wed, 28 Nov 2012 10:13:59 +0000
>> >> Mel Gorman <mgorman@suse.de> wrote:
>> >> > Based on the reports I've seen I expect the following to work for 3.7
>> >> > Keep
>> >> >   96710098 mm: revert "mm: vmscan: scale number of pages reclaimed by reclaim/compaction based on failures"
>> >> >   ef6c5be6 fix incorrect NR_FREE_PAGES accounting (appears like memory leak)
>> >> > Revert
>> >> >   82b212f4 Revert "mm: remove __GFP_NO_KSWAPD"
>> >> > Merge
>> >> >   mm: vmscan: fix kswapd endless loop on higher order allocation
>> >> >   mm: Avoid waking kswapd for THP allocations when compaction is deferred or contended
>> >> "mm: Avoid waking kswapd for THP ..." is marked "I have not tested it
>> >> myself" and when Zdenek tested it he hit an unexplained oom.
>> > I thought Zdenek was testing with __GFP_NO_KSWAPD when he hit that OOM.
>> > Further, when he hit that OOM, it looked like a genuine OOM. He had no
>> > swap configured and inactive/active file pages were very low. Finally,
>> > the free pages for Normal looked off and could also have been affected by
>> > the accounting bug. I'm looking at https://lkml.org/lkml/2012/11/18/132
>> > here. Are you thinking of something else?
>> > I have not tested with the patch admittedly but Thorsten has and seemed
>> > to be ok with it https://lkml.org/lkml/2012/11/23/276.
>> Yeah, on my two main work horses a few different kernels based on rc6 or
>> rc7 worked fine with this patch. But sorry, it seems the patch doesn't
>> fix the problems Fedora user John Ellson sees, who tried kernels I built
>> in the Fedora buildsystem. Details:
> [...]
>> I know, this makes things more complicated again; but I wanted to let
>> you guys know that some problem might still be lurking somewhere. Side
>> note: right now it seems John with kernels that contain
>> "Avoid-waking-kswapd-for-THP-allocations-when" can trigger the problem
>> quicker (or only?) on i686 than on x86-64.
>
> Humm, highmem...  Could this be the lowmem protection forcing kswapd
> to reclaim highmem at DEF_PRIORITY (not useful but burns CPU) every
> time it's woken up?
> 
> This requires somebody to wake up kswapd regularly, though and from
> his report it's not quite clear to me if kswapd gets stuck or just has
> really high CPU usage while the system is still under load.  The
> initial post says he would expect "<5% cpu when idling" but his top
> snippet in there shows there are other tasks running as well.  So does
> it happen while the system is busy or when it's otherwise idle?
> 
> [ On the other hand, not waking kswapd from THP allocations seems to
>   not show this problem on his i686 machine.  But it could also just
>   be a tiny window of conditions aligning perfectly that drops kswapd
>   in an endless loop, and the increased wakeups increase the
>   probability of hitting it.  So, yeah, this would be good to know. ]
> 
> As the system is still responsive when this happens, any chance he
> could capture /proc/zoneinfo and /proc/vmstat when kswapd goes
> haywire?
> 
> Or even run perf record -a -g sleep 5; perf report > kswapd.txt?
> 
> Preferrably with this patch applied, to rule out faulty lowmem
> protection:
> 
> buffer_heads_over_limit can put kswapd into reclaim, but it's ignored
> when figuring out whether the zone is balanced and so priority levels
> are not descended and no progress is ever made.

/me wonders how to elegantly get out of his man-in-the-middle position

John was able to reproduce the problem quickly with a kernel that 
contained the patch from your mail. For details see 

https://bugzilla.redhat.com/show_bug.cgi?id=866988#c42 and later

He provided the informations there. Parts of it:

/proc/vmstat while kswad0 at 100%cpu

nr_free_pages 196858
nr_inactive_anon 15804
nr_active_anon 65
nr_inactive_file 20792
nr_active_file 11307
nr_unevictable 0
nr_mlock 0
nr_anon_pages 14385
nr_mapped 2393
nr_file_pages 32563
nr_dirty 5
nr_writeback 0
nr_slab_reclaimable 3113
nr_slab_unreclaimable 4725
nr_page_table_pages 271
nr_kernel_stack 96
nr_unstable 0
nr_bounce 0
nr_vmscan_write 1487
nr_vmscan_immediate_reclaim 3
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 381
nr_dirtied 388323
nr_written 361128
nr_anon_transparent_hugepages 1
nr_free_cma 0
nr_dirty_threshold 38188
nr_dirty_background_threshold 19094
pgpgin 1057223
pgpgout 1552306
pswpin 8
pswpout 1487
pgalloc_dma 5548
pgalloc_normal 10651864
pgalloc_high 2191246
pgalloc_movable 0
pgfree 13055503
pgactivate 440358
pgdeactivate 259724
pgfault 31423675
pgmajfault 3760
pgrefill_dma 2174
pgrefill_normal 212914
pgrefill_high 51755
pgrefill_movable 0
pgsteal_kswapd_dma 1
pgsteal_kswapd_normal 202106
pgsteal_kswapd_high 36515
pgsteal_kswapd_movable 0
pgsteal_direct_dma 18
pgsteal_direct_normal 0
pgsteal_direct_high 3818
pgsteal_direct_movable 0
pgscan_kswapd_dma 1
pgscan_kswapd_normal 203044
pgscan_kswapd_high 40407
pgscan_kswapd_movable 0
pgscan_direct_dma 18
pgscan_direct_normal 0
pgscan_direct_high 4409
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 0
slabs_scanned 264192
kswapd_inodesteal 171676
kswapd_low_wmark_hit_quickly 0
kswapd_high_wmark_hit_quickly 26
kswapd_skip_congestion_wait 0
pageoutrun 117729182
allocstall 5
pgrotated 1628
compact_blocks_moved 313
compact_pages_moved 7192
compact_pagemigrate_failed 265
compact_stall 13
compact_fail 9
compact_success 4
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 2985
unevictable_pgs_scanned 0
unevictable_pgs_rescued 1877
unevictable_pgs_mlocked 3965
unevictable_pgs_munlocked 3965
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
thp_fault_alloc 636
thp_fault_fallback 10
thp_collapse_alloc 342
thp_collapse_alloc_failed 2
thp_split 6


/proc/zoneinfo with kswapd0 at 100% cpu

Node 0, zone      DMA
  pages free     1655
        min      196
        low      245
        high     294
        scanned  0
        spanned  4080
        present  3951
    nr_free_pages 1655
    nr_inactive_anon 0
    nr_active_anon 0
    nr_inactive_file 0
    nr_active_file 0
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 0
    nr_mapped    0
    nr_file_pages 0
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 3
    nr_slab_unreclaimable 1
    nr_page_table_pages 0
    nr_kernel_stack 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     0
    nr_dirtied   315
    nr_written   315
    nr_anon_transparent_hugepages 0
    nr_free_cma  0
        protection: (0, 861, 1000, 1000)
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 2
  all_unreclaimable: 1
  start_pfn:         16
  inactive_ratio:    1
Node 0, zone   Normal
  pages free     186234
        min      10953
        low      13691
        high     16429
        scanned  0
        spanned  222206
        present  220470
    nr_free_pages 186234
    nr_inactive_anon 3147
    nr_active_anon 2
    nr_inactive_file 14064
    nr_active_file 4672
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 3028
    nr_mapped    216
    nr_file_pages 18857
    nr_dirty     8
    nr_writeback 0
    nr_slab_reclaimable 3110
    nr_slab_unreclaimable 4729
    nr_page_table_pages 62
    nr_kernel_stack 96
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 311
    nr_vmscan_immediate_reclaim 2
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     114
    nr_dirtied   339809
    nr_written   315061
    nr_anon_transparent_hugepages 0
    nr_free_cma  0
        protection: (0, 0, 1111, 1111)
  pagesets
    cpu: 0
              count: 81
              high:  186
              batch: 31
  vm stats threshold: 8
  all_unreclaimable: 0
  start_pfn:         4096
  inactive_ratio:    1
Node 0, zone  HighMem
  pages free     8983
        min      34
        low      475
        high     917
        scanned  0
        spanned  35840
        present  35560
    nr_free_pages 8983
    nr_inactive_anon 12661
    nr_active_anon 64
    nr_inactive_file 6849
    nr_active_file 6500
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 11357
    nr_mapped    2177
    nr_file_pages 13692
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 0
    nr_slab_unreclaimable 0
    nr_page_table_pages 209
    nr_kernel_stack 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 1176
    nr_vmscan_immediate_reclaim 1
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     267
    nr_dirtied   48189
    nr_written   45739
    nr_anon_transparent_hugepages 1
    nr_free_cma  0
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 20
              high:  42
              batch: 7
  vm stats threshold: 4
  all_unreclaimable: 0
  start_pfn:         226302
  inactive_ratio:    1


First few lines of /proc/vmstat while kswad0 at 100%cpu

# ========
# captured on: Fri Nov 30 07:22:00 2012
# hostname : rawhide
# os release : 3.7.0-0.rc7.git1.2.van.main.knurd.kswap.3.fc18.i686
# perf version : 3.7.0-0.rc7.git1.2.van.main.knurd.kswap.3.fc18.i686
# arch : i686
# nrcpus online : 1
# nrcpus avail : 1
# cpudesc : QEMU Virtual CPU version 1.0.1
# cpuid : AuthenticAMD,6,2,3
# total memory : 1027716 kB
# cmdline : /usr/bin/perf record -g -a sleep 5 
# event : name = cpu-clock, type = 1, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, excl_host = 0, excl_guest = 1, precise_ip = 0, id = { 7 }
# HEADER_CPU_TOPOLOGY info available, use -I to display
# pmu mappings: software = 1, tracepoint = 2, breakpoint = 5
# ========
#
# Samples: 20K of event 'cpu-clock'
# Event count (approx.): 20016
#
# Overhead      Command              Shared Object                               Symbol
# ........  ...........  .........................  ...................................
#
    16.52%      kswapd0  [kernel.kallsyms]          [k] idr_get_next                   
                |
                --- idr_get_next
                   |          
                   |--99.76%-- css_get_next
                   |          mem_cgroup_iter
                   |          |          
                   |          |--50.49%-- shrink_zone
                   |          |          kswapd
                   |          |          kthread
                   |          |          ret_from_kernel_thread
                   |          |          
                   |           --49.51%-- kswapd
                   |                     kthread
                   |                     ret_from_kernel_thread
                    --0.24%-- [...]

    11.23%      kswapd0  [kernel.kallsyms]          [k] prune_super                    
                |
                --- prune_super
                   |          
                   |--86.74%-- shrink_slab
                   |          kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                   |          
                    --13.26%-- kswapd
                              kthread
                              ret_from_kernel_thread

    10.73%      kswapd0  [kernel.kallsyms]          [k] shrink_slab                    
                |
                --- shrink_slab
                   |          
                   |--99.58%-- kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                    --0.42%-- [...]

     7.36%      kswapd0  [kernel.kallsyms]          [k] grab_super_passive             
                |
                --- grab_super_passive
                   |          
                   |--92.46%-- prune_super
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                   |          
                    --7.54%-- shrink_slab
                              kswapd
                              kthread
                              ret_from_kernel_thread

     5.82%      kswapd0  [kernel.kallsyms]          [k] _raw_spin_lock                 
                |
                --- _raw_spin_lock
                   |          
                   |--34.28%-- put_super
                   |          drop_super
                   |          prune_super
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                   |          
                   |--30.50%-- grab_super_passive
                   |          prune_super
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                   |          
                   |--17.27%-- prune_super
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                   |          
                   |--16.15%-- drop_super
                   |          prune_super
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                   |          
                   |--1.20%-- mb_cache_shrink_fn
                   |          shrink_slab
                   |          kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                   |          
                    --0.60%-- shrink_slab
                              kswapd
                              kthread
                              ret_from_kernel_thread

     4.43%      kswapd0  [kernel.kallsyms]          [k] fill_contig_page_info          
                |
                --- fill_contig_page_info
                   |          
                   |--99.10%-- fragmentation_index
                   |          compaction_suitable
                   |          kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                   |          
                    --0.90%-- compaction_suitable
                              kswapd
                              kthread
                              ret_from_kernel_thread

     3.81%      kswapd0  [kernel.kallsyms]          [k] shrink_lruvec                  
                |
                --- shrink_lruvec
                   |          
                   |--99.34%-- shrink_zone
                   |          kswapd
                   |          kthread
                   |          ret_from_kernel_thread
                   |          
                    --0.66%-- kswapd
                              kthread
                              ret_from_kernel_thread

The rest at https://bugzilla.redhat.com/attachment.cgi?id=654977

CU
 Thorsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
