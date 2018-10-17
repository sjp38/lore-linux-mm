Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D81F36B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:13:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id i189-v6so21197889pge.6
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:13:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b28-v6si19268884pff.192.2018.10.17.15.13.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:13:35 -0700 (PDT)
Date: Wed, 17 Oct 2018 15:13:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] writeback: don't decrement wb->refcnt if !wb->bdi
Message-Id: <20181017151334.e6017d0ee91be973514605df@linux-foundation.org>
In-Reply-To: <20181017140311.28679-2-anders.roxell@linaro.org>
References: <20181017140311.28679-1-anders.roxell@linaro.org>
	<20181017140311.28679-2-anders.roxell@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anders Roxell <anders.roxell@linaro.org>
Cc: linux@armlinux.org.uk, gregkh@linuxfoundation.org, linux-serial@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, tj@kernel.org, Arnd Bergmann <arnd@arndb.de>

On Wed, 17 Oct 2018 16:03:11 +0200 Anders Roxell <anders.roxell@linaro.org> wrote:

> When enabling CONFIG_DEBUG_TEST_DRIVER_REMOVE devtmpfs gets killed
> because we try to remove a file and decrement the wb reference count
> before the noop_backing_device_info gets initialized.
> 
> Since arch_initcall(pl011_init) came before
> subsys_initcall(default_bdi_init), devtmpfs' handle_remove() crashes
> because the reference count is a NULL pointer only because bdi->wb
> hasn't been initialized yet.

Is this changelog correct?  What does drivers/tty/serial/amba-pl011.c
have to do with page writeback?  Confused.

> [    0.332075] Serial: AMBA PL011 UART driver
> [    0.485276] 9000000.pl011: ttyAMA0 at MMIO 0x9000000 (irq = 39, base_baud = 0) is a PL011 rev1
> [    0.502382] console [ttyAMA0] enabled
> [    0.515710] Unable to handle kernel paging request at virtual address 0000800074c12000
> [    0.516053] Mem abort info:
> [    0.516222]   ESR = 0x96000004
> [    0.516417]   Exception class = DABT (current EL), IL = 32 bits
> [    0.516641]   SET = 0, FnV = 0
> [    0.516826]   EA = 0, S1PTW = 0
> [    0.516984] Data abort info:
> [    0.517149]   ISV = 0, ISS = 0x00000004
> [    0.517339]   CM = 0, WnR = 0
> [    0.517553] [0000800074c12000] user address but active_mm is swapper
> [    0.517928] Internal error: Oops: 96000004 [#1] PREEMPT SMP
> [    0.518305] Modules linked in:
> [    0.518839] CPU: 0 PID: 13 Comm: kdevtmpfs Not tainted 4.19.0-rc5-next-20180928-00002-g2ba39ab0cd01-dirty #82
> [    0.519307] Hardware name: linux,dummy-virt (DT)
> [    0.519681] pstate: 80000005 (Nzcv daif -PAN -UAO)
> [    0.519959] pc : __destroy_inode+0x94/0x2a8
> [    0.520212] lr : __destroy_inode+0x78/0x2a8
> [    0.520401] sp : ffff0000098c3b20
> [    0.520590] x29: ffff0000098c3b20 x28: 00000000087a3714
> [    0.520904] x27: 0000000000002000 x26: 0000000000002000
> [    0.521179] x25: ffff000009583000 x24: 0000000000000000
> [    0.521467] x23: ffff80007bb52000 x22: ffff80007bbaa7c0
> [    0.521737] x21: ffff0000093f9338 x20: 0000000000000000
> [    0.522033] x19: ffff80007bbb05d8 x18: 0000000000000400
> [    0.522376] x17: 0000000000000000 x16: 0000000000000000
> [    0.522727] x15: 0000000000000400 x14: 0000000000000400
> [    0.523068] x13: 0000000000000001 x12: 0000000000000001
> [    0.523421] x11: 0000000000000000 x10: 0000000000000970
> [    0.523749] x9 : ffff0000098c3a60 x8 : ffff80007bbab190
> [    0.524017] x7 : ffff80007bbaa880 x6 : 0000000000000c88
> [    0.524305] x5 : ffff0000093d96c8 x4 : 61c8864680b583eb
> [    0.524567] x3 : ffff0000093d6180 x2 : ffffffffffffffff
> [    0.524872] x1 : 0000800074c12000 x0 : 0000800074c12000
> [    0.525207] Process kdevtmpfs (pid: 13, stack limit = 0x(____ptrval____))
> [    0.525529] Call trace:
> [    0.525806]  __destroy_inode+0x94/0x2a8
> [    0.526108]  destroy_inode+0x34/0x88
> [    0.526370]  evict+0x144/0x1c8
> [    0.526636]  iput+0x184/0x230
> [    0.526871]  dentry_unlink_inode+0x118/0x130
> [    0.527152]  d_delete+0xd8/0xe0
> [    0.527420]  vfs_unlink+0x240/0x270
> [    0.527665]  handle_remove+0x1d8/0x330
> [    0.527875]  devtmpfsd+0x138/0x1c8
> [    0.528085]  kthread+0x14c/0x158
> [    0.528291]  ret_from_fork+0x10/0x18
> [    0.528720] Code: 92800002 aa1403e0 d538d081 8b010000 (c85f7c04)

Seems that there is indeed some form of linkage.  Can this be spelled
out more in the changelog please?

> 
> Rework so that wb_put have an extra check if wb->bdi before decrement
> wb->refcnt and also add a WARN_ON to get a warning if it happens again
> in other drivers.
> 
> Fixes: 52ebea749aae ("writeback: make backing_dev_info host cgroup-specific bdi_writebacks")
> Cc: Arnd Bergmann <arnd@arndb.de>
> Co-developed-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Anders Roxell <anders.roxell@linaro.org>

Signed-off-by: Arnd, please.

> --- a/include/linux/backing-dev-defs.h
> +++ b/include/linux/backing-dev-defs.h
> @@ -258,7 +258,7 @@ static inline void wb_get(struct bdi_writeback *wb)
>   */
>  static inline void wb_put(struct bdi_writeback *wb)
>  {
> -	if (wb != &wb->bdi->wb)
> +	if (!WARN_ON(!wb->bdi) && wb != &wb->bdi->wb)
>  		percpu_ref_put(&wb->refcnt);
>  }

The !WARN_ON(!expr) isn't very easy to follow.   This:

{
	if (WARN_ON_ONCE(!wb->bdi)) {
		/*
		 * Nice comment explaining how this situation comes about
		 */
		return;
	}

	if (wb != &wb->bdi->wb)
		percpu_ref_put(&wb->refcnt);
}

is better, no?

Also, please note the s/WARN_ON/WARN_ON_ONCE/.  I don't think we gain
anything from reporting the same thing many times?
