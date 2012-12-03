Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 16E956B002B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 10:23:33 -0500 (EST)
Message-ID: <50BCC3E3.40804@redhat.com>
Date: Mon, 03 Dec 2012 16:23:15 +0100
From: Zdenek Kabelac <zkabelac@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org> <20121128094511.GS8218@suse.de>
In-Reply-To: <20121128094511.GS8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Thorsten Leemhuis <fedora@leemhuis.info>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jslaby@suse.cz>, Bruno Wolff III <bruno@wolff.to>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Dne 28.11.2012 10:45, Mel Gorman napsal(a):
> (Adding Thorsten to cc)
>
> On Tue, Nov 27, 2012 at 03:48:34PM -0500, Johannes Weiner wrote:
>> Hi everyone,
>>
>> I hope I included everybody that participated in the various threads
>> on kswapd getting stuck / exhibiting high CPU usage.  We were looking
>> at at least three root causes as far as I can see, so it's not really
>> clear who observed which problem.  Please correct me if the
>> reported-by, tested-by, bisected-by tags are incomplete.
>>
>> One problem was, as it seems, overly aggressive reclaim due to scaling
>> up reclaim goals based on compaction failures.  This one was reverted
>> in 9671009 mm: revert "mm: vmscan: scale number of pages reclaimed by
>> reclaim/compaction based on failures".
>>
>
> This particular one would have been made worse by the accounting bug and
> if kswapd was staying awake longer than necessary. As scaling the amount
> of reclaim only for direct reclaim helped this problem a lot, I strongly
> suspect the accounting bug was a factor.
>
> However the benefit for this is marginal -- it primarily affects how
> many THP pages we can allocate under stress. There is already a graceful
> fallback path and a system under heavy reclaim pressure is not going to
> notice the performance benefit of THP.
>
>> Another one was an accounting problem where a freed higher order page
>> was underreported, and so kswapd had trouble restoring watermarks.
>> This one was fixed in ef6c5be fix incorrect NR_FREE_PAGES accounting
>> (appears like memory leak).
>>
>
> This almost certainly also requires the follow-on fix at
> https://lkml.org/lkml/2012/11/26/225 for reasons I explained in
> https://lkml.org/lkml/2012/11/27/190 .
>
>> The third one is a problem with small zones, like the DMA zone, where
>> the high watermark is lower than the low watermark plus compaction gap
>> (2 * allocation size).  The zonelist reclaim in kswapd would do
>> nothing because all high watermarks are met, but the compaction logic
>> would find its own requirements unmet and loop over the zones again.
>> Indefinitely, until some third party would free enough memory to help
>> meet the higher compaction watermark.  The problematic code has been
>> there since the 3.4 merge window for non-THP higher order allocations
>> but has been more prominent since the 3.7 merge window, where kswapd
>> is also woken up for the much more common THP allocations.
>>
>
> Yes.
>
>> The following patch should fix the third issue by making both reclaim
>> and compaction code in kswapd use the same predicate to determine
>> whether a zone is balanced or not.
>>
>> Hopefully, the sum of all three fixes should tame kswapd enough for
>> 3.7.
>>
>
> Not exactly sure of that. With just those patches it is possible for
> allocations for THP entering the slow path to keep kswapd continually awake
> doing busy work. This was an alternative to the revert that covered that
> https://lkml.org/lkml/2012/11/12/151 but it was not enough because kswapd
> would stay awake due to the bug you identified and fixed.
>
> I went with the __GFP_NO_KSWAPD patch in this cycle because 3.6 was/is
> very poor in how it handles THP after the removal of lumpy reclaim. 3.7
> was shaping up to be even worse with multiple root causes too close to the
> release date.  Taking kswapd out of the equation covered some of the
> problems (yes, by hiding them) so it could be revisited but Johannes may
> have finally squashed it.
>
> However, if we revert the revert then I strongly recommend that it be
> replaced with "Avoid waking kswapd for THP allocations when compaction is
> deferred or contended".
>


Ok, bad news - I've been hit by  kswapd0 loop again -
my kernel git commit cc19528bd3084c3c2d870b31a3578da8c69952f3 again shown 
kswapd0 for couple minutes on CPU.

It seemed to go instantly away when I've drop caches
(echo 3 >/proc/sys/vm/drop_cache)
(After that I've had over 1G free memory)

Here are some stats before drop while kswapd0 was running:

kswapd0         R  running task        0    30      2 0x00000000
  ffff880133207b08 0000000000000082 ffff880133207b18 0000000000000246
  ffff880135b92340 ffff880133207fd8 ffff880133207fd8 ffff880133207fd8
  ffff880103098000 ffff880135b92340 0000000000000000 ffff880133206000
Call Trace:
  [<ffffffff815566b2>] preempt_schedule+0x42/0x60
  [<ffffffff81558555>] _raw_spin_unlock+0x55/0x60
  [<ffffffff81193b3c>] grab_super_passive+0x3c/0x90
  [<ffffffff81193bd6>] prune_super+0x46/0x1b0
  [<ffffffff81141eda>] shrink_slab+0xba/0x510
  [<ffffffff81185c3a>] ? mem_cgroup_iter+0x17a/0x2e0
  [<ffffffff81185b8a>] ? mem_cgroup_iter+0xca/0x2e0
  [<ffffffff81145141>] balance_pgdat+0x621/0x7e0
  [<ffffffff81145474>] kswapd+0x174/0x640
  [<ffffffff8106fd40>] ? __init_waitqueue_head+0x60/0x60
  [<ffffffff81145300>] ? balance_pgdat+0x7e0/0x7e0
  [<ffffffff8106f52b>] kthread+0xdb/0xe0
  [<ffffffff8106f450>] ? kthread_create_on_node+0x140/0x140
  [<ffffffff815604dc>] ret_from_fork+0x7c/0xb0
  [<ffffffff8106f450>] ? kthread_create_on_node+0x140/0x140

runnable tasks:
             task   PID         tree-key  switches  prio     exec-runtime 
     sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
          kswapd0    30   8087056.792356     30543   120   8087056.792356 
158938.479290 137131605.711862 /
      kworker/0:3 29833   8087050.792356    526664   120   8087050.792356 
24710.527691  24775203.529553 /
R           bash 24767     43813.836355       121   120     43813.836355 
   40.855087     10579.107486 /autogroup-392

----

Showing all locks held in the system:
1 lock held by bash/10668:
  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff813b3dc0>] 
n_tty_read+0x610/0x990
1 lock held by bash/10756:
  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff813b3dc0>] 
n_tty_read+0x610/0x990
1 lock held by bash/26989:
  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff813b3dc0>] 
n_tty_read+0x610/0x990
1 lock held by less/10268:
  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff813b3dc0>] 
n_tty_read+0x610/0x990
1 lock held by less/19112:
  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff813b3dc0>] 
n_tty_read+0x610/0x990
1 lock held by bash/13774:
  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff813b3dc0>] 
n_tty_read+0x610/0x990
1 lock held by less/32444:
  #0:  (&tty->atomic_read_lock){+.+.+.}, at: [<ffffffff813b3dc0>] 
n_tty_read+0x610/0x990
2 locks held by bash/24767:
  #0:  (sysrq_key_table_lock){......}, at: [<ffffffff813bb553>] 
__handle_sysrq+0x33/0x190
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810ad973>] 
debug_show_all_locks+0x43/0x2a0

=============================================

SysRq : HELP : loglevel(0-9) reBoot Crash show-all-locks(D) 
terminate-all-tasks(E) memory-full-oom-kill(F) kill-all-tasks(I) 
thaw-filesystems(J) saK show-backtrace-all-active-cpus(L) show-memory-usage(M) 
nice-all-RT-tasks(N) powerOff show-registers(P) show-all-timers(Q) unRaw Sync 
show-task-states(T) Unmount force-fb(V) show-blocked-tasks(W) 
dump-ftrace-buffer(Z)
SysRq : Show Memory
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 147
CPU    1: hi:  186, btch:  31 usd: 157
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 154
CPU    1: hi:  186, btch:  31 usd: 182
active_anon:610014 inactive_anon:16551 isolated_anon:0
  active_file:83258 inactive_file:151927 isolated_file:0
  unevictable:16 dirty:12 writeback:0 unstable:0
  free:72021 slab_reclaimable:18685 slab_unreclaimable:13682
  mapped:23445 shmem:29913 pagetables:7689 bounce:0
  free_cma:0
DMA free:15892kB min:260kB low:324kB high:388kB active_anon:0kB 
inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:15644kB mlocked:0kB dirty:0kB 
writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB 
kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 2982 3927 3927
DMA32 free:251976kB min:51124kB low:63904kB high:76684kB active_anon:1738128kB 
inactive_anon:58108kB active_file:316652kB inactive_file:591328kB 
unevictable:16kB isolated(anon):0kB isolated(file):0kB present:3054528kB 
mlocked:16kB dirty:40kB writeback:0kB mapped:58684kB shmem:108216kB 
slab_reclaimable:38888kB slab_unreclaimable:15988kB kernel_stack:1416kB 
pagetables:8684kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 945 945
Normal free:20216kB min:16196kB low:20244kB high:24292kB active_anon:701928kB 
inactive_anon:8096kB active_file:16380kB inactive_file:16380kB 
unevictable:48kB isolated(anon):0kB isolated(file):0kB present:967680kB 
mlocked:48kB dirty:8kB writeback:0kB mapped:35096kB shmem:11436kB 
slab_reclaimable:35852kB slab_unreclaimable:38732kB kernel_stack:3200kB 
pagetables:22072kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:42 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 0*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 
1*2048kB 3*4096kB = 15892kB
DMA32: 56*4kB 577*8kB 754*16kB 1192*32kB 713*64kB 484*128kB 223*256kB 57*512kB 
1*1024kB 1*2048kB 0*4096kB = 251976kB
Normal: 526*4kB 350*8kB 181*16kB 152*32kB 66*64kB 18*128kB 2*256kB 1*512kB 
0*1024kB 0*2048kB 0*4096kB = 20216kB
265099 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
1032176 pages RAM
42790 pages reserved
672981 pages shared
820401 pages non-shared

vmstat:

nr_free_pages 72360
nr_inactive_anon 16501
nr_active_anon 609811
nr_inactive_file 151932
nr_active_file 83212
nr_unevictable 16
nr_mlock 16
nr_anon_pages 503314
nr_mapped 23443
nr_file_pages 264982
nr_dirty 234
nr_writeback 0
nr_slab_reclaimable 18685
nr_slab_unreclaimable 13682
nr_page_table_pages 7690
nr_kernel_stack 577
nr_unstable 0
nr_bounce 0
nr_vmscan_write 0
nr_vmscan_immediate_reclaim 29
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 29838
nr_dirtied 2206202
nr_written 2066654
nr_anon_transparent_hugepages 182
nr_free_cma 0
nr_dirty_threshold 13870
nr_dirty_background_threshold 6935
pgpgin 3224666
pgpgout 9329522
pswpin 0
pswpout 0
pgalloc_dma 2
pgalloc_dma32 100605413
pgalloc_normal 25009399
pgalloc_movable 0
pgfree 126647271
pgactivate 1185101
pgdeactivate 214747
pgfault 106494704
pgmajfault 9834
pgrefill_dma 0
pgrefill_dma32 99747
pgrefill_normal 232841
pgrefill_movable 0
pgsteal_kswapd_dma 0
pgsteal_kswapd_dma32 208294
pgsteal_kswapd_normal 162100
pgsteal_kswapd_movable 0
pgsteal_direct_dma 0
pgsteal_direct_dma32 11942
pgsteal_direct_normal 91155
pgsteal_direct_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 211693
pgscan_kswapd_normal 182157
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 12129
pgscan_direct_normal 96028
pgscan_direct_movable 0
pgscan_direct_throttle 0
pginodesteal 77546
slabs_scanned 784384
kswapd_inodesteal 47090
kswapd_low_wmark_hit_quickly 57
kswapd_high_wmark_hit_quickly 275
kswapd_skip_congestion_wait 0
pageoutrun 1636173
allocstall 175
pgrotated 73
compact_blocks_moved 80209
compact_pages_moved 345293
compact_pagemigrate_failed 64875
compact_stall 736
compact_fail 314
compact_success 422
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 2848
unevictable_pgs_scanned 0
unevictable_pgs_rescued 3330
unevictable_pgs_mlocked 3346
unevictable_pgs_munlocked 3330
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
thp_fault_alloc 53631
thp_fault_fallback 1682
thp_collapse_alloc 13390
thp_collapse_alloc_failed 643
thp_split 2387


Zdenek


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
