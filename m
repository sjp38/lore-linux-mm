Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC59E6B006C
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 03:45:18 -0500 (EST)
Date: Tue, 22 Nov 2011 09:45:13 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111122084513.GA1688@x4.trippels.de>
References: <20111121161036.GA1679@x4.trippels.de>
 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121173556.GA1673@x4.trippels.de>
 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121185215.GA1673@x4.trippels.de>
 <20111121195113.GA1678@x4.trippels.de>
 <1321907275.13860.12.camel@pasglop>
 <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
 <alpine.DEB.2.00.1111212105330.19606@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111212105330.19606@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On 2011.11.21 at 21:18 -0600, Christoph Lameter wrote:
> On Mon, 21 Nov 2011, Christian Kujau wrote:
> 
> > On Tue, 22 Nov 2011 at 07:27, Benjamin Herrenschmidt wrote:
> > > Note that I hit a similar looking crash (sorry, I couldn't capture a
> > > backtrace back then) on a PowerMac G5 (ppc64) while doing a large rsync
> > > transfer yesterday with -rc2-something (cfcfc9ec) and
> > > Christian Kujau (CC) seems to be able to reproduce something similar on
> > > some other ppc platform (Christian, what is your setup ?)
> >
> > I seem to hit it with heavy disk & cpu IO is in progress on this PowerBook
> > G4. Full dmesg & .config: http://nerdbynature.de/bits/3.2.0-rc1/oops/
> >
> > I've enabled some debug options and now it really points to slub.c:2166
> 

I sometimes see the following pattern. Is this a false positive?


=============================================================================
BUG anon_vma: Redzone overwritten
-----------------------------------------------------------------------------

INFO: 0xffff88020f347c80-0xffff88020f347c87. First byte 0xbb instead of 0xcc
INFO: Allocated in anon_vma_fork+0x51/0x140 age=1 cpu=2 pid=1826
	__slab_alloc.constprop.70+0x1ac/0x1e8
	kmem_cache_alloc+0x12e/0x160
	anon_vma_fork+0x51/0x140
	dup_mm+0x1f2/0x4a0
	copy_process+0xd10/0xf70
	do_fork+0x100/0x2b0
	sys_clone+0x23/0x30
	stub_clone+0x13/0x20
INFO: Freed in __put_anon_vma+0x54/0xa0 age=0 cpu=1 pid=1827
	__slab_free+0x33/0x2d0
	kmem_cache_free+0x10e/0x120
	__put_anon_vma+0x54/0xa0
	unlink_anon_vmas+0x12f/0x1c0
	free_pgtables+0x83/0xe0
	exit_mmap+0xee/0x140
	mmput+0x43/0xf0
	flush_old_exec+0x33f/0x630
	load_elf_binary+0x340/0x1960
	search_binary_handler+0x8f/0x180
	do_execve+0x2d3/0x370
	sys_execve+0x42/0x70
	stub_execve+0x6c/0xc0
INFO: Slab 0xffffea00083cd1c0 objects=10 used=9 fp=0xffff88020f347ab8 flags=0x4000000000000081
INFO: Object 0xffff88020f347c40 @offset=3136 fp=0xffff88020f347ab8

Bytes b4 ffff88020f347c30: 39 b6 fb ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  9.......ZZZZZZZZ
Object ffff88020f347c40: 30 c9 9b 0d 02 88 ff ff 01 00 00 00 00 00 5a 5a  0.............ZZ
Object ffff88020f347c50: 50 7c 34 0f 02 88 ff ff 50 7c 34 0f 02 88 ff ff  P|4.....P|4.....
Object ffff88020f347c60: 00 00 00 00 00 00 00 00 00 00 00 00 5a 5a 5a 5a  ............ZZZZ
Object ffff88020f347c70: 70 7c 34 0f 02 88 ff ff 70 7c 34 0f 02 88 ff ff  p|4.....p|4.....
Redzone ffff88020f347c80: bb bb bb bb bb bb bb bb                          ........
Padding ffff88020f347dc0: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
Pid: 1820, comm: slabinfo Not tainted 3.2.0-rc2-00369-gbbbc479-dirty #83
Call Trace:
 [<ffffffff81105df8>] ? print_section+0x38/0x40
 [<ffffffff811062f3>] print_trailer+0xe3/0x150
 [<ffffffff811064f0>] check_bytes_and_report+0xe0/0x100
 [<ffffffff81107313>] check_object+0x183/0x240
 [<ffffffff81107eb0>] validate_slab_slab+0x1c0/0x230
 [<ffffffff8110a4a6>] validate_store+0xa6/0x190
 [<ffffffff8110573c>] slab_attr_store+0x1c/0x30
 [<ffffffff81168838>] sysfs_write_file+0xc8/0x140
 [<ffffffff811124a3>] vfs_write+0xa3/0x160
 [<ffffffff81112635>] sys_write+0x45/0x90
 [<ffffffff814d3ffb>] system_call_fastpath+0x16/0x1b
FIX anon_vma: Restoring 0xffff88020f347c80-0xffff88020f347c87=0xcc

=============================================================================
BUG kmalloc-64: Redzone overwritten
-----------------------------------------------------------------------------

INFO: 0xffff880214361970-0xffff880214361977. First byte 0xbb instead of 0xcc
INFO: Allocated in drm_mm_kmalloc+0x37/0xd0 age=14 cpu=0 pid=1539
	__slab_alloc.constprop.70+0x1ac/0x1e8
	kmem_cache_alloc_trace+0x136/0x170
	drm_mm_kmalloc+0x37/0xd0
	drm_mm_get_block_range_generic+0x37/0x80
	ttm_bo_man_get_node+0x8f/0xd0
	ttm_bo_mem_space+0x192/0x380
	ttm_bo_move_buffer+0xe8/0x150
	ttm_bo_validate+0x94/0x110
	ttm_bo_init+0x2a2/0x360
	radeon_bo_create+0x16a/0x2b0
	radeon_gem_object_create+0x55/0xf0
	radeon_gem_create_ioctl+0x52/0xc0
	drm_ioctl+0x404/0x4f0
	do_vfs_ioctl+0x8c/0x500
	sys_ioctl+0x4a/0x80
	system_call_fastpath+0x16/0x1b
INFO: Freed in drm_mm_put_block+0x70/0x80 age=0 cpu=1 pid=766
	__slab_free+0x33/0x2d0
	kfree+0x12b/0x150
	drm_mm_put_block+0x70/0x80
	ttm_bo_man_put_node+0x34/0x50
	ttm_bo_cleanup_memtype_use+0x59/0x80
	ttm_bo_cleanup_refs+0xee/0x150
	ttm_bo_delayed_delete+0xf2/0x150
	ttm_bo_delayed_workqueue+0x1a/0x40
	process_one_work+0x11a/0x430
	worker_thread+0x126/0x2d0
	kthread+0x87/0x90
	kernel_thread_helper+0x4/0x10
INFO: Slab 0xffffea000850d840 objects=10 used=6 fp=0xffff880214361dc8 flags=0x4000000000000081
INFO: Object 0xffff880214361930 @offset=2352 fp=0xffff880214361dc8

Bytes b4 ffff880214361920: 58 ac fb ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  X.......ZZZZZZZZ
Object ffff880214361930: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880214361940: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880214361950: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880214361960: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
Redzone ffff880214361970: bb bb bb bb bb bb bb bb                          ........
Padding ffff880214361ab0: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
Pid: 1820, comm: slabinfo Not tainted 3.2.0-rc2-00369-gbbbc479-dirty #83
Call Trace:
 [<ffffffff81105df8>] ? print_section+0x38/0x40
 [<ffffffff811062f3>] print_trailer+0xe3/0x150
 [<ffffffff811064f0>] check_bytes_and_report+0xe0/0x100
 [<ffffffff81107313>] check_object+0x183/0x240
 [<ffffffff81107eb0>] validate_slab_slab+0x1c0/0x230
 [<ffffffff8110a4a6>] validate_store+0xa6/0x190
 [<ffffffff8110573c>] slab_attr_store+0x1c/0x30
 [<ffffffff81168838>] sysfs_write_file+0xc8/0x140
 [<ffffffff811124a3>] vfs_write+0xa3/0x160
 [<ffffffff81112635>] sys_write+0x45/0x90
 [<ffffffff814d3ffb>] system_call_fastpath+0x16/0x1b
FIX kmalloc-64: Restoring 0xffff880214361970-0xffff880214361977=0xcc

=============================================================================
BUG kmalloc-64: Redzone overwritten
-----------------------------------------------------------------------------

INFO: 0xffff880214361970-0xffff880214361977. First byte 0xcc instead of 0xbb
INFO: Allocated in drm_mm_kmalloc+0x37/0xd0 age=1028 cpu=0 pid=1539
	__slab_alloc.constprop.70+0x1ac/0x1e8
	kmem_cache_alloc_trace+0x136/0x170
	drm_mm_kmalloc+0x37/0xd0
	drm_mm_get_block_range_generic+0x37/0x80
	ttm_bo_man_get_node+0x8f/0xd0
	ttm_bo_mem_space+0x192/0x380
	ttm_bo_move_buffer+0xe8/0x150
	ttm_bo_validate+0x94/0x110
	ttm_bo_init+0x2a2/0x360
	radeon_bo_create+0x16a/0x2b0
	radeon_gem_object_create+0x55/0xf0
	radeon_gem_create_ioctl+0x52/0xc0
	drm_ioctl+0x404/0x4f0
	do_vfs_ioctl+0x8c/0x500
	sys_ioctl+0x4a/0x80
	system_call_fastpath+0x16/0x1b
INFO: Freed in drm_mm_put_block+0x70/0x80 age=1014 cpu=1 pid=766
	__slab_free+0x33/0x2d0
	kfree+0x12b/0x150
	drm_mm_put_block+0x70/0x80
	ttm_bo_man_put_node+0x34/0x50
	ttm_bo_cleanup_memtype_use+0x59/0x80
	ttm_bo_cleanup_refs+0xee/0x150
	ttm_bo_delayed_delete+0xf2/0x150
	ttm_bo_delayed_workqueue+0x1a/0x40
	process_one_work+0x11a/0x430
	worker_thread+0x126/0x2d0
	kthread+0x87/0x90
	kernel_thread_helper+0x4/0x10
INFO: Slab 0xffffea000850d840 objects=10 used=10 fp=0x          (null) flags=0x4000000000000080
INFO: Object 0xffff880214361930 @offset=2352 fp=0xffff880214361dc8

Bytes b4 ffff880214361920: 9d b7 fb ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
Object ffff880214361930: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880214361940: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880214361950: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Object ffff880214361960: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
Redzone ffff880214361970: cc cc cc cc cc cc cc cc                          ........
Padding ffff880214361ab0: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
Pid: 1837, comm: uptime Not tainted 3.2.0-rc2-00369-gbbbc479-dirty #83
Call Trace:
 [<ffffffff81105df8>] ? print_section+0x38/0x40
 [<ffffffff811062f3>] print_trailer+0xe3/0x150
 [<ffffffff811064f0>] check_bytes_and_report+0xe0/0x100
 [<ffffffff81107313>] check_object+0x183/0x240
 [<ffffffff8115ab86>] ? proc_reg_open+0x46/0x170
 [<ffffffff814ccbbb>] alloc_debug_processing+0x62/0xe4
 [<ffffffff814cd479>] __slab_alloc.constprop.70+0x1ac/0x1e8
 [<ffffffff8115ab86>] ? proc_reg_open+0x46/0x170
 [<ffffffff8108e416>] ? bit_waitqueue+0x16/0xb0
 [<ffffffff81125b3d>] ? __d_instantiate+0xbd/0xf0
 [<ffffffff811091b6>] kmem_cache_alloc_trace+0x136/0x170
 [<ffffffff8115ab86>] ? proc_reg_open+0x46/0x170
 [<ffffffff8116051e>] ? proc_lookup_de+0xde/0xf0
 [<ffffffff8115ab86>] proc_reg_open+0x46/0x170
 [<ffffffff8115ab40>] ? init_once+0x10/0x10
 [<ffffffff8111055e>] __dentry_open.isra.15+0x20e/0x2f0
 [<ffffffff81095569>] ? in_group_p+0x29/0x30
 [<ffffffff8111122e>] nameidata_to_filp+0x4e/0x60
 [<ffffffff8111f124>] do_last.isra.46+0x2a4/0x7f0
 [<ffffffff8111f736>] path_openat+0xc6/0x370
 [<ffffffff810f634d>] ? do_brk+0x2fd/0x3b0
 [<ffffffff8111c1c6>] ? getname_flags+0x36/0x230
 [<ffffffff810f0582>] ? handle_mm_fault+0x192/0x290
 [<ffffffff8111fa1c>] do_filp_open+0x3c/0x90
 [<ffffffff8112c96c>] ? alloc_fd+0xdc/0x120
 [<ffffffff81111687>] do_sys_open+0xe7/0x1c0
 [<ffffffff8111177b>] sys_open+0x1b/0x20
 [<ffffffff814d3ffb>] system_call_fastpath+0x16/0x1b
FIX kmalloc-64: Restoring 0xffff880214361970-0xffff880214361977=0xbb

FIX kmalloc-64: Marking all objects used
=============================================================================
BUG anon_vma: Redzone overwritten
-----------------------------------------------------------------------------

INFO: 0xffff88020f347c80-0xffff88020f347c87. First byte 0xcc instead of 0xbb
INFO: Allocated in anon_vma_fork+0x51/0x140 age=1034 cpu=2 pid=1826
	__slab_alloc.constprop.70+0x1ac/0x1e8
	kmem_cache_alloc+0x12e/0x160
	anon_vma_fork+0x51/0x140
	dup_mm+0x1f2/0x4a0
	copy_process+0xd10/0xf70
	do_fork+0x100/0x2b0
	sys_clone+0x23/0x30
	stub_clone+0x13/0x20
INFO: Freed in __put_anon_vma+0x54/0xa0 age=1033 cpu=1 pid=1827
	__slab_free+0x33/0x2d0
	kmem_cache_free+0x10e/0x120
	__put_anon_vma+0x54/0xa0
	unlink_anon_vmas+0x12f/0x1c0
	free_pgtables+0x83/0xe0
	exit_mmap+0xee/0x140
	mmput+0x43/0xf0
	flush_old_exec+0x33f/0x630
	load_elf_binary+0x340/0x1960
	search_binary_handler+0x8f/0x180
	do_execve+0x2d3/0x370
	sys_execve+0x42/0x70
	stub_execve+0x6c/0xc0
INFO: Slab 0xffffea00083cd1c0 objects=10 used=10 fp=0x          (null) flags=0x4000000000000080
INFO: Object 0xffff88020f347c40 @offset=3136 fp=0xffff88020f347620

Bytes b4 ffff88020f347c30: 39 b6 fb ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  9.......ZZZZZZZZ
Object ffff88020f347c40: 30 c9 9b 0d 02 88 ff ff 01 00 00 00 00 00 5a 5a  0.............ZZ
Object ffff88020f347c50: 50 7c 34 0f 02 88 ff ff 50 7c 34 0f 02 88 ff ff  P|4.....P|4.....
Object ffff88020f347c60: 00 00 00 00 00 00 00 00 00 00 00 00 5a 5a 5a 5a  ............ZZZZ
Object ffff88020f347c70: 70 7c 34 0f 02 88 ff ff 70 7c 34 0f 02 88 ff ff  p|4.....p|4.....
Redzone ffff88020f347c80: cc cc cc cc cc cc cc cc                          ........
Padding ffff88020f347dc0: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
Pid: 1839, comm: date Not tainted 3.2.0-rc2-00369-gbbbc479-dirty #83
Call Trace:
 [<ffffffff81105df8>] ? print_section+0x38/0x40
 [<ffffffff811062f3>] print_trailer+0xe3/0x150
 [<ffffffff811064f0>] check_bytes_and_report+0xe0/0x100
 [<ffffffff81107313>] check_object+0x183/0x240
 [<ffffffff810f9955>] ? anon_vma_prepare+0x115/0x180
 [<ffffffff814ccbbb>] alloc_debug_processing+0x62/0xe4
 [<ffffffff814cd479>] __slab_alloc.constprop.70+0x1ac/0x1e8
 [<ffffffff810f9955>] ? anon_vma_prepare+0x115/0x180
 [<ffffffff810d5a5e>] ? __alloc_pages_nodemask+0xfe/0x7a0
 [<ffffffff8110904e>] kmem_cache_alloc+0x12e/0x160
 [<ffffffff810f9955>] ? anon_vma_prepare+0x115/0x180
 [<ffffffff810f9895>] ? anon_vma_prepare+0x55/0x180
 [<ffffffff810f9955>] anon_vma_prepare+0x115/0x180
 [<ffffffff810f00f1>] handle_pte_fault+0x611/0x7d0
 [<ffffffff8105c79a>] ? pte_alloc_one+0x3a/0x40
 [<ffffffff810edf46>] ? __pte_alloc+0x76/0x110
 [<ffffffff8110fb42>] do_huge_pmd_anonymous_page+0xb2/0x2f0
 [<ffffffff810f634d>] ? do_brk+0x2fd/0x3b0
 [<ffffffff810f0524>] handle_mm_fault+0x134/0x290
 [<ffffffff810591b2>] do_page_fault+0x112/0x440
 [<ffffffff810f428b>] ? vma_link+0x9b/0xa0
 [<ffffffff810f62ba>] ? do_brk+0x26a/0x3b0
 [<ffffffff81045429>] ? init_fpu+0xb9/0x150
 [<ffffffff814d3bef>] page_fault+0x1f/0x30
FIX anon_vma: Restoring 0xffff88020f347c80-0xffff88020f347c87=0xbb

FIX anon_vma: Marking all objects used

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
