Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E91816B004F
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 04:30:09 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n638fG4G021028
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Jul 2009 17:41:17 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A145245DE62
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 17:41:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 76D8245DE63
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 17:41:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 55AFAE08001
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 17:41:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E3B1CE08004
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 17:41:15 +0900 (JST)
Date: Fri, 3 Jul 2009 17:39:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: BUG at mm/vmscan.c:904 [mmotm 2009-07-02-19-57]
Message-Id: <20090703173934.dc278fda.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4A4DBF16.1020509@gmail.com>
References: <4A4DBF16.1020509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 03 Jul 2009 10:19:34 +0200
Jiri Slaby <jirislaby@gmail.com> wrote:

> Hi,
> 
> I don't know what exactly lead to this, but I got it when installing a
> kernel rpm (io load) in qemu:
> 
IIUC....

plz revert this.

  vmscan-dont-attempt-to-reclaim-anon-page-in-lumpy-reclaim-when-no-swap-space-is-available.patch

or rewrite as following.
==
+	if (nr_swap_pages <= 0 && (PageAnon(page) && !PageSwapCache(page)))
+		return -EBUSY;
+
==

CCed to Minchan and Kosaki.

Regards,
-Kame



> ------------[ cut here ]------------
> kernel BUG at mm/vmscan.c:904!
> invalid opcode: 0000 [#1] PREEMPT SMP
> last sysfs file: /sys/devices/pci0000:00/0000:00:05.0/modalias
> CPU 0
> Modules linked in: e1000
> Pid: 290, comm: kswapd0 Tainted: G       AW  2.6.31-rc1-mm1 #103
> RIP: 0010:[<ffffffff81095c96>]  [<ffffffff81095c96>]
> isolate_pages_global+0x196/0x260
> RSP: 0018:ffff880011943c40  EFLAGS: 00010082
> RAX: 00000000ffffffea RBX: ffffea0000050170 RCX: 0000000000000001
> RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffea0000050170
> RBP: ffff880011943cd0 R08: 0000000000000001 R09: ffffffff81668b00
> R10: 00000000ffffffff R11: 0000000000000001 R12: ffffffff81669060
> R13: ffffea0000050198 R14: ffff880011943d50 R15: ffffffff81668b00
> FS:  0000000000000000(0000) GS:ffff88000176f000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> CR2: 00007f5d32981000 CR3: 0000000011adb000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process kswapd0 (pid: 290, threadinfo ffff880011942000, task
> ffff88001254c840)
> Stack:
>  ffff880011943d68 0000000000000020 0000000000000030 000000020177f4b0
> <0> 0000000000000003 000000008103329b 0000000000000001 ffffffffffffffff
> <0> 0000000100000003 0000000000000000 0000000000000000 0000000000000000
> Call Trace:
>  [<ffffffff81096ae6>] shrink_active_list+0xa6/0x330
>  [<ffffffff81032fe8>] ? task_rq_lock+0x48/0x90
>  [<ffffffff810985c0>] ? kswapd+0x0/0x770
>  [<ffffffff81098ab5>] kswapd+0x4f5/0x770
>  [<ffffffff81037177>] ? pick_next_task_fair+0xd7/0xf0
>  [<ffffffff810985c0>] ? kswapd+0x0/0x770
>  [<ffffffff81095b00>] ? isolate_pages_global+0x0/0x260
>  [<ffffffff8103f1ed>] ? default_wake_function+0xd/0x10
>  [<ffffffff8105aa30>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff813f9978>] ? preempt_schedule+0x38/0x60
>  [<ffffffff813fbb40>] ? _spin_unlock_irqrestore+0x30/0x40
>  [<ffffffff810985c0>] ? kswapd+0x0/0x770
>  [<ffffffff8105a6b6>] kthread+0x96/0xa0
>  [<ffffffff8100ceaa>] child_rip+0xa/0x20
>  [<ffffffff8105a620>] ? kthread+0x0/0xa0
>  [<ffffffff8100cea0>] ? child_rip+0x0/0x20
> Code: 80 75 12 8b 55 bc 8b 75 b4 4c 89 ef e8 f4 f9 ff ff 85 c0 74 79 49
> ff c7 49 83 c5 38 4c 39 7d 98 77 cf 48 ff 45 c8 e9 e9 fe ff ff <0f> 0b
> eb fe 48 8b 53 30 48 8b 4b 28 48 8d 43 28 48 89 51 08 48
> RIP  [<ffffffff81095c96>] isolate_pages_global+0x196/0x260
>  RSP <ffff880011943c40>
> ---[ end trace fc1de39f3465335f ]---
> note: kswapd0[290] exited with preempt_count 1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
