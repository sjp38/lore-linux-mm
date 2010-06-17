Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EA8706B01AC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 14:43:08 -0400 (EDT)
Subject: [Patch] Call cond_resched() at bottom of main look in
	balance_pgdat()
From: Larry Woodman <lwoodman@redhat.com>
Content-Type: text/plain
Date: Thu, 17 Jun 2010 14:48:40 -0400
Message-Id: <1276800520.8736.236.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We are seeing a problem where kswapd gets stuck and hogs the CPU on a
small single CPU system when an OOM kill should occur.  When this
happens swap space has been exhausted and the pagecache has been shrunk
to zero.  Once kswapd gets the CPU it never gives it up because at least
one zone is below high.  Adding a single cond_resched() at the end of
the main loop in balance_pgdat() fixes the problem by allowing the
watchdog and tasks to run and eventually do an OOM kill which frees up
the resources.


----------------------------------------------------------------
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..c5c46b7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2182,6 +2182,7 @@ loop_again:
                 */
                if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
                        break;
+               cond_resched();
        }
 out:
        /*

-----------------------------------------------------------------

Signed-off-by: Larry Woodman <lwoodman@redhat.com>


-----------------------------------------------------------------
BUG: soft lockup - CPU#0 stuck for 61s! [kswapd0:26]
Modules linked in: sunrpc(U) p4_clockmod(U) ipv6(U) dm_mirror(U)...

Pid: 26, comm: kswapd0 Not tainted (2.6.32-34.el6.i686 #1) HP Compaq dx2300
EIP: 0060:[<c04e84fb>] EFLAGS: 00000246 CPU: 0
EIP is at shrink_slab+0x7b/0x170
EAX: 00000040 EBX: 00000000 ECX: dbf43e54 EDX: 00000000
ESI: e01c2b30 EDI: 00000000 EBP: c0ad4600 ESP: dbc8dec0
 DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
CR0: 8005003b CR2: 0805090c CR3: 108eb000 CR4: 000006f0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Call Trace:
 [<c04eab91>] ? kswapd+0x541/0x830
 [<c04eae80>] ? isolate_pages_global+0x0/0x220
 [<c04702d0>] ? autoremove_wake_function+0x0/0x40
 [<c043d5e0>] ? complete+0x40/0x60
 [<c04ea650>] ? kswapd+0x0/0x830
 [<c0470094>] ? kthread+0x74/0x80
 [<c0470020>] ? kthread+0x0/0x80
 [<c040a547>] ? kernel_thread_helper+0x7/0x10
-------------------------------------------------------------------
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 152
active_anon:54902 inactive_anon:54849 isolated_anon:32
 active_file:0 inactive_file:25 isolated_file:0
 unevictable:660 dirty:0 writeback:6 unstable:0
 free:1172 slab_reclaimable:1969 slab_unreclaimable:8322
 mapped:196 shmem:801 pagetables:1300 bounce:0
...
Normal free:2672kB min:2764kB low:3452kB high:4144kB 
...
21729 total pagecache pages
20240 pages in swap cache
Swap cache stats: add 468211, delete 447971, find 12560445/12560936
Free swap  = 0kB
Total swap = 1015800kB
128720 pages RAM
0 pages HighMem
3223 pages reserved
1206 pages shared
121413 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
