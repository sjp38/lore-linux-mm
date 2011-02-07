Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 811A78D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 16:46:00 -0500 (EST)
Date: Mon, 7 Feb 2011 22:45:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: khugepaged eating 100%CPU
Message-ID: <20110207214553.GA26371@tiehlicka.suse.cz>
References: <20110207210517.GA24837@tiehlicka.suse.cz>
 <20110207211601.GA25665@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110207211601.GA25665@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 07-02-11 22:16:01, Michal Hocko wrote:
> On Mon 07-02-11 22:06:54, Michal Hocko wrote:
> > Hi Andrea,
> > 
> > I am currently running into an issue when khugepaged is running 100% on
> > one of my CPUs for a long time (at least one hour as I am writing the
> > email). The kernel is the clean 2.6.38-rc3 (i386) vanilla kernel.
> > 
> > I have tried to disable defrag but it didn't help (I haven't rebooted
> > after setting the value). I am not sure what information is helpful and
> > also not sure whether I am able to reproduce it after restart (it is the
> > first time I can see this problem) so sorry for the poor report.
> > 
> > Here is some basic info which might be useful (config and sysrq+t are
> > attached):
> > =========
> 
> And I have just realized that I forgot about the daemon stack:
> # cat /proc/573/stack 
> [<c019c981>] shrink_zone+0x1b9/0x455
> [<c019d462>] do_try_to_free_pages+0x9d/0x301
> [<c019d803>] try_to_free_pages+0xb3/0x104
> [<c01966d7>] __alloc_pages_nodemask+0x358/0x589
> [<c01bf314>] khugepaged+0x13f/0xc60
> [<c014c301>] kthread+0x67/0x6c
> [<c0102db6>] kernel_thread_helper+0x6/0x10
> [<ffffffff>] 0xffffffff

And the issue is gone. Same like it came - without any obvious trigger.
$ cat /proc/573/stack
[<c01bfc8a>] khugepaged+0xab5/0xc60
[<c014c301>] kthread+0x67/0x6c
[<c0102db6>] kernel_thread_helper+0x6/0x10]]]

So it looks like it managed to free some pages. Anyway it took a while
(I would say an hour) to do it so something seems to be fishy.
Just for reference I am attaching also the allocator state:
====

# cat /proc/buddyinfo
Node 0, zone      DMA      8      3      2      5      6      5      3      1      1      1      1 
Node 0, zone   Normal   2670   3000   2194   1489   1069    690    363    180     84     43      2 
Node 0, zone  HighMem    657   3474   1338    873    254     12      0      0      0      0      0 
====

# cat /proc/vmstat
nr_free_pages 187236
nr_inactive_anon 27928
nr_active_anon 94882
nr_inactive_file 78838
nr_active_file 97601
nr_unevictable 0
nr_mlock 0
nr_anon_pages 71401
nr_mapped 20701
nr_file_pages 219722
nr_dirty 8
nr_writeback 0
nr_slab_reclaimable 4269
nr_slab_unreclaimable 4188
nr_page_table_pages 827
nr_kernel_stack 235
nr_unstable 0
nr_bounce 0
nr_vmscan_write 23503
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 39642
nr_dirtied 1735727
nr_written 1607464
nr_anon_transparent_hugepages 9
nr_dirty_threshold 77463
nr_dirty_background_threshold 19365
pgpgin 19253206
pgpgout 6972134
pswpin 4233
pswpout 23401
pgalloc_dma 11688
pgalloc_normal 153681036
pgalloc_high 45511627
pgalloc_movable 0
pgfree 199845128
pgactivate 1831896
pgdeactivate 318554
pgfault 87302686
pgmajfault 15523
pgrefill_dma 288
pgrefill_normal 93009
pgrefill_high 200394
pgrefill_movable 0
pgsteal_dma 0
pgsteal_normal 3949660
pgsteal_high 601671
pgsteal_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_normal 3678094
pgscan_kswapd_high 366447
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_normal 290984
pgscan_direct_high 303477
pgscan_direct_movable 0
pginodesteal 73185
slabs_scanned 353792
kswapd_steal 4026528
kswapd_inodesteal 173760
kswapd_low_wmark_hit_quickly 6
kswapd_high_wmark_hit_quickly 7758
kswapd_skip_congestion_wait 0
pageoutrun 79411
allocstall 310
pgrotated 22447
compact_blocks_moved 11205
compact_pages_moved 325766
compact_pagemigrate_failed 6165
compact_stall 347
compact_fail 67
compact_success 280
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 1093
unevictable_pgs_scanned 0
unevictable_pgs_rescued 359
unevictable_pgs_mlocked 1307
unevictable_pgs_munlocked 1306
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0
====

# grep . -r /sys/kernel/mm/transparent_hugepage/
/sys/kernel/mm/transparent_hugepage/enabled:[always] madvise never
/sys/kernel/mm/transparent_hugepage/defrag:always madvise [never]
/sys/kernel/mm/transparent_hugepage/khugepaged/defrag:yes [no]
/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none:1023
/sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan:8192
/sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed:1524
/sys/kernel/mm/transparent_hugepage/khugepaged/full_scans:1510
/sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs:10000
/sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs:60000
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
