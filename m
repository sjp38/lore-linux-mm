Date: Mon, 30 Jul 2007 15:06:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/14] NUMA: Memoryless node support V4
In-Reply-To: <20070730211937.GD5668@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0707301503560.21604@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070730211937.GD5668@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007, Nishanth Aravamudan wrote:

> On moe, a NUMA-Q box (part of test.kernel.org), I didn't see the same
> panic that Andy reported, instead I got:
> 
> ------------[ cut here ]------------
> kernel BUG at mm/slub.c:1895!
> invalid opcode: 0000 [#1]
> SMP 
> Modules linked in:
> CPU:    0
> EIP:    0060:[<c105d0a8>]    Not tainted VLI
> EFLAGS: 00010046   (2.6.23-rc1-mm1-autokern1 #1)
> EIP is at early_kmem_cache_node_alloc+0x2b/0x8d
> eax: 00000000   ebx: 00000001   ecx: d38014e4   edx: c12c3a60
> esi: 00000000   edi: 00000001   ebp: 000000d0   esp: c1343f3c
> ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
> Process swapper (pid: 0, ti=c1342000 task=c12c3a60 task.ti=c1342000)
> Stack: 00000001 c133c3e0 00000000 c105d20c 00000000 c133c3e0 00000000 000000d0 
>        c105d5e7 00000003 c1343fa4 000000d0 00010e56 c1343fa4 c1276826 00000003 
>        00000055 c127b3c1 00000000 000000d0 c133c3e0 0000001c c105d86e 0000001c 
> Call Trace:
>  [<c105d20c>] init_kmem_cache_nodes+0x8f/0xdd
>  [<c105d5e7>] kmem_cache_open+0x86/0xdd
>  [<c105d86e>] create_kmalloc_cache+0x51/0xa7
>  [<c135a483>] kmem_cache_init+0x50/0x16e
>  [<c101b72a>] printk+0x16/0x19
>  [<c1355855>] test_wp_bit+0x7e/0x81
>  [<c1348966>] start_kernel+0x19f/0x21c
>  [<c13483d8>] unknown_bootoption+0x0/0x139
>  =======================
> Code: 83 3d e4 c3 33 c1 1b 57 89 d7 56 53 77 04 0f 0b eb fe 0d 00 12 04 00 89 d1 89 c2 b8 e0 c3 33 c1 e8 99 f5 ff ff 85 c0 89 c6 75 04 <0f> 0b eb fe 8b 58 14 85 db 75 04 0f 0b eb fe a1 ec c3 33 c1 b9 
> EIP: [<c105d0a8>] early_kmem_cache_node_alloc+0x2b/0x8d SS:ESP 0068:c1343f3c
> Kernel panic - not syncing: Attempted to kill the idle task!

Hmmm... yes trouble with NUMAQ is that the nodes only have HIGHMEM 
but no NORMAL memory. The memory is not available to the slab allocator 
(needs ZONE_NORMAL memory) and we cannot fall back anymore. We may need 
something like N_SLAB that defines the allowed nodes for the slab 
allocators. Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
