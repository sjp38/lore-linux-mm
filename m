Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 36D116B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:19:53 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1262024pdj.22
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 17:19:52 -0700 (PDT)
Date: Sat, 24 Aug 2013 09:19:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram: hang/deadlock when used as swap
Message-ID: <20130824001943.GA2708@gmail.com>
References: <5217EF52.2010307@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5217EF52.2010307@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Barber <smbarber@google.com>
Cc: linux-mm@kvack.org, Luigi Semenzato <semenzato@google.com>, David Rientjes <rientjes@google.com>

Hello,

On Fri, Aug 23, 2013 at 04:25:06PM -0700, Stephen Barber wrote:
> Hi all,
> 
> I've been experimenting with zram on 3.11-rc6 (x86_64), and am getting a
> deadlock under certain conditions when zram is used as a swap device.
> 
> Here's my speculative diagnosis: calls into zram_slot_free_notify will
> try to down a semaphore, which has a chance of sleeping. In at least a
> few of the paths to zram_slot_free_notify, there may be some held spin
> locks (such as in swap_info_struct). This leads to a deadlock when the
> process holding the spin lock is put to sleep, since no other process
> can acquire it.
> 
> I can reproduce the deadlock almost 100% of the time by creating a large
> number of processes (~50) that are all using swap. git bisect indicates
> that things broke here:
> 
> commit 57ab048532c0d975538cebd4456491b5c34248f4
> Author: Jiang Liu <liuj97@gmail.com>
> Commit: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> zram: use zram->lock to protect zram_free_page() in swap free notify path
> 
> 
> Any insights would be much appreciated!

Could you apply this in recent linux-next?
[1] a0c516cbfc, zram: don't grab mutex in zram_slot_free_noity

> 
> 
> Relevant call trace after hang detected:
> CPU: 1 PID: 13564 Comm: hog Tainted: G        WC   3.11.0-rc6 #3
> Hardware name: SAMSUNG Lumpy, BIOS Google_Lumpy.2.111.0 03/18/2012
> task: ffff88013f308000 ti: ffff88012ea60000 task.ti: ffff88012ea60000
> RIP: 0010:[<ffffffff81211768>]  [<ffffffff81211768>] delay_tsc+0x19/0x50
> RSP: 0000:ffff88012ea617f8  EFLAGS: 00000206
> RAX: 00000000ac4c158b RBX: ffffffff814e7b1c RCX: 00000000ac4c153f
> RDX: 0000000000000023 RSI: 0000000000000001 RDI: 0000000000000001
> RBP: ffff88012ea617f8 R08: 0000000000000002 R09: 0000000000000000
> R10: ffffffff817e282b R11: ffffffff81a321d0 R12: ffff88012ea61768
> R13: ffff88014fb13740 R14: ffff88012ea60000 R15: 0000000000000046
> FS:  00007f8405cf7700(0000) GS:ffff88014fb00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f4a43ceaa08 CR3: 000000012ea46000 CR4: 00000000000407e0
> Stack:
>  ffff88012ea61808 ffffffff812116f9 ffff88012ea61838 ffffffff8121816d
>  0000000000017588 ffff88013f095500 0000000000017588 0000000000017588
>  ffff88012ea61868 ffffffff814e70a7 ffffffff810ee1e2 ffffffff814e1a84
> Call Trace:
>  [<ffffffff812116f9>] __delay+0xf/0x11
>  [<ffffffff8121816d>] do_raw_spin_lock+0xac/0xfe
>  [<ffffffff814e70a7>] _raw_spin_lock+0x39/0x40
>  [<ffffffff810ee1e2>] ? spin_lock+0x2e/0x33
>  [<ffffffff814e1a84>] ? dump_stack+0x46/0x58
>  [<ffffffff8106f519>] ? vprintk_emit+0x3d0/0x436
>  [<ffffffff810ee1e2>] spin_lock+0x2e/0x33
>  [<ffffffff810ee245>] swap_info_get+0x5e/0x9a
>  [<ffffffff810eedab>] swapcache_free+0x14/0x3d
>  [<ffffffff810d0b06>] __remove_mapping+0x84/0xc8
>  [<ffffffff810d25f7>] shrink_page_list+0x691/0x860
>  [<ffffffff810d2cec>] shrink_inactive_list+0x240/0x3df
>  [<ffffffff810d31fd>] shrink_lruvec+0x372/0x52d
>  [<ffffffff810d3cf5>] try_to_free_pages+0x15f/0x36c
>  [<ffffffff810cb19d>] __alloc_pages_nodemask+0x323/0x54f
>  [<ffffffff810e09ad>] handle_pte_fault+0x149/0x4f8
>  [<ffffffff8102edcd>] ? __do_page_fault+0x159/0x38c
>  [<ffffffff810e0f72>] handle_mm_fault+0x99/0xbf
>  [<ffffffff8102efb6>] __do_page_fault+0x342/0x38c
>  [<ffffffff8107a53d>] ? arch_local_irq_save+0x9/0xc
>  [<ffffffff8107c7e2>] ? trace_hardirqs_on+0xd/0xf
>  [<ffffffff814e76dc>] ? _raw_spin_unlock_irq+0x2d/0x32
>  [<ffffffff8105e534>] ? finish_task_switch+0x80/0xcc
>  [<ffffffff8105e4f6>] ? finish_task_switch+0x42/0xcc
>  [<ffffffff8121275d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>  [<ffffffff8102f032>] do_page_fault+0xe/0x10
>  [<ffffffff814e7d22>] page_fault+0x22/0x30
> 
> Thanks,
> Stephen

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
