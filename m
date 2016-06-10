From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [mmots-2016-06-09-16-49] sleeping function called from
 slab_alloc()
Date: Fri, 10 Jun 2016 18:50:48 +0900
Message-ID: <20160610095048.GA655@swordfish>
References: <20160610061139.GA374@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160610061139.GA374@swordfish>
Sender: linux-next-owner@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
List-Id: linux-mm.kvack.org

Hello,

forked from http://marc.info/?l=linux-mm&m=146553910928716&w=2

new_slab()->BUG->die()->exit_signals() can be called from atomic
context: local IRQs disabled in slab_alloc().

[  429.232059] BUG: sleeping function called from invalid context at include/linux/sched.h:2960
[  429.232719] in_atomic(): 0, irqs_disabled(): 1, pid: 562, name: gzip
[  429.233376] INFO: lockdep is turned off.
[  429.234034] irq event stamp: 1994762
[  429.234697] hardirqs last  enabled at (1994761): [<ffffffff8113f360>] __find_get_block+0xd9/0x117
[  429.235360] hardirqs last disabled at (1994762): [<ffffffff81105516>] __slab_alloc.isra.18.constprop.22+0x20/0x6d
[  429.236026] softirqs last  enabled at (1994554): [<ffffffff81040285>] __do_softirq+0x1bc/0x217
[  429.236694] softirqs last disabled at (1994535): [<ffffffff810404ba>] irq_exit+0x3b/0x8f
[  429.237360] CPU: 0 PID: 562 Comm: gzip Tainted: G      D         4.7.0-rc2-mm1-dbg-00231-g201dcbd-dirty #141
[  429.238708]  0000000000000000 ffff88009434f520 ffffffff811e632c 0000000000000000
[  429.239397]  ffff8800bf8e3a80 ffff88009434f548 ffffffff810598c8 ffffffff8174b8c3
[  429.240077]  0000000000000b90 0000000000000000 ffff88009434f570 ffffffff8105993f
[  429.240757] Call Trace:
[  429.241433]  [<ffffffff811e632c>] dump_stack+0x68/0x92
[  429.242113]  [<ffffffff810598c8>] ___might_sleep+0x1fb/0x202
[  429.242816]  [<ffffffff8105993f>] __might_sleep+0x70/0x77
[  429.243493]  [<ffffffff810487a0>] exit_signals+0x1e/0x119
[  429.244168]  [<ffffffff8103eec3>] do_exit+0x111/0x8f8
[  429.244844]  [<ffffffff8107da75>] ? kmsg_dump+0x149/0x154
[  429.245525]  [<ffffffff81014a03>] oops_end+0x9d/0xa4
[  429.246200]  [<ffffffff81014b27>] die+0x55/0x5e
[  429.246868]  [<ffffffff81012450>] do_trap+0x67/0x11d
[  429.247538]  [<ffffffff8101272d>] do_error_trap+0x100/0x10f
[  429.248212]  [<ffffffff811036a5>] ? new_slab+0x25/0x2be
[  429.248878]  [<ffffffff8107c870>] ? wake_up_klogd+0x4e/0x61
[  429.249544]  [<ffffffff8107ccda>] ? console_unlock+0x457/0x4a2
[  429.250202]  [<ffffffff81001036>] ? trace_hardirqs_off_thunk+0x1a/0x1c
[  429.250856]  [<ffffffff81012889>] do_invalid_op+0x1b/0x1d
[  429.251508]  [<ffffffff814a5e25>] invalid_op+0x15/0x20
[  429.252158]  [<ffffffff811036a5>] ? new_slab+0x25/0x2be
[  429.252803]  [<ffffffff81105467>] ___slab_alloc.constprop.23+0x2f8/0x387
[  429.253451]  [<ffffffff8105993f>] ? __might_sleep+0x70/0x77
[  429.254102]  [<ffffffff810c7582>] ? mempool_alloc_slab+0x10/0x12
[  429.254740]  [<ffffffff810767fa>] ? lock_acquire+0x46/0x60
[  429.255376]  [<ffffffffa01ba17d>] ? fat_cache_add.part.1+0x135/0x140 [fat]
[  429.256012]  [<ffffffff8110553b>] __slab_alloc.isra.18.constprop.22+0x45/0x6d
[  429.256657]  [<ffffffff8110553b>] ? __slab_alloc.isra.18.constprop.22+0x45/0x6d
[  429.257292]  [<ffffffff810c7582>] ? mempool_alloc_slab+0x10/0x12
[  429.257959]  [<ffffffff810c7582>] ? mempool_alloc_slab+0x10/0x12
[  429.258592]  [<ffffffff811055d9>] kmem_cache_alloc+0x76/0xc7
[  429.259226]  [<ffffffff810c7582>] mempool_alloc_slab+0x10/0x12
[  429.259849]  [<ffffffff810c7636>] mempool_alloc+0x7e/0x147
[  429.260432]  [<ffffffffa01ba53f>] ? fat_get_mapped_cluster+0x5a/0xeb [fat]
[  429.261024]  [<ffffffff811ca221>] bio_alloc_bioset+0xbd/0x1b1
[  429.261614]  [<ffffffff81148078>] mpage_alloc+0x28/0x7b
[  429.262185]  [<ffffffff8114856a>] do_mpage_readpage+0x43d/0x545
[  429.262753]  [<ffffffff81148767>] mpage_readpages+0xf5/0x152
[  429.263320]  [<ffffffffa01c0d1a>] ? fat_add_cluster+0x48/0x48 [fat]
[  429.263887]  [<ffffffffa01c0d1a>] ? fat_add_cluster+0x48/0x48 [fat]
[  429.264447]  [<ffffffff811ea19f>] ? __radix_tree_lookup+0x70/0xa3
[  429.265017]  [<ffffffffa01befc6>] fat_readpages+0x18/0x1a [fat]
[  429.265575]  [<ffffffff810d0477>] __do_page_cache_readahead+0x215/0x2d6
[  429.266135]  [<ffffffff810d0883>] ondemand_readahead+0x34b/0x360
[  429.266691]  [<ffffffff810d0883>] ? ondemand_readahead+0x34b/0x360
[  429.267240]  [<ffffffff810d0a3a>] page_cache_async_readahead+0xae/0xb9
[  429.267798]  [<ffffffff810c546d>] generic_file_read_iter+0x1d1/0x6cf
[  429.268345]  [<ffffffff81071351>] ? update_fast_ctr+0x49/0x63
[  429.268896]  [<ffffffff8111b183>] ? pipe_write+0x3c7/0x3d9
[  429.269438]  [<ffffffff81114418>] __vfs_read+0xc4/0xe8
[  429.269976]  [<ffffffff811144da>] vfs_read+0x9e/0x109
[  429.270518]  [<ffffffff81114892>] SyS_read+0x4c/0x89
[  429.271057]  [<ffffffff814a4ba5>] entry_SYSCALL_64_fastpath+0x18/0xa8

 	-ss
