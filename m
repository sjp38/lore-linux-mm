From: Andi Kleen <ak@suse.de>
Subject: deadlock in 2.6.21-rc7-gitduring LTP mmap01 over nfs/no swap
Date: Tue, 24 Apr 2007 15:07:51 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704241507.51099.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

I ran LTP on a 512MB i386 UP nfsroot test system with no swap with
2.6.21-rc7-git6

It deadlocked during the LTP run with no progress anymore and 
ssh remote login not working anymore:

<<<test_output>>>
mmap001     0  INFO  :  mmap()ing file of 10000 pages or 40960000 bytes
mmap001     1  PASS  :  mmap() completed successfully.
mmap001     0  INFO  :  touching mmaped memory
mmap001     2  PASS  :  we're still here, mmaped area must be good
... hang...

sysreq-m:

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd: 154   Cold: hi:   62, btch:  15 usd:  11
Active:9293 inactive:34731 dirty:4261 writeback:5713 unstable:0
 free:79407 slab:4268 mapped:11117 pagetables:93 bounce:0
DMA free:10768kB min:88kB low:108kB high:132kB active:0kB inactive:0kB present:16256kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 491 491
Normal free:306860kB min:2788kB low:3484kB high:4180kB active:37172kB inactive:138924kB present:502860kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 4*4kB 4*8kB 2*16kB 4*32kB 3*64kB 3*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 2*4096kB = 10768kB
Normal: 1*4kB 3*8kB 1*16kB 0*32kB 0*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 74*4096kB = 306860kB
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap  = 0kB
Total swap = 0kB
Free swap:            0kB
130800 pages of RAM
0 pages of HIGHMEM
2637 reserved pages
20071 pages shared
0 pages swap cached
4261 pages dirty
5713 pages writeback
11117 pages mapped
4268 pages slab
93 pages pagetables


Excerpts from sysrq-t output:

rpciod/0      S 00000000     0   938      7 (L-TLB)
       c17bdf8c 00000046 df989f60 00000000 00000001 c17bdf64 c0113f7a 00000000 
       0000000a c14d0ab0 db56d570 9dcdf400 000004d7 00000000 c14d0bbc c1404fe0 
       00000000 db613ac0 ffffffff 00000000 00000246 df989f40 c14a1b24 c17bdfbc 
Call Trace:
 [<c0113f7a>] __wake_up+0x32/0x43
 [<c01272c9>] worker_thread+0xd0/0x124
 [<c0115b8a>] default_wake_function+0x0/0xc
 [<c01271f9>] worker_thread+0x0/0x124
 [<c01297b8>] kthread+0xb0/0xd8
 [<c0129708>] kthread+0x0/0xd8
 [<c0103cbb>] kernel_thread_helper+0x7/0x10

pdflush       S 00000000     0   198      7 (L-TLB)
       dfe95fa4 00000046 c1402280 00000000 dfed7a30 c0113ff2 c15435b0 c15435b0 
       00000001 c15435b0 dfedfab0 726509e3 00000007 00000426 c15436bc c1404fe0 
       00000000 c052e280 c01141cb c1405028 00000286 dfe95fbc c14a1f50 c013d3ae 
Call Trace:
 [<c0113ff2>] task_rq_lock+0x31/0x58
 [<c01141cb>] set_user_nice+0xca/0xd1
 [<c013d3ae>] pdflush+0x0/0x19d
 [<c013d45a>] pdflush+0xac/0x19d
 [<c01297b8>] kthread+0xb0/0xd8
 [<c0129708>] kthread+0x0/0xd8
 [<c0103cbb>] kernel_thread_helper+0x7/0x10

kswapd0       S DFEBFF68     0   200      7 (L-TLB)
       dfebff48 00000046 dfebff6b dfebff68 ffffffff c0113ff2 dfe79530 dfe79530 
       00000001 dfe79530 dfedfab0 72940801 00000007 00000415 dfe7963c c1404fe0 
       00000000 c052e280 dfe756c0 00000246 c0129994 dfe79530 c14a1f48 dfebffac 
Call Trace:
 [<c0113ff2>] task_rq_lock+0x31/0x58
 [<c0129994>] prepare_to_wait+0x12/0x49
 [<c013f94d>] kswapd+0xb4/0x3cf
 [<c040b327>] __sched_text_start+0x6cf/0x77e
 [<c0129881>] autoremove_wake_function+0x0/0x35
 [<c0113ee8>] complete+0x39/0x48
 [<c013f899>] kswapd+0x0/0x3cf
 [<c01297b8>] kthread+0xb0/0xd8
 [<c0129708>] kthread+0x0/0xd8
 [<c0103cbb>] kernel_thread_helper+0x7/0x10


pan           S DF945A20     0  2203      1 (NOTLB)
       db59ff54 00000082 c01233c6 df945a20 db59ff24 0000000f 0000000f c0123404 
       0000000a db46a030 dfd435b0 2adf0400 000004cf 00000000 db46a13c c1404fe0 
       00000000 db44d040 db46b400 c05dcf20 00000246 ffffffff 00000001 d9b13ab0 
Call Trace:
 [<c01233c6>] __kill_pgrp_info+0x2f/0x4f
 [<c0123404>] kill_pgrp_info+0x1e/0x29
 [<c011c30f>] do_wait+0x885/0x957
 [<c0115b8a>] default_wake_function+0x0/0xc
 [<c011c412>] sys_wait4+0x31/0x34
 [<c01030e0>] syscall_call+0x7/0xb


mmap001       D D56DDEAC     0  6777   2203 (NOTLB)
       d56ddec0 00000082 00000002 d56ddeac d56ddea8 00000000 db728c80 c1345520 
       0000000a d9b13ab0 c052e440 8a2d5200 000004ce 00000000 d9b13bbc c1404fe0 
       00000000 df146c80 ffffffff 00000000 00000000 c1404fe0 00000000 d56ddefc 
Call Trace:
 [<c040b913>] io_schedule+0x22/0x2c
 [<c01380be>] sync_page+0x38/0x3b
 [<c040bb9a>] __wait_on_bit+0x33/0x58
 [<c0138086>] sync_page+0x0/0x3b
 [<c01381f8>] wait_on_page_bit+0x61/0x66
 [<c01298b6>] wake_bit_function+0x0/0x3c
 [<c0138b70>] wait_on_page_writeback_range+0x4d/0xf8
 [<c016b488>] do_fsync+0x7b/0x83
 [<c0147307>] sys_msync+0xf3/0x158
 [<c01030e0>] syscall_call+0x7/0xb

cron          S DB9437D0     0  6779   1718 (NOTLB)
       d5311e5c 00000086 db943874 db9437d0 01000000 00000000 00000000 df9e9480 
       00000005 dfd430b0 dfa2eab0 b46c6400 0000016f 00000000 dfd431bc c1404fe0 
       00000000 db613900 c03ff343 00000246 c0129994 df811a00 db69440c d5311e78 
Call Trace:
 [<c03ff343>] xs_udp_write_space+0xe/0x53
 [<c0129994>] prepare_to_wait+0x12/0x49
 [<c01574a2>] pipe_wait+0x51/0x6f
 [<c0129881>] autoremove_wake_function+0x0/0x35
 [<c0157b84>] pipe_read+0x2ad/0x31d
 [<c011e027>] irq_exit+0x53/0x6b
 [<c0105038>] do_IRQ+0x7e/0x92
 [<c011e027>] irq_exit+0x53/0x6b
 [<c015256b>] do_sync_read+0xc7/0x10a
 [<c0129881>] autoremove_wake_function+0x0/0x35
 [<c01524a4>] do_sync_read+0x0/0x10a
 [<c0152cce>] vfs_read+0x88/0x10a
 [<c01530ca>] sys_read+0x41/0x67
 [<c01030e0>] syscall_call+0x7/0xb
sshd          S DB57FB4C     0  6892   1666 (NOTLB)
       db57fb60 00000086 00000002 db57fb4c db57fb48 00000000 c01219a5 00000286 
       0000000a c153e570 c052e440 47403200 000004d3 00000000 c153e67c c1404fe0 
       00000000 db637900 ffffffff 00000000 00000000 7fffffff dbad0780 0000000a 
Call Trace:
 [<c01219a5>] __mod_timer+0x90/0x9a
 [<c040ba0c>] schedule_timeout+0x13/0x8d
 [<c0254d9c>] tty_poll+0x53/0x60
 [<c015c8a5>] do_select+0x365/0x3bc
 [<c015ce47>] __pollwait+0x0/0xac
 [<c0115b8a>] default_wake_function+0x0/0xc
 [<c0115b8a>] default_wake_function+0x0/0xc
 [<c0115b8a>] default_wake_function+0x0/0xc
 [<c0115b8a>] default_wake_function+0x0/0xc
 [<c039dd73>] __qdisc_run+0x2e/0x182
 [<c0394b0d>] dev_queue_xmit+0x21b/0x23a
 [<c0160532>] dput+0x22/0x11d
 [<c03a86e1>] ip_output+0x173/0x1ab
 [<c03a8f0f>] ip_queue_xmit+0x348/0x388
 [<c03bae88>] tcp_v4_send_check+0x74/0xaa
 [<c03b625b>] tcp_transmit_skb+0x639/0x667
 [<c0158214>] do_lookup+0x4f/0x140
 [<c02067fa>] _atomic_dec_and_lock+0x2a/0x44
 [<c012189d>] lock_timer_base+0x15/0x2f
 [<c01219a5>] __mod_timer+0x90/0x9a
 [<c038c424>] sk_reset_timer+0xc/0x16
 [<c03b7b97>] __tcp_push_pending_frames+0x6f4/0x7aa
 [<c03e3a78>] ipv6_setsockopt+0x3e/0xaaa
 [<c040c8ab>] _spin_lock_bh+0x8/0x18
 [<c038c2e4>] release_sock+0x12/0x9c
 [<c03ae46e>] tcp_sendmsg+0x8da/0x9c8
 [<c015cba0>] core_sys_select+0x2a4/0x2c5
 [<c0389f5c>] sock_aio_write+0xc8/0xd4
 [<c0152461>] do_sync_write+0xc7/0x10a
 [<c0129881>] autoremove_wake_function+0x0/0x35
 [<c015cfc9>] sys_select+0xd6/0x187
 [<c0153131>] sys_write+0x41/0x67
 [<c01030e0>] syscall_call+0x7/0xb
 =======================

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
