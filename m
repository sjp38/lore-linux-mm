Date: Tue, 24 Jun 2008 17:31:54 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH] prevent incorrect oom under split_lru
Message-Id: <20080624171816.D835.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi Rik,

I encounted strange OOM when ran stress workload.
oom-killer happned but swappable page exist many.

I guess this is split_lru related bug.
what do you think below patch?

-------------
page01 invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0

Call Trace:
 [<a0000001000175e0>] show_stack+0x80/0xa0
                                sp=e00001600e1ffae0 bsp=e00001600e1f1598
 [<a000000100017630>] dump_stack+0x30/0x60
                                sp=e00001600e1ffcb0 bsp=e00001600e1f1580
 [<a000000100133f10>] oom_kill_process+0x250/0x4c0
                                sp=e00001600e1ffcb0 bsp=e00001600e1f1518
 [<a000000100134db0>] out_of_memory+0x3f0/0x520
                                sp=e00001600e1ffcc0 bsp=e00001600e1f14b8
 [<a00000010013f650>] __alloc_pages_internal+0x6b0/0x860
                                sp=e00001600e1ffd60 bsp=e00001600e1f13e8
 [<a00000010018ae80>] alloc_pages_current+0x120/0x1c0
                                sp=e00001600e1ffd70 bsp=e00001600e1f13b0
 [<a00000010012cad0>] __page_cache_alloc+0x130/0x160
                                sp=e00001600e1ffd70 bsp=e00001600e1f1390
 [<a000000100144270>] __do_page_cache_readahead+0x150/0x580
                                sp=e00001600e1ffd70 bsp=e00001600e1f12f8
 [<a0000001001451d0>] do_page_cache_readahead+0xf0/0x120
                                sp=e00001600e1ffd80 bsp=e00001600e1f12c0
 [<a000000100132250>] filemap_fault+0x430/0x8e0
                                sp=e00001600e1ffd80 bsp=e00001600e1f1208
 [<a000000100158900>] __do_fault+0xa0/0xc80
                                sp=e00001600e1ffd80 bsp=e00001600e1f1178
 [<a00000010015d740>] handle_mm_fault+0x260/0x1240
                                sp=e00001600e1ffda0 bsp=e00001600e1f10f0
 [<a0000001007aaab0>] ia64_do_page_fault+0x6f0/0xb00
                                sp=e00001600e1ffda0 bsp=e00001600e1f1090
 [<a00000010000c4e0>] ia64_native_leave_kernel+0x0/0x270
                                sp=e00001600e1ffe30 bsp=e00001600e1f1090
Node 2 DMA per-cpu:
CPU    0: hi:    6, btch:   1 usd:   5
CPU    1: hi:    6, btch:   1 usd:   5
CPU    2: hi:    6, btch:   1 usd:   5
CPU    3: hi:    6, btch:   1 usd:   5
CPU    4: hi:    6, btch:   1 usd:   5
CPU    5: hi:    6, btch:   1 usd:   5
CPU    6: hi:    6, btch:   1 usd:   5
CPU    7: hi:    6, btch:   1 usd:   5
Node 2 Normal per-cpu:
CPU    0: hi:    6, btch:   1 usd:   5
CPU    1: hi:    6, btch:   1 usd:   5
CPU    2: hi:    6, btch:   1 usd:   5
CPU    3: hi:    6, btch:   1 usd:   5
CPU    4: hi:    6, btch:   1 usd:   5
CPU    5: hi:    6, btch:   1 usd:   5
CPU    6: hi:    6, btch:   1 usd:   5
CPU    7: hi:    6, btch:   1 usd:   5
Node 3 Normal per-cpu:
CPU    0: hi:    6, btch:   1 usd:   5
CPU    1: hi:    6, btch:   1 usd:   5
CPU    2: hi:    6, btch:   1 usd:   2
CPU    3: hi:    6, btch:   1 usd:   2
CPU    4: hi:    6, btch:   1 usd:   4
CPU    5: hi:    6, btch:   1 usd:   5
CPU    6: hi:    6, btch:   1 usd:   4
CPU    7: hi:    6, btch:   1 usd:   5
Active_anon:53395 active_file:141 inactive_anon18042
 inactive_file:544 unevictable:12288 dirty:494 writeback:365 unstable:0
 free:288 slab:28313 mapped:83 pagetables:663 bounce:0
Node 2 DMA free:8128kB min:2624kB low:3264kB high:3904kB active_anon:753536kB inactive_anon:587840kB active_file:2176kB inactive_file:8064kB unevictable:0kB present:1863168kB pages_scanned:3934 all_unreclaimable? no
lowmem_reserve[]: 0 110 110
Node 2 Normal free:6464kB min:2560kB low:3200kB high:3840kB active_anon:198400kB inactive_anon:73472kB active_file:1664kB inactive_file:18816kB unevictable:0kB present:1802240kB pages_scanned:64 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
Node 3 Normal free:3840kB min:5888kB low:7360kB high:8832kB active_anon:2465344kB inactive_anon:493376kB active_file:5184kB inactive_file:7936kB unevictable:786432kB present:4124224kB pages_scanned:872 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
Node 2 DMA: 61*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB 0*65536kB 0*131072kB 0*262144kB 0*524288kB 0*1048576kB 0*2097152kB 0*4194304kB = 6336kB
Node 2 Normal: 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB 0*65536kB 0*131072kB 0*262144kB 0*524288kB 0*1048576kB 0*2097152kB 0*4194304kB = 0kB
Node 3 Normal: 57*64kB 6*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB 0*65536kB 0*131072kB 0*262144kB 0*524288kB 0*1048576kB 0*2097152kB 0*4194304kB = 4416kB
1158 total pagecache pages
Swap cache: add 525, delete 283, find 0/0
Free swap  = 1997888kB
Total swap = 2031488kB
Out of memory: kill process 56203 (usex) score 2837 or a child
Killed process 56309 (usex)



----------------------
if zone->recent_scanned parameter become inbalanceing anon and file,
OOM killer can happened although swappable page exist.

So, if priority==0, We should try to reclaim all page for prevent OOM.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmscan.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1464,8 +1464,10 @@ static unsigned long shrink_zone(int pri
 			 * kernel will slowly sift through each list.
 			 */
 			scan = zone_page_state(zone, NR_LRU_BASE + l);
-			scan >>= priority;
-			scan = (scan * percent[file]) / 100;
+			if (priority) {
+				scan >>= priority;
+				scan = (scan * percent[file]) / 100;
+			}
 			zone->lru[l].nr_scan += scan + 1;
 			nr[l] = zone->lru[l].nr_scan;
 			if (nr[l] >= sc->swap_cluster_max)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
