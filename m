Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A1F876B0093
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 03:48:43 -0400 (EDT)
Date: Mon, 31 Aug 2009 16:48:43 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: page allocator regression on nommu
Message-ID: <20090831074842.GA28091@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Mel,

It seems we've managed to trigger a fairly interesting conflict between
the anti-fragmentation disabling code and the nommu region rbtree. I've
bisected it down to:

commit 49255c619fbd482d704289b5eb2795f8e3b7ff2e
Author: Mel Gorman <mel@csn.ul.ie>
Date:   Tue Jun 16 15:31:58 2009 -0700

    page allocator: move check for disabled anti-fragmentation out of fastpath

    On low-memory systems, anti-fragmentation gets disabled as there is
    nothing it can do and it would just incur overhead shuffling pages between
    lists constantly.  Currently the check is made in the free page fast path
    for every page.  This patch moves it to a slow path.  On machines with low
    memory, there will be small amount of additional overhead as pages get
    shuffled between lists but it should quickly settle.

which causes death on unpacking initramfs on my nommu board. With this
reverted, everything works as expected. Note that this blows up with all of
SLOB/SLUB/SLAB.

I'll continue debugging it, and can post my .config if it will be helpful, but
hopefully you have some suggestions on what to try :-)

---

modprobe: page allocation failure. order:7, mode:0xd0
Stack: (0x0c909d2c to 0x0c90a000)
9d20:                            0c0387d2 00000000 00000000 0c107fcc 00000000
9d40: 00000000 0c107fcc 0c2f8960 00000000 00000010 00000000 00000000 000200d0
9d60: 00000000 0c041614 0c9f8cf4 00000000 0c9f8d1c 00000000 00000004 00000000
9d80: 00000007 0c01a582 0c2f8cd0 00000000 00000000 00049000 00000049 00048fff
9da0: 00049fff 00049000 00000007 0c06633a 00000001 0c909f30 0003e950 0c0bad00
9dc0: 0000984a 0c2f8ea0 ffffe000 00000002 00000000 0c065314 0c2f8ea0 0c077f60
9de0: 00049000 0000673c 00000050 000369a0 000019cf 00000004 00004e20 0003e950
9e00: 000481aa 00000001 00004eaa 000049a0 00007fb0 000369a0 00000000 00000000
9e20: 0c909e50 00000000 00000000 0c066790 00000000 0c909f30 00000000 00000000
9e40: 0c2f8ea0 0c909f30 0c909e50 00004eaa 00000000 00000000 00000000 00000000
9e60: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9e80: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9ea0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9ec0: 0c0482ee 00000000 fffffff8 0c2f8ea0 0c104ff8 0c04884e 0c0feb64 00000001
9ee0: 0c048570 ffffe000 0c2f8ea0 00000000 00000000 0c813eb8 0c909f30 0c002e68
9f00: 00000000 00000000 00000000 0c0feb64 0c813eb8 0c909f30 0c960000 0c007972
9f20: ffffff0f 00000071 00000100 0c002e38 0000000b ffffff0f 00000001 0000000b
9f40: 0c0fea64 0c813eb8 0c0feb64 0c2f898c 00000000 ffffe000 0c9f8990 00000000
9f60: 00000000 00000000 00000000 0c909f8c 0c0050ca 0c01e874 40000001 00000000
9f80: 00000000 4795ce40 0000004c 0c002cca 00000000 00000000 00000000 00000000
9fa0: 00000000 00000000 00000000 00000000 00000000 0c9f8990 0c01e7a4 00000000
9fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9fe0: 0c909f9c 0c002cc4 00000000 40000000 00000000 00000000 00000000 00000000

Call trace:
 [<0c041614>] do_mmap_pgoff+0x638/0xa68
 [<0c01a582>] flush_itimer_signals+0x36/0x60
 [<0c06633a>] load_flat_file+0x32a/0x738
 [<0c0bad00>] down_write+0x0/0xc
 [<0c065314>] load_elf_fdpic_binary+0x44/0xa8c
 [<0c077f60>] memset+0x0/0x60
 [<0c066790>] load_flat_binary+0x48/0x2fc
 [<0c0482ee>] search_binary_handler+0x4a/0x1fc
 [<0c04884e>] do_execve+0x156/0x2bc
 [<0c048570>] copy_strings+0x0/0x150
 [<0c002e68>] sys_execve+0x30/0x5c
 [<0c007972>] syscall_call+0xc/0x10
 [<0c002e38>] sys_execve+0x0/0x5c
 [<0c0050ca>] kernel_execve+0x6/0xc
 [<0c01e874>] ____call_usermodehelper+0xd0/0xfc
 [<0c002cca>] kernel_thread_helper+0x6/0x10
 [<0c01e7a4>] ____call_usermodehelper+0x0/0xfc
 [<0c002cc4>] kernel_thread_helper+0x0/0x10

Mem-Info:
Normal per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Active_anon:0 active_file:0 inactive_anon:0
 inactive_file:0 unevictable:323 dirty:0 writeback:0 unstable:0
 free:2967 slab:0 mapped:0 pagetables:0 bounce:0
Normal free:11868kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:1292kB present:16256kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0
Normal: 267*4kB 268*8kB 251*16kB 145*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB = 11868kB
323 total pagecache pages
------------[ cut here ]------------
kernel BUG at mm/nommu.c:598!
Kernel BUG: 003e [#1]
Modules linked in:

Pid : 51, Comm:                 modprobe
CPU : 0                 Not tainted  (2.6.31-rc7 #2835)

PC is at __put_nommu_region+0xe/0xb0
PR is at do_mmap_pgoff+0x8dc/0xa68
PC  : 0c040e7a SP  : 0c909d7c SR  : 40000001
R0  : 0000001d R1  : 00000000 R2  : 00000000 R3  : 0000000d
R4  : 0c9f8cf4 R5  : 000017de R6  : ffffffff R7  : 00000035
R8  : 0c9f8cf4 R9  : 00000000 R10 : 00000000 R11 : fffffff4
R12 : 0c9f8d1c R13 : 00000000 R14 : 0c9f8cf4
MACH: 0000017e MACL: baf11680 GBR : 00000000 PR  : 0c0418b8

Call trace:
 [<0c0418b8>] do_mmap_pgoff+0x8dc/0xa68
 [<0c01a582>] flush_itimer_signals+0x36/0x60
 [<0c06633a>] load_flat_file+0x32a/0x738
 [<0c0bad00>] down_write+0x0/0xc
 [<0c065314>] load_elf_fdpic_binary+0x44/0xa8c
 [<0c077f60>] memset+0x0/0x60
 [<0c066790>] load_flat_binary+0x48/0x2fc
 [<0c0482ee>] search_binary_handler+0x4a/0x1fc
 [<0c04884e>] do_execve+0x156/0x2bc
 [<0c048570>] copy_strings+0x0/0x150
 [<0c002e68>] sys_execve+0x30/0x5c
 [<0c007972>] syscall_call+0xc/0x10
 [<0c002e38>] sys_execve+0x0/0x5c
 [<0c0050ca>] kernel_execve+0x6/0xc
 [<0c01e874>] ____call_usermodehelper+0xd0/0xfc
 [<0c002cca>] kernel_thread_helper+0x6/0x10
 [<0c01e7a4>] ____call_usermodehelper+0x0/0xfc
 [<0c002cc4>] kernel_thread_helper+0x0/0x10

Code:
  0c040e74:  tst       r1, r1
  0c040e76:  bf.s      0c040e7c
  0c040e78:  mov       r4, r8
->0c040e7a:  trapa     #62
  0c040e7c:  stc       sr, r1
  0c040e7e:  mov       r1, r0
  0c040e80:  or        #-16, r0
  0c040e82:  ldc       r0, sr
  0c040e84:  mov       r1, r0

Process: modprobe (pid: 51, stack limit = 0c908001)
Stack: (0x0c909d7c to 0x0c90a000)
9d60:                                                                0c0418b8
9d80: 00000007 0c01a582 0c2f8cd0 00000000 00000000 00049000 00000049 00048fff
9da0: 00049fff 00049000 00000007 0c06633a 00000001 0c909f30 0003e950 0c0bad00
9dc0: 0000984a 0c2f8ea0 ffffe000 00000002 00000000 0c065314 0c2f8ea0 0c077f60
9de0: 00049000 0000673c 00000050 000369a0 000019cf 00000004 00004e20 0003e950
9e00: 000481aa 00000001 00004eaa 000049a0 00007fb0 000369a0 00000000 00000000
9e20: 0c909e50 00000000 00000000 0c066790 00000000 0c909f30 00000000 00000000
9e40: 0c2f8ea0 0c909f30 0c909e50 00004eaa 00000000 00000000 00000000 00000000
9e60: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9e80: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9ea0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9ec0: 0c0482ee 00000000 fffffff8 0c2f8ea0 0c104ff8 0c04884e 0c0feb64 00000001
9ee0: 0c048570 ffffe000 0c2f8ea0 00000000 00000000 0c813eb8 0c909f30 0c002e68
9f00: 00000000 00000000 00000000 0c0feb64 0c813eb8 0c909f30 0c960000 0c007972
9f20: ffffff0f 00000071 00000100 0c002e38 0000000b ffffff0f 00000001 0000000b
9f40: 0c0fea64 0c813eb8 0c0feb64 0c2f898c 00000000 ffffe000 0c9f8990 00000000
9f60: 00000000 00000000 00000000 0c909f8c 0c0050ca 0c01e874 40000001 00000000
9f80: 00000000 4795ce40 0000004c 0c002cca 00000000 00000000 00000000 00000000
9fa0: 00000000 00000000 00000000 00000000 00000000 0c9f8990 0c01e7a4 00000000
9fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9fe0: 0c909f9c 0c002cc4 00000000 40000000 00000000 00000000 00000000 00000000
---[ end trace 139ce121c98e96c9 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
