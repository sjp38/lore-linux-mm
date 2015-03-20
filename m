Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1B46B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 11:08:53 -0400 (EDT)
Received: by ykcn8 with SMTP id n8so43636572ykc.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 08:08:53 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d27si2268289yho.12.2015.03.20.08.07.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 08:08:26 -0700 (PDT)
Message-ID: <550C37C9.2060200@oracle.com>
Date: Fri, 20 Mar 2015 09:07:53 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: 4.0.0-rc4: panic in free_block
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

I can easily reproduce the panic below doing a kernel build with make -j 
N, N=128, 256, etc. This is a 1024 cpu system running 4.0.0-rc4.

The top 3 frames are consistently:
     free_block+0x60
     cache_flusharray+0xac
     kmem_cache_free+0xfc

After that one path has been from __mmdrop and the others are like 
below, from remove_vma.

Unable to handle kernel paging request at virtual address 0006100000000000
tsk->{mm,active_mm}->context = 00000000000000ce
tsk->{mm,active_mm}->pgd = fff8803b56698000
               \|/ ____ \|/
               "@'/ .. \`@"
               /_| \__/ |_\
                  \__U_/
sh(173167): Oops [#1]
CPU: 760 PID: 173167 Comm: sh Not tainted 4.0.0-rc4+ #1
task: fff8803b4e928b00 ti: fff8803b51800000 task.ti: fff8803b51800000
TSTATE: 0000009911e01601 TPC: 000000000055de88 TNPC: 000000000055de8c Y: 
000003f0    Not tainted
TPC: <free_block+0x60/0x16c>
g0: fff1ffef00000001 g1: fff8803b75826e00 g2: 0000000000100100 g3: 
0000100000000000
g4: fff8803b4e928b00 g5: fff8803b76664000 g6: fff8803b51800000 g7: 
0006000000000000
o0: 0000000000008000 o1: 0000000000000046 o2: 0000000000000023 o3: 
00060100767db6a0
o4: 0000000000000000 o5: 0000000000000015 sp: fff8803b51802d11 ret_pc: 
fff8803b75826e08
RPC: <0xfff8803b75826e08>
l0: 0000000000200200 l1: 0000000000c005e8 l2: 0000000000d7e2b8 l3: 
fff8803b3edb4000
l4: 0000000000000007 l5: 0000000000000001 l6: 00000000000000b1 l7: 
ffffffffffefffff
i0: fff8000050409c60 i1: fff8803b7738f168 i2: 000000000000003c i3: 
fff8803b75826e28
i4: fff8803b51803670 i5: 0000000000000000 i6: fff8803b51802dc1 i7: 
000000000055eaa4
I7: <cache_flusharray+0xac/0xf4>
Call Trace:
  [000000000055eaa4] cache_flusharray+0xac/0xf4
  [000000000055e66c] kmem_cache_free+0xfc/0x1ac
  [000000000054139c] remove_vma+0x68/0x78
  [00000000005414ac] exit_mmap+0x100/0x130
  [000000000045acb4] mmput+0x50/0xe8
  [000000000056c284] flush_old_exec+0x500/0x5d8
  [00000000005b0614] load_elf_binary+0x254/0xff4
  [000000000056ba70] search_binary_handler+0xa4/0x28c
  [000000000056d068] do_execveat_common+0x44c/0x624
  [000000000056d3e0] do_execve+0x34/0x48
  [000000000056d40c] SyS_execve+0x18/0x2c
  [0000000000406254] linux_sparc_syscall+0x34/0x44
Disabling lock debugging due to kernel taint
Caller[000000000055eaa4]: cache_flusharray+0xac/0xf4
Caller[000000000055e66c]: kmem_cache_free+0xfc/0x1ac
Caller[000000000054139c]: remove_vma+0x68/0x78
Caller[00000000005414ac]: exit_mmap+0x100/0x130
Caller[000000000045acb4]: mmput+0x50/0xe8
Caller[000000000056c284]: flush_old_exec+0x500/0x5d8
Caller[00000000005b0614]: load_elf_binary+0x254/0xff4
Caller[000000000056ba70]: search_binary_handler+0xa4/0x28c
Caller[000000000056d068]: do_execveat_common+0x44c/0x624
Caller[000000000056d3e0]: do_execve+0x34/0x48
Caller[000000000056d40c]: SyS_execve+0x18/0x2c
Caller[0000000000406254]: linux_sparc_syscall+0x34/0x44
Caller[fff80001004134c8]: 0xfff80001004134c8
Instruction DUMP: 86230003  8730f00d  8728f006 <d658c007> 8600c007 
8e0ac008  2ac1c002  c658e030  d458e028

####

objdump for free_block on the vmlinux:

vmlinux-4.0.0-rc4+:     file format elf64-sparc


Disassembly of section .text:

000000000055de28 <free_block>:
free_block():
...
free_block():
/opt/dahern/linux.git/kbuild/../mm/slab.c:3265
   55de64:       10 68 00 47     b  %xcc, 55df80 <free_block+0x158>
   55de68:       85 30 b0 02     srlx  %g2, 2, %g2
clear_obj_pfmemalloc():
/opt/dahern/linux.git/kbuild/../mm/slab.c:224
   55de6c:       98 0b 3f fe     and  %o4, -2, %o4
   55de70:       d8 76 40 00     stx  %o4, [ %i1 ]
virt_to_head_page():
/opt/dahern/linux.git/kbuild/../include/linux/mm.h:554
   55de74:       c6 5c 80 00     ldx  [ %l2 ], %g3
   55de78:       ce 5c 40 00     ldx  [ %l1 ], %g7
   55de7c:       86 23 00 03     sub  %o4, %g3, %g3
   55de80:       87 30 f0 0d     srlx  %g3, 0xd, %g3
   55de84:       87 28 f0 06     sllx  %g3, 6, %g3
test_bit():
/opt/dahern/linux.git/kbuild/../include/asm-generic/bitops/non-atomic.h:105
   55de88:       d6 58 c0 07     ldx  [ %g3 + %g7 ], %o3
virt_to_head_page():
/opt/dahern/linux.git/kbuild/../include/linux/mm.h:554
   55de8c:       86 00 c0 07     add  %g3, %g7, %g3
...

Let me know if you need anything else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
