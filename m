Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 111586B0062
	for <linux-mm@kvack.org>; Sun,  1 Jul 2012 23:42:46 -0400 (EDT)
Date: Mon, 2 Jul 2012 11:42:41 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: linux-next BUG: held lock freed!
Message-ID: <20120702034241.GA7511@localhost>
References: <20120626145432.GA15289@localhost>
 <20120626172918.GA16446@localhost>
 <20120627122306.GA19252@localhost>
 <20120702025625.GA6531@localhost>
 <20120702033914.GA7433@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120702033914.GA7433@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Mon, Jul 02, 2012 at 11:39:14AM +0800, Fengguang Wu wrote:
> On Mon, Jul 02, 2012 at 10:56:25AM +0800, Fengguang Wu wrote:
> > Hi all,
> > 
> > More observations on this bug:
> > 
> > The slab tree itself actually boots fine. So Christoph's commit may be
> > merely disclosing some bug hidden in another for-next tree which
> > happens to be merged before the slab tree..
> 
> Sorry: the bug does appear in the standalone slab tree, where the
> dmesg is
> 
> [  307.648802] blkid (2963) used greatest stack depth: 2832 bytes left
> [  307.892070] vhci_hcd: changed 0
> [  308.766647] 
> [  308.766648] =========================
> [  308.766649] [ BUG: held lock freed! ]
> [  308.766651] 3.5.0-rc1+ #44 Not tainted
> [  308.766651] -------------------------
> [  308.766653] mtd_probe/3040 is freeing memory ffff880006defdd0-ffff880006df0dcf, with a lock still held there!
> [  308.766662]  (&type->s_umount_key#31/1){+.+.+.}, at: [<ffffffff81187166>] sget+0x299/0x463
> [  308.766663] 3 locks held by mtd_probe/3040:
> [  308.766667]  #0:  (&type->s_umount_key#31/1){+.+.+.}, at: [<ffffffff81187166>] sget+0x299/0x463
> [  308.766671]  #1:  (sb_lock){+.+.-.}, at: [<ffffffff81186f00>] sget+0x33/0x463
> [  308.766675]  #2:  (unnamed_dev_lock){+.+...}, at: [<ffffffff81186711>] get_anon_bdev+0x38/0xe8
> [  308.766675] 
> [  308.766675] stack backtrace:
> [  308.766677] Pid: 3040, comm: mtd_probe Not tainted 3.5.0-rc1+ #44
> [  308.766678] Call Trace:
> [  308.766683]  [<ffffffff810ddc6e>] debug_check_no_locks_freed+0x109/0x14b
> [  308.766703]  [<ffffffff81173f7c>] kmem_cache_free+0x2e/0xa7
> [  308.766708]  [<ffffffff816a5d9d>] ida_get_new_above+0x173/0x184
> [  308.766711]  [<ffffffff810db9a4>] ? lock_acquired+0x1e4/0x219
> [  308.766713]  [<ffffffff81186727>] get_anon_bdev+0x4e/0xe8
> [  308.766715]  [<ffffffff811867d8>] set_anon_super+0x17/0x2a
> [  308.766717]  [<ffffffff81187270>] sget+0x3a3/0x463
> [  308.766719]  [<ffffffff811867c1>] ? get_anon_bdev+0xe8/0xe8
> [  308.766722]  [<ffffffff811a1fbe>] mount_pseudo+0x31/0x152
> [  308.766727]  [<ffffffff81cb1f54>] mtd_inodefs_mount+0x24/0x26
> [  308.766729]  [<ffffffff81187e34>] mount_fs+0x69/0x155
> [  308.766733]  [<ffffffff811531b2>] ? __alloc_percpu+0x10/0x12
> [  308.766736]  [<ffffffff8119ca4c>] vfs_kern_mount+0x62/0xd9
> [  308.766739]  [<ffffffff811a1b43>] simple_pin_fs+0x4c/0x9b
> [  308.766741]  [<ffffffff81cb338a>] mtdchar_open+0x42/0x188
> [  308.766744]  [<ffffffff811886ef>] chrdev_open+0x11f/0x14a
> [  308.766747]  [<ffffffff810c0880>] ? local_clock+0x19/0x52
> [  308.766750]  [<ffffffff811885d0>] ? cdev_put+0x26/0x26
> [  308.766752]  [<ffffffff811836cc>] do_dentry_open+0x1e4/0x2b2
> [  308.766754]  [<ffffffff8118434a>] nameidata_to_filp+0x5e/0xa3
> [  308.766756]  [<ffffffff8119118f>] do_last+0x68f/0x6d3
> [  308.766759]  [<ffffffff811912d8>] path_openat+0xd2/0x32a
> [  308.766762]  [<ffffffff8111eed8>] ? time_hardirqs_off+0x26/0x2a
> [  308.766765]  [<ffffffff810d9e88>] ? trace_hardirqs_off+0xd/0xf
> [  308.766767]  [<ffffffff81191630>] do_filp_open+0x38/0x86
> [  308.766771]  [<ffffffff82e95e22>] ? _raw_spin_unlock+0x28/0x3b
> [  308.766773]  [<ffffffff8119baa7>] ? alloc_fd+0xe5/0xf7
> [  308.766776]  [<ffffffff811843fd>] do_sys_open+0x6e/0xfb
> [  308.766777]  [<ffffffff811844ab>] sys_open+0x21/0x23
> [  308.766780]  [<ffffffff82e9cb69>] system_call_fastpath+0x16/0x1b

Another dmesg on the slab tree:

[   54.522438] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   54.567847] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   54.591289] 
[   54.591290] =========================
[   54.591291] [ BUG: held lock freed! ]
[   54.591293] 3.5.0-rc1+ #45 Not tainted
[   54.591293] -------------------------
[   54.591295] swapper/0/1 is freeing memory ffff88000f45fdd0-ffff88000f460dcf, with a lock still held there!
[   54.591304]  (&port->mutex){+.+.+.}, at: [<ffffffff817df6d2>] uart_add_one_port+0x84/0x356
[   54.591306] 3 locks held by swapper/0/1:
[   54.591310]  #0:  (port_mutex){+.+.+.}, at: [<ffffffff817df6c0>] uart_add_one_port+0x72/0x356
[   54.591314]  #1:  (&port->mutex){+.+.+.}, at: [<ffffffff817df6d2>] uart_add_one_port+0x84/0x356
[   54.591319]  #2:  (sysfs_ino_lock){+.+...}, at: [<ffffffff811e273f>] sysfs_new_dirent+0x6b/0x10c
[   54.591320] 
[   54.591320] stack backtrace:
[   54.591322] Pid: 1, comm: swapper/0 Not tainted 3.5.0-rc1+ #45
[   54.591323] Call Trace:
[   54.591338]  [<ffffffff810ddc6e>] debug_check_no_locks_freed+0x109/0x14b
[   54.591342]  [<ffffffff81173fa0>] kmem_cache_free+0x2e/0xa7
[   54.591346]  [<ffffffff816a5d9d>] ida_get_new_above+0x173/0x184
[   54.591351]  [<ffffffff810db9a4>] ? lock_acquired+0x1e4/0x219
[   54.591354]  [<ffffffff811e2754>] sysfs_new_dirent+0x80/0x10c
[   54.591357]  [<ffffffff811e1cad>] sysfs_add_file_mode+0x4e/0xce
[   54.591366]  [<ffffffff811e1d3f>] sysfs_add_file+0x12/0x14
[   54.591368]  [<ffffffff811e4296>] sysfs_merge_group+0x45/0x97
[   54.591372]  [<ffffffff819bff1b>] dpm_sysfs_add+0x54/0xab
[   54.591374]  [<ffffffff819b9394>] device_add+0x3ba/0x5d7
[   54.591377]  [<ffffffff819b95cc>] device_register+0x1b/0x1f
[   54.591379]  [<ffffffff819b9661>] device_create_vargs+0x91/0xc8
[   54.591381]  [<ffffffff819b96c9>] device_create+0x31/0x33
[   54.591385]  [<ffffffff817c1792>] tty_register_device+0xde/0xfb
[   54.591388]  [<ffffffff817df90f>] uart_add_one_port+0x2c1/0x356
[   54.591406]  [<ffffffff84641c95>] serial8250_init+0x12b/0x189
[   54.591409]  [<ffffffff84641095>] ? r3964_init+0x25/0x41
[   54.591411]  [<ffffffff84641b6a>] ? serial8250_console_init+0x2c/0x2c
[   54.591414]  [<ffffffff81002099>] do_one_initcall+0x7f/0x13a
[   54.591419]  [<ffffffff84603d39>] kernel_init+0x170/0x1f8
[   54.591422]  [<ffffffff84603590>] ? do_early_param+0x8c/0x8c
[   54.591435]  [<ffffffff82e9dfb4>] kernel_thread_helper+0x4/0x10
[   54.591438]  [<ffffffff82e961f0>] ? retint_restore_args+0x13/0x13
[   54.591441]  [<ffffffff84603bc9>] ? start_kernel+0x3e7/0x3e7
[   54.591443]  [<ffffffff82e9dfb0>] ? gs_change+0x13/0x13
[   54.625113] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
