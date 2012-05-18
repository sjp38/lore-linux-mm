Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 98FA66B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 14:58:56 -0400 (EDT)
Date: Fri, 18 May 2012 14:58:51 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.4-rc7 numa_policy slab poison.
Message-ID: <20120518185851.GA5728@redhat.com>
References: <20120517213120.GA12329@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120517213120.GA12329@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

On Thu, May 17, 2012 at 05:31:20PM -0400, Dave Jones wrote:

 > =============================================================================
 > BUG numa_policy (Not tainted): Poison overwritten
 > -----------------------------------------------------------------------------
 > 
 > INFO: 0xffff880146498250-0xffff880146498250. First byte 0x6a instead of 0x6b
 > INFO: Allocated in mpol_new+0xa3/0x140 age=46310 cpu=6 pid=32154
 > 	__slab_alloc+0x3d3/0x445
 > 	kmem_cache_alloc+0x29d/0x2b0
 > 	mpol_new+0xa3/0x140
 > 	sys_mbind+0x142/0x620
 > 	system_call_fastpath+0x16/0x1b
 > INFO: Freed in __mpol_put+0x27/0x30 age=46268 cpu=6 pid=32154
 > 	__slab_free+0x2e/0x1de
 > 	kmem_cache_free+0x25a/0x260
 > 	__mpol_put+0x27/0x30
 > 	remove_vma+0x68/0x90
 > 	exit_mmap+0x118/0x140
 > 	mmput+0x73/0x110
 > 	exit_mm+0x108/0x130
 > 	do_exit+0x162/0xb90
 > 	do_group_exit+0x4f/0xc0
 > 	sys_exit_group+0x17/0x20
 > 	system_call_fastpath+0x16/0x1b
 > INFO: Slab 0xffffea0005192600 objects=27 used=27 fp=0x          (null) flags=0x20000000004080
 > INFO: Object 0xffff880146498250 @offset=592 fp=0xffff88014649b9d0

As I can reproduce this fairly easily, I enabled the dynamic debug prints for mempolicy.c,
and noticed something odd (but different to the above trace..)

INFO: 0xffff88014649abf0-0xffff88014649abf0. First byte 0x6a instead of 0x6b
INFO: Allocated in mpol_new+0xa3/0x140 age=196087 cpu=7 pid=11496
 __slab_alloc+0x3d3/0x445
 kmem_cache_alloc+0x29d/0x2b0
 mpol_new+0xa3/0x140
 sys_mbind+0x142/0x620
 system_call_fastpath+0x16/0x1b
INFO: Freed in __mpol_put+0x27/0x30 age=40838 cpu=7 pid=20824
 __slab_free+0x2e/0x1de
 kmem_cache_free+0x25a/0x260
 __mpol_put+0x27/0x30
 mpol_set_shared_policy+0xe6/0x280
 shmem_set_policy+0x2a/0x30
 shm_set_policy+0x28/0x30
 sys_mbind+0x4e7/0x620
 system_call_fastpath+0x16/0x1b
INFO: Slab 0xffffea0005192600 objects=27 used=27 fp=0x          (null) flags=0x20000000004080
INFO: Object 0xffff88014649abf0 @offset=11248 fp=0xffff880146498de0

In this case, it seems the policy was allocated by pid 11496, and freed by a different pid!
How is that possible ?  (Does kind of explain why it looks like a double-free though I guess).

debug printout for the relevant pids below, in case it yields further clues..

	Dave


[  599.486348] [11496] setting mode 1 flags 0 nodes[0] 11ff
[  599.486360] [11496] mbind 7f3eae3c7000-7f3eae447000 mode:1 flags:0 nodes:11ff
[  599.486380] [11496] vma 7f3eae3c7000-7f3eae3c8000/0 vm_ops           (null) vm_file ffff88014233f640 set_policy           (null)
[  599.486384] [11496] vma 7f3eae3c8000-7f3eae3c9000/0 vm_ops           (null) vm_file ffff8801423cc200 set_policy           (null)
[  599.486389] [11496] vma 7f3eae3c9000-7f3eae3ca000/0 vm_ops           (null) vm_file ffff8801423cf380 set_policy           (null)
[  599.486393] [11496] vma 7f3eae3ca000-7f3eae3cb000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486398] [11496] vma 7f3eae3cb000-7f3eae3cc000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486402] [11496] vma 7f3eae3cc000-7f3eae3cd000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486406] [11496] vma 7f3eae3cd000-7f3eae3ce000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486411] [11496] vma 7f3eae3ce000-7f3eae3cf000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486416] [11496] vma 7f3eae3cf000-7f3eae3d0000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486418] [11496] vma 7f3eae3d0000-7f3eae3d1000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486421] [11496] vma 7f3eae3d1000-7f3eae3d2000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486424] [11496] vma 7f3eae3d2000-7f3eae3d3000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486427] [11496] vma 7f3eae3d3000-7f3eae3d4000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486430] [11496] vma 7f3eae3d4000-7f3eae3d5000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486432] [11496] vma 7f3eae3d5000-7f3eae3d6000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486435] [11496] vma 7f3eae3d6000-7f3eae3d7000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486438] [11496] vma 7f3eae3d7000-7f3eae3d8000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486441] [11496] vma 7f3eae3d8000-7f3eae3d9000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486443] [11496] vma 7f3eae3d9000-7f3eae3da000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486446] [11496] vma 7f3eae3da000-7f3eae3db000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486449] [11496] vma 7f3eae3db000-7f3eae3dc000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486452] [11496] vma 7f3eae3dc000-7f3eae3dd000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486455] [11496] vma 7f3eae3dd000-7f3eae3de000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486457] [11496] vma 7f3eae3de000-7f3eae3df000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486460] [11496] vma 7f3eae3df000-7f3eae3e0000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486463] [11496] vma 7f3eae3e0000-7f3eae3e1000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486465] [11496] vma 7f3eae3e1000-7f3eae3e2000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486468] [11496] vma 7f3eae3e2000-7f3eae3e3000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486471] [11496] vma 7f3eae3e3000-7f3eae3e4000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486474] [11496] vma 7f3eae3e4000-7f3eae3e5000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486477] [11496] vma 7f3eae3e5000-7f3eae3e6000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486479] [11496] vma 7f3eae3e6000-7f3eae3e7000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486482] [11496] vma 7f3eae3e7000-7f3eae3e8000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486485] [11496] vma 7f3eae3e8000-7f3eae3e9000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486488] [11496] vma 7f3eae3e9000-7f3eae3ea000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486491] [11496] vma 7f3eae3ea000-7f3eae3eb000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486494] [11496] vma 7f3eae3eb000-7f3eae3ec000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486497] [11496] vma 7f3eae3ec000-7f3eae3ed000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486500] [11496] vma 7f3eae3ed000-7f3eae3ee000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486502] [11496] vma 7f3eae3ee000-7f3eae3ef000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486505] [11496] vma 7f3eae3ef000-7f3eae3f0000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486508] [11496] vma 7f3eae3f0000-7f3eae3f1000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486511] [11496] vma 7f3eae3f1000-7f3eae3f2000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486513] [11496] vma 7f3eae3f2000-7f3eae3f3000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486516] [11496] vma 7f3eae3f3000-7f3eae3f4000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486519] [11496] vma 7f3eae3f4000-7f3eae3f5000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486522] [11496] vma 7f3eae3f5000-7f3eae3f6000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486525] [11496] vma 7f3eae3f6000-7f3eae3f7000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486527] [11496] vma 7f3eae3f7000-7f3eae3fa000/7f3eae3f7 vm_ops           (null) vm_file           (null) set_policy           (null)
[  599.486530] [11496] vma 7f3eae3fa000-7f3eae3fb000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486533] [11496] vma 7f3eae3fb000-7f3eae3fc000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486536] [11496] vma 7f3eae3fc000-7f3eae3fd000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486540] [11496] vma 7f3eae3fd000-7f3eae3fe000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486545] [11496] vma 7f3eae3fe000-7f3eae3ff000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  599.486550] [11496] vma 7f3eae3ff000-7f3eae401000/0 vm_ops ffffffff81835ae0 vm_file ffff880141c86040 set_policy ffffffff812a0570
[  599.486554] [11496] set_shared_policy 0 sz 2 1 0 6b6b6b6b6b6b0000
[  599.486568] [11496] inserting 0-2: 1
[  599.486572] [11496] vma 7f3eae401000-7f3eae403000/7f3eae401 vm_ops           (null) vm_file           (null) set_policy           (null)

...

[  754.449821] [20824] setting mode 3 flags 0 nodes[0] 1
[  754.449834] [20824] mbind 7f3eae3c7000-7f3fae3c7000 mode:3 flags:0 nodes:1
[  754.449853] [20824] vma 7f3eae3c7000-7f3eae3c8000/0 vm_ops           (null) vm_file ffff88014233f640 set_policy           (null)
[  754.449858] [20824] vma 7f3eae3c8000-7f3eae3c9000/0 vm_ops           (null) vm_file ffff8801423cc200 set_policy           (null)
[  754.449862] [20824] vma 7f3eae3c9000-7f3eae3ca000/0 vm_ops           (null) vm_file ffff8801423cf380 set_policy           (null)
[  754.449867] [20824] vma 7f3eae3ca000-7f3eae3cb000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449872] [20824] vma 7f3eae3cb000-7f3eae3cc000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449877] [20824] vma 7f3eae3cc000-7f3eae3cd000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449881] [20824] vma 7f3eae3cd000-7f3eae3ce000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449885] [20824] vma 7f3eae3ce000-7f3eae3cf000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449890] [20824] vma 7f3eae3cf000-7f3eae3d0000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449895] [20824] vma 7f3eae3d0000-7f3eae3d1000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449899] [20824] vma 7f3eae3d1000-7f3eae3d2000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449903] [20824] vma 7f3eae3d2000-7f3eae3d3000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449908] [20824] vma 7f3eae3d3000-7f3eae3d4000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449912] [20824] vma 7f3eae3d4000-7f3eae3d5000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449917] [20824] vma 7f3eae3d5000-7f3eae3d6000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449921] [20824] vma 7f3eae3d6000-7f3eae3d7000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449926] [20824] vma 7f3eae3d7000-7f3eae3d8000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449930] [20824] vma 7f3eae3d8000-7f3eae3d9000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449935] [20824] vma 7f3eae3d9000-7f3eae3da000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449939] [20824] vma 7f3eae3da000-7f3eae3db000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449943] [20824] vma 7f3eae3db000-7f3eae3dc000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449948] [20824] vma 7f3eae3dc000-7f3eae3dd000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449952] [20824] vma 7f3eae3dd000-7f3eae3de000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449957] [20824] vma 7f3eae3de000-7f3eae3df000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449962] [20824] vma 7f3eae3df000-7f3eae3e0000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449966] [20824] vma 7f3eae3e0000-7f3eae3e1000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449970] [20824] vma 7f3eae3e1000-7f3eae3e2000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449975] [20824] vma 7f3eae3e2000-7f3eae3e3000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449979] [20824] vma 7f3eae3e3000-7f3eae3e4000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449984] [20824] vma 7f3eae3e4000-7f3eae3e5000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449988] [20824] vma 7f3eae3e5000-7f3eae3e6000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449993] [20824] vma 7f3eae3e6000-7f3eae3e7000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.449998] [20824] vma 7f3eae3e7000-7f3eae3e8000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450002] [20824] vma 7f3eae3e8000-7f3eae3e9000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450007] [20824] vma 7f3eae3e9000-7f3eae3ea000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450011] [20824] vma 7f3eae3ea000-7f3eae3eb000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450016] [20824] vma 7f3eae3eb000-7f3eae3ec000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450020] [20824] vma 7f3eae3ec000-7f3eae3ed000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450024] [20824] vma 7f3eae3ed000-7f3eae3ee000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450029] [20824] vma 7f3eae3ee000-7f3eae3ef000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450034] [20824] vma 7f3eae3ef000-7f3eae3f0000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450038] [20824] vma 7f3eae3f0000-7f3eae3f1000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450043] [20824] vma 7f3eae3f1000-7f3eae3f2000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450047] [20824] vma 7f3eae3f2000-7f3eae3f3000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450052] [20824] vma 7f3eae3f3000-7f3eae3f4000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450057] [20824] vma 7f3eae3f4000-7f3eae3f5000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450061] [20824] vma 7f3eae3f5000-7f3eae3f6000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450066] [20824] vma 7f3eae3f6000-7f3eae3f7000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450070] [20824] vma 7f3eae3f7000-7f3eae3fa000/7f3eae3f7 vm_ops           (null) vm_file           (null) set_policy           (null)
[  754.450075] [20824] vma 7f3eae3fa000-7f3eae3fb000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450079] [20824] vma 7f3eae3fb000-7f3eae3fc000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450084] [20824] vma 7f3eae3fc000-7f3eae3fd000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450088] [20824] vma 7f3eae3fd000-7f3eae3fe000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450093] [20824] vma 7f3eae3fe000-7f3eae3ff000/0 vm_ops           (null) vm_file ffff880141e76e00 set_policy           (null)
[  754.450098] [20824] vma 7f3eae3ff000-7f3eae401000/0 vm_ops ffffffff81835ae0 vm_file ffff880141c86040 set_policy ffffffff812a0570
[  754.450102] [20824] set_shared_policy 0 sz 2 3 0 1
[  754.450115] [20824] deleting 0-l2
[  754.450133] [20824] inserting 0-2: 3
[  754.450137] [20824] vma 7f3eae401000-7f3eae403000/7f3eae401 vm_ops           (null) vm_file           (null) set_policy           (null)

[  754.595861] ------------[ cut here ]------------
[  754.595992] kernel BUG at mm/mempolicy.c:1564!
[  754.596019] invalid opcode: 0000 [#1] PREEMPT SMP 
[  754.596057] CPU 1 
[  754.596069] Modules linked in: dccp_ipv6 sctp libcrc32c ip_queue ipt_ULOG ip6_queue binfmt_misc dccp_ipv4 dccp nfnetlink caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose ax25 x25 atm appletalk ipx p8022 psnap llc p8023 lockd ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables crc32c_intel ghash_clmulni_intel microcode serio_raw pcspkr i2c_i801 usb_debug iTCO_wdt iTCO_vendor_support e1000e sunrpc i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  754.596516] 
[  754.596528] Pid: 1102, comm: trinity Not tainted 3.4.0-rc7+ #11 Intel Corporation 2012 Client Platform/Emerald Lake 2
[  754.596587] RIP: 0010:[<ffffffff8118176e>]  [<ffffffff8118176e>] policy_zonelist+0x1e/0xa0
[  754.596637] RSP: 0000:ffff88013c0f5878  EFLAGS: 00010206
[  754.596663] RAX: 0000000000006b6b RBX: 00000000000200da RCX: 0000000000000000
[  754.596699] RDX: 0000000000000000 RSI: ffff88013c0f59e0 RDI: 00000000000200da
[  754.596797] RBP: ffff88013c0f5888 R08: 0000000000000000 R09: 0000000000000000
[  754.596834] R10: 0000000000000001 R11: 0000000000000001 R12: ffff88013c0f59e0
[  754.596870] R13: ffff8801422a8000 R14: 0000000000000000 R15: 0000000000000000
[  754.596906] FS:  00007f883cd9f700(0000) GS:ffff880147e00000(0000) knlGS:0000000000000000
[  754.596947] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  754.596977] CR2: 00007f883cda6024 CR3: 000000013c200000 CR4: 00000000001407e0
[  754.597013] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  754.597050] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  754.597085] Process trinity (pid: 1102, threadinfo ffff88013c0f4000, task ffff8801422a8000)
[  754.597126] Stack:
[  754.597140]  ffff88013c0f5898 00000000000200da ffff88013c0f5908 ffffffff81184e64
[  754.597193]  00000000000aeed0 0000000000000000 ffff8801422a8000 ffff8801422a8000
[  754.597244]  ffff8801422a8000 0000000000000000 ffff88013c0f5ae8 0000000082301e50
[  754.597295] Call Trace:
[  754.597314]  [<ffffffff81184e64>] alloc_pages_vma+0x84/0x190
[  754.597347]  [<ffffffff811783eb>] read_swap_cache_async+0x13b/0x230
[  754.597382]  [<ffffffff81185a64>] ? mpol_shared_policy_lookup+0x64/0x80
[  754.597419]  [<ffffffff8117856e>] swapin_readahead+0x8e/0xd0
[  754.597451]  [<ffffffff81155c84>] shmem_swapin+0x74/0x90
[  754.597483]  [<ffffffff8113cc25>] ? find_get_page+0x105/0x260
[  754.597515]  [<ffffffff8163d7ad>] ? sub_preempt_count+0x9d/0xd0
[  754.597548]  [<ffffffff8113cc42>] ? find_get_page+0x122/0x260
[  754.597579]  [<ffffffff8113cb20>] ? find_get_pages_tag+0x330/0x330
[  754.597613]  [<ffffffff81157ea8>] shmem_getpage_gfp+0x3c8/0x620
[  754.597645]  [<ffffffff81158fdf>] shmem_fault+0x4f/0xa0
[  754.597675]  [<ffffffff812a056e>] shm_fault+0x1e/0x20
[  754.599119]  [<ffffffff81162f91>] __do_fault+0x71/0x510
[  754.600558]  [<ffffffff81165a64>] handle_pte_fault+0x84/0xa10
[  754.602013]  [<ffffffff8119c850>] ? mem_cgroup_count_vm_event+0xe0/0x1e0
[  754.603485]  [<ffffffff8163d7ad>] ? sub_preempt_count+0x9d/0xd0
[  754.604921]  [<ffffffff811666f2>] handle_mm_fault+0x1c2/0x2c0
[  754.606336]  [<ffffffff8163d002>] do_page_fault+0x152/0x570
[  754.607763]  [<ffffffff8104d75c>] ? do_wait+0x12c/0x370
[  754.609162]  [<ffffffff812fee7d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  754.610553]  [<ffffffff8163a1ef>] page_fault+0x1f/0x30
[  754.611914] Code: 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53 48 83 ec 08 66 66 66 66 90 0f b7 46 04 66 83 f8 01 74 08 66 83 f8 02 74 42 <0f> 0b 89 fb 81 e3 00 00 04 00 f6 46 06 02 75 04 0f bf 56 08 31 
[  754.615023] RIP  [<ffffffff8118176e>] policy_zonelist+0x1e/0xa0
[  754.616489]  RSP <ffff88013c0f5878>
[  754.619312] ---[ end trace 3b02e3f05b002502 ]---

[  795.194185] =============================================================================
[  795.195612] BUG numa_policy (Tainted: G      D     ): Poison overwritten
[  795.197091] -----------------------------------------------------------------------------
[  795.197093] 
[  795.200089] INFO: 0xffff88014649abf0-0xffff88014649abf0. First byte 0x6a instead of 0x6b
[  795.201584] INFO: Allocated in mpol_new+0xa3/0x140 age=196087 cpu=7 pid=11496
[  795.203129] 	__slab_alloc+0x3d3/0x445
[  795.204659] 	kmem_cache_alloc+0x29d/0x2b0
[  795.206238] 	mpol_new+0xa3/0x140
[  795.207699] 	sys_mbind+0x142/0x620
[  795.209174] 	system_call_fastpath+0x16/0x1b
[  795.210542] INFO: Freed in __mpol_put+0x27/0x30 age=40838 cpu=7 pid=20824
[  795.211950] 	__slab_free+0x2e/0x1de
[  795.213291] 	kmem_cache_free+0x25a/0x260
[  795.214595] 	__mpol_put+0x27/0x30
[  795.215939] 	mpol_set_shared_policy+0xe6/0x280
[  795.217218] 	shmem_set_policy+0x2a/0x30
[  795.218506] 	shm_set_policy+0x28/0x30
[  795.219801] 	sys_mbind+0x4e7/0x620
[  795.221094] 	system_call_fastpath+0x16/0x1b
[  795.222393] INFO: Slab 0xffffea0005192600 objects=27 used=27 fp=0x          (null) flags=0x20000000004080
[  795.223753] INFO: Object 0xffff88014649abf0 @offset=11248 fp=0xffff880146498de0
[  795.223754] 
[  795.226369] Bytes b4 ffff88014649abe0: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
[  795.227713] Object ffff88014649abf0: 6a 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  jkkkkkkkkkkkkkkk
[  795.229054] Object ffff88014649ac00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.230435] Object ffff88014649ac10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.231795] Object ffff88014649ac20: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.233085] Object ffff88014649ac30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.234405] Object ffff88014649ac40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.235752] Object ffff88014649ac50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.237015] Object ffff88014649ac60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.238288] Object ffff88014649ac70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.239546] Object ffff88014649ac80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.240793] Object ffff88014649ac90: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.242008] Object ffff88014649aca0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.243191] Object ffff88014649acb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.244375] Object ffff88014649acc0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.245549] Object ffff88014649acd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.246775] Object ffff88014649ace0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  795.247929] Object ffff88014649acf0: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
[  795.249095] Redzone ffff88014649acf8: bb bb bb bb bb bb bb bb                          ........
[  795.250265] Padding ffff88014649ae38: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
[  795.251446] Pid: 26939, comm: trinity Tainted: G      D      3.4.0-rc7+ #11
[  795.252619] Call Trace:
[  795.253785]  [<ffffffff8118cc5d>] ? print_section+0x3d/0x40
[  795.255054]  [<ffffffff8118d008>] print_trailer+0xe8/0x160
[  795.256203]  [<ffffffff8118d1b0>] check_bytes_and_report+0xe0/0x120
[  795.257488]  [<ffffffff8118df9a>] check_object+0x22a/0x270
[  795.258670]  [<ffffffff811821a3>] ? mpol_new+0xa3/0x140
[  795.259914]  [<ffffffff811821a3>] ? mpol_new+0xa3/0x140
[  795.261109]  [<ffffffff8162ffe2>] alloc_debug_processing+0x65/0xef
[  795.262264]  [<ffffffff816308b2>] __slab_alloc+0x3d3/0x445
[  795.263420]  [<ffffffff811821a3>] ? mpol_new+0xa3/0x140
[  795.264551]  [<ffffffff81310bf7>] ? __dynamic_pr_debug+0x87/0xb0
[  795.265624]  [<ffffffff811821a3>] ? mpol_new+0xa3/0x140
[  795.266727]  [<ffffffff81190cdd>] kmem_cache_alloc+0x29d/0x2b0
[  795.267786]  [<ffffffff81162ecc>] ? might_fault+0x9c/0xb0
[  795.268852]  [<ffffffff81162e83>] ? might_fault+0x53/0xb0
[  795.269907]  [<ffffffff811821a3>] mpol_new+0xa3/0x140
[  795.270936]  [<ffffffff81185422>] sys_mbind+0x142/0x620
[  795.271975]  [<ffffffff810856a1>] ? get_parent_ip+0x11/0x50
[  795.272997]  [<ffffffff8163d7ad>] ? sub_preempt_count+0x9d/0xd0
[  795.274018]  [<ffffffff81639a9b>] ? _raw_spin_unlock_irq+0x3b/0x60
[  795.275032]  [<ffffffff81641752>] system_call_fastpath+0x16/0x1b
[  795.276027] FIX numa_policy: Restoring 0xffff88014649abf0-0xffff88014649abf0=0x6b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
