Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6UKFECl001251
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 16:15:14 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6ULJdga426044
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 17:19:39 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6ULJcI8021370
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 17:19:38 -0400
Date: Mon, 30 Jul 2007 14:19:37 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 00/14] NUMA: Memoryless node support V4
Message-ID: <20070730211937.GD5668@us.ibm.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On 27.07.2007 [15:43:16 -0400], Lee Schermerhorn wrote:
> Changes V3->V4:
> - Refresh against 23-rc1-mm1
> - teach cpusets about memoryless nodes.
> 
> Changes V2->V3:
> - Refresh patches (sigh)
> - Add comments suggested by Kamezawa Hiroyuki
> - Add signoff by Jes Sorensen
> 
> Changes V1->V2:
> - Add a generic layer that allows the definition of additional node bitmaps
> 
> This patchset is implementing additional node bitmaps that allow the system
> to track nodes that are online without memory and nodes that have processors.

Ok, submitted a bunch of jobs to just touch test this stack. Found two
issues:

On moe, a NUMA-Q box (part of test.kernel.org), I didn't see the same
panic that Andy reported, instead I got:

------------[ cut here ]------------
kernel BUG at mm/slub.c:1895!
invalid opcode: 0000 [#1]
SMP 
Modules linked in:
CPU:    0
EIP:    0060:[<c105d0a8>]    Not tainted VLI
EFLAGS: 00010046   (2.6.23-rc1-mm1-autokern1 #1)
EIP is at early_kmem_cache_node_alloc+0x2b/0x8d
eax: 00000000   ebx: 00000001   ecx: d38014e4   edx: c12c3a60
esi: 00000000   edi: 00000001   ebp: 000000d0   esp: c1343f3c
ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
Process swapper (pid: 0, ti=c1342000 task=c12c3a60 task.ti=c1342000)
Stack: 00000001 c133c3e0 00000000 c105d20c 00000000 c133c3e0 00000000 000000d0 
       c105d5e7 00000003 c1343fa4 000000d0 00010e56 c1343fa4 c1276826 00000003 
       00000055 c127b3c1 00000000 000000d0 c133c3e0 0000001c c105d86e 0000001c 
Call Trace:
 [<c105d20c>] init_kmem_cache_nodes+0x8f/0xdd
 [<c105d5e7>] kmem_cache_open+0x86/0xdd
 [<c105d86e>] create_kmalloc_cache+0x51/0xa7
 [<c135a483>] kmem_cache_init+0x50/0x16e
 [<c101b72a>] printk+0x16/0x19
 [<c1355855>] test_wp_bit+0x7e/0x81
 [<c1348966>] start_kernel+0x19f/0x21c
 [<c13483d8>] unknown_bootoption+0x0/0x139
 =======================
Code: 83 3d e4 c3 33 c1 1b 57 89 d7 56 53 77 04 0f 0b eb fe 0d 00 12 04 00 89 d1 89 c2 b8 e0 c3 33 c1 e8 99 f5 ff ff 85 c0 89 c6 75 04 <0f> 0b eb fe 8b 58 14 85 db 75 04 0f 0b eb fe a1 ec c3 33 c1 b9 
EIP: [<c105d0a8>] early_kmem_cache_node_alloc+0x2b/0x8d SS:ESP 0068:c1343f3c
Kernel panic - not syncing: Attempted to kill the idle task!

Then, on a !NUMA ppc64 box, I got:

lloc_bootmem_core(): zero-sized request
------------[ cut here ]------------
kernel BUG at mm/bootmem.c:190!
cpu 0x0: Vector: 700 (Program Check) at [c000000000833910]
    pc: c0000000006b4644: .__alloc_bootmem_core+0x58/0x410
    lr: c0000000006b4640: .__alloc_bootmem_core+0x54/0x410
    sp: c000000000833b90
   msr: 8000000000029032
  current = 0xc0000000007276a0
  paca    = 0xc000000000728000
    pid   = 0, comm = swapper
kernel BUG at mm/bootmem.c:190!
enter ? for help
[c000000000833c50] c0000000006b4b14 .__alloc_bootmem_nopanic+0x40/0xac
[c000000000833cf0] c0000000006b4ba0 .__alloc_bootmem+0x20/0x5c
[c000000000833d70] c0000000006b56e0 .alloc_large_system_hash+0x120/0x2bc
[c000000000833e50] c0000000006b6b14 .vfs_caches_init_early+0x54/0xb4
[c000000000833ee0] c000000000694cc4 .start_kernel+0x2e8/0x3f4
[c000000000833f90] c000000000008534 .start_here_common+0x60/0x12c

I'm going to verify if the latter, at least, happens with plain
2.6.23-rc1-mm1, but wanted to get these reports out there.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
