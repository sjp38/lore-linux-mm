Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 479696B0062
	for <linux-mm@kvack.org>; Sun,  1 Jul 2012 23:39:19 -0400 (EDT)
Date: Mon, 2 Jul 2012 11:39:14 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: linux-next BUG: held lock freed!
Message-ID: <20120702033914.GA7433@localhost>
References: <20120626145432.GA15289@localhost>
 <20120626172918.GA16446@localhost>
 <20120627122306.GA19252@localhost>
 <20120702025625.GA6531@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120702025625.GA6531@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Mon, Jul 02, 2012 at 10:56:25AM +0800, Fengguang Wu wrote:
> Hi all,
> 
> More observations on this bug:
> 
> The slab tree itself actually boots fine. So Christoph's commit may be
> merely disclosing some bug hidden in another for-next tree which
> happens to be merged before the slab tree..

Sorry: the bug does appear in the standalone slab tree, where the
dmesg is

[  307.648802] blkid (2963) used greatest stack depth: 2832 bytes left
[  307.892070] vhci_hcd: changed 0
[  308.766647] 
[  308.766648] =========================
[  308.766649] [ BUG: held lock freed! ]
[  308.766651] 3.5.0-rc1+ #44 Not tainted
[  308.766651] -------------------------
[  308.766653] mtd_probe/3040 is freeing memory ffff880006defdd0-ffff880006df0dcf, with a lock still held there!
[  308.766662]  (&type->s_umount_key#31/1){+.+.+.}, at: [<ffffffff81187166>] sget+0x299/0x463
[  308.766663] 3 locks held by mtd_probe/3040:
[  308.766667]  #0:  (&type->s_umount_key#31/1){+.+.+.}, at: [<ffffffff81187166>] sget+0x299/0x463
[  308.766671]  #1:  (sb_lock){+.+.-.}, at: [<ffffffff81186f00>] sget+0x33/0x463
[  308.766675]  #2:  (unnamed_dev_lock){+.+...}, at: [<ffffffff81186711>] get_anon_bdev+0x38/0xe8
[  308.766675] 
[  308.766675] stack backtrace:
[  308.766677] Pid: 3040, comm: mtd_probe Not tainted 3.5.0-rc1+ #44
[  308.766678] Call Trace:
[  308.766683]  [<ffffffff810ddc6e>] debug_check_no_locks_freed+0x109/0x14b
[  308.766703]  [<ffffffff81173f7c>] kmem_cache_free+0x2e/0xa7
[  308.766708]  [<ffffffff816a5d9d>] ida_get_new_above+0x173/0x184
[  308.766711]  [<ffffffff810db9a4>] ? lock_acquired+0x1e4/0x219
[  308.766713]  [<ffffffff81186727>] get_anon_bdev+0x4e/0xe8
[  308.766715]  [<ffffffff811867d8>] set_anon_super+0x17/0x2a
[  308.766717]  [<ffffffff81187270>] sget+0x3a3/0x463
[  308.766719]  [<ffffffff811867c1>] ? get_anon_bdev+0xe8/0xe8
[  308.766722]  [<ffffffff811a1fbe>] mount_pseudo+0x31/0x152
[  308.766727]  [<ffffffff81cb1f54>] mtd_inodefs_mount+0x24/0x26
[  308.766729]  [<ffffffff81187e34>] mount_fs+0x69/0x155
[  308.766733]  [<ffffffff811531b2>] ? __alloc_percpu+0x10/0x12
[  308.766736]  [<ffffffff8119ca4c>] vfs_kern_mount+0x62/0xd9
[  308.766739]  [<ffffffff811a1b43>] simple_pin_fs+0x4c/0x9b
[  308.766741]  [<ffffffff81cb338a>] mtdchar_open+0x42/0x188
[  308.766744]  [<ffffffff811886ef>] chrdev_open+0x11f/0x14a
[  308.766747]  [<ffffffff810c0880>] ? local_clock+0x19/0x52
[  308.766750]  [<ffffffff811885d0>] ? cdev_put+0x26/0x26
[  308.766752]  [<ffffffff811836cc>] do_dentry_open+0x1e4/0x2b2
[  308.766754]  [<ffffffff8118434a>] nameidata_to_filp+0x5e/0xa3
[  308.766756]  [<ffffffff8119118f>] do_last+0x68f/0x6d3
[  308.766759]  [<ffffffff811912d8>] path_openat+0xd2/0x32a
[  308.766762]  [<ffffffff8111eed8>] ? time_hardirqs_off+0x26/0x2a
[  308.766765]  [<ffffffff810d9e88>] ? trace_hardirqs_off+0xd/0xf
[  308.766767]  [<ffffffff81191630>] do_filp_open+0x38/0x86
[  308.766771]  [<ffffffff82e95e22>] ? _raw_spin_unlock+0x28/0x3b
[  308.766773]  [<ffffffff8119baa7>] ? alloc_fd+0xe5/0xf7
[  308.766776]  [<ffffffff811843fd>] do_sys_open+0x6e/0xfb
[  308.766777]  [<ffffffff811844ab>] sys_open+0x21/0x23
[  308.766780]  [<ffffffff82e9cb69>] system_call_fastpath+0x16/0x1b

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
