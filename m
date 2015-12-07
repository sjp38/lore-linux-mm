From: Andrey Ryabinin <aryabinin@odin.com>
Subject: undefined shift in wb_update_dirty_ratelimit()
Date: Mon, 7 Dec 2015 17:17:06 +0300
Message-ID: <566594E2.3050306@odin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Sasha Levin <sasha.levin@oracle.com>
List-Id: linux-mm.kvack.org


I've hit undefined shift in wb_update_dirty_ratelimit() which does some
mysterious 'step' calculations:

	/*
	 * Don't pursue 100% rate matching. It's impossible since the balanced
	 * rate itself is constantly fluctuating. So decrease the track speed
	 * when it gets close to the target. Helps eliminate pointless tremors.
	 */
	step >>= dirty_ratelimit / (2 * step + 1);


dirty_ratelimit = INIT_BW and step = 0 results in this:

[ 5006.957366] ================================================================================
[ 5006.957798] UBSAN: Undefined behaviour in ../mm/page-writeback.c:1286:7
[ 5006.958091] shift exponent 25600 is too large for 64-bit type 'long unsigned int'
[ 5006.958414] CPU: 2 PID: 7452 Comm: trinity-c2 Not tainted 4.4.0-rc1+ #19
[ 5006.958740] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5006.959247]  ffffffff8261427a ffff88007ddaf798 ffffffff815e6cd6 0000000000000001
[ 5006.959630]  ffff88007ddaf7c8 ffff88007ddaf7b0 ffffffff8163a62d ffffffff8261427a
[ 5006.959997]  ffff88007ddaf850 ffffffff8163accf ffff88013afac780 0000000000000202
[ 5006.960345] Call Trace:
[ 5006.960460]  [<ffffffff815e6cd6>] dump_stack+0x45/0x5f
[ 5006.960723]  [<ffffffff8163a62d>] ubsan_epilogue+0xd/0x40
[ 5006.960961]  [<ffffffff8163accf>] __ubsan_handle_shift_out_of_bounds+0xef/0x130
[ 5006.961282]  [<ffffffff8140555c>] ? __es_insert_extent+0x2ec/0x670
[ 5006.961554]  [<ffffffff815f19f3>] ? radix_tree_lookup_slot+0x13/0x30
[ 5006.961867]  [<ffffffff81218431>] __wb_update_bandwidth.constprop.26+0x521/0x6a0
[ 5006.962190]  [<ffffffff81219c67>] balance_dirty_pages.isra.23+0xa27/0x1900
[ 5006.962498]  [<ffffffff814174b7>] ? jbd2_journal_stop+0x237/0x6b0
[ 5006.962835]  [<ffffffff81301d1f>] ? __block_commit_write.isra.23+0x6f/0x140
[ 5006.963140]  [<ffffffff8121aca3>] balance_dirty_pages_ratelimited+0x163/0x340
[ 5006.963453]  [<ffffffff81204954>] generic_perform_write+0x184/0x290
[ 5006.963750]  [<ffffffff81206bb7>] __generic_file_write_iter+0x1b7/0x3b0
[ 5006.964064]  [<ffffffff8137fdc4>] ext4_file_write_iter+0x154/0x930
[ 5006.964336]  [<ffffffff812ad414>] vfs_iter_write+0xa4/0x140
[ 5006.964581]  [<ffffffff812fa32a>] iter_file_splice_write+0x27a/0x4f0
[ 5006.964881]  [<ffffffff812f8c13>] direct_splice_actor+0x53/0xd0
[ 5006.965141]  [<ffffffff812f91f6>] splice_direct_to_actor+0xf6/0x390
[ 5006.965417]  [<ffffffff81526c11>] ? security_file_permission+0x41/0x110
[ 5006.965708]  [<ffffffff812f8bc0>] ? wakeup_pipe_writers+0x60/0x60
[ 5006.965976]  [<ffffffff812f9529>] do_splice_direct+0x99/0x100
[ 5006.966228]  [<ffffffff81526c11>] ? security_file_permission+0x41/0x110
[ 5006.966539]  [<ffffffff812af36b>] do_sendfile+0x18b/0x6a0
[ 5006.966825]  [<ffffffff812b0431>] compat_SyS_sendfile+0x71/0x80
[ 5006.967092]  [<ffffffff81004875>] do_syscall_32_irqs_off+0x75/0x110
[ 5006.967382]  [<ffffffff81e35903>] entry_INT80_compat+0x33/0x40
[ 5006.967653] ================================================================================
