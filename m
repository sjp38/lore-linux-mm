Received: by py-out-1112.google.com with SMTP id d32so3518734pye
        for <linux-mm@kvack.org>; Fri, 14 Sep 2007 16:04:17 -0700 (PDT)
Message-ID: <170fa0d20709141604o301dfcceqc3652e23a72e639@mail.gmail.com>
Date: Fri, 14 Sep 2007 19:04:16 -0400
From: "Mike Snitzer" <snitzer@gmail.com>
Subject: deadlock w/ parallel mke2fs on 2 servers that each host an MD w/ an NBD member?
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hello,

I'm interested in any insight into how to avoid the following deadlock
scenario.  Here is the overview of the systems' configuration with
each of 2 4GB servers hosting an lvm2 LV on MD raid1 with 2 750GB
members (one local, one remote via nbd):

server A:
[lvm2 vg1/lv1]
[raid1 md0]
[sda][nbd0]
nbd-server -> [sdb]

server B:
[lvm2 vg2/lv2]
[raid1 md0]
[sdb][nbd0]
nbd-server -> [sda]

The deadlock occurs when the following is started simulataneously:
on server A: mke2fs -j /dev/vg1/lv1
on server B: mke2fs -j /dev/vg2/lv2

This deadlocks with both 2.6.15.7 and 2.6.19.7.  I can easily try any
newer kernel with any patchset that might help (peterz's net deadlock
avoidance or per-bdi dirty accounting or CFS or ...).

All the following data is from a 2.6.15.7 kernel to which I've applied
2 nbd patches that peterz posted to LKML over the past year.  One to
pin nbd to the noop scheduler and the other being the proposed nbd
request_fn fix:
http://lkml.org/lkml/2006/7/7/164
http://lkml.org/lkml/2007/4/29/283

I've tried playing games with prolonging the inevitable deadlock with
dirty_ratio=60, background_dirty_ratio=1, and running mke2fs with nice
19.  The deadlock hits once the dirty_ratio is reached on server A and
B.

I could easily be missing a quick fix (via an existing patchset) but
it feels like the nbd-server _needs_ to be able to reserve a pool of
memory in the kernel to be able guarantee progress on its contribution
to the overall cross-connected systems' writeback.  If not that then
what?  And if that, how?

I have the full vmcore from 'system B' and can pull out any data that
you'd like to see via crash.  Here are some traces that may be useful:

PID: 5185   TASK: ffff81015e0497f0  CPU: 1   COMMAND: "md0_raid1"
 #0 [ffff81015543fbe8] schedule at ffffffff8031db68
 #1 [ffff81015543fca0] io_schedule at ffffffff8031e52f
 #2 [ffff81015543fcc0] get_request_wait at ffffffff801e084f
 #3 [ffff81015543fd60] __make_request at ffffffff801e1565
 #4 [ffff81015543fdb0] generic_make_request at ffffffff801e18af
 #5 [ffff81015543fdd8] raid1d at ffffffff8806a6c7
 #6 [ffff81015543fe00] raid1d at ffffffff8806a6d8
 #7 [ffff81015543fe40] del_timer_sync at ffffffff80138bc5
 #8 [ffff81015543fe50] schedule_timeout at ffffffff8031e614
 #9 [ffff81015543fea0] md_thread at ffffffff802ac1bf
#10 [ffff81015543ff20] kthread at ffffffff80143e9f
#11 [ffff81015543ff50] kernel_thread at ffffffff8010e97e

PID: 5176   TASK: ffff81015fbce080  CPU: 0   COMMAND: "nbd-server"
 #0 [ffff810157395938] schedule at ffffffff8031db68
 #1 [ffff8101573959f0] schedule_timeout at ffffffff8031e60c
 #2 [ffff810157395a40] io_schedule_timeout at ffffffff8031e568
 #3 [ffff810157395a60] blk_congestion_wait at ffffffff801e1106
 #4 [ffff810157395a90] get_writeback_state at ffffffff80158894
 #5 [ffff810157395ae0] balance_dirty_pages_ratelimited at ffffffff80158a9d
 #6 [ffff810157395ae8] blkdev_get_block at ffffffff80177d21
 #7 [ffff810157395ba0] generic_file_buffered_write at ffffffff80155026
 #8 [ffff810157395c40] skb_copy_datagram_iovec at ffffffff802bd137
 #9 [ffff810157395c70] current_fs_time at ffffffff8013540d
#10 [ffff810157395ce0] __generic_file_aio_write_nolock at ffffffff80155676
#11 [ffff810157395d40] sock_aio_read at ffffffff802b66f9
#12 [ffff810157395dc0] generic_file_aio_write_nolock at ffffffff801559ec
#13 [ffff810157395e00] generic_file_write_nolock at ffffffff80155b24
#14 [ffff810157395e10] generic_file_read at ffffffff80155e50
#15 [ffff810157395ef0] blkdev_file_write at ffffffff80178bfa
#16 [ffff810157395f10] vfs_write at ffffffff801710f8
#17 [ffff810157395f40] sys_write at ffffffff80171249
#18 [ffff810157395f80] system_call at ffffffff8010d84a
    RIP: 0000003ccbdb9302  RSP: 00007fffff71f3d8  RFLAGS: 00000246
    RAX: 0000000000000001  RBX: ffffffff8010d84a  RCX: 0000003ccbdb9302
    RDX: 0000000000001000  RSI: 00007fffff71f3e0  RDI: 0000000000000003
    RBP: 0000000000001000   R8: 0000000000000000   R9: 0000000000000000
    R10: 00007fffff71f301  R11: 0000000000000246  R12: 0000000000505a40
    R13: 0000000000000000  R14: 0000000000000000  R15: 00000000ff71f301
    ORIG_RAX: 0000000000000001  CS: 0033  SS: 002b

PID: 5274   TASK: ffff81015facd040  CPU: 0   COMMAND: "mke2fs"
 #0 [ffff81014a7e3938] schedule at ffffffff8031db68
 #1 [ffff81014a7e39f0] schedule_timeout at ffffffff8031e60c
 #2 [ffff81014a7e3a40] io_schedule_timeout at ffffffff8031e568
 #3 [ffff81014a7e3a60] blk_congestion_wait at ffffffff801e1106
 #4 [ffff81014a7e3a90] get_writeback_state at ffffffff80158894
 #5 [ffff81014a7e3ae0] balance_dirty_pages_ratelimited at ffffffff80158a9d
 #6 [ffff81014a7e3ae8] blkdev_get_block at ffffffff80177d21
 #7 [ffff81014a7e3ba0] generic_file_buffered_write at ffffffff80155026
 #8 [ffff81014a7e3c80] __mark_inode_dirty at ffffffff80191e89
 #9 [ffff81014a7e3ce0] __generic_file_aio_write_nolock at ffffffff80155676
#10 [ffff81014a7e3d30] thread_return at ffffffff8031dbcd
#11 [ffff81014a7e3dc0] generic_file_aio_write_nolock at ffffffff801559ec
#12 [ffff81014a7e3e00] generic_file_write_nolock at ffffffff80155b24
#13 [ffff81014a7e3e50] __wake_up at ffffffff8012c124
#14 [ffff81014a7e3ef0] blkdev_file_write at ffffffff80178bfa
#15 [ffff81014a7e3f10] vfs_write at ffffffff801710f8
#16 [ffff81014a7e3f40] sys_write at ffffffff80171249
#17 [ffff81014a7e3f80] system_call at ffffffff8010d84a
    RIP: 0000003ccbdb9302  RSP: 00007fffff988b18  RFLAGS: 00000246
    RAX: 0000000000000001  RBX: ffffffff8010d84a  RCX: 0000003ccbdc6902
    RDX: 0000000000008000  RSI: 0000000000514c60  RDI: 0000000000000003
    RBP: 0000000000008000   R8: 0000000000514c60   R9: 00007fffff988c4c
    R10: 0000000000000000  R11: 0000000000000246  R12: 000000000050b470
    R13: 0000000000000008  R14: 000000191804a000  R15: 0000000000000000
    ORIG_RAX: 0000000000000001  CS: 0033  SS: 002b

crash> kmem -i
              PAGES        TOTAL      PERCENTAGE
 TOTAL MEM   969567       3.7 GB         ----
      FREE   337073       1.3 GB   34% of TOTAL MEM
      USED   632494       2.4 GB   65% of TOTAL MEM
    SHARED   340951       1.3 GB   35% of TOTAL MEM
   BUFFERS   479526       1.8 GB   49% of TOTAL MEM
    CACHED    35846       140 MB    3% of TOTAL MEM
      SLAB   100397     392.2 MB   10% of TOTAL MEM

TOTAL HIGH        0            0    0% of TOTAL MEM
 FREE HIGH        0            0    0% of TOTAL HIGH
 TOTAL LOW   969567       3.7 GB  100% of TOTAL MEM
  FREE LOW   337073       1.3 GB   34% of TOTAL LOW

TOTAL SWAP  2096472         8 GB         ----
 SWAP USED        0            0    0% of TOTAL SWAP
 SWAP FREE  2096472         8 GB  100% of TOTAL SWAP

SysRq : Show Memory
Mem-info:
DMA per-cpu:
cpu 0 hot: low 0, high 0, batch 1 used:0
cpu 0 cold: low 0, high 0, batch 1 used:0
cpu 1 hot: low 0, high 0, batch 1 used:0
cpu 1 cold: low 0, high 0, batch 1 used:0
DMA32 per-cpu:
cpu 0 hot: low 0, high 186, batch 31 used:138
cpu 0 cold: low 0, high 62, batch 15 used:0
cpu 1 hot: low 0, high 186, batch 31 used:28
cpu 1 cold: low 0, high 62, batch 15 used:0
Normal per-cpu:
cpu 0 hot: low 0, high 186, batch 31 used:178
cpu 0 cold: low 0, high 62, batch 15 used:14
cpu 1 hot: low 0, high 186, batch 31 used:104
cpu 1 cold: low 0, high 62, batch 15 used:3
HighMem per-cpu: empty
Free pages:     1352420kB (0kB HighMem)
Active:28937 inactive:496921 dirty:1 writeback:409317 unstable:0
free:338105 slab:100341 mapped:12395 pagetables:373
DMA free:10732kB min:56kB low:68kB high:84kB active:0kB inactive:0kB
present:11368kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 2466 3975 3975
DMA32 free:1331696kB min:12668kB low:15832kB high:19000kB active:0kB
inactive:698504kB present:2526132kB pages_scanned:0 all_unreclaimable?
no
lowmem_reserve[]: 0 0 1509 1509
Normal free:9992kB min:7748kB low:9684kB high:11620kB active:115748kB
inactive:1289180kB present:1545216kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
HighMem free:0kB min:128kB low:128kB high:128kB active:0kB
inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 0*4kB 1*8kB 2*16kB 4*32kB 5*64kB 2*128kB 1*256kB 1*512kB 1*1024kB
0*2048kB 2*4096kB = 10728kB
DMA32: 0*4kB 0*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 0*512kB
0*1024kB 0*2048kB 325*4096kB = 1331696kB
Normal: 76*4kB 7*8kB 2*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB
1*1024kB 0*2048kB 2*4096kB = 9992kB
HighMem: empty
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap  = 8385888kB
Total swap = 8385888kB
Free swap:       8385888kB
1441792 pages of RAM
472225 reserved pages
551969 pages shared
0 pages swap cached

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
