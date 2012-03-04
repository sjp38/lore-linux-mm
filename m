Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 851E26B004A
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 11:35:38 -0500 (EST)
Received: by mail-lpp01m010-f41.google.com with SMTP id z14so5247478lag.14
        for <linux-mm@kvack.org>; Sun, 04 Mar 2012 08:35:38 -0800 (PST)
Date: Sun, 4 Mar 2012 18:35:34 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 2/3] vmevent: Fix deadlock when using si_meminfo()
In-Reply-To: <20120303000918.GB30207@oksana.dev.rtsoft.ru>
Message-ID: <alpine.LFD.2.02.1203041835210.1636@tux.localdomain>
References: <20120303000918.GB30207@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

On Sat, 3 Mar 2012, Anton Vorontsov wrote:
> si_meminfo() calls nr_blockdev_pages() that grabs bdev_lock, but it is
> not safe to grab the lock from the hardirq context (the lock is never
> taken with an _irqsave variant in block_dev.c). When taken from an
> inappropriate context it easily causes the following deadlock:
> 
> - - - -
>  =================================
>  [ INFO: inconsistent lock state ]
>  3.2.0+ #1
>  ---------------------------------
>  inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
>  swapper/0/0 [HC1[1]:SC0[0]:HE0:SE1] takes:
>   (bdev_lock){?.+...}, at: [<ffffffff810f1017>] nr_blockdev_pages+0x17/0x70
>  {HARDIRQ-ON-W} state was registered at:
>    [<ffffffff81061b20>] mark_irqflags+0x140/0x1b0
>    [<ffffffff81062f03>] __lock_acquire+0x4c3/0x9c0
>    [<ffffffff810639c6>] lock_acquire+0x96/0xc0
>    [<ffffffff8131c58c>] _raw_spin_lock+0x2c/0x40
>    [<ffffffff810f1017>] nr_blockdev_pages+0x17/0x70
>    [<ffffffff81089ba8>] si_meminfo+0x38/0x60
>    [<ffffffff81675493>] eventpoll_init+0x11/0xa1
>    [<ffffffff8165eb40>] do_one_initcall+0x7a/0x12e
>    [<ffffffff8165ec8e>] kernel_init+0x9a/0x114
>    [<ffffffff8131e934>] kernel_thread_helper+0x4/0x10
>  irq event stamp: 135250
>  hardirqs last  enabled at (135247): [<ffffffff81009897>] default_idle+0x27/0x50
>  hardirqs last disabled at (135248): [<ffffffff8131e1ab>] apic_timer_interrupt+0x6b/0x80
>  softirqs last  enabled at (135250): [<ffffffff8103814e>] _local_bh_enable+0xe/0x10
>  softirqs last disabled at (135249): [<ffffffff81038665>] irq_enter+0x65/0x80
> 
>  other info that might help us debug this:
>   Possible unsafe locking scenario:
> 
>         CPU0
>         ----
>    lock(bdev_lock);
>    <Interrupt>
>      lock(bdev_lock);
> 
>   *** DEADLOCK ***
> 
>  no locks held by swapper/0/0.
> - - - -
> 
> The patch fixes the issue by using totalram_pages instead of
> si_meminfo().
> 
> p.s.
> Note that VMEVENT_EATTR_NR_SWAP_PAGES type calls si_swapinfo(), which
> has a very similar problem. But there is no easy way to fix it.
> 
> Do we have any use case for the VMEVENT_EATTR_NR_SWAP_PAGES event? If
> not, I'd vote for removing it and thus keeping things simple.
> 
> Otherwise we would have two options:
> 
> 1. Modify swap accounting for vmevent (either start grabbing
>    _irqsave variant of swapfile.c's swap_lock, or try to
>    make the accounting atomic);
> 2. Start using kthreads for vmevent_sample().
> 
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
