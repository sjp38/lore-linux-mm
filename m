Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 450E36B0033
	for <linux-mm@kvack.org>; Sun, 22 Sep 2013 17:48:01 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so2441288pdj.40
        for <linux-mm@kvack.org>; Sun, 22 Sep 2013 14:48:00 -0700 (PDT)
Date: Thu, 19 Sep 2013 16:49:48 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: linux-3.10.12 dies after many allocation errors when copying
 lots of data to it over nfs. How to debug?
Message-ID: <20130919144948.GC20140@quack.suse.cz>
References: <20130918230514.1d0e0ac5@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130918230514.1d0e0ac5@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stevie Trujillo <stevie.trujillo@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-raid@vger.kernel.org, dm-devel@redhat.com, linux-nfs@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

  Hello,

On Wed 18-09-13 23:05:14, Stevie Trujillo wrote:
> my server dies when copying lots of data to it over nfs. I upgraded it to the
> latest stable kernel 3.10.12 (from 3.9.8), enabled netconsole and tried again.
> It died after 2-3 hours, but it looks like most of the call traces only show
> the stack used to send the netconsole message.
> 
> I have 6x 3TB harddrives (ST3000DM001-1CH166) configured like this:
> sd{a..f}3 <= mdadm raid6 <= lvm dm_crypt <= xfs (<= nfsd)
  Hum, that's rather complex storage stack. Can you reproduce the problem
with generating data directly on the server (e.g. by running 10 parallel
processes doing 'dd if=/dev/zero of=/your-fs bs=1M count=30000')?

My suspicion is that the dm_crypt target is what makes things unusual and
can lead to problems.

> To copy the files I run "rsync -av --progress ./300gb-folder /mnt/nfs-server/"
> from a faster computer. I think the server is having trouble keeping up.
> 
> What should I do to debug this? REPORTING-BUGS said I should narrow down the
> subsystem, so I picked the ones that seemed relevant in the MAINTAINERS file.
> 
> model name: Intel(R) Core(TM)2 Quad CPU @ 2.40GHz
> RAM: 4GiB (~500MiB used in htop)
> Network speed: 1000mbit/s
> 00:1f.2 SATA controller: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH) 6 port SATA Controller [AHCI mode] (rev 02)
> 03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168 PCI Express Gigabit Ethernet controller (rev 01)
> 
> Netconsole output:
> ~18:30 started copying
> Sep 18 20:48:55 [88988.266617] cron: page allocation failure: order:0, mode:0x20
> Sep 18 20:48:55 [88988.266651] CPU: 1 PID: 2634 Comm: cron Not tainted 3.10.12 #1
> Sep 18 20:48:55 [88988.266665] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:48:55 [88988.266685]  0000000000000020 ffff88010bc83bd8 ffffffff812665b6 ffff88010bc83c68 
> Sep 18 20:48:55 [88988.266716]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:48:55 [88988.266892]  ffffffff810507e7 0000000000000030 ffff8801060046b8 ffff88010bc83e84 
> Sep 18 20:48:55 [88988.267214] Call Trace:
> Sep 18 20:48:55 [88988.267368]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:48:55 [88988.267548]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:48:55 [88988.267712]  [<ffffffff810507e7>] ? update_sd_lb_stats+0x23f/0x481
> Sep 18 20:48:55 [88988.267876]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:48:55 [88988.268041]  [<ffffffff8104b701>] ? set_task_cpu+0x68/0xa4
> Sep 18 20:48:55 [88988.268201]  [<ffffffff8104fb00>] ? enqueue_task_fair+0x9e/0x130
> Sep 18 20:48:55 [88988.268367]  [<ffffffff811dd56b>] __netdev_alloc_frag+0x5b/0xff
> Sep 18 20:48:55 [88988.268528]  [<ffffffff811de266>] __netdev_alloc_skb+0x39/0x9a
> Sep 18 20:48:55 [88988.268705]  [<ffffffffa01b4c1a>] rtl8169_poll+0x21b/0x4cd [r8169]
> Sep 18 20:48:55 [88988.268866]  [<ffffffff8104f084>] ? sched_slice.isra.47+0x70/0x7f
> Sep 18 20:48:55 [88988.269030]  [<ffffffff811e825b>] net_rx_action+0xa3/0x181
> Sep 18 20:48:55 [88988.269193]  [<ffffffff81030da5>] __do_softirq+0xb7/0x16d
> Sep 18 20:48:55 [88988.269354]  [<ffffffff81030f2c>] irq_exit+0x3e/0x83
  All the allocation failures are for GFP_ATOMIC allocations. These are not
a fundamental problem - atomic allocations are expected to fail from time
to time. Although you get *lots* of them. So the culprit of the hang is
likely somewhere else. Any chance of setting up proper serial console or
taking a picture of VGA console?  Hopefully that would tell us something
more.

Anyway I'm CCing linux-mm as those guys could have better idea of where to
look.

								Honza

> Sep 18 20:48:55 [88988.269513] cron: page allocation failure: order:0, mode:0x200020
> Sep 18 20:48:55 [88988.269515] CPU: 1 PID: 2634 Comm: cron Not tainted 3.10.12 #1
> Sep 18 20:48:55 [88988.269516] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:48:55 [88988.269520]  0000000000200020 ffff88010bc83488 ffffffff812665b6 ffff88010bc83518
> Sep 18 20:48:55 [88988.269522]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffffffff00000002
> Sep 18 20:48:55 [88988.269525]  ffff88010bc834d0 ffffffff00000030 ffff88010bc834f0 0000000000000082
> Sep 18 20:48:55 [88988.269526] Call Trace:
> Sep 18 20:48:55 [88988.269529]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:48:55 [88988.269532]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:48:55 [88988.269536]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:48:55 [88988.269540]  [<ffffffff8113fe00>] ? vsnprintf+0x37d/0x435
> Sep 18 20:48:55 [88988.269544]  [<ffffffff810aca3b>] alloc_slab_page+0x21/0x23
> Sep 18 20:48:55 [88988.269547]  [<ffffffff810acab2>] new_slab+0x75/0x1ba
> Sep 18 20:48:55 [88988.269550]  [<ffffffff81265d1b>] __slab_alloc.constprop.71+0x12e/0x3f5
> Sep 18 20:48:55 [88988.269552]  [<ffffffff811de030>] ? __alloc_skb+0x44/0x19e
> Sep 18 20:48:55 [88988.269556]  [<ffffffff810af5d2>] ? __kmalloc_track_caller+0x3c/0xc8
> Sep 18 20:48:55 [88988.269558]  [<ffffffff810ae3d7>] kmem_cache_alloc+0x3b/0x91
> Sep 18 20:48:55 [88988.269561]  [<ffffffff811de030>] __alloc_skb+0x44/0x19e
> Sep 18 20:48:55 [88988.269565]  [<ffffffff811fafe5>] find_skb.isra.25+0x35/0x7e
> Sep 18 20:48:55 [88988.269567]  [<ffffffff811fb08b>] netpoll_send_udp+0x5d/0x334
> Sep 18 20:48:55 [88988.269572]  [<ffffffffa07a2728>] write_msg+0xb7/0xec [netconsole]
> Sep 18 20:48:55 [88988.269576]  [<ffffffff8102b8b4>] call_console_drivers.constprop.23+0x75/0x80
> Sep 18 20:48:55 [88988.269579]  [<ffffffff8102c8ea>] console_unlock+0x268/0x2fa
> Sep 18 20:48:55 [88988.269582]  [<ffffffff8102ce61>] vprintk_emit+0x347/0x372
> Sep 18 20:48:57 [88988.269585]  [<ffffffff81030f2c>] ? irq_exit+0x3e/0x83
> Sep 18 20:48:57 [88988.269588]  [<ffffffff812642d4>] printk+0x48/0x4a
> Sep 18 20:48:57 [88988.269590]  [<ffffffff81030f2c>] ? irq_exit+0x3e/0x83
> Sep 18 20:48:57 [88988.269593]  [<ffffffff81030f2c>] ? irq_exit+0x3e/0x83
> Sep 18 20:48:57 [88988.269596]  [<ffffffff81004f89>] printk_address+0x2c/0x2e
> Sep 18 20:48:57 [88988.269599]  [<ffffffff81004faa>] print_trace_address+0x1f/0x24
> Sep 18 20:48:57 [88988.269601]  [<ffffffff81004e85>] print_context_stack+0x67/0xb1
> Sep 18 20:49:01 [88993.386206] warn_alloc_failed: 11056 callbacks suppressed
> Sep 18 20:49:01 [88993.386409] kworker/1:22: page allocation failure: order:0, mode:0x20
> Sep 18 20:49:01 [88993.386572] CPU: 1 PID: 804 Comm: kworker/1:22 Not tainted 3.10.12 #1
> Sep 18 20:49:01 [88993.386733] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:49:01 [88993.387066] Workqueue: kcryptd kcryptd_crypt [dm_crypt] 
> Sep 18 20:49:01 [88993.387228]  0000000000000020 ffff88010bc83bd8 ffffffff812665b6 ffff88010bc83c68
> Sep 18 20:49:01 [88993.387402] kworker/1:22: page allocation failure: order:0, mode:0x200020
> Sep 18 20:49:01 [88993.387404] CPU: 1 PID: 804 Comm: kworker/1:22 Not tainted 3.10.12 #1
> Sep 18 20:49:01 [88993.387405] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:49:01 [88993.387409] Workqueue: kcryptd kcryptd_crypt [dm_crypt] 
> Sep 18 20:49:01 [88993.387411]  0000000000200020 ffff88010bc835e8 ffffffff812665b6 ffff88010bc83678 
> Sep 18 20:49:01 [88993.387414]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:49:01 [88993.387417]  ffffffff811de030 ffff880100000030 0000000000000096 ffff88010bc93f0a 
> Sep 18 20:49:01 [88993.387420] Call Trace:
> Sep 18 20:49:01 [88993.387422]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:49:01 [88993.387430]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:49:01 [88993.387435]  [<ffffffff811de030>] ? __alloc_skb+0x44/0x19e
> Sep 18 20:49:01 [88993.387440]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:49:01 [88993.387443]  [<ffffffff8113fafa>] ? vsnprintf+0x77/0x435
> Sep 18 20:49:07 [88999.386191] warn_alloc_failed: 23962 callbacks suppressed
> Sep 18 20:49:07 [88999.386385] __slab_alloc: 23956 callbacks suppressed
> Sep 18 20:49:07 [88999.386386] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.386388]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.386390]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:49:07 [88999.386559] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.386561]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.386562]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:49:07 [88999.386565] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.386567]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.386568]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:49:07 [88999.386728] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.386730]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.386732]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:49:07 [88999.386734] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.386736]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.386737]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:49:07 [88999.387047] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.387049]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.387050]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:49:07 [88999.387053] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.387055]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.387056]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:49:07 [88999.387215] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.387217]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.387219]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:49:07 [88999.387221] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.387223]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.387224]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:49:07 [88999.387385] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:49:07 [88999.387387]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:49:07 [88999.387388]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:50:19 [89071.386168] warn_alloc_failed: 12487 callbacks suppressed
> Sep 18 20:50:19 [89071.386361] imap-login: page allocation failure: order:0, mode:0x20
> Sep 18 20:50:19 [89071.386524] CPU: 3 PID: 28011 Comm: imap-login Not tainted 3.10.12 #1
> Sep 18 20:50:19 [89071.386686] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:19 [89071.386997]  0000000000000020 ffff88010bd83bd8 ffffffff812665b6 ffff88010bd83c68 
> Sep 18 20:50:19 [89071.387320]  ffffffff81085fbb
> Sep 18 20:50:19 [89071.387330] imap-login: page allocation failure: order:0, mode:0x200020
> Sep 18 20:50:19 [89071.387333] CPU: 3 PID: 28011 Comm: imap-login Not tainted 3.10.12 #1
> Sep 18 20:50:19 [89071.387334] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:19 [89071.387335]  0000000000200020 ffff88010bd835e8 ffffffff812665b6 ffff88010bd83678 
> Sep 18 20:50:19 [89071.387338]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:50:19 [89071.387341]  ffffffffa01b3e25 ffff880100000030 ffff88010328e700 0000000180100010 
> Sep 18 20:50:19 [89071.387345] Call Trace:
> Sep 18 20:50:19 [89071.387346]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:50:19 [89071.387356]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:50:19 [89071.387371]  [<ffffffffa01b3e25>] ? dma_map_single_attrs.constprop.96+0x71/0x7c [r8169]
> Sep 18 20:50:19 [89071.387379]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:19 [89071.387383]  [<ffffffff81008879>] ? native_sched_clock+0x39/0x3b
> Sep 18 20:50:19 [89071.387387]  [<ffffffff8104b112>] ? resched_task+0x36/0x60
> Sep 18 20:50:24 [89077.080411] warn_alloc_failed: 23061 callbacks suppressed
> Sep 18 20:50:24 [89077.080611] cron: page allocation failure: order:0, mode:0x20
> Sep 18 20:50:24 [89077.080775] CPU: 1 PID: 2634 Comm: cron Not tainted 3.10.12 #1
> Sep 18 20:50:24 [89077.080936] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:24 [89077.081246]  0000000000000020 ffff88010bc83bd8 ffffffff812665b6 ffff88010bc83c68 
> Sep 18 20:50:24 [89077.081568]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:50:24 [89077.081890]  ffffffff810507e7 0000000000000030
> Sep 18 20:50:24 [89077.081905] cron: page allocation failure: order:0, mode:0x200020
> Sep 18 20:50:24 [89077.081907] CPU: 1 PID: 2634 Comm: cron Not tainted 3.10.12 #1
> Sep 18 20:50:24 [89077.081909] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:24 [89077.081910]  0000000000200020 ffff88010bc835e8 ffffffff812665b6 ffff88010bc83678 
> Sep 18 20:50:24 [89077.081913]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:50:24 [89077.081916]  ffffffff811de030 ffff880100000030 0000000000000096 ffff88010bc93f0a 
> Sep 18 20:50:24 [89077.081919] Call Trace:
> Sep 18 20:50:24 [89077.081921]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:50:24 [89077.081931]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:50:24 [89077.081937]  [<ffffffff811de030>] ? __alloc_skb+0x44/0x19e
> Sep 18 20:50:24 [89077.081942]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:24 [89077.081945]  [<ffffffff81008879>] ? native_sched_clock+0x39/0x3b
> Sep 18 20:50:24 [89077.081949]  [<ffffffff8104b112>] ? resched_task+0x36/0x60
> Sep 18 20:50:29 [89082.130410] warn_alloc_failed: 23399 callbacks suppressed
> Sep 18 20:50:29 [89082.130608] mdadm: page allocation failure: order:0, mode:0x20
> Sep 18 20:50:29 [89082.130773] CPU: 3 PID: 6622 Comm: mdadm Not tainted 3.10.12 #1
> Sep 18 20:50:29 [89082.130933] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:29 [89082.131245]  0000000000000020 ffff88010bd83bd8 ffffffff812665b6 ffff88010bd83c68 
> Sep 18 20:50:29 [89082.131566]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:50:29 [89082.131886]  ffffffff81210acc 0000000000000030 ffff880100000000 ffff88010bd83c38 
> Sep 18 20:50:29 [89082.132208] Call Trace:
> Sep 18 20:50:29 [89082.132362]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:50:29 [89082.132538] mdadm: page allocation failure: order:0, mode:0x200020
> Sep 18 20:50:29 [89082.132541] CPU: 3 PID: 6622 Comm: mdadm Not tainted 3.10.12 #1
> Sep 18 20:50:29 [89082.132542] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:29 [89082.132545]  0000000000200020 ffff88010bd83488 ffffffff812665b6 ffff88010bd83518
> Sep 18 20:50:29 [89082.132548]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002
> Sep 18 20:50:29 [89082.132550]  ffffffff8108817a ffffffff00000030 ffffffff00000000 ffffffff813b5e68
> Sep 18 20:50:29 [89082.132551] Call Trace:
> Sep 18 20:50:29 [89082.132555]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:50:29 [89082.132561]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:50:29 [89082.132564]  [<ffffffff8108817a>] ? __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:29 [89082.132567]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:29 [89082.132572]  [<ffffffff8113fe00>] ? vsnprintf+0x37d/0x435
> Sep 18 20:50:29 [89082.132576]  [<ffffffff810aca3b>] alloc_slab_page+0x21/0x23
> Sep 18 20:50:29 [89082.132579]  [<ffffffff810acab2>] new_slab+0x75/0x1ba
> Sep 18 20:50:29 [89082.132582]  [<ffffffff81265d1b>] __slab_alloc.constprop.71+0x12e/0x3f5
> Sep 18 20:50:29 [89082.132587]  [<ffffffff811de030>] ? __alloc_skb+0x44/0x19e
> Sep 18 20:50:29 [89082.132590]  [<ffffffff8113f527>] ? symbol_string.isra.8+0x7c/0xa2
> Sep 18 20:50:29 [89082.132593]  [<ffffffff810ae3d7>] kmem_cache_alloc+0x3b/0x91
> Sep 18 20:50:29 [89082.132596]  [<ffffffff811de030>] __alloc_skb+0x44/0x19e
> Sep 18 20:50:29 [89082.132599]  [<ffffffff811fafe5>] find_skb.isra.25+0x35/0x7e
> Sep 18 20:50:29 [89082.132602]  [<ffffffff811fb08b>] netpoll_send_udp+0x5d/0x334
> Sep 18 20:50:29 [89082.132607]  [<ffffffffa07a2728>] write_msg+0xb7/0xec [netconsole]
> Sep 18 20:50:29 [89082.132613]  [<ffffffff8102b8b4>] call_console_drivers.constprop.23+0x75/0x80
> Sep 18 20:50:29 [89082.132616]  [<ffffffff8102c7b9>] console_unlock+0x137/0x2fa
> Sep 18 20:50:29 [89082.132620]  [<ffffffff81047ddf>] ? down_trylock+0x27/0x32
> Sep 18 20:50:32 [89082.132623]  [<ffffffff8102ce61>] vprintk_emit+0x347/0x372
> Sep 18 20:50:32 [89082.132626]  [<ffffffff812665b6>] ? dump_stack+0x19/0x1b
> Sep 18 20:50:32 [89082.132629]  [<ffffffff812642d4>] printk+0x48/0x4a
> Sep 18 20:50:32 [89082.132631]  [<ffffffff812665b6>] ? dump_stack+0x19/0x1b
> Sep 18 20:50:32 [89082.132634]  [<ffffffff812665b6>] ? dump_stack+0x19/0x1b
> Sep 18 20:50:32 [89082.132638]  [<ffffffff81004f89>] printk_address+0x2c/0x2e
> Sep 18 20:50:36 [89088.795176] warn_alloc_failed: 11990 callbacks suppressed
> Sep 18 20:50:36 [89088.795367] __slab_alloc: 11988 callbacks suppressed
> Sep 18 20:50:36 [89088.795369] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:50:36 [89088.795372]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:50:36 [89088.795374]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:50:36 [89088.795376] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:50:36 [89088.795378]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:50:36 [89088.795380]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:50:36 [89088.795551] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:50:36 [89088.795553]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:50:36 [89088.795554]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:50:36 [89088.795557] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:50:36 [89088.795558]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:50:36 [89088.795560]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:50:36 [89088.795721] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:50:36 [89088.795723]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:50:36 [89088.795725]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:50:36 [89088.795727] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:50:36 [89088.795729]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:50:36 [89088.795730]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:50:36 [89088.796041] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:50:36 [89088.796042]   cache: kmalloc-256, object size: 256, buffer size: 256, default order: 0, min order: 0
> Sep 18 20:50:36 [89088.796044]   node 0: slabs: 468, objs: 7488, free: 0
> Sep 18 20:50:36 [89088.796046] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> Sep 18 20:50:47 [89099.862556] warn_alloc_failed: 10377 callbacks suppressed
> Sep 18 20:50:47 [89099.862757] mdadm: page allocation failure: order:0, mode:0x20
> Sep 18 20:50:47 [89099.862919] CPU: 3 PID: 6622 Comm: mdadm Not tainted 3.10.12 #1
> Sep 18 20:50:47 [89099.863081] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:47 [89099.863390]  0000000000000020 ffff88010bd83bd8 ffffffff812665b6 ffff88010bd83c68 
> Sep 18 20:50:47 [89099.863714]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:50:47 [89099.864037]  ffffffff810507e7 0000000000000030 ffff8801060046b8 ffff88010bd83e84 
> Sep 18 20:50:47 [89099.864361] Call Trace:
> Sep 18 20:50:47 [89099.864516]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:50:47 [89099.864694]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:50:47 [89099.864857]  [<ffffffff810507e7>] ? update_sd_lb_stats+0x23f/0x481
> Sep 18 20:50:47 [89099.865019]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:47 [89099.865182]  [<ffffffff81050a00>] ? update_sd_lb_stats+0x458/0x481
> Sep 18 20:50:47 [89099.865347]  [<ffffffff811dd56b>] __netdev_alloc_frag+0x5b/0xff
> Sep 18 20:50:47 [89099.865508]  [<ffffffff811de266>] __netdev_alloc_skb+0x39/0x9a
> Sep 18 20:50:47 [89099.865685]  [<ffffffffa01b4c1a>] rtl8169_poll+0x21b/0x4cd [r8169]
> Sep 18 20:50:47 [89099.865849]  [<ffffffff8104a980>] ? __wake_up+0x3f/0x48
> Sep 18 20:50:47 [89099.866011]  [<ffffffff811e825b>] net_rx_action+0xa3/0x181
> Sep 18 20:50:47 [89099.866175]  [<ffffffff81030da5>] __do_softirq+0xb7/0x16d
> Sep 18 20:50:47 [89099.866336]  [<ffffffff81030f2c>] irq_exit+0x3e/0x83
> Sep 18 20:50:47 [89099.866496]  [<ffffffff81003c7c>] do_IRQ+0x89/0xa0
> Sep 18 20:50:47 [89099.866657]  [<ffffffff8126906a>] common_interrupt+0x6a/0x6a
> Sep 18 20:50:47 [89099.866818]  <EOI>  [<ffffffff8108c8e1>] ? __isolate_lru_page+0x97/0xa5
> Sep 18 20:50:47 [89099.866990]  [<ffffffff8108bf40>] ? spin_unlock_irq+0x9/0xa
> Sep 18 20:50:47 [89099.867151]  [<ffffffff8108db93>] ? shrink_inactive_list+0x1be/0x2c0
> Sep 18 20:50:47 [89099.867315]  [<ffffffff8108e042>] shrink_zone+0x3ad/0x4e6
> Sep 18 20:50:47 [89099.867477]  [<ffffffff8108e9a3>] try_to_free_pages+0x1f8/0x41b
> Sep 18 20:50:47 [89099.867639]  [<ffffffff81088256>] __alloc_pages_nodemask+0x3b2/0x5d9
> Sep 18 20:50:47 [89099.867804]  [<ffffffff8109acd9>] handle_pte_fault+0x156/0x5dc
> Sep 18 20:50:47 [89099.867968]  [<ffffffff8113ef8b>] ? number.isra.1+0x140/0x26a
> Sep 18 20:50:47 [89099.868128] mdadm: page allocation failure: order:0, mode:0x200020
> Sep 18 20:50:47 [89099.868131] CPU: 3 PID: 6622 Comm: mdadm Not tainted 3.10.12 #1
> Sep 18 20:50:47 [89099.868132] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:49 [89099.868135]  0000000000200020 ffff88010bd83488 ffffffff812665b6 ffff88010bd83518
> Sep 18 20:50:49 [89099.868138]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002
> Sep 18 20:50:49 [89099.868140]  ffffffff8108817a ffffffff00000030 ffffffff00000000 ffffffff813b5e68
> Sep 18 20:50:49 [89099.868141] Call Trace:
> Sep 18 20:50:49 [89099.868145]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:50:49 [89099.868148]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:50:49 [89099.868151]  [<ffffffff8108817a>] ? __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:49 [89099.868154]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:49 [89099.868157]  [<ffffffff8113fe00>] ? vsnprintf+0x37d/0x435
> Sep 18 20:50:49 [89099.868161]  [<ffffffff810aca3b>] alloc_slab_page+0x21/0x23
> Sep 18 20:50:49 [89099.868163]  [<ffffffff810acab2>] new_slab+0x75/0x1ba
> Sep 18 20:50:49 [89099.868166]  [<ffffffff81265d1b>] __slab_alloc.constprop.71+0x12e/0x3f5
> Sep 18 20:50:49 [89099.868169]  [<ffffffff811de030>] ? __alloc_skb+0x44/0x19e
> Sep 18 20:50:49 [89099.868172]  [<ffffffff810af5d2>] ? __kmalloc_track_caller+0x3c/0xc8
> Sep 18 20:50:49 [89099.868175]  [<ffffffff810ae3d7>] kmem_cache_alloc+0x3b/0x91
> Sep 18 20:50:49 [89099.868178]  [<ffffffff811de030>] __alloc_skb+0x44/0x19e
> Sep 18 20:50:49 [89099.868181]  [<ffffffff811fafe5>] find_skb.isra.25+0x35/0x7e
> Sep 18 20:50:49 [89099.868184]  [<ffffffff811fb08b>] netpoll_send_udp+0x5d/0x334
> Sep 18 20:50:49 [89099.868188]  [<ffffffffa07a2728>] write_msg+0xb7/0xec [netconsole]
> Sep 18 20:50:49 [89099.868193]  [<ffffffff8102b8b4>] call_console_drivers.constprop.23+0x75/0x80
> Sep 18 20:50:49 [89099.868196]  [<ffffffff8102c8ea>] console_unlock+0x268/0x2fa
> Sep 18 20:50:49 [89099.868199]  [<ffffffff8102ce61>] vprintk_emit+0x347/0x372
> Sep 18 20:50:49 [89099.868202]  [<ffffffff8113ef8b>] ? number.isra.1+0x140/0x26a
> Sep 18 20:50:49 [89099.868205]  [<ffffffff812642d4>] printk+0x48/0x4a
> Sep 18 20:50:49 [89099.868208]  [<ffffffff8113ef8b>] ? number.isra.1+0x140/0x26a
> Sep 18 20:50:49 [89099.868211]  [<ffffffff8113ef8b>] ? number.isra.1+0x140/0x26a
> Sep 18 20:50:49 [89099.868214]  [<ffffffff81004f89>] printk_address+0x2c/0x2e
> Sep 18 20:50:49 [89099.868217]  [<ffffffff81004faa>] print_trace_address+0x1f/0x24
> Sep 18 20:50:52 [89105.179845] warn_alloc_failed: 11525 callbacks suppressed
> Sep 18 20:50:52 [89105.180003] pickup: page allocation failure: order:0, mode:0x20
> Sep 18 20:50:52 [89105.180003] CPU: 3 PID: 31502 Comm: pickup Not tainted 3.10.12 #1
> Sep 18 20:50:52 [89105.180003] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:52 [89105.180003]  0000000000000020 ffff88010bd83bd8 ffffffff812665b6
> Sep 18 20:50:52 [89105.180003] pickup: page allocation failure: order:0, mode:0x200020
> Sep 18 20:50:52 [89105.180003] CPU: 3 PID: 31502 Comm: pickup Not tainted 3.10.12 #1
> Sep 18 20:50:52 [89105.180003] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:52 [89105.180003]  0000000000200020 ffff88010bd835e8 ffffffff812665b6 ffff88010bd83678 
> Sep 18 20:50:52 [89105.180003]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:50:52 [89105.180003]  ffffffff811de030 ffff880100000030 0000000000000096 ffff88010bd93f0a 
> Sep 18 20:50:52 [89105.180003] Call Trace:
> Sep 18 20:50:52 [89105.180003]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:50:52 [89105.180003]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:50:52 [89105.180003]  [<ffffffff811de030>] ? __alloc_skb+0x44/0x19e
> Sep 18 20:50:52 [89105.180003]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:52 [89105.180003]  [<ffffffff81008879>] ? native_sched_clock+0x39/0x3b
> Sep 18 20:50:52 [89105.180003]  [<ffffffff8104b112>] ? resched_task+0x36/0x60
> Sep 18 20:50:58 [89111.221781] warn_alloc_failed: 23515 callbacks suppressed
> Sep 18 20:50:58 [89111.221985] nfsd: page allocation failure: order:0, mode:0x20
> Sep 18 20:50:58 [89111.222148] CPU: 1 PID: 6816 Comm: nfsd Not tainted 3.10.12 #1
> Sep 18 20:50:58 [89111.222309] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:58 [89111.222619]  0000000000000020 ffff88010bc83bd8 ffffffff812665b6 ffff88010bc83c68 
> Sep 18 20:50:58 [89111.222941]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:50:58 [89111.223263]  ffffffff810507e7 0000000000000030 ffff8801060046b8 ffff88010bc83e84 
> Sep 18 20:50:58 [89111.223584] Call Trace:
> Sep 18 20:50:58 [89111.223739]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:50:58 [89111.223917]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:50:58 [89111.224082]  [<ffffffff810507e7>] ? update_sd_lb_stats+0x23f/0x481
> Sep 18 20:50:58 [89111.224245]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:58 [89111.224407]  [<ffffffff81050a00>] ? update_sd_lb_stats+0x458/0x481
> Sep 18 20:50:58 [89111.224568] nfsd: page allocation failure: order:0, mode:0x200020
> Sep 18 20:50:58 [89111.224570] CPU: 1 PID: 6816 Comm: nfsd Not tainted 3.10.12 #1
> Sep 18 20:50:58 [89111.224571] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:50:58 [89111.224575]  0000000000200020 ffff88010bc83488 ffffffff812665b6 ffff88010bc83518
> Sep 18 20:50:58 [89111.224577]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002
> Sep 18 20:50:58 [89111.224580]  ffffffff8108817a ffffffff00000030 ffffffff00000000 ffffffff813b5e68
> Sep 18 20:50:58 [89111.224581] Call Trace:
> Sep 18 20:50:58 [89111.224584]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:50:58 [89111.224587]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:50:58 [89111.224590]  [<ffffffff8108817a>] ? __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:58 [89111.224593]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:50:58 [89111.224598]  [<ffffffff8113fe00>] ? vsnprintf+0x37d/0x435
> Sep 18 20:50:58 [89111.224602]  [<ffffffff810aca3b>] alloc_slab_page+0x21/0x23
> Sep 18 20:50:58 [89111.224605]  [<ffffffff810acab2>] new_slab+0x75/0x1ba
> Sep 18 20:50:58 [89111.224608]  [<ffffffff81265d1b>] __slab_alloc.constprop.71+0x12e/0x3f5
> Sep 18 20:50:58 [89111.224612]  [<ffffffff811de030>] ? __alloc_skb+0x44/0x19e
> Sep 18 20:50:58 [89111.224615]  [<ffffffff810af5d2>] ? __kmalloc_track_caller+0x3c/0xc8
> Sep 18 20:50:58 [89111.224618]  [<ffffffff810ae3d7>] kmem_cache_alloc+0x3b/0x91
> Sep 18 20:50:58 [89111.224621]  [<ffffffff811de030>] __alloc_skb+0x44/0x19e
> Sep 18 20:50:58 [89111.224625]  [<ffffffff811fafe5>] find_skb.isra.25+0x35/0x7e
> Sep 18 20:50:58 [89111.224628]  [<ffffffff811fb08b>] netpoll_send_udp+0x5d/0x334
> Sep 18 20:51:01 [89111.224633]  [<ffffffffa07a2728>] write_msg+0xb7/0xec [netconsole]
> Sep 18 20:51:01 [89111.224639]  [<ffffffff8102b8b4>] call_console_drivers.constprop.23+0x75/0x80
> Sep 18 20:51:01 [89111.224642]  [<ffffffff8102c8ea>] console_unlock+0x268/0x2fa
> Sep 18 20:51:01 [89111.224645]  [<ffffffff8102ce61>] vprintk_emit+0x347/0x372
> Sep 18 20:51:01 [89111.224648]  [<ffffffff81050a00>] ? update_sd_lb_stats+0x458/0x481
> Sep 18 20:51:01 [89111.224651]  [<ffffffff812642d4>] printk+0x48/0x4a
> Sep 18 20:51:01 [89111.224653]  [<ffffffff81050a00>] ? update_sd_lb_stats+0x458/0x481
> Sep 18 20:51:01 [89111.224656]  [<ffffffff81050a00>] ? update_sd_lb_stats+0x458/0x481
> Sep 18 20:51:01 [89111.224659]  [<ffffffff81004f89>] printk_address+0x2c/0x2e
> Sep 18 20:51:01 [89111.224662]  [<ffffffff81004faa>] print_trace_address+0x1f/0x24
> Sep 18 20:51:05 [89117.669846] warn_alloc_failed: 13808 callbacks suppressed
> Sep 18 20:51:05 [89117.670033] kworker/3:1: page allocation failure: order:0, mode:0x20
> Sep 18 20:51:05 [89117.670033] CPU: 3 PID: 1917 Comm: kworker/3:1 Not tainted 3.10.12 #1
> Sep 18 20:51:05 [89117.670033] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:51:05 [89117.670033] Workqueue: kcryptd kcryptd_crypt [dm_crypt] 
> Sep 18 20:51:05 [89117.670033]  0000000000000020 ffff88010bd83bd8 ffffffff812665b6 ffff88010bd83c68 
> Sep 18 20:51:05 [89117.670033]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002 
> Sep 18 20:51:05 [89117.670033]  ffffffff810507e7 0000000000000030 ffff8801060046b8 ffff88010bd83e84 
> Sep 18 20:51:05 [89117.670033] Call Trace:
> Sep 18 20:51:05 [89117.670033]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:51:05 [89117.670033]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:51:05 [89117.670033]  [<ffffffff810507e7>] ? update_sd_lb_stats+0x23f/0x481
> Sep 18 20:51:05 [89117.670033]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:51:05 [89117.670033]  [<ffffffff81050a00>] ? update_sd_lb_stats+0x458/0x481
> Sep 18 20:51:05 [89117.670033]  [<ffffffff811dd56b>] __netdev_alloc_frag+0x5b/0xff
> Sep 18 20:51:05 [89117.670033]  [<ffffffff811de266>] __netdev_alloc_skb+0x39/0x9a
> Sep 18 20:51:05 [89117.670033]  [<ffffffffa01b4c1a>] rtl8169_poll+0x21b/0x4cd [r8169]
> Sep 18 20:51:05 [89117.670033] kworker/3:1: page allocation failure: order:0, mode:0x200020
> Sep 18 20:51:05 [89117.670033] CPU: 3 PID: 1917 Comm: kworker/3:1 Not tainted 3.10.12 #1
> Sep 18 20:51:05 [89117.670033] Hardware name: Gigabyte Technology Co., Ltd. P35-DS4/P35-DS4, BIOS F14 06/19/2009
> Sep 18 20:51:05 [89117.670033] Workqueue: kcryptd kcryptd_crypt [dm_crypt]
> Sep 18 20:51:05 [89117.670033]  0000000000200020 ffff88010bd83488 ffffffff812665b6 ffff88010bd83518
> Sep 18 20:51:05 [89117.670033]  ffffffff81085fbb ffffffff813b5e78 0000000000000010 ffff880100000002
> Sep 18 20:51:05 [89117.670033]  ffffffff8108817a ffffffff00000030 ffffffff00000000 ffffffff813b5e68
> Sep 18 20:51:05 [89117.670033] Call Trace:
> Sep 18 20:51:05 [89117.670033]  <IRQ>  [<ffffffff812665b6>] dump_stack+0x19/0x1b
> Sep 18 20:51:05 [89117.670033]  [<ffffffff81085fbb>] warn_alloc_failed+0x110/0x124
> Sep 18 20:51:05 [89117.670033]  [<ffffffff8108817a>] ? __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:51:05 [89117.670033]  [<ffffffff8108817a>] __alloc_pages_nodemask+0x2d6/0x5d9
> Sep 18 20:51:05 [89117.670033]  [<ffffffff8113f0f2>] ? string.isra.3+0x3d/0xa2
> Sep 18 20:51:05 [89117.670033]  [<ffffffff8113fa00>] ? pointer.isra.11+0x1b2/0x235
> Sep 18 20:51:05 [89117.670033]  [<ffffffff810aca3b>] alloc_slab_page+0x21/0x23
> Sep 18 20:51:05 [89117.670033]  [<ffffffff810acab2>] new_slab+0x75/0x1ba
> Sep 18 20:51:05 [89117.670033]  [<ffffffff81265d1b>] __slab_alloc.constprop.71+0x12e/0x3f5
> Sep 18 20:51:05 [89117.670033]  [<ffffffff811de030>] ? __alloc_skb+0x44/0x19e
> Sep 18 20:51:05 [89117.670033]  [<ffffffff810ae3d7>] kmem_cache_alloc+0x3b/0x91
> Sep 18 20:51:05 [89117.670033]  [<ffffffff811de030>] __alloc_skb+0x44/0x19e
> Sep 18 20:51:05 [89117.670033]  [<ffffffff811fafe5>] find_skb.isra.25+0x35/0x7e
> Sep 18 20:51:05 [89117.670033]  [<ffffffff811fb08b>] netpoll_send_udp+0x5d/0x334
> Sep 18 20:51:05 [89117.670033]  [<ffffffffa07a2728>] write_msg+0xb7/0xec [netconsole]
> Sep 18 20:51:05 [89117.670033]  [<ffffffff8102b8b4>] call_console_drivers.constprop.23+0x75/0x80
> Sep 18 20:51:05 [89117.670033]  [<ffffffff8102c8ea>] console_unlock+0x268/0x2fa
> Sep 18 20:51:05 [89117.670033]  [<ffffffff8102ce61>] vprintk_emit+0x347/0x372
> Sep 18 20:51:05 [89117.670033]  [<ffffffffa01b4c1a>] ? rtl8169_poll+0x21b/0x4cd [r8169]
> Sep 18 20:51:05 [89117.670033]  [<ffffffff812642d4>] printk+0x48/0x4a
> Sep 18 20:51:05 [89117.670033]  [<ffffffffa01b4c1a>] ? rtl8169_poll+0x21b/0x4cd [r8169]
> Sep 18 20:51:05 [89117.670033]  [<ffffffffa01b4c1a>] ? rtl8169_poll+0x21b/0x4cd [r8169]
>  21:06 No route to host
> ~21:30 discovered it was dead
> 
> REPORTING-BUGS 4.1: Kernel version (from /proc/version):
> Linux version 3.10.12 (root@server) (gcc version 4.7.3 (Gentoo 4.7.3 p1.0, pie-0.5.5) ) #1 SMP Mon Sep 16 12:57:50 CEST 2013
> 
> REPORTING-BUGS 4.2: Kernel .config file:
> #
> # Automatically generated file; DO NOT EDIT.
> # Linux/x86 3.10.12 Kernel Configuration
> #
> CONFIG_64BIT=y
> CONFIG_X86_64=y
> CONFIG_X86=y
> CONFIG_INSTRUCTION_DECODER=y
> CONFIG_OUTPUT_FORMAT="elf64-x86-64"
> CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
> CONFIG_LOCKDEP_SUPPORT=y
> CONFIG_STACKTRACE_SUPPORT=y
> CONFIG_HAVE_LATENCYTOP_SUPPORT=y
> CONFIG_MMU=y
> CONFIG_NEED_DMA_MAP_STATE=y
> CONFIG_NEED_SG_DMA_LENGTH=y
> CONFIG_GENERIC_ISA_DMA=y
> CONFIG_GENERIC_BUG=y
> CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
> CONFIG_GENERIC_HWEIGHT=y
> CONFIG_ARCH_MAY_HAVE_PC_FDC=y
> CONFIG_RWSEM_XCHGADD_ALGORITHM=y
> CONFIG_GENERIC_CALIBRATE_DELAY=y
> CONFIG_ARCH_HAS_CPU_RELAX=y
> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
> CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
> CONFIG_HAVE_SETUP_PER_CPU_AREA=y
> CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
> CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
> CONFIG_ARCH_HIBERNATION_POSSIBLE=y
> CONFIG_ARCH_SUSPEND_POSSIBLE=y
> CONFIG_ZONE_DMA32=y
> CONFIG_AUDIT_ARCH=y
> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
> CONFIG_X86_64_SMP=y
> CONFIG_X86_HT=y
> CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
> CONFIG_ARCH_CPU_PROBE_RELEASE=y
> CONFIG_ARCH_SUPPORTS_UPROBES=y
> CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
> CONFIG_IRQ_WORK=y
> CONFIG_BUILDTIME_EXTABLE_SORT=y
> 
> #
> # General setup
> #
> CONFIG_INIT_ENV_ARG_LIMIT=32
> CONFIG_CROSS_COMPILE=""
> CONFIG_LOCALVERSION=""
> CONFIG_LOCALVERSION_AUTO=y
> CONFIG_HAVE_KERNEL_GZIP=y
> CONFIG_HAVE_KERNEL_BZIP2=y
> CONFIG_HAVE_KERNEL_LZMA=y
> CONFIG_HAVE_KERNEL_XZ=y
> CONFIG_HAVE_KERNEL_LZO=y
> # CONFIG_KERNEL_GZIP is not set
> # CONFIG_KERNEL_BZIP2 is not set
> # CONFIG_KERNEL_LZMA is not set
> CONFIG_KERNEL_XZ=y
> # CONFIG_KERNEL_LZO is not set
> CONFIG_DEFAULT_HOSTNAME="(none)"
> CONFIG_SWAP=y
> CONFIG_SYSVIPC=y
> CONFIG_SYSVIPC_SYSCTL=y
> CONFIG_POSIX_MQUEUE=y
> CONFIG_POSIX_MQUEUE_SYSCTL=y
> CONFIG_FHANDLE=y
> CONFIG_AUDIT=y
> # CONFIG_AUDITSYSCALL is not set
> # CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set
> CONFIG_HAVE_GENERIC_HARDIRQS=y
> 
> #
> # IRQ subsystem
> #
> CONFIG_GENERIC_HARDIRQS=y
> CONFIG_GENERIC_IRQ_PROBE=y
> CONFIG_GENERIC_IRQ_SHOW=y
> CONFIG_GENERIC_PENDING_IRQ=y
> CONFIG_IRQ_DOMAIN=y
> CONFIG_IRQ_FORCED_THREADING=y
> CONFIG_SPARSE_IRQ=y
> CONFIG_CLOCKSOURCE_WATCHDOG=y
> CONFIG_ARCH_CLOCKSOURCE_DATA=y
> CONFIG_GENERIC_TIME_VSYSCALL=y
> CONFIG_GENERIC_CLOCKEVENTS=y
> CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
> CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
> CONFIG_GENERIC_CMOS_UPDATE=y
> 
> #
> # Timers subsystem
> #
> CONFIG_TICK_ONESHOT=y
> CONFIG_NO_HZ_COMMON=y
> # CONFIG_HZ_PERIODIC is not set
> CONFIG_NO_HZ_IDLE=y
> # CONFIG_NO_HZ_FULL is not set
> CONFIG_NO_HZ=y
> CONFIG_HIGH_RES_TIMERS=y
> 
> #
> # CPU/Task time and stats accounting
> #
> CONFIG_TICK_CPU_ACCOUNTING=y
> # CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
> # CONFIG_IRQ_TIME_ACCOUNTING is not set
> # CONFIG_BSD_PROCESS_ACCT is not set
> CONFIG_TASKSTATS=y
> CONFIG_TASK_DELAY_ACCT=y
> CONFIG_TASK_XACCT=y
> CONFIG_TASK_IO_ACCOUNTING=y
> 
> #
> # RCU Subsystem
> #
> CONFIG_TREE_RCU=y
> # CONFIG_PREEMPT_RCU is not set
> CONFIG_RCU_STALL_COMMON=y
> # CONFIG_RCU_USER_QS is not set
> CONFIG_RCU_FANOUT=64
> CONFIG_RCU_FANOUT_LEAF=16
> # CONFIG_RCU_FANOUT_EXACT is not set
> # CONFIG_RCU_FAST_NO_HZ is not set
> # CONFIG_TREE_RCU_TRACE is not set
> # CONFIG_RCU_NOCB_CPU is not set
> CONFIG_IKCONFIG=y
> CONFIG_IKCONFIG_PROC=y
> CONFIG_LOG_BUF_SHIFT=18
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
> CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
> CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
> CONFIG_CGROUPS=y
> # CONFIG_CGROUP_DEBUG is not set
> # CONFIG_CGROUP_FREEZER is not set
> # CONFIG_CGROUP_DEVICE is not set
> # CONFIG_CPUSETS is not set
> # CONFIG_CGROUP_CPUACCT is not set
> # CONFIG_RESOURCE_COUNTERS is not set
> # CONFIG_CGROUP_PERF is not set
> # CONFIG_CGROUP_SCHED is not set
> CONFIG_BLK_CGROUP=y
> # CONFIG_DEBUG_BLK_CGROUP is not set
> # CONFIG_CHECKPOINT_RESTORE is not set
> CONFIG_NAMESPACES=y
> CONFIG_UTS_NS=y
> CONFIG_IPC_NS=y
> CONFIG_PID_NS=y
> CONFIG_NET_NS=y
> # CONFIG_SCHED_AUTOGROUP is not set
> # CONFIG_SYSFS_DEPRECATED is not set
> # CONFIG_RELAY is not set
> CONFIG_BLK_DEV_INITRD=y
> CONFIG_INITRAMFS_SOURCE=""
> CONFIG_RD_GZIP=y
> CONFIG_RD_BZIP2=y
> CONFIG_RD_LZMA=y
> CONFIG_RD_XZ=y
> CONFIG_RD_LZO=y
> CONFIG_CC_OPTIMIZE_FOR_SIZE=y
> CONFIG_SYSCTL=y
> CONFIG_ANON_INODES=y
> CONFIG_HAVE_UID16=y
> CONFIG_SYSCTL_EXCEPTION_TRACE=y
> CONFIG_HOTPLUG=y
> CONFIG_HAVE_PCSPKR_PLATFORM=y
> # CONFIG_EXPERT is not set
> CONFIG_UID16=y
> # CONFIG_SYSCTL_SYSCALL is not set
> CONFIG_KALLSYMS=y
> CONFIG_PRINTK=y
> CONFIG_BUG=y
> CONFIG_ELF_CORE=y
> CONFIG_PCSPKR_PLATFORM=y
> CONFIG_BASE_FULL=y
> CONFIG_FUTEX=y
> CONFIG_EPOLL=y
> CONFIG_SIGNALFD=y
> CONFIG_TIMERFD=y
> CONFIG_EVENTFD=y
> CONFIG_SHMEM=y
> CONFIG_AIO=y
> CONFIG_PCI_QUIRKS=y
> # CONFIG_EMBEDDED is not set
> CONFIG_HAVE_PERF_EVENTS=y
> 
> #
> # Kernel Performance Events And Counters
> #
> CONFIG_PERF_EVENTS=y
> CONFIG_VM_EVENT_COUNTERS=y
> CONFIG_SLUB_DEBUG=y
> # CONFIG_COMPAT_BRK is not set
> # CONFIG_SLAB is not set
> CONFIG_SLUB=y
> # CONFIG_PROFILING is not set
> CONFIG_HAVE_OPROFILE=y
> CONFIG_OPROFILE_NMI_TIMER=y
> # CONFIG_KPROBES is not set
> CONFIG_JUMP_LABEL=y
> # CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
> CONFIG_ARCH_USE_BUILTIN_BSWAP=y
> CONFIG_USER_RETURN_NOTIFIER=y
> CONFIG_HAVE_IOREMAP_PROT=y
> CONFIG_HAVE_KPROBES=y
> CONFIG_HAVE_KRETPROBES=y
> CONFIG_HAVE_OPTPROBES=y
> CONFIG_HAVE_KPROBES_ON_FTRACE=y
> CONFIG_HAVE_ARCH_TRACEHOOK=y
> CONFIG_HAVE_DMA_ATTRS=y
> CONFIG_USE_GENERIC_SMP_HELPERS=y
> CONFIG_GENERIC_SMP_IDLE_THREAD=y
> CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
> CONFIG_HAVE_DMA_API_DEBUG=y
> CONFIG_HAVE_HW_BREAKPOINT=y
> CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
> CONFIG_HAVE_USER_RETURN_NOTIFIER=y
> CONFIG_HAVE_PERF_EVENTS_NMI=y
> CONFIG_HAVE_PERF_REGS=y
> CONFIG_HAVE_PERF_USER_STACK_DUMP=y
> CONFIG_HAVE_ARCH_JUMP_LABEL=y
> CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
> CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
> CONFIG_HAVE_CMPXCHG_LOCAL=y
> CONFIG_HAVE_CMPXCHG_DOUBLE=y
> CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
> CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
> CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
> CONFIG_SECCOMP_FILTER=y
> CONFIG_HAVE_CONTEXT_TRACKING=y
> CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
> CONFIG_MODULES_USE_ELF_RELA=y
> CONFIG_OLD_SIGSUSPEND3=y
> CONFIG_COMPAT_OLD_SIGACTION=y
> 
> #
> # GCOV-based kernel profiling
> #
> # CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
> CONFIG_SLABINFO=y
> CONFIG_RT_MUTEXES=y
> CONFIG_BASE_SMALL=0
> CONFIG_MODULES=y
> CONFIG_MODULE_FORCE_LOAD=y
> CONFIG_MODULE_UNLOAD=y
> CONFIG_MODULE_FORCE_UNLOAD=y
> # CONFIG_MODVERSIONS is not set
> # CONFIG_MODULE_SRCVERSION_ALL is not set
> # CONFIG_MODULE_SIG is not set
> CONFIG_STOP_MACHINE=y
> CONFIG_BLOCK=y
> CONFIG_BLK_DEV_BSG=y
> # CONFIG_BLK_DEV_BSGLIB is not set
> # CONFIG_BLK_DEV_INTEGRITY is not set
> CONFIG_BLK_DEV_THROTTLING=y
> 
> #
> # Partition Types
> #
> CONFIG_PARTITION_ADVANCED=y
> # CONFIG_ACORN_PARTITION is not set
> # CONFIG_OSF_PARTITION is not set
> # CONFIG_AMIGA_PARTITION is not set
> # CONFIG_ATARI_PARTITION is not set
> # CONFIG_MAC_PARTITION is not set
> CONFIG_MSDOS_PARTITION=y
> # CONFIG_BSD_DISKLABEL is not set
> # CONFIG_MINIX_SUBPARTITION is not set
> # CONFIG_SOLARIS_X86_PARTITION is not set
> # CONFIG_UNIXWARE_DISKLABEL is not set
> # CONFIG_LDM_PARTITION is not set
> # CONFIG_SGI_PARTITION is not set
> # CONFIG_ULTRIX_PARTITION is not set
> # CONFIG_SUN_PARTITION is not set
> # CONFIG_KARMA_PARTITION is not set
> CONFIG_EFI_PARTITION=y
> # CONFIG_SYSV68_PARTITION is not set
> CONFIG_BLOCK_COMPAT=y
> 
> #
> # IO Schedulers
> #
> CONFIG_IOSCHED_NOOP=y
> CONFIG_IOSCHED_DEADLINE=y
> CONFIG_IOSCHED_CFQ=y
> CONFIG_CFQ_GROUP_IOSCHED=y
> CONFIG_DEFAULT_DEADLINE=y
> # CONFIG_DEFAULT_CFQ is not set
> # CONFIG_DEFAULT_NOOP is not set
> CONFIG_DEFAULT_IOSCHED="deadline"
> CONFIG_PREEMPT_NOTIFIERS=y
> CONFIG_PADATA=y
> CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
> CONFIG_INLINE_READ_UNLOCK=y
> CONFIG_INLINE_READ_UNLOCK_IRQ=y
> CONFIG_INLINE_WRITE_UNLOCK=y
> CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
> CONFIG_MUTEX_SPIN_ON_OWNER=y
> # CONFIG_FREEZER is not set
> 
> #
> # Processor type and features
> #
> CONFIG_ZONE_DMA=y
> CONFIG_SMP=y
> # CONFIG_X86_MPPARSE is not set
> # CONFIG_X86_EXTENDED_PLATFORM is not set
> # CONFIG_X86_INTEL_LPSS is not set
> CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
> CONFIG_SCHED_OMIT_FRAME_POINTER=y
> # CONFIG_HYPERVISOR_GUEST is not set
> CONFIG_NO_BOOTMEM=y
> # CONFIG_MEMTEST is not set
> # CONFIG_MK8 is not set
> # CONFIG_MPSC is not set
> CONFIG_MCORE2=y
> # CONFIG_MATOM is not set
> # CONFIG_GENERIC_CPU is not set
> CONFIG_X86_INTERNODE_CACHE_SHIFT=6
> CONFIG_X86_L1_CACHE_SHIFT=6
> CONFIG_X86_INTEL_USERCOPY=y
> CONFIG_X86_USE_PPRO_CHECKSUM=y
> CONFIG_X86_P6_NOP=y
> CONFIG_X86_TSC=y
> CONFIG_X86_CMPXCHG64=y
> CONFIG_X86_CMOV=y
> CONFIG_X86_MINIMUM_CPU_FAMILY=64
> CONFIG_X86_DEBUGCTLMSR=y
> CONFIG_CPU_SUP_INTEL=y
> CONFIG_CPU_SUP_AMD=y
> CONFIG_CPU_SUP_CENTAUR=y
> CONFIG_HPET_TIMER=y
> CONFIG_DMI=y
> CONFIG_GART_IOMMU=y
> # CONFIG_CALGARY_IOMMU is not set
> CONFIG_SWIOTLB=y
> CONFIG_IOMMU_HELPER=y
> CONFIG_NR_CPUS=8
> CONFIG_SCHED_SMT=y
> CONFIG_SCHED_MC=y
> CONFIG_PREEMPT_NONE=y
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
> CONFIG_X86_LOCAL_APIC=y
> CONFIG_X86_IO_APIC=y
> # CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
> CONFIG_X86_MCE=y
> CONFIG_X86_MCE_INTEL=y
> # CONFIG_X86_MCE_AMD is not set
> CONFIG_X86_MCE_THRESHOLD=y
> # CONFIG_X86_MCE_INJECT is not set
> CONFIG_X86_THERMAL_VECTOR=y
> # CONFIG_I8K is not set
> # CONFIG_MICROCODE is not set
> CONFIG_X86_MSR=y
> CONFIG_X86_CPUID=y
> CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
> CONFIG_ARCH_DMA_ADDR_T_64BIT=y
> CONFIG_DIRECT_GBPAGES=y
> # CONFIG_NUMA is not set
> CONFIG_ARCH_SPARSEMEM_ENABLE=y
> CONFIG_ARCH_SPARSEMEM_DEFAULT=y
> CONFIG_ARCH_SELECT_MEMORY_MODEL=y
> CONFIG_ARCH_PROC_KCORE_TEXT=y
> CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
> CONFIG_SELECT_MEMORY_MODEL=y
> CONFIG_SPARSEMEM_MANUAL=y
> CONFIG_SPARSEMEM=y
> CONFIG_HAVE_MEMORY_PRESENT=y
> CONFIG_SPARSEMEM_EXTREME=y
> CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
> CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
> CONFIG_SPARSEMEM_VMEMMAP=y
> CONFIG_HAVE_MEMBLOCK=y
> CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
> CONFIG_ARCH_DISCARD_MEMBLOCK=y
> # CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
> # CONFIG_MEMORY_HOTPLUG is not set
> CONFIG_PAGEFLAGS_EXTENDED=y
> CONFIG_SPLIT_PTLOCK_CPUS=4
> CONFIG_COMPACTION=y
> CONFIG_MIGRATION=y
> CONFIG_PHYS_ADDR_T_64BIT=y
> CONFIG_ZONE_DMA_FLAG=1
> CONFIG_BOUNCE=y
> CONFIG_VIRT_TO_BUS=y
> CONFIG_MMU_NOTIFIER=y
> # CONFIG_KSM is not set
> CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
> CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
> # CONFIG_MEMORY_FAILURE is not set
> # CONFIG_TRANSPARENT_HUGEPAGE is not set
> CONFIG_CROSS_MEMORY_ATTACH=y
> CONFIG_CLEANCACHE=y
> CONFIG_FRONTSWAP=y
> # CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
> CONFIG_X86_RESERVE_LOW=64
> CONFIG_MTRR=y
> CONFIG_MTRR_SANITIZER=y
> CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
> CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
> CONFIG_X86_PAT=y
> CONFIG_ARCH_USES_PG_UNCACHED=y
> CONFIG_ARCH_RANDOM=y
> CONFIG_X86_SMAP=y
> # CONFIG_EFI is not set
> CONFIG_SECCOMP=y
> CONFIG_CC_STACKPROTECTOR=y
> CONFIG_HZ_100=y
> # CONFIG_HZ_250 is not set
> # CONFIG_HZ_300 is not set
> # CONFIG_HZ_1000 is not set
> CONFIG_HZ=100
> CONFIG_SCHED_HRTICK=y
> CONFIG_KEXEC=y
> # CONFIG_CRASH_DUMP is not set
> CONFIG_PHYSICAL_START=0x1000000
> CONFIG_RELOCATABLE=y
> CONFIG_PHYSICAL_ALIGN=0x1000000
> CONFIG_HOTPLUG_CPU=y
> # CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
> # CONFIG_DEBUG_HOTPLUG_CPU0 is not set
> # CONFIG_COMPAT_VDSO is not set
> # CONFIG_CMDLINE_BOOL is not set
> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
> 
> #
> # Power management and ACPI options
> #
> # CONFIG_SUSPEND is not set
> # CONFIG_HIBERNATION is not set
> # CONFIG_PM_RUNTIME is not set
> CONFIG_ACPI=y
> # CONFIG_ACPI_PROCFS is not set
> # CONFIG_ACPI_PROCFS_POWER is not set
> # CONFIG_ACPI_EC_DEBUGFS is not set
> # CONFIG_ACPI_PROC_EVENT is not set
> # CONFIG_ACPI_AC is not set
> # CONFIG_ACPI_BATTERY is not set
> CONFIG_ACPI_BUTTON=m
> CONFIG_ACPI_FAN=m
> CONFIG_ACPI_DOCK=y
> CONFIG_ACPI_I2C=m
> CONFIG_ACPI_PROCESSOR=m
> CONFIG_ACPI_HOTPLUG_CPU=y
> # CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
> CONFIG_ACPI_THERMAL=m
> # CONFIG_ACPI_CUSTOM_DSDT is not set
> # CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
> CONFIG_ACPI_BLACKLIST_YEAR=0
> # CONFIG_ACPI_DEBUG is not set
> CONFIG_ACPI_PCI_SLOT=y
> CONFIG_X86_PM_TIMER=y
> CONFIG_ACPI_CONTAINER=y
> # CONFIG_ACPI_SBS is not set
> # CONFIG_ACPI_HED is not set
> # CONFIG_ACPI_APEI is not set
> # CONFIG_SFI is not set
> 
> #
> # CPU Frequency scaling
> #
> CONFIG_CPU_FREQ=y
> CONFIG_CPU_FREQ_TABLE=y
> CONFIG_CPU_FREQ_GOV_COMMON=y
> CONFIG_CPU_FREQ_STAT=y
> # CONFIG_CPU_FREQ_STAT_DETAILS is not set
> CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
> # CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
> CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
> CONFIG_CPU_FREQ_GOV_POWERSAVE=m
> CONFIG_CPU_FREQ_GOV_USERSPACE=m
> CONFIG_CPU_FREQ_GOV_ONDEMAND=m
> CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m
> 
> #
> # x86 CPU frequency scaling drivers
> #
> CONFIG_X86_INTEL_PSTATE=y
> # CONFIG_X86_PCC_CPUFREQ is not set
> CONFIG_X86_ACPI_CPUFREQ=m
> # CONFIG_X86_ACPI_CPUFREQ_CPB is not set
> # CONFIG_X86_POWERNOW_K8 is not set
> # CONFIG_X86_AMD_FREQ_SENSITIVITY is not set
> # CONFIG_X86_SPEEDSTEP_CENTRINO is not set
> # CONFIG_X86_P4_CLOCKMOD is not set
> 
> #
> # shared options
> #
> # CONFIG_X86_SPEEDSTEP_LIB is not set
> CONFIG_CPU_IDLE=y
> # CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
> CONFIG_CPU_IDLE_GOV_LADDER=y
> CONFIG_CPU_IDLE_GOV_MENU=y
> # CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
> CONFIG_INTEL_IDLE=y
> 
> #
> # Memory power savings
> #
> # CONFIG_I7300_IDLE is not set
> 
> #
> # Bus options (PCI etc.)
> #
> CONFIG_PCI=y
> CONFIG_PCI_DIRECT=y
> CONFIG_PCI_MMCONFIG=y
> CONFIG_PCI_DOMAINS=y
> CONFIG_PCIEPORTBUS=y
> CONFIG_PCIEAER=y
> # CONFIG_PCIE_ECRC is not set
> # CONFIG_PCIEAER_INJECT is not set
> CONFIG_PCIEASPM=y
> # CONFIG_PCIEASPM_DEBUG is not set
> CONFIG_PCIEASPM_DEFAULT=y
> # CONFIG_PCIEASPM_POWERSAVE is not set
> # CONFIG_PCIEASPM_PERFORMANCE is not set
> CONFIG_ARCH_SUPPORTS_MSI=y
> CONFIG_PCI_MSI=y
> # CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
> # CONFIG_PCI_STUB is not set
> CONFIG_HT_IRQ=y
> # CONFIG_PCI_IOV is not set
> # CONFIG_PCI_PRI is not set
> # CONFIG_PCI_PASID is not set
> # CONFIG_PCI_IOAPIC is not set
> CONFIG_PCI_LABEL=y
> CONFIG_ISA_DMA_API=y
> CONFIG_AMD_NB=y
> # CONFIG_PCCARD is not set
> # CONFIG_HOTPLUG_PCI is not set
> # CONFIG_RAPIDIO is not set
> 
> #
> # Executable file formats / Emulations
> #
> CONFIG_BINFMT_ELF=y
> CONFIG_COMPAT_BINFMT_ELF=y
> CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
> # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
> CONFIG_BINFMT_SCRIPT=y
> # CONFIG_HAVE_AOUT is not set
> # CONFIG_BINFMT_MISC is not set
> CONFIG_COREDUMP=y
> CONFIG_IA32_EMULATION=y
> # CONFIG_IA32_AOUT is not set
> # CONFIG_X86_X32 is not set
> CONFIG_COMPAT=y
> CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
> CONFIG_SYSVIPC_COMPAT=y
> CONFIG_KEYS_COMPAT=y
> CONFIG_HAVE_TEXT_POKE_SMP=y
> CONFIG_X86_DEV_DMA_OPS=y
> CONFIG_NET=y
> 
> #
> # Networking options
> #
> CONFIG_PACKET=y
> CONFIG_PACKET_DIAG=y
> CONFIG_UNIX=y
> CONFIG_UNIX_DIAG=y
> # CONFIG_XFRM_USER is not set
> # CONFIG_NET_KEY is not set
> CONFIG_INET=y
> CONFIG_IP_MULTICAST=y
> CONFIG_IP_ADVANCED_ROUTER=y
> # CONFIG_IP_FIB_TRIE_STATS is not set
> CONFIG_IP_MULTIPLE_TABLES=y
> CONFIG_IP_ROUTE_MULTIPATH=y
> CONFIG_IP_ROUTE_VERBOSE=y
> CONFIG_IP_ROUTE_CLASSID=y
> # CONFIG_IP_PNP is not set
> CONFIG_NET_IPIP=m
> # CONFIG_NET_IPGRE_DEMUX is not set
> CONFIG_NET_IP_TUNNEL=m
> CONFIG_IP_MROUTE=y
> CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
> CONFIG_IP_PIMSM_V1=y
> CONFIG_IP_PIMSM_V2=y
> # CONFIG_ARPD is not set
> CONFIG_SYN_COOKIES=y
> # CONFIG_INET_AH is not set
> # CONFIG_INET_ESP is not set
> # CONFIG_INET_IPCOMP is not set
> # CONFIG_INET_XFRM_TUNNEL is not set
> CONFIG_INET_TUNNEL=m
> # CONFIG_INET_XFRM_MODE_TRANSPORT is not set
> # CONFIG_INET_XFRM_MODE_TUNNEL is not set
> # CONFIG_INET_XFRM_MODE_BEET is not set
> CONFIG_INET_LRO=y
> CONFIG_INET_DIAG=y
> CONFIG_INET_TCP_DIAG=y
> CONFIG_INET_UDP_DIAG=m
> # CONFIG_TCP_CONG_ADVANCED is not set
> CONFIG_TCP_CONG_CUBIC=y
> CONFIG_DEFAULT_TCP_CONG="cubic"
> # CONFIG_TCP_MD5SIG is not set
> CONFIG_IPV6=m
> CONFIG_IPV6_PRIVACY=y
> # CONFIG_IPV6_ROUTER_PREF is not set
> # CONFIG_IPV6_OPTIMISTIC_DAD is not set
> # CONFIG_INET6_AH is not set
> # CONFIG_INET6_ESP is not set
> # CONFIG_INET6_IPCOMP is not set
> # CONFIG_IPV6_MIP6 is not set
> # CONFIG_INET6_XFRM_TUNNEL is not set
> CONFIG_INET6_TUNNEL=m
> # CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
> # CONFIG_INET6_XFRM_MODE_TUNNEL is not set
> # CONFIG_INET6_XFRM_MODE_BEET is not set
> # CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
> CONFIG_IPV6_SIT=m
> # CONFIG_IPV6_SIT_6RD is not set
> CONFIG_IPV6_NDISC_NODETYPE=y
> CONFIG_IPV6_TUNNEL=m
> CONFIG_IPV6_GRE=m
> CONFIG_IPV6_MULTIPLE_TABLES=y
> CONFIG_IPV6_SUBTREES=y
> CONFIG_IPV6_MROUTE=y
> CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
> CONFIG_IPV6_PIMSM_V2=y
> # CONFIG_NETWORK_SECMARK is not set
> # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
> CONFIG_NETFILTER=y
> # CONFIG_NETFILTER_DEBUG is not set
> CONFIG_NETFILTER_ADVANCED=y
> CONFIG_BRIDGE_NETFILTER=y
> 
> #
> # Core Netfilter Configuration
> #
> CONFIG_NETFILTER_NETLINK=m
> CONFIG_NETFILTER_NETLINK_ACCT=m
> CONFIG_NETFILTER_NETLINK_QUEUE=m
> CONFIG_NETFILTER_NETLINK_LOG=m
> CONFIG_NF_CONNTRACK=m
> CONFIG_NF_CONNTRACK_MARK=y
> # CONFIG_NF_CONNTRACK_ZONES is not set
> # CONFIG_NF_CONNTRACK_PROCFS is not set
> CONFIG_NF_CONNTRACK_EVENTS=y
> CONFIG_NF_CONNTRACK_TIMEOUT=y
> # CONFIG_NF_CONNTRACK_TIMESTAMP is not set
> CONFIG_NF_CONNTRACK_LABELS=y
> CONFIG_NF_CT_PROTO_DCCP=m
> CONFIG_NF_CT_PROTO_GRE=m
> CONFIG_NF_CT_PROTO_SCTP=m
> CONFIG_NF_CT_PROTO_UDPLITE=m
> CONFIG_NF_CONNTRACK_AMANDA=m
> CONFIG_NF_CONNTRACK_FTP=m
> CONFIG_NF_CONNTRACK_H323=m
> CONFIG_NF_CONNTRACK_IRC=m
> CONFIG_NF_CONNTRACK_BROADCAST=m
> CONFIG_NF_CONNTRACK_NETBIOS_NS=m
> CONFIG_NF_CONNTRACK_SNMP=m
> CONFIG_NF_CONNTRACK_PPTP=m
> CONFIG_NF_CONNTRACK_SANE=m
> CONFIG_NF_CONNTRACK_SIP=m
> CONFIG_NF_CONNTRACK_TFTP=m
> CONFIG_NF_CT_NETLINK=m
> CONFIG_NF_CT_NETLINK_TIMEOUT=m
> CONFIG_NF_CT_NETLINK_HELPER=m
> CONFIG_NETFILTER_NETLINK_QUEUE_CT=y
> CONFIG_NF_NAT=m
> CONFIG_NF_NAT_NEEDED=y
> CONFIG_NF_NAT_PROTO_DCCP=m
> CONFIG_NF_NAT_PROTO_UDPLITE=m
> CONFIG_NF_NAT_PROTO_SCTP=m
> CONFIG_NF_NAT_AMANDA=m
> CONFIG_NF_NAT_FTP=m
> CONFIG_NF_NAT_IRC=m
> CONFIG_NF_NAT_SIP=m
> CONFIG_NF_NAT_TFTP=m
> CONFIG_NETFILTER_TPROXY=m
> CONFIG_NETFILTER_XTABLES=m
> 
> #
> # Xtables combined modules
> #
> CONFIG_NETFILTER_XT_MARK=m
> CONFIG_NETFILTER_XT_CONNMARK=m
> CONFIG_NETFILTER_XT_SET=m
> 
> #
> # Xtables targets
> #
> CONFIG_NETFILTER_XT_TARGET_AUDIT=m
> CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m
> CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
> CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
> CONFIG_NETFILTER_XT_TARGET_CT=m
> CONFIG_NETFILTER_XT_TARGET_DSCP=m
> CONFIG_NETFILTER_XT_TARGET_HL=m
> CONFIG_NETFILTER_XT_TARGET_HMARK=m
> CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
> CONFIG_NETFILTER_XT_TARGET_LOG=m
> CONFIG_NETFILTER_XT_TARGET_MARK=m
> CONFIG_NETFILTER_XT_TARGET_NETMAP=m
> CONFIG_NETFILTER_XT_TARGET_NFLOG=m
> CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
> # CONFIG_NETFILTER_XT_TARGET_NOTRACK is not set
> CONFIG_NETFILTER_XT_TARGET_RATEEST=m
> CONFIG_NETFILTER_XT_TARGET_REDIRECT=m
> CONFIG_NETFILTER_XT_TARGET_TEE=m
> CONFIG_NETFILTER_XT_TARGET_TPROXY=m
> CONFIG_NETFILTER_XT_TARGET_TRACE=m
> CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
> CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
> 
> #
> # Xtables matches
> #
> CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
> CONFIG_NETFILTER_XT_MATCH_BPF=m
> CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
> CONFIG_NETFILTER_XT_MATCH_COMMENT=m
> CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
> CONFIG_NETFILTER_XT_MATCH_CONNLABEL=m
> CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
> CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
> CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
> CONFIG_NETFILTER_XT_MATCH_CPU=m
> CONFIG_NETFILTER_XT_MATCH_DCCP=m
> CONFIG_NETFILTER_XT_MATCH_DEVGROUP=m
> CONFIG_NETFILTER_XT_MATCH_DSCP=m
> CONFIG_NETFILTER_XT_MATCH_ECN=m
> CONFIG_NETFILTER_XT_MATCH_ESP=m
> CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
> CONFIG_NETFILTER_XT_MATCH_HELPER=m
> CONFIG_NETFILTER_XT_MATCH_HL=m
> CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
> CONFIG_NETFILTER_XT_MATCH_LENGTH=m
> CONFIG_NETFILTER_XT_MATCH_LIMIT=m
> CONFIG_NETFILTER_XT_MATCH_MAC=m
> CONFIG_NETFILTER_XT_MATCH_MARK=m
> CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
> CONFIG_NETFILTER_XT_MATCH_NFACCT=m
> CONFIG_NETFILTER_XT_MATCH_OSF=m
> CONFIG_NETFILTER_XT_MATCH_OWNER=m
> CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
> CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
> CONFIG_NETFILTER_XT_MATCH_QUOTA=m
> CONFIG_NETFILTER_XT_MATCH_RATEEST=m
> CONFIG_NETFILTER_XT_MATCH_REALM=m
> CONFIG_NETFILTER_XT_MATCH_RECENT=m
> CONFIG_NETFILTER_XT_MATCH_SCTP=m
> CONFIG_NETFILTER_XT_MATCH_SOCKET=m
> CONFIG_NETFILTER_XT_MATCH_STATE=m
> CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
> CONFIG_NETFILTER_XT_MATCH_STRING=m
> CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
> CONFIG_NETFILTER_XT_MATCH_TIME=m
> CONFIG_NETFILTER_XT_MATCH_U32=m
> CONFIG_IP_SET=m
> CONFIG_IP_SET_MAX=256
> CONFIG_IP_SET_BITMAP_IP=m
> CONFIG_IP_SET_BITMAP_IPMAC=m
> CONFIG_IP_SET_BITMAP_PORT=m
> CONFIG_IP_SET_HASH_IP=m
> CONFIG_IP_SET_HASH_IPPORT=m
> CONFIG_IP_SET_HASH_IPPORTIP=m
> CONFIG_IP_SET_HASH_IPPORTNET=m
> CONFIG_IP_SET_HASH_NET=m
> CONFIG_IP_SET_HASH_NETPORT=m
> CONFIG_IP_SET_HASH_NETIFACE=m
> CONFIG_IP_SET_LIST_SET=m
> # CONFIG_IP_VS is not set
> 
> #
> # IP: Netfilter Configuration
> #
> CONFIG_NF_DEFRAG_IPV4=m
> CONFIG_NF_CONNTRACK_IPV4=m
> CONFIG_IP_NF_IPTABLES=m
> CONFIG_IP_NF_MATCH_AH=m
> CONFIG_IP_NF_MATCH_ECN=m
> CONFIG_IP_NF_MATCH_RPFILTER=m
> CONFIG_IP_NF_MATCH_TTL=m
> CONFIG_IP_NF_FILTER=m
> CONFIG_IP_NF_TARGET_REJECT=m
> CONFIG_IP_NF_TARGET_ULOG=m
> CONFIG_NF_NAT_IPV4=m
> CONFIG_IP_NF_TARGET_MASQUERADE=m
> CONFIG_IP_NF_TARGET_NETMAP=m
> CONFIG_IP_NF_TARGET_REDIRECT=m
> CONFIG_NF_NAT_SNMP_BASIC=m
> CONFIG_NF_NAT_PROTO_GRE=m
> CONFIG_NF_NAT_PPTP=m
> CONFIG_NF_NAT_H323=m
> CONFIG_IP_NF_MANGLE=m
> CONFIG_IP_NF_TARGET_CLUSTERIP=m
> CONFIG_IP_NF_TARGET_ECN=m
> CONFIG_IP_NF_TARGET_TTL=m
> CONFIG_IP_NF_RAW=m
> CONFIG_IP_NF_ARPTABLES=m
> CONFIG_IP_NF_ARPFILTER=m
> CONFIG_IP_NF_ARP_MANGLE=m
> 
> #
> # IPv6: Netfilter Configuration
> #
> CONFIG_NF_DEFRAG_IPV6=m
> CONFIG_NF_CONNTRACK_IPV6=m
> CONFIG_IP6_NF_IPTABLES=m
> CONFIG_IP6_NF_MATCH_AH=m
> CONFIG_IP6_NF_MATCH_EUI64=m
> CONFIG_IP6_NF_MATCH_FRAG=m
> CONFIG_IP6_NF_MATCH_OPTS=m
> CONFIG_IP6_NF_MATCH_HL=m
> CONFIG_IP6_NF_MATCH_IPV6HEADER=m
> CONFIG_IP6_NF_MATCH_MH=m
> CONFIG_IP6_NF_MATCH_RPFILTER=m
> CONFIG_IP6_NF_MATCH_RT=m
> CONFIG_IP6_NF_TARGET_HL=m
> CONFIG_IP6_NF_FILTER=m
> CONFIG_IP6_NF_TARGET_REJECT=m
> CONFIG_IP6_NF_MANGLE=m
> CONFIG_IP6_NF_RAW=m
> CONFIG_NF_NAT_IPV6=m
> CONFIG_IP6_NF_TARGET_MASQUERADE=m
> CONFIG_IP6_NF_TARGET_NPT=m
> CONFIG_BRIDGE_NF_EBTABLES=m
> CONFIG_BRIDGE_EBT_BROUTE=m
> CONFIG_BRIDGE_EBT_T_FILTER=m
> CONFIG_BRIDGE_EBT_T_NAT=m
> CONFIG_BRIDGE_EBT_802_3=m
> CONFIG_BRIDGE_EBT_AMONG=m
> CONFIG_BRIDGE_EBT_ARP=m
> CONFIG_BRIDGE_EBT_IP=m
> CONFIG_BRIDGE_EBT_IP6=m
> CONFIG_BRIDGE_EBT_LIMIT=m
> CONFIG_BRIDGE_EBT_MARK=m
> CONFIG_BRIDGE_EBT_PKTTYPE=m
> CONFIG_BRIDGE_EBT_STP=m
> CONFIG_BRIDGE_EBT_VLAN=m
> CONFIG_BRIDGE_EBT_ARPREPLY=m
> CONFIG_BRIDGE_EBT_DNAT=m
> CONFIG_BRIDGE_EBT_MARK_T=m
> CONFIG_BRIDGE_EBT_REDIRECT=m
> CONFIG_BRIDGE_EBT_SNAT=m
> CONFIG_BRIDGE_EBT_LOG=m
> CONFIG_BRIDGE_EBT_ULOG=m
> CONFIG_BRIDGE_EBT_NFLOG=m
> # CONFIG_IP_DCCP is not set
> # CONFIG_IP_SCTP is not set
> # CONFIG_RDS is not set
> # CONFIG_TIPC is not set
> # CONFIG_ATM is not set
> # CONFIG_L2TP is not set
> CONFIG_STP=m
> CONFIG_GARP=m
> CONFIG_BRIDGE=m
> CONFIG_BRIDGE_IGMP_SNOOPING=y
> CONFIG_BRIDGE_VLAN_FILTERING=y
> CONFIG_HAVE_NET_DSA=y
> CONFIG_VLAN_8021Q=m
> CONFIG_VLAN_8021Q_GVRP=y
> # CONFIG_VLAN_8021Q_MVRP is not set
> # CONFIG_DECNET is not set
> CONFIG_LLC=m
> # CONFIG_LLC2 is not set
> # CONFIG_IPX is not set
> # CONFIG_ATALK is not set
> # CONFIG_X25 is not set
> # CONFIG_LAPB is not set
> # CONFIG_PHONET is not set
> # CONFIG_IEEE802154 is not set
> CONFIG_NET_SCHED=y
> 
> #
> # Queueing/Scheduling
> #
> CONFIG_NET_SCH_CBQ=m
> CONFIG_NET_SCH_HTB=m
> CONFIG_NET_SCH_HFSC=m
> CONFIG_NET_SCH_PRIO=m
> CONFIG_NET_SCH_MULTIQ=m
> CONFIG_NET_SCH_RED=m
> CONFIG_NET_SCH_SFB=m
> CONFIG_NET_SCH_SFQ=m
> CONFIG_NET_SCH_TEQL=m
> CONFIG_NET_SCH_TBF=m
> CONFIG_NET_SCH_GRED=m
> CONFIG_NET_SCH_DSMARK=m
> CONFIG_NET_SCH_NETEM=m
> CONFIG_NET_SCH_DRR=m
> CONFIG_NET_SCH_MQPRIO=m
> CONFIG_NET_SCH_CHOKE=m
> CONFIG_NET_SCH_QFQ=m
> CONFIG_NET_SCH_CODEL=m
> CONFIG_NET_SCH_FQ_CODEL=m
> CONFIG_NET_SCH_INGRESS=m
> CONFIG_NET_SCH_PLUG=m
> 
> #
> # Classification
> #
> CONFIG_NET_CLS=y
> CONFIG_NET_CLS_BASIC=m
> CONFIG_NET_CLS_TCINDEX=m
> CONFIG_NET_CLS_ROUTE4=m
> CONFIG_NET_CLS_FW=m
> CONFIG_NET_CLS_U32=m
> CONFIG_CLS_U32_PERF=y
> CONFIG_CLS_U32_MARK=y
> CONFIG_NET_CLS_RSVP=m
> CONFIG_NET_CLS_RSVP6=m
> CONFIG_NET_CLS_FLOW=m
> CONFIG_NET_CLS_CGROUP=m
> CONFIG_NET_EMATCH=y
> CONFIG_NET_EMATCH_STACK=32
> CONFIG_NET_EMATCH_CMP=m
> CONFIG_NET_EMATCH_NBYTE=m
> CONFIG_NET_EMATCH_U32=m
> CONFIG_NET_EMATCH_META=m
> CONFIG_NET_EMATCH_TEXT=m
> # CONFIG_NET_EMATCH_IPSET is not set
> CONFIG_NET_CLS_ACT=y
> CONFIG_NET_ACT_POLICE=m
> CONFIG_NET_ACT_GACT=m
> CONFIG_GACT_PROB=y
> CONFIG_NET_ACT_MIRRED=m
> CONFIG_NET_ACT_IPT=m
> CONFIG_NET_ACT_NAT=m
> CONFIG_NET_ACT_PEDIT=m
> CONFIG_NET_ACT_SIMP=m
> CONFIG_NET_ACT_SKBEDIT=m
> CONFIG_NET_ACT_CSUM=m
> CONFIG_NET_CLS_IND=y
> CONFIG_NET_SCH_FIFO=y
> # CONFIG_DCB is not set
> CONFIG_DNS_RESOLVER=y
> # CONFIG_BATMAN_ADV is not set
> # CONFIG_OPENVSWITCH is not set
> # CONFIG_VSOCKETS is not set
> # CONFIG_NETLINK_MMAP is not set
> # CONFIG_NETLINK_DIAG is not set
> CONFIG_RPS=y
> CONFIG_RFS_ACCEL=y
> CONFIG_XPS=y
> CONFIG_NETPRIO_CGROUP=m
> CONFIG_BQL=y
> CONFIG_BPF_JIT=y
> 
> #
> # Network testing
> #
> # CONFIG_NET_PKTGEN is not set
> # CONFIG_HAMRADIO is not set
> # CONFIG_CAN is not set
> # CONFIG_IRDA is not set
> # CONFIG_BT is not set
> # CONFIG_AF_RXRPC is not set
> CONFIG_FIB_RULES=y
> # CONFIG_WIRELESS is not set
> # CONFIG_WIMAX is not set
> # CONFIG_RFKILL is not set
> # CONFIG_NET_9P is not set
> # CONFIG_CAIF is not set
> # CONFIG_CEPH_LIB is not set
> # CONFIG_NFC is not set
> CONFIG_HAVE_BPF_JIT=y
> 
> #
> # Device Drivers
> #
> 
> #
> # Generic Driver Options
> #
> CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
> CONFIG_DEVTMPFS=y
> # CONFIG_DEVTMPFS_MOUNT is not set
> CONFIG_STANDALONE=y
> CONFIG_PREVENT_FIRMWARE_BUILD=y
> CONFIG_FW_LOADER=y
> # CONFIG_FIRMWARE_IN_KERNEL is not set
> CONFIG_EXTRA_FIRMWARE=""
> # CONFIG_FW_LOADER_USER_HELPER is not set
> # CONFIG_SYS_HYPERVISOR is not set
> # CONFIG_GENERIC_CPU_DEVICES is not set
> # CONFIG_DMA_SHARED_BUFFER is not set
> 
> #
> # Bus devices
> #
> CONFIG_CONNECTOR=m
> # CONFIG_MTD is not set
> # CONFIG_PARPORT is not set
> CONFIG_PNP=y
> CONFIG_PNP_DEBUG_MESSAGES=y
> 
> #
> # Protocols
> #
> CONFIG_PNPACPI=y
> CONFIG_BLK_DEV=y
> # CONFIG_BLK_DEV_FD is not set
> # CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
> # CONFIG_BLK_CPQ_DA is not set
> # CONFIG_BLK_CPQ_CISS_DA is not set
> # CONFIG_BLK_DEV_DAC960 is not set
> # CONFIG_BLK_DEV_UMEM is not set
> # CONFIG_BLK_DEV_COW_COMMON is not set
> CONFIG_BLK_DEV_LOOP=m
> CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
> CONFIG_BLK_DEV_CRYPTOLOOP=m
> CONFIG_BLK_DEV_DRBD=m
> # CONFIG_DRBD_FAULT_INJECTION is not set
> CONFIG_BLK_DEV_NBD=m
> # CONFIG_BLK_DEV_NVME is not set
> # CONFIG_BLK_DEV_SX8 is not set
> CONFIG_BLK_DEV_RAM=m
> CONFIG_BLK_DEV_RAM_COUNT=16
> CONFIG_BLK_DEV_RAM_SIZE=4096
> # CONFIG_BLK_DEV_XIP is not set
> # CONFIG_CDROM_PKTCDVD is not set
> # CONFIG_ATA_OVER_ETH is not set
> # CONFIG_BLK_DEV_HD is not set
> # CONFIG_BLK_DEV_RBD is not set
> # CONFIG_BLK_DEV_RSXX is not set
> 
> #
> # Misc devices
> #
> # CONFIG_SENSORS_LIS3LV02D is not set
> # CONFIG_AD525X_DPOT is not set
> # CONFIG_DUMMY_IRQ is not set
> # CONFIG_IBM_ASM is not set
> # CONFIG_PHANTOM is not set
> # CONFIG_INTEL_MID_PTI is not set
> # CONFIG_SGI_IOC4 is not set
> # CONFIG_TIFM_CORE is not set
> # CONFIG_ICS932S401 is not set
> # CONFIG_ATMEL_SSC is not set
> # CONFIG_ENCLOSURE_SERVICES is not set
> # CONFIG_HP_ILO is not set
> # CONFIG_APDS9802ALS is not set
> # CONFIG_ISL29003 is not set
> # CONFIG_ISL29020 is not set
> # CONFIG_SENSORS_TSL2550 is not set
> # CONFIG_SENSORS_BH1780 is not set
> # CONFIG_SENSORS_BH1770 is not set
> # CONFIG_SENSORS_APDS990X is not set
> # CONFIG_HMC6352 is not set
> # CONFIG_DS1682 is not set
> # CONFIG_BMP085_I2C is not set
> # CONFIG_PCH_PHUB is not set
> # CONFIG_USB_SWITCH_FSA9480 is not set
> # CONFIG_SRAM is not set
> # CONFIG_C2PORT is not set
> 
> #
> # EEPROM support
> #
> # CONFIG_EEPROM_AT24 is not set
> # CONFIG_EEPROM_LEGACY is not set
> # CONFIG_EEPROM_MAX6875 is not set
> # CONFIG_EEPROM_93CX6 is not set
> # CONFIG_CB710_CORE is not set
> 
> #
> # Texas Instruments shared transport line discipline
> #
> # CONFIG_SENSORS_LIS3_I2C is not set
> 
> #
> # Altera FPGA firmware download module
> #
> # CONFIG_ALTERA_STAPL is not set
> # CONFIG_VMWARE_VMCI is not set
> CONFIG_HAVE_IDE=y
> # CONFIG_IDE is not set
> 
> #
> # SCSI device support
> #
> CONFIG_SCSI_MOD=m
> # CONFIG_RAID_ATTRS is not set
> CONFIG_SCSI=m
> CONFIG_SCSI_DMA=y
> # CONFIG_SCSI_TGT is not set
> # CONFIG_SCSI_NETLINK is not set
> # CONFIG_SCSI_PROC_FS is not set
> 
> #
> # SCSI support type (disk, tape, CD-ROM)
> #
> CONFIG_BLK_DEV_SD=m
> # CONFIG_CHR_DEV_ST is not set
> # CONFIG_CHR_DEV_OSST is not set
> # CONFIG_BLK_DEV_SR is not set
> # CONFIG_CHR_DEV_SG is not set
> # CONFIG_CHR_DEV_SCH is not set
> # CONFIG_SCSI_MULTI_LUN is not set
> CONFIG_SCSI_CONSTANTS=y
> # CONFIG_SCSI_LOGGING is not set
> # CONFIG_SCSI_SCAN_ASYNC is not set
> 
> #
> # SCSI Transports
> #
> # CONFIG_SCSI_SPI_ATTRS is not set
> # CONFIG_SCSI_FC_ATTRS is not set
> # CONFIG_SCSI_ISCSI_ATTRS is not set
> # CONFIG_SCSI_SAS_ATTRS is not set
> # CONFIG_SCSI_SAS_LIBSAS is not set
> # CONFIG_SCSI_SRP_ATTRS is not set
> # CONFIG_SCSI_LOWLEVEL is not set
> # CONFIG_SCSI_DH is not set
> # CONFIG_SCSI_OSD_INITIATOR is not set
> CONFIG_ATA=m
> # CONFIG_ATA_NONSTANDARD is not set
> CONFIG_ATA_VERBOSE_ERROR=y
> CONFIG_ATA_ACPI=y
> # CONFIG_SATA_ZPODD is not set
> CONFIG_SATA_PMP=y
> 
> #
> # Controllers with non-SFF native interface
> #
> CONFIG_SATA_AHCI=m
> # CONFIG_SATA_AHCI_PLATFORM is not set
> # CONFIG_SATA_INIC162X is not set
> # CONFIG_SATA_ACARD_AHCI is not set
> CONFIG_SATA_SIL24=m
> CONFIG_ATA_SFF=y
> 
> #
> # SFF controllers with custom DMA interface
> #
> # CONFIG_PDC_ADMA is not set
> # CONFIG_SATA_QSTOR is not set
> # CONFIG_SATA_SX4 is not set
> CONFIG_ATA_BMDMA=y
> 
> #
> # SATA SFF controllers with BMDMA
> #
> CONFIG_ATA_PIIX=m
> # CONFIG_SATA_HIGHBANK is not set
> CONFIG_SATA_MV=m
> # CONFIG_SATA_NV is not set
> # CONFIG_SATA_PROMISE is not set
> # CONFIG_SATA_SIL is not set
> # CONFIG_SATA_SIS is not set
> # CONFIG_SATA_SVW is not set
> # CONFIG_SATA_ULI is not set
> # CONFIG_SATA_VIA is not set
> # CONFIG_SATA_VITESSE is not set
> 
> #
> # PATA SFF controllers with BMDMA
> #
> # CONFIG_PATA_ALI is not set
> # CONFIG_PATA_AMD is not set
> # CONFIG_PATA_ARTOP is not set
> # CONFIG_PATA_ATIIXP is not set
> # CONFIG_PATA_ATP867X is not set
> # CONFIG_PATA_CMD64X is not set
> # CONFIG_PATA_CS5520 is not set
> # CONFIG_PATA_CS5530 is not set
> # CONFIG_PATA_CS5536 is not set
> # CONFIG_PATA_CYPRESS is not set
> # CONFIG_PATA_EFAR is not set
> # CONFIG_PATA_HPT366 is not set
> # CONFIG_PATA_HPT37X is not set
> # CONFIG_PATA_HPT3X2N is not set
> # CONFIG_PATA_HPT3X3 is not set
> # CONFIG_PATA_IT8213 is not set
> # CONFIG_PATA_IT821X is not set
> # CONFIG_PATA_JMICRON is not set
> CONFIG_PATA_MARVELL=m
> # CONFIG_PATA_NETCELL is not set
> # CONFIG_PATA_NINJA32 is not set
> # CONFIG_PATA_NS87415 is not set
> # CONFIG_PATA_OLDPIIX is not set
> # CONFIG_PATA_OPTIDMA is not set
> # CONFIG_PATA_PDC2027X is not set
> # CONFIG_PATA_PDC_OLD is not set
> # CONFIG_PATA_RADISYS is not set
> # CONFIG_PATA_RDC is not set
> # CONFIG_PATA_SC1200 is not set
> # CONFIG_PATA_SCH is not set
> # CONFIG_PATA_SERVERWORKS is not set
> # CONFIG_PATA_SIL680 is not set
> # CONFIG_PATA_SIS is not set
> # CONFIG_PATA_TOSHIBA is not set
> # CONFIG_PATA_TRIFLEX is not set
> # CONFIG_PATA_VIA is not set
> # CONFIG_PATA_WINBOND is not set
> 
> #
> # PIO-only SFF controllers
> #
> # CONFIG_PATA_CMD640_PCI is not set
> # CONFIG_PATA_MPIIX is not set
> # CONFIG_PATA_NS87410 is not set
> # CONFIG_PATA_OPTI is not set
> # CONFIG_PATA_RZ1000 is not set
> 
> #
> # Generic fallback / legacy drivers
> #
> # CONFIG_PATA_ACPI is not set
> # CONFIG_ATA_GENERIC is not set
> # CONFIG_PATA_LEGACY is not set
> CONFIG_MD=y
> CONFIG_BLK_DEV_MD=m
> CONFIG_MD_LINEAR=m
> CONFIG_MD_RAID0=m
> CONFIG_MD_RAID1=m
> CONFIG_MD_RAID10=m
> CONFIG_MD_RAID456=m
> CONFIG_MD_MULTIPATH=m
> CONFIG_MD_FAULTY=m
> CONFIG_BCACHE=m
> # CONFIG_BCACHE_DEBUG is not set
> # CONFIG_BCACHE_EDEBUG is not set
> # CONFIG_BCACHE_CLOSURES_DEBUG is not set
> CONFIG_BLK_DEV_DM=y
> CONFIG_DM_DEBUG=y
> CONFIG_DM_BUFIO=m
> CONFIG_DM_BIO_PRISON=m
> CONFIG_DM_PERSISTENT_DATA=m
> CONFIG_DM_CRYPT=m
> CONFIG_DM_SNAPSHOT=m
> CONFIG_DM_THIN_PROVISIONING=m
> # CONFIG_DM_DEBUG_BLOCK_STACK_TRACING is not set
> CONFIG_DM_CACHE=m
> CONFIG_DM_CACHE_MQ=m
> CONFIG_DM_CACHE_CLEANER=m
> CONFIG_DM_MIRROR=m
> CONFIG_DM_RAID=m
> CONFIG_DM_LOG_USERSPACE=m
> CONFIG_DM_ZERO=m
> # CONFIG_DM_MULTIPATH is not set
> # CONFIG_DM_DELAY is not set
> CONFIG_DM_UEVENT=y
> # CONFIG_DM_FLAKEY is not set
> # CONFIG_DM_VERITY is not set
> # CONFIG_TARGET_CORE is not set
> # CONFIG_FUSION is not set
> 
> #
> # IEEE 1394 (FireWire) support
> #
> # CONFIG_FIREWIRE is not set
> # CONFIG_FIREWIRE_NOSY is not set
> # CONFIG_I2O is not set
> # CONFIG_MACINTOSH_DRIVERS is not set
> CONFIG_NETDEVICES=y
> CONFIG_NET_CORE=y
> CONFIG_BONDING=m
> # CONFIG_DUMMY is not set
> # CONFIG_EQUALIZER is not set
> # CONFIG_NET_FC is not set
> CONFIG_MII=m
> # CONFIG_IFB is not set
> # CONFIG_NET_TEAM is not set
> CONFIG_MACVLAN=m
> CONFIG_MACVTAP=m
> # CONFIG_VXLAN is not set
> CONFIG_NETCONSOLE=m
> CONFIG_NETCONSOLE_DYNAMIC=y
> CONFIG_NETPOLL=y
> # CONFIG_NETPOLL_TRAP is not set
> CONFIG_NET_POLL_CONTROLLER=y
> CONFIG_TUN=m
> CONFIG_VETH=m
> # CONFIG_ARCNET is not set
> 
> #
> # CAIF transport drivers
> #
> CONFIG_VHOST_NET=m
> CONFIG_VHOST_RING=m
> 
> #
> # Distributed Switch Architecture drivers
> #
> # CONFIG_NET_DSA_MV88E6XXX is not set
> # CONFIG_NET_DSA_MV88E6060 is not set
> # CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
> # CONFIG_NET_DSA_MV88E6131 is not set
> # CONFIG_NET_DSA_MV88E6123_61_65 is not set
> CONFIG_ETHERNET=y
> # CONFIG_NET_VENDOR_3COM is not set
> # CONFIG_NET_VENDOR_ADAPTEC is not set
> # CONFIG_NET_VENDOR_ALTEON is not set
> # CONFIG_NET_VENDOR_AMD is not set
> # CONFIG_NET_VENDOR_ATHEROS is not set
> # CONFIG_NET_CADENCE is not set
> # CONFIG_NET_VENDOR_BROADCOM is not set
> # CONFIG_NET_VENDOR_BROCADE is not set
> # CONFIG_NET_CALXEDA_XGMAC is not set
> # CONFIG_NET_VENDOR_CHELSIO is not set
> # CONFIG_NET_VENDOR_CISCO is not set
> # CONFIG_DNET is not set
> # CONFIG_NET_VENDOR_DEC is not set
> # CONFIG_NET_VENDOR_DLINK is not set
> # CONFIG_NET_VENDOR_EMULEX is not set
> # CONFIG_NET_VENDOR_EXAR is not set
> # CONFIG_NET_VENDOR_HP is not set
> CONFIG_NET_VENDOR_INTEL=y
> # CONFIG_E100 is not set
> CONFIG_E1000=m
> CONFIG_E1000E=m
> # CONFIG_IGB is not set
> # CONFIG_IGBVF is not set
> # CONFIG_IXGB is not set
> # CONFIG_IXGBE is not set
> # CONFIG_IXGBEVF is not set
> # CONFIG_NET_VENDOR_I825XX is not set
> # CONFIG_IP1000 is not set
> # CONFIG_JME is not set
> # CONFIG_NET_VENDOR_MARVELL is not set
> # CONFIG_NET_VENDOR_MELLANOX is not set
> # CONFIG_NET_VENDOR_MICREL is not set
> # CONFIG_NET_VENDOR_MYRI is not set
> # CONFIG_FEALNX is not set
> # CONFIG_NET_VENDOR_NATSEMI is not set
> # CONFIG_NET_VENDOR_NVIDIA is not set
> # CONFIG_NET_VENDOR_OKI is not set
> # CONFIG_ETHOC is not set
> # CONFIG_NET_PACKET_ENGINE is not set
> # CONFIG_NET_VENDOR_QLOGIC is not set
> CONFIG_NET_VENDOR_REALTEK=y
> # CONFIG_8139CP is not set
> # CONFIG_8139TOO is not set
> CONFIG_R8169=m
> # CONFIG_NET_VENDOR_RDC is not set
> # CONFIG_NET_VENDOR_SEEQ is not set
> # CONFIG_NET_VENDOR_SILAN is not set
> # CONFIG_NET_VENDOR_SIS is not set
> # CONFIG_SFC is not set
> # CONFIG_NET_VENDOR_SMSC is not set
> # CONFIG_NET_VENDOR_STMICRO is not set
> # CONFIG_NET_VENDOR_SUN is not set
> # CONFIG_NET_VENDOR_TEHUTI is not set
> # CONFIG_NET_VENDOR_TI is not set
> # CONFIG_NET_VENDOR_VIA is not set
> # CONFIG_NET_VENDOR_WIZNET is not set
> # CONFIG_FDDI is not set
> # CONFIG_HIPPI is not set
> # CONFIG_NET_SB1000 is not set
> # CONFIG_PHYLIB is not set
> CONFIG_PPP=m
> CONFIG_PPP_BSDCOMP=m
> CONFIG_PPP_DEFLATE=m
> CONFIG_PPP_FILTER=y
> CONFIG_PPP_MPPE=m
> CONFIG_PPP_MULTILINK=y
> CONFIG_PPPOE=m
> CONFIG_PPP_ASYNC=m
> CONFIG_PPP_SYNC_TTY=m
> # CONFIG_SLIP is not set
> CONFIG_SLHC=m
> 
> #
> # USB Network Adapters
> #
> # CONFIG_USB_CATC is not set
> # CONFIG_USB_KAWETH is not set
> # CONFIG_USB_PEGASUS is not set
> # CONFIG_USB_RTL8150 is not set
> # CONFIG_USB_RTL8152 is not set
> # CONFIG_USB_USBNET is not set
> # CONFIG_USB_IPHETH is not set
> # CONFIG_WLAN is not set
> 
> #
> # Enable WiMAX (Networking options) to see the WiMAX drivers
> #
> # CONFIG_WAN is not set
> # CONFIG_VMXNET3 is not set
> # CONFIG_ISDN is not set
> 
> #
> # Input device support
> #
> CONFIG_INPUT=y
> # CONFIG_INPUT_FF_MEMLESS is not set
> # CONFIG_INPUT_POLLDEV is not set
> # CONFIG_INPUT_SPARSEKMAP is not set
> # CONFIG_INPUT_MATRIXKMAP is not set
> 
> #
> # Userland interfaces
> #
> CONFIG_INPUT_MOUSEDEV=y
> # CONFIG_INPUT_MOUSEDEV_PSAUX is not set
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
> # CONFIG_INPUT_JOYDEV is not set
> CONFIG_INPUT_EVDEV=m
> # CONFIG_INPUT_EVBUG is not set
> 
> #
> # Input Device Drivers
> #
> CONFIG_INPUT_KEYBOARD=y
> # CONFIG_KEYBOARD_ADP5588 is not set
> # CONFIG_KEYBOARD_ADP5589 is not set
> CONFIG_KEYBOARD_ATKBD=y
> # CONFIG_KEYBOARD_QT1070 is not set
> # CONFIG_KEYBOARD_QT2160 is not set
> # CONFIG_KEYBOARD_LKKBD is not set
> # CONFIG_KEYBOARD_TCA6416 is not set
> # CONFIG_KEYBOARD_TCA8418 is not set
> # CONFIG_KEYBOARD_LM8333 is not set
> # CONFIG_KEYBOARD_MAX7359 is not set
> # CONFIG_KEYBOARD_MCS is not set
> # CONFIG_KEYBOARD_MPR121 is not set
> # CONFIG_KEYBOARD_NEWTON is not set
> # CONFIG_KEYBOARD_OPENCORES is not set
> # CONFIG_KEYBOARD_STOWAWAY is not set
> # CONFIG_KEYBOARD_SUNKBD is not set
> # CONFIG_KEYBOARD_XTKBD is not set
> # CONFIG_INPUT_MOUSE is not set
> # CONFIG_INPUT_JOYSTICK is not set
> # CONFIG_INPUT_TABLET is not set
> # CONFIG_INPUT_TOUCHSCREEN is not set
> # CONFIG_INPUT_MISC is not set
> 
> #
> # Hardware I/O ports
> #
> CONFIG_SERIO=y
> CONFIG_SERIO_I8042=y
> # CONFIG_SERIO_SERPORT is not set
> # CONFIG_SERIO_CT82C710 is not set
> # CONFIG_SERIO_PCIPS2 is not set
> CONFIG_SERIO_LIBPS2=y
> # CONFIG_SERIO_RAW is not set
> # CONFIG_SERIO_ALTERA_PS2 is not set
> # CONFIG_SERIO_PS2MULT is not set
> # CONFIG_SERIO_ARC_PS2 is not set
> # CONFIG_GAMEPORT is not set
> 
> #
> # Character devices
> #
> CONFIG_TTY=y
> CONFIG_VT=y
> CONFIG_CONSOLE_TRANSLATIONS=y
> CONFIG_VT_CONSOLE=y
> CONFIG_HW_CONSOLE=y
> # CONFIG_VT_HW_CONSOLE_BINDING is not set
> CONFIG_UNIX98_PTYS=y
> CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
> # CONFIG_LEGACY_PTYS is not set
> # CONFIG_SERIAL_NONSTANDARD is not set
> # CONFIG_NOZOMI is not set
> # CONFIG_N_GSM is not set
> # CONFIG_TRACE_SINK is not set
> # CONFIG_DEVKMEM is not set
> 
> #
> # Serial drivers
> #
> CONFIG_SERIAL_8250=y
> # CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
> CONFIG_SERIAL_8250_PNP=y
> CONFIG_SERIAL_8250_CONSOLE=y
> CONFIG_FIX_EARLYCON_MEM=y
> CONFIG_SERIAL_8250_PCI=y
> CONFIG_SERIAL_8250_NR_UARTS=4
> CONFIG_SERIAL_8250_RUNTIME_UARTS=4
> # CONFIG_SERIAL_8250_EXTENDED is not set
> # CONFIG_SERIAL_8250_DW is not set
> 
> #
> # Non-8250 serial port support
> #
> # CONFIG_SERIAL_MFD_HSU is not set
> CONFIG_SERIAL_CORE=y
> CONFIG_SERIAL_CORE_CONSOLE=y
> # CONFIG_SERIAL_JSM is not set
> # CONFIG_SERIAL_SCCNXP is not set
> # CONFIG_SERIAL_TIMBERDALE is not set
> # CONFIG_SERIAL_ALTERA_JTAGUART is not set
> # CONFIG_SERIAL_ALTERA_UART is not set
> # CONFIG_SERIAL_PCH_UART is not set
> # CONFIG_SERIAL_ARC is not set
> # CONFIG_SERIAL_RP2 is not set
> # CONFIG_IPMI_HANDLER is not set
> # CONFIG_HW_RANDOM is not set
> # CONFIG_NVRAM is not set
> # CONFIG_R3964 is not set
> # CONFIG_APPLICOM is not set
> # CONFIG_MWAVE is not set
> # CONFIG_RAW_DRIVER is not set
> CONFIG_HPET=y
> # CONFIG_HPET_MMAP is not set
> # CONFIG_HANGCHECK_TIMER is not set
> # CONFIG_TCG_TPM is not set
> # CONFIG_TELCLOCK is not set
> CONFIG_DEVPORT=y
> CONFIG_I2C=m
> CONFIG_I2C_BOARDINFO=y
> # CONFIG_I2C_COMPAT is not set
> CONFIG_I2C_CHARDEV=m
> # CONFIG_I2C_MUX is not set
> CONFIG_I2C_HELPER_AUTO=y
> 
> #
> # I2C Hardware Bus support
> #
> 
> #
> # PC SMBus host controller drivers
> #
> # CONFIG_I2C_ALI1535 is not set
> # CONFIG_I2C_ALI1563 is not set
> # CONFIG_I2C_ALI15X3 is not set
> # CONFIG_I2C_AMD756 is not set
> # CONFIG_I2C_AMD8111 is not set
> CONFIG_I2C_I801=m
> CONFIG_I2C_ISCH=m
> # CONFIG_I2C_ISMT is not set
> CONFIG_I2C_PIIX4=m
> # CONFIG_I2C_NFORCE2 is not set
> # CONFIG_I2C_SIS5595 is not set
> # CONFIG_I2C_SIS630 is not set
> # CONFIG_I2C_SIS96X is not set
> # CONFIG_I2C_VIA is not set
> # CONFIG_I2C_VIAPRO is not set
> 
> #
> # ACPI drivers
> #
> # CONFIG_I2C_SCMI is not set
> 
> #
> # I2C system bus drivers (mostly embedded / system-on-chip)
> #
> # CONFIG_I2C_DESIGNWARE_PCI is not set
> # CONFIG_I2C_EG20T is not set
> # CONFIG_I2C_INTEL_MID is not set
> # CONFIG_I2C_OCORES is not set
> # CONFIG_I2C_PCA_PLATFORM is not set
> # CONFIG_I2C_PXA_PCI is not set
> # CONFIG_I2C_SIMTEC is not set
> # CONFIG_I2C_XILINX is not set
> 
> #
> # External I2C/SMBus adapter drivers
> #
> # CONFIG_I2C_DIOLAN_U2C is not set
> # CONFIG_I2C_PARPORT_LIGHT is not set
> # CONFIG_I2C_TAOS_EVM is not set
> # CONFIG_I2C_TINY_USB is not set
> 
> #
> # Other I2C/SMBus bus drivers
> #
> # CONFIG_I2C_STUB is not set
> # CONFIG_I2C_DEBUG_CORE is not set
> # CONFIG_I2C_DEBUG_ALGO is not set
> # CONFIG_I2C_DEBUG_BUS is not set
> # CONFIG_SPI is not set
> 
> #
> # Qualcomm MSM SSBI bus support
> #
> # CONFIG_SSBI is not set
> # CONFIG_HSI is not set
> 
> #
> # PPS support
> #
> CONFIG_PPS=m
> # CONFIG_PPS_DEBUG is not set
> 
> #
> # PPS clients support
> #
> # CONFIG_PPS_CLIENT_KTIMER is not set
> # CONFIG_PPS_CLIENT_LDISC is not set
> # CONFIG_PPS_CLIENT_GPIO is not set
> 
> #
> # PPS generators support
> #
> 
> #
> # PTP clock support
> #
> CONFIG_PTP_1588_CLOCK=m
> 
> #
> # Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
> #
> # CONFIG_PTP_1588_CLOCK_PCH is not set
> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
> CONFIG_GPIO_DEVRES=y
> # CONFIG_GPIOLIB is not set
> # CONFIG_W1 is not set
> # CONFIG_POWER_SUPPLY is not set
> # CONFIG_POWER_AVS is not set
> CONFIG_HWMON=m
> CONFIG_HWMON_VID=m
> # CONFIG_HWMON_DEBUG_CHIP is not set
> 
> #
> # Native drivers
> #
> # CONFIG_SENSORS_ABITUGURU is not set
> # CONFIG_SENSORS_ABITUGURU3 is not set
> # CONFIG_SENSORS_AD7414 is not set
> # CONFIG_SENSORS_AD7418 is not set
> # CONFIG_SENSORS_ADM1021 is not set
> # CONFIG_SENSORS_ADM1025 is not set
> # CONFIG_SENSORS_ADM1026 is not set
> # CONFIG_SENSORS_ADM1029 is not set
> # CONFIG_SENSORS_ADM1031 is not set
> # CONFIG_SENSORS_ADM9240 is not set
> # CONFIG_SENSORS_ADT7410 is not set
> # CONFIG_SENSORS_ADT7411 is not set
> # CONFIG_SENSORS_ADT7462 is not set
> # CONFIG_SENSORS_ADT7470 is not set
> # CONFIG_SENSORS_ADT7475 is not set
> # CONFIG_SENSORS_ASC7621 is not set
> # CONFIG_SENSORS_K8TEMP is not set
> # CONFIG_SENSORS_K10TEMP is not set
> # CONFIG_SENSORS_FAM15H_POWER is not set
> # CONFIG_SENSORS_ASB100 is not set
> # CONFIG_SENSORS_ATXP1 is not set
> # CONFIG_SENSORS_DS620 is not set
> # CONFIG_SENSORS_DS1621 is not set
> # CONFIG_SENSORS_I5K_AMB is not set
> # CONFIG_SENSORS_F71805F is not set
> # CONFIG_SENSORS_F71882FG is not set
> # CONFIG_SENSORS_F75375S is not set
> # CONFIG_SENSORS_FSCHMD is not set
> # CONFIG_SENSORS_G760A is not set
> # CONFIG_SENSORS_GL518SM is not set
> # CONFIG_SENSORS_GL520SM is not set
> # CONFIG_SENSORS_HIH6130 is not set
> CONFIG_SENSORS_CORETEMP=m
> CONFIG_SENSORS_IT87=m
> # CONFIG_SENSORS_JC42 is not set
> # CONFIG_SENSORS_LINEAGE is not set
> # CONFIG_SENSORS_LM63 is not set
> # CONFIG_SENSORS_LM73 is not set
> # CONFIG_SENSORS_LM75 is not set
> # CONFIG_SENSORS_LM77 is not set
> # CONFIG_SENSORS_LM78 is not set
> # CONFIG_SENSORS_LM80 is not set
> # CONFIG_SENSORS_LM83 is not set
> # CONFIG_SENSORS_LM85 is not set
> # CONFIG_SENSORS_LM87 is not set
> # CONFIG_SENSORS_LM90 is not set
> # CONFIG_SENSORS_LM92 is not set
> # CONFIG_SENSORS_LM93 is not set
> # CONFIG_SENSORS_LTC4151 is not set
> # CONFIG_SENSORS_LTC4215 is not set
> # CONFIG_SENSORS_LTC4245 is not set
> # CONFIG_SENSORS_LTC4261 is not set
> # CONFIG_SENSORS_LM95234 is not set
> # CONFIG_SENSORS_LM95241 is not set
> # CONFIG_SENSORS_LM95245 is not set
> # CONFIG_SENSORS_MAX16065 is not set
> # CONFIG_SENSORS_MAX1619 is not set
> # CONFIG_SENSORS_MAX1668 is not set
> # CONFIG_SENSORS_MAX197 is not set
> # CONFIG_SENSORS_MAX6639 is not set
> # CONFIG_SENSORS_MAX6642 is not set
> # CONFIG_SENSORS_MAX6650 is not set
> # CONFIG_SENSORS_MAX6697 is not set
> # CONFIG_SENSORS_MCP3021 is not set
> # CONFIG_SENSORS_NCT6775 is not set
> # CONFIG_SENSORS_NTC_THERMISTOR is not set
> # CONFIG_SENSORS_PC87360 is not set
> # CONFIG_SENSORS_PC87427 is not set
> # CONFIG_SENSORS_PCF8591 is not set
> # CONFIG_PMBUS is not set
> # CONFIG_SENSORS_SHT21 is not set
> # CONFIG_SENSORS_SIS5595 is not set
> # CONFIG_SENSORS_SMM665 is not set
> # CONFIG_SENSORS_DME1737 is not set
> # CONFIG_SENSORS_EMC1403 is not set
> # CONFIG_SENSORS_EMC2103 is not set
> # CONFIG_SENSORS_EMC6W201 is not set
> # CONFIG_SENSORS_SMSC47M1 is not set
> # CONFIG_SENSORS_SMSC47M192 is not set
> # CONFIG_SENSORS_SMSC47B397 is not set
> # CONFIG_SENSORS_SCH56XX_COMMON is not set
> # CONFIG_SENSORS_ADS1015 is not set
> # CONFIG_SENSORS_ADS7828 is not set
> # CONFIG_SENSORS_AMC6821 is not set
> # CONFIG_SENSORS_INA209 is not set
> # CONFIG_SENSORS_INA2XX is not set
> # CONFIG_SENSORS_THMC50 is not set
> # CONFIG_SENSORS_TMP102 is not set
> # CONFIG_SENSORS_TMP401 is not set
> # CONFIG_SENSORS_TMP421 is not set
> # CONFIG_SENSORS_VIA_CPUTEMP is not set
> # CONFIG_SENSORS_VIA686A is not set
> # CONFIG_SENSORS_VT1211 is not set
> # CONFIG_SENSORS_VT8231 is not set
> # CONFIG_SENSORS_W83781D is not set
> # CONFIG_SENSORS_W83791D is not set
> # CONFIG_SENSORS_W83792D is not set
> # CONFIG_SENSORS_W83793 is not set
> # CONFIG_SENSORS_W83795 is not set
> # CONFIG_SENSORS_W83L785TS is not set
> # CONFIG_SENSORS_W83L786NG is not set
> # CONFIG_SENSORS_W83627HF is not set
> # CONFIG_SENSORS_W83627EHF is not set
> # CONFIG_SENSORS_APPLESMC is not set
> 
> #
> # ACPI drivers
> #
> # CONFIG_SENSORS_ACPI_POWER is not set
> CONFIG_SENSORS_ATK0110=m
> CONFIG_THERMAL=m
> CONFIG_THERMAL_HWMON=y
> CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
> # CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
> # CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
> CONFIG_THERMAL_GOV_FAIR_SHARE=y
> CONFIG_THERMAL_GOV_STEP_WISE=y
> # CONFIG_THERMAL_GOV_USER_SPACE is not set
> # CONFIG_CPU_THERMAL is not set
> # CONFIG_THERMAL_EMULATION is not set
> CONFIG_INTEL_POWERCLAMP=m
> # CONFIG_WATCHDOG is not set
> CONFIG_SSB_POSSIBLE=y
> 
> #
> # Sonics Silicon Backplane
> #
> # CONFIG_SSB is not set
> CONFIG_BCMA_POSSIBLE=y
> 
> #
> # Broadcom specific AMBA
> #
> # CONFIG_BCMA is not set
> 
> #
> # Multifunction device drivers
> #
> CONFIG_MFD_CORE=m
> # CONFIG_MFD_CS5535 is not set
> # CONFIG_MFD_CROS_EC is not set
> # CONFIG_MFD_MC13XXX_I2C is not set
> # CONFIG_HTC_PASIC3 is not set
> CONFIG_LPC_ICH=m
> CONFIG_LPC_SCH=m
> # CONFIG_MFD_JANZ_CMODIO is not set
> # CONFIG_MFD_VIPERBOARD is not set
> # CONFIG_MFD_RETU is not set
> # CONFIG_MFD_PCF50633 is not set
> # CONFIG_MFD_RDC321X is not set
> # CONFIG_MFD_RTSX_PCI is not set
> # CONFIG_MFD_SI476X_CORE is not set
> # CONFIG_MFD_SM501 is not set
> # CONFIG_ABX500_CORE is not set
> # CONFIG_MFD_SYSCON is not set
> # CONFIG_MFD_TI_AM335X_TSCADC is not set
> # CONFIG_TPS6105X is not set
> # CONFIG_TPS6507X is not set
> # CONFIG_MFD_TPS65217 is not set
> # CONFIG_MFD_WL1273_CORE is not set
> # CONFIG_MFD_LM3533 is not set
> # CONFIG_MFD_TMIO is not set
> # CONFIG_MFD_VX855 is not set
> # CONFIG_MFD_ARIZONA_I2C is not set
> # CONFIG_REGULATOR is not set
> # CONFIG_MEDIA_SUPPORT is not set
> 
> #
> # Graphics support
> #
> # CONFIG_AGP is not set
> CONFIG_VGA_ARB=y
> CONFIG_VGA_ARB_MAX_GPUS=1
> # CONFIG_VGA_SWITCHEROO is not set
> # CONFIG_DRM is not set
> # CONFIG_VGASTATE is not set
> # CONFIG_VIDEO_OUTPUT_CONTROL is not set
> # CONFIG_FB is not set
> # CONFIG_EXYNOS_VIDEO is not set
> # CONFIG_BACKLIGHT_LCD_SUPPORT is not set
> 
> #
> # Console display driver support
> #
> CONFIG_VGA_CONSOLE=y
> CONFIG_VGACON_SOFT_SCROLLBACK=y
> CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=256
> CONFIG_DUMMY_CONSOLE=y
> # CONFIG_SOUND is not set
> 
> #
> # HID support
> #
> CONFIG_HID=m
> # CONFIG_HIDRAW is not set
> # CONFIG_UHID is not set
> CONFIG_HID_GENERIC=m
> 
> #
> # Special HID drivers
> #
> CONFIG_HID_A4TECH=m
> # CONFIG_HID_ACRUX is not set
> CONFIG_HID_APPLE=m
> # CONFIG_HID_APPLEIR is not set
> # CONFIG_HID_AUREAL is not set
> CONFIG_HID_BELKIN=m
> CONFIG_HID_CHERRY=m
> CONFIG_HID_CHICONY=m
> CONFIG_HID_CYPRESS=m
> # CONFIG_HID_DRAGONRISE is not set
> # CONFIG_HID_EMS_FF is not set
> # CONFIG_HID_ELECOM is not set
> CONFIG_HID_EZKEY=m
> # CONFIG_HID_HOLTEK is not set
> # CONFIG_HID_KEYTOUCH is not set
> # CONFIG_HID_KYE is not set
> # CONFIG_HID_UCLOGIC is not set
> # CONFIG_HID_WALTOP is not set
> # CONFIG_HID_GYRATION is not set
> # CONFIG_HID_ICADE is not set
> # CONFIG_HID_TWINHAN is not set
> CONFIG_HID_KENSINGTON=m
> # CONFIG_HID_LCPOWER is not set
> # CONFIG_HID_LENOVO_TPKBD is not set
> CONFIG_HID_LOGITECH=m
> # CONFIG_HID_LOGITECH_DJ is not set
> # CONFIG_LOGITECH_FF is not set
> # CONFIG_LOGIRUMBLEPAD2_FF is not set
> # CONFIG_LOGIG940_FF is not set
> # CONFIG_LOGIWHEELS_FF is not set
> # CONFIG_HID_MAGICMOUSE is not set
> CONFIG_HID_MICROSOFT=m
> CONFIG_HID_MONTEREY=m
> # CONFIG_HID_MULTITOUCH is not set
> # CONFIG_HID_NTRIG is not set
> # CONFIG_HID_ORTEK is not set
> # CONFIG_HID_PANTHERLORD is not set
> # CONFIG_HID_PETALYNX is not set
> # CONFIG_HID_PICOLCD is not set
> # CONFIG_HID_PRIMAX is not set
> # CONFIG_HID_PS3REMOTE is not set
> # CONFIG_HID_ROCCAT is not set
> # CONFIG_HID_SAITEK is not set
> # CONFIG_HID_SAMSUNG is not set
> # CONFIG_HID_SONY is not set
> # CONFIG_HID_SPEEDLINK is not set
> # CONFIG_HID_STEELSERIES is not set
> # CONFIG_HID_SUNPLUS is not set
> # CONFIG_HID_GREENASIA is not set
> # CONFIG_HID_SMARTJOYPLUS is not set
> # CONFIG_HID_TIVO is not set
> # CONFIG_HID_TOPSEED is not set
> # CONFIG_HID_THRUSTMASTER is not set
> # CONFIG_HID_ZEROPLUS is not set
> # CONFIG_HID_ZYDACRON is not set
> # CONFIG_HID_SENSOR_HUB is not set
> 
> #
> # USB HID support
> #
> CONFIG_USB_HID=m
> # CONFIG_HID_PID is not set
> # CONFIG_USB_HIDDEV is not set
> 
> #
> # I2C HID support
> #
> # CONFIG_I2C_HID is not set
> CONFIG_USB_ARCH_HAS_OHCI=y
> CONFIG_USB_ARCH_HAS_EHCI=y
> CONFIG_USB_ARCH_HAS_XHCI=y
> CONFIG_USB_SUPPORT=y
> CONFIG_USB_COMMON=m
> CONFIG_USB_ARCH_HAS_HCD=y
> CONFIG_USB=m
> # CONFIG_USB_DEBUG is not set
> # CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set
> 
> #
> # Miscellaneous USB options
> #
> CONFIG_USB_DEFAULT_PERSIST=y
> # CONFIG_USB_DYNAMIC_MINORS is not set
> # CONFIG_USB_MON is not set
> # CONFIG_USB_WUSB_CBAF is not set
> 
> #
> # USB Host Controller Drivers
> #
> # CONFIG_USB_C67X00_HCD is not set
> CONFIG_USB_XHCI_HCD=m
> # CONFIG_USB_XHCI_HCD_DEBUGGING is not set
> CONFIG_USB_EHCI_HCD=m
> # CONFIG_USB_EHCI_ROOT_HUB_TT is not set
> # CONFIG_USB_EHCI_TT_NEWSCHED is not set
> CONFIG_USB_EHCI_PCI=m
> # CONFIG_USB_EHCI_HCD_PLATFORM is not set
> # CONFIG_USB_OXU210HP_HCD is not set
> # CONFIG_USB_ISP116X_HCD is not set
> # CONFIG_USB_ISP1760_HCD is not set
> # CONFIG_USB_ISP1362_HCD is not set
> CONFIG_USB_OHCI_HCD=m
> # CONFIG_USB_OHCI_HCD_PLATFORM is not set
> # CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
> # CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
> CONFIG_USB_OHCI_LITTLE_ENDIAN=y
> CONFIG_USB_UHCI_HCD=m
> # CONFIG_USB_SL811_HCD is not set
> # CONFIG_USB_R8A66597_HCD is not set
> 
> #
> # USB Device Class drivers
> #
> # CONFIG_USB_ACM is not set
> # CONFIG_USB_PRINTER is not set
> # CONFIG_USB_WDM is not set
> # CONFIG_USB_TMC is not set
> 
> #
> # NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
> #
> 
> #
> # also be needed; see USB_STORAGE Help for more info
> #
> CONFIG_USB_STORAGE=m
> # CONFIG_USB_STORAGE_DEBUG is not set
> # CONFIG_USB_STORAGE_REALTEK is not set
> # CONFIG_USB_STORAGE_DATAFAB is not set
> # CONFIG_USB_STORAGE_FREECOM is not set
> # CONFIG_USB_STORAGE_ISD200 is not set
> # CONFIG_USB_STORAGE_USBAT is not set
> # CONFIG_USB_STORAGE_SDDR09 is not set
> # CONFIG_USB_STORAGE_SDDR55 is not set
> # CONFIG_USB_STORAGE_JUMPSHOT is not set
> # CONFIG_USB_STORAGE_ALAUDA is not set
> # CONFIG_USB_STORAGE_ONETOUCH is not set
> # CONFIG_USB_STORAGE_KARMA is not set
> # CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
> # CONFIG_USB_STORAGE_ENE_UB6250 is not set
> 
> #
> # USB Imaging devices
> #
> # CONFIG_USB_MDC800 is not set
> # CONFIG_USB_MICROTEK is not set
> # CONFIG_USB_DWC3 is not set
> # CONFIG_USB_CHIPIDEA is not set
> 
> #
> # USB port drivers
> #
> # CONFIG_USB_SERIAL is not set
> 
> #
> # USB Miscellaneous drivers
> #
> # CONFIG_USB_EMI62 is not set
> # CONFIG_USB_EMI26 is not set
> # CONFIG_USB_ADUTUX is not set
> # CONFIG_USB_SEVSEG is not set
> # CONFIG_USB_RIO500 is not set
> # CONFIG_USB_LEGOTOWER is not set
> # CONFIG_USB_LCD is not set
> # CONFIG_USB_LED is not set
> # CONFIG_USB_CYPRESS_CY7C63 is not set
> # CONFIG_USB_CYTHERM is not set
> # CONFIG_USB_IDMOUSE is not set
> # CONFIG_USB_FTDI_ELAN is not set
> # CONFIG_USB_APPLEDISPLAY is not set
> # CONFIG_USB_SISUSBVGA is not set
> # CONFIG_USB_LD is not set
> # CONFIG_USB_TRANCEVIBRATOR is not set
> # CONFIG_USB_IOWARRIOR is not set
> # CONFIG_USB_TEST is not set
> # CONFIG_USB_ISIGHTFW is not set
> # CONFIG_USB_YUREX is not set
> # CONFIG_USB_EZUSB_FX2 is not set
> # CONFIG_USB_HSIC_USB3503 is not set
> # CONFIG_USB_PHY is not set
> # CONFIG_USB_GADGET is not set
> # CONFIG_UWB is not set
> # CONFIG_MMC is not set
> # CONFIG_MEMSTICK is not set
> # CONFIG_NEW_LEDS is not set
> # CONFIG_ACCESSIBILITY is not set
> # CONFIG_INFINIBAND is not set
> # CONFIG_EDAC is not set
> CONFIG_RTC_LIB=y
> # CONFIG_RTC_CLASS is not set
> # CONFIG_DMADEVICES is not set
> # CONFIG_AUXDISPLAY is not set
> # CONFIG_UIO is not set
> # CONFIG_VIRT_DRIVERS is not set
> 
> #
> # Virtio drivers
> #
> # CONFIG_VIRTIO_PCI is not set
> # CONFIG_VIRTIO_MMIO is not set
> 
> #
> # Microsoft Hyper-V guest support
> #
> # CONFIG_STAGING is not set
> # CONFIG_X86_PLATFORM_DEVICES is not set
> 
> #
> # Hardware Spinlock drivers
> #
> CONFIG_CLKEVT_I8253=y
> CONFIG_I8253_LOCK=y
> CONFIG_CLKBLD_I8253=y
> # CONFIG_MAILBOX is not set
> # CONFIG_IOMMU_SUPPORT is not set
> 
> #
> # Remoteproc drivers
> #
> # CONFIG_STE_MODEM_RPROC is not set
> 
> #
> # Rpmsg drivers
> #
> # CONFIG_PM_DEVFREQ is not set
> # CONFIG_EXTCON is not set
> # CONFIG_MEMORY is not set
> # CONFIG_IIO is not set
> # CONFIG_NTB is not set
> # CONFIG_VME_BUS is not set
> # CONFIG_PWM is not set
> # CONFIG_IPACK_BUS is not set
> # CONFIG_RESET_CONTROLLER is not set
> 
> #
> # Firmware Drivers
> #
> # CONFIG_EDD is not set
> CONFIG_FIRMWARE_MEMMAP=y
> # CONFIG_DELL_RBU is not set
> # CONFIG_DCDBAS is not set
> CONFIG_DMIID=y
> # CONFIG_DMI_SYSFS is not set
> # CONFIG_ISCSI_IBFT_FIND is not set
> # CONFIG_GOOGLE_FIRMWARE is not set
> 
> #
> # File systems
> #
> CONFIG_DCACHE_WORD_ACCESS=y
> CONFIG_EXT2_FS=m
> CONFIG_EXT2_FS_XATTR=y
> CONFIG_EXT2_FS_POSIX_ACL=y
> CONFIG_EXT2_FS_SECURITY=y
> # CONFIG_EXT2_FS_XIP is not set
> CONFIG_EXT3_FS=m
> # CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
> CONFIG_EXT3_FS_XATTR=y
> CONFIG_EXT3_FS_POSIX_ACL=y
> CONFIG_EXT3_FS_SECURITY=y
> CONFIG_EXT4_FS=m
> CONFIG_EXT4_FS_POSIX_ACL=y
> CONFIG_EXT4_FS_SECURITY=y
> # CONFIG_EXT4_DEBUG is not set
> CONFIG_JBD=m
> CONFIG_JBD2=m
> CONFIG_FS_MBCACHE=m
> # CONFIG_REISERFS_FS is not set
> # CONFIG_JFS_FS is not set
> CONFIG_XFS_FS=m
> CONFIG_XFS_QUOTA=y
> CONFIG_XFS_POSIX_ACL=y
> # CONFIG_XFS_RT is not set
> CONFIG_XFS_WARN=y
> # CONFIG_XFS_DEBUG is not set
> # CONFIG_GFS2_FS is not set
> # CONFIG_OCFS2_FS is not set
> CONFIG_BTRFS_FS=m
> CONFIG_BTRFS_FS_POSIX_ACL=y
> # CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
> # CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
> # CONFIG_BTRFS_DEBUG is not set
> # CONFIG_NILFS2_FS is not set
> CONFIG_FS_POSIX_ACL=y
> CONFIG_EXPORTFS=y
> CONFIG_FILE_LOCKING=y
> CONFIG_FSNOTIFY=y
> CONFIG_DNOTIFY=y
> CONFIG_INOTIFY_USER=y
> # CONFIG_FANOTIFY is not set
> CONFIG_QUOTA=y
> # CONFIG_QUOTA_NETLINK_INTERFACE is not set
> # CONFIG_PRINT_QUOTA_WARNING is not set
> # CONFIG_QUOTA_DEBUG is not set
> # CONFIG_QFMT_V1 is not set
> # CONFIG_QFMT_V2 is not set
> CONFIG_QUOTACTL=y
> CONFIG_QUOTACTL_COMPAT=y
> # CONFIG_AUTOFS4_FS is not set
> CONFIG_FUSE_FS=m
> CONFIG_CUSE=m
> CONFIG_GENERIC_ACL=y
> 
> #
> # Caches
> #
> # CONFIG_FSCACHE is not set
> 
> #
> # CD-ROM/DVD Filesystems
> #
> CONFIG_ISO9660_FS=m
> CONFIG_JOLIET=y
> # CONFIG_ZISOFS is not set
> # CONFIG_UDF_FS is not set
> 
> #
> # DOS/FAT/NT Filesystems
> #
> CONFIG_FAT_FS=m
> CONFIG_MSDOS_FS=m
> CONFIG_VFAT_FS=m
> CONFIG_FAT_DEFAULT_CODEPAGE=437
> CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
> # CONFIG_NTFS_FS is not set
> 
> #
> # Pseudo filesystems
> #
> CONFIG_PROC_FS=y
> CONFIG_PROC_KCORE=y
> CONFIG_PROC_SYSCTL=y
> CONFIG_PROC_PAGE_MONITOR=y
> CONFIG_SYSFS=y
> CONFIG_TMPFS=y
> CONFIG_TMPFS_POSIX_ACL=y
> CONFIG_TMPFS_XATTR=y
> # CONFIG_HUGETLBFS is not set
> # CONFIG_HUGETLB_PAGE is not set
> CONFIG_CONFIGFS_FS=m
> CONFIG_MISC_FILESYSTEMS=y
> # CONFIG_ADFS_FS is not set
> # CONFIG_AFFS_FS is not set
> # CONFIG_ECRYPT_FS is not set
> # CONFIG_HFS_FS is not set
> # CONFIG_HFSPLUS_FS is not set
> # CONFIG_BEFS_FS is not set
> # CONFIG_BFS_FS is not set
> # CONFIG_EFS_FS is not set
> # CONFIG_LOGFS is not set
> # CONFIG_CRAMFS is not set
> CONFIG_SQUASHFS=m
> CONFIG_SQUASHFS_XATTR=y
> CONFIG_SQUASHFS_ZLIB=y
> CONFIG_SQUASHFS_LZO=y
> CONFIG_SQUASHFS_XZ=y
> # CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
> # CONFIG_SQUASHFS_EMBEDDED is not set
> CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
> # CONFIG_VXFS_FS is not set
> # CONFIG_MINIX_FS is not set
> # CONFIG_OMFS_FS is not set
> # CONFIG_HPFS_FS is not set
> # CONFIG_QNX4FS_FS is not set
> # CONFIG_QNX6FS_FS is not set
> # CONFIG_ROMFS_FS is not set
> # CONFIG_PSTORE is not set
> # CONFIG_SYSV_FS is not set
> # CONFIG_UFS_FS is not set
> # CONFIG_F2FS_FS is not set
> CONFIG_NETWORK_FILESYSTEMS=y
> CONFIG_NFS_FS=m
> # CONFIG_NFS_V2 is not set
> CONFIG_NFS_V3=m
> CONFIG_NFS_V3_ACL=y
> CONFIG_NFS_V4=m
> # CONFIG_NFS_SWAP is not set
> CONFIG_NFS_V4_1=y
> CONFIG_PNFS_FILE_LAYOUT=m
> CONFIG_PNFS_BLOCK=m
> CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
> # CONFIG_NFS_USE_LEGACY_DNS is not set
> CONFIG_NFS_USE_KERNEL_DNS=y
> CONFIG_NFSD=m
> CONFIG_NFSD_V2_ACL=y
> CONFIG_NFSD_V3=y
> CONFIG_NFSD_V3_ACL=y
> CONFIG_NFSD_V4=y
> CONFIG_LOCKD=m
> CONFIG_LOCKD_V4=y
> CONFIG_NFS_ACL_SUPPORT=m
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=m
> CONFIG_SUNRPC_GSS=m
> CONFIG_SUNRPC_BACKCHANNEL=y
> CONFIG_RPCSEC_GSS_KRB5=m
> # CONFIG_SUNRPC_DEBUG is not set
> # CONFIG_CEPH_FS is not set
> # CONFIG_CIFS is not set
> # CONFIG_NCP_FS is not set
> # CONFIG_CODA_FS is not set
> # CONFIG_AFS_FS is not set
> CONFIG_NLS=y
> CONFIG_NLS_DEFAULT="utf-8"
> CONFIG_NLS_CODEPAGE_437=m
> # CONFIG_NLS_CODEPAGE_737 is not set
> # CONFIG_NLS_CODEPAGE_775 is not set
> # CONFIG_NLS_CODEPAGE_850 is not set
> # CONFIG_NLS_CODEPAGE_852 is not set
> # CONFIG_NLS_CODEPAGE_855 is not set
> # CONFIG_NLS_CODEPAGE_857 is not set
> # CONFIG_NLS_CODEPAGE_860 is not set
> # CONFIG_NLS_CODEPAGE_861 is not set
> # CONFIG_NLS_CODEPAGE_862 is not set
> # CONFIG_NLS_CODEPAGE_863 is not set
> # CONFIG_NLS_CODEPAGE_864 is not set
> # CONFIG_NLS_CODEPAGE_865 is not set
> # CONFIG_NLS_CODEPAGE_866 is not set
> # CONFIG_NLS_CODEPAGE_869 is not set
> # CONFIG_NLS_CODEPAGE_936 is not set
> # CONFIG_NLS_CODEPAGE_950 is not set
> # CONFIG_NLS_CODEPAGE_932 is not set
> # CONFIG_NLS_CODEPAGE_949 is not set
> # CONFIG_NLS_CODEPAGE_874 is not set
> # CONFIG_NLS_ISO8859_8 is not set
> # CONFIG_NLS_CODEPAGE_1250 is not set
> # CONFIG_NLS_CODEPAGE_1251 is not set
> CONFIG_NLS_ASCII=m
> CONFIG_NLS_ISO8859_1=m
> # CONFIG_NLS_ISO8859_2 is not set
> # CONFIG_NLS_ISO8859_3 is not set
> # CONFIG_NLS_ISO8859_4 is not set
> # CONFIG_NLS_ISO8859_5 is not set
> # CONFIG_NLS_ISO8859_6 is not set
> # CONFIG_NLS_ISO8859_7 is not set
> # CONFIG_NLS_ISO8859_9 is not set
> # CONFIG_NLS_ISO8859_13 is not set
> # CONFIG_NLS_ISO8859_14 is not set
> CONFIG_NLS_ISO8859_15=m
> # CONFIG_NLS_KOI8_R is not set
> # CONFIG_NLS_KOI8_U is not set
> # CONFIG_NLS_MAC_ROMAN is not set
> # CONFIG_NLS_MAC_CELTIC is not set
> # CONFIG_NLS_MAC_CENTEURO is not set
> # CONFIG_NLS_MAC_CROATIAN is not set
> # CONFIG_NLS_MAC_CYRILLIC is not set
> # CONFIG_NLS_MAC_GAELIC is not set
> # CONFIG_NLS_MAC_GREEK is not set
> # CONFIG_NLS_MAC_ICELAND is not set
> # CONFIG_NLS_MAC_INUIT is not set
> # CONFIG_NLS_MAC_ROMANIAN is not set
> # CONFIG_NLS_MAC_TURKISH is not set
> CONFIG_NLS_UTF8=m
> # CONFIG_DLM is not set
> 
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=y
> CONFIG_PRINTK_TIME=y
> CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
> # CONFIG_ENABLE_WARN_DEPRECATED is not set
> # CONFIG_ENABLE_MUST_CHECK is not set
> CONFIG_FRAME_WARN=2048
> CONFIG_MAGIC_SYSRQ=y
> # CONFIG_STRIP_ASM_SYMS is not set
> # CONFIG_UNUSED_SYMBOLS is not set
> # CONFIG_DEBUG_FS is not set
> # CONFIG_HEADERS_CHECK is not set
> # CONFIG_DEBUG_SECTION_MISMATCH is not set
> # CONFIG_DEBUG_KERNEL is not set
> # CONFIG_PANIC_ON_OOPS is not set
> CONFIG_PANIC_ON_OOPS_VALUE=0
> # CONFIG_SLUB_DEBUG_ON is not set
> # CONFIG_SLUB_STATS is not set
> CONFIG_HAVE_DEBUG_KMEMLEAK=y
> CONFIG_DEBUG_BUGVERBOSE=y
> CONFIG_DEBUG_MEMORY_INIT=y
> CONFIG_ARCH_WANT_FRAME_POINTERS=y
> CONFIG_FRAME_POINTER=y
> 
> #
> # RCU Debugging
> #
> # CONFIG_SPARSE_RCU_POINTER is not set
> CONFIG_RCU_CPU_STALL_TIMEOUT=60
> CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
> CONFIG_USER_STACKTRACE_SUPPORT=y
> CONFIG_HAVE_FUNCTION_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
> CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
> CONFIG_HAVE_DYNAMIC_FTRACE=y
> CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
> CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
> CONFIG_HAVE_FENTRY=y
> CONFIG_HAVE_C_RECORDMCOUNT=y
> CONFIG_TRACING_SUPPORT=y
> # CONFIG_FTRACE is not set
> # CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
> # CONFIG_DMA_API_DEBUG is not set
> # CONFIG_ATOMIC64_SELFTEST is not set
> # CONFIG_ASYNC_RAID6_TEST is not set
> # CONFIG_SAMPLES is not set
> CONFIG_HAVE_ARCH_KGDB=y
> CONFIG_HAVE_ARCH_KMEMCHECK=y
> # CONFIG_TEST_STRING_HELPERS is not set
> # CONFIG_TEST_KSTRTOX is not set
> CONFIG_STRICT_DEVMEM=y
> CONFIG_X86_VERBOSE_BOOTUP=y
> CONFIG_EARLY_PRINTK=y
> # CONFIG_EARLY_PRINTK_DBGP is not set
> # CONFIG_DEBUG_SET_MODULE_RONX is not set
> # CONFIG_IOMMU_STRESS is not set
> CONFIG_HAVE_MMIOTRACE_SUPPORT=y
> CONFIG_IO_DELAY_TYPE_0X80=0
> CONFIG_IO_DELAY_TYPE_0XED=1
> CONFIG_IO_DELAY_TYPE_UDELAY=2
> CONFIG_IO_DELAY_TYPE_NONE=3
> CONFIG_IO_DELAY_0X80=y
> # CONFIG_IO_DELAY_0XED is not set
> # CONFIG_IO_DELAY_UDELAY is not set
> # CONFIG_IO_DELAY_NONE is not set
> CONFIG_DEFAULT_IO_DELAY_TYPE=0
> CONFIG_OPTIMIZE_INLINING=y
> 
> #
> # Security options
> #
> CONFIG_KEYS=y
> # CONFIG_ENCRYPTED_KEYS is not set
> CONFIG_KEYS_DEBUG_PROC_KEYS=y
> # CONFIG_SECURITY_DMESG_RESTRICT is not set
> # CONFIG_SECURITY is not set
> # CONFIG_SECURITYFS is not set
> CONFIG_DEFAULT_SECURITY_DAC=y
> CONFIG_DEFAULT_SECURITY=""
> CONFIG_XOR_BLOCKS=m
> CONFIG_ASYNC_CORE=m
> CONFIG_ASYNC_MEMCPY=m
> CONFIG_ASYNC_XOR=m
> CONFIG_ASYNC_PQ=m
> CONFIG_ASYNC_RAID6_RECOV=m
> CONFIG_CRYPTO=y
> 
> #
> # Crypto core or helper
> #
> # CONFIG_CRYPTO_FIPS is not set
> CONFIG_CRYPTO_ALGAPI=y
> CONFIG_CRYPTO_ALGAPI2=y
> CONFIG_CRYPTO_AEAD=m
> CONFIG_CRYPTO_AEAD2=y
> CONFIG_CRYPTO_BLKCIPHER=m
> CONFIG_CRYPTO_BLKCIPHER2=y
> CONFIG_CRYPTO_HASH=m
> CONFIG_CRYPTO_HASH2=y
> CONFIG_CRYPTO_RNG=m
> CONFIG_CRYPTO_RNG2=y
> CONFIG_CRYPTO_PCOMP=m
> CONFIG_CRYPTO_PCOMP2=y
> CONFIG_CRYPTO_MANAGER=y
> CONFIG_CRYPTO_MANAGER2=y
> CONFIG_CRYPTO_USER=m
> # CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
> CONFIG_CRYPTO_GF128MUL=m
> CONFIG_CRYPTO_NULL=m
> CONFIG_CRYPTO_PCRYPT=m
> CONFIG_CRYPTO_WORKQUEUE=y
> CONFIG_CRYPTO_CRYPTD=m
> CONFIG_CRYPTO_AUTHENC=m
> CONFIG_CRYPTO_TEST=m
> CONFIG_CRYPTO_ABLK_HELPER_X86=m
> CONFIG_CRYPTO_GLUE_HELPER_X86=m
> 
> #
> # Authenticated Encryption with Associated Data
> #
> CONFIG_CRYPTO_CCM=m
> CONFIG_CRYPTO_GCM=m
> CONFIG_CRYPTO_SEQIV=m
> 
> #
> # Block modes
> #
> CONFIG_CRYPTO_CBC=m
> CONFIG_CRYPTO_CTR=m
> CONFIG_CRYPTO_CTS=m
> CONFIG_CRYPTO_ECB=m
> CONFIG_CRYPTO_LRW=m
> CONFIG_CRYPTO_PCBC=m
> CONFIG_CRYPTO_XTS=m
> 
> #
> # Hash modes
> #
> # CONFIG_CRYPTO_CMAC is not set
> CONFIG_CRYPTO_HMAC=m
> CONFIG_CRYPTO_XCBC=m
> CONFIG_CRYPTO_VMAC=m
> 
> #
> # Digest
> #
> CONFIG_CRYPTO_CRC32C=m
> CONFIG_CRYPTO_CRC32C_INTEL=m
> # CONFIG_CRYPTO_CRC32 is not set
> # CONFIG_CRYPTO_CRC32_PCLMUL is not set
> CONFIG_CRYPTO_GHASH=m
> CONFIG_CRYPTO_MD4=m
> CONFIG_CRYPTO_MD5=m
> CONFIG_CRYPTO_MICHAEL_MIC=m
> CONFIG_CRYPTO_RMD128=m
> CONFIG_CRYPTO_RMD160=m
> CONFIG_CRYPTO_RMD256=m
> CONFIG_CRYPTO_RMD320=m
> CONFIG_CRYPTO_SHA1=m
> CONFIG_CRYPTO_SHA1_SSSE3=m
> # CONFIG_CRYPTO_SHA256_SSSE3 is not set
> # CONFIG_CRYPTO_SHA512_SSSE3 is not set
> CONFIG_CRYPTO_SHA256=m
> CONFIG_CRYPTO_SHA512=m
> CONFIG_CRYPTO_TGR192=m
> CONFIG_CRYPTO_WP512=m
> # CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set
> 
> #
> # Ciphers
> #
> CONFIG_CRYPTO_AES=y
> CONFIG_CRYPTO_AES_X86_64=m
> CONFIG_CRYPTO_AES_NI_INTEL=m
> CONFIG_CRYPTO_ANUBIS=m
> CONFIG_CRYPTO_ARC4=m
> CONFIG_CRYPTO_BLOWFISH=m
> CONFIG_CRYPTO_BLOWFISH_COMMON=m
> CONFIG_CRYPTO_BLOWFISH_X86_64=m
> CONFIG_CRYPTO_CAMELLIA=m
> CONFIG_CRYPTO_CAMELLIA_X86_64=m
> CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=m
> # CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
> CONFIG_CRYPTO_CAST_COMMON=m
> CONFIG_CRYPTO_CAST5=m
> # CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
> CONFIG_CRYPTO_CAST6=m
> # CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
> CONFIG_CRYPTO_DES=m
> CONFIG_CRYPTO_FCRYPT=m
> CONFIG_CRYPTO_KHAZAD=m
> CONFIG_CRYPTO_SALSA20=m
> CONFIG_CRYPTO_SALSA20_X86_64=m
> CONFIG_CRYPTO_SEED=m
> CONFIG_CRYPTO_SERPENT=m
> CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
> CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
> # CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
> CONFIG_CRYPTO_TEA=m
> CONFIG_CRYPTO_TWOFISH=m
> CONFIG_CRYPTO_TWOFISH_COMMON=m
> CONFIG_CRYPTO_TWOFISH_X86_64=m
> CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=m
> CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m
> 
> #
> # Compression
> #
> CONFIG_CRYPTO_DEFLATE=m
> CONFIG_CRYPTO_ZLIB=m
> CONFIG_CRYPTO_LZO=m
> 
> #
> # Random Number Generation
> #
> CONFIG_CRYPTO_ANSI_CPRNG=m
> # CONFIG_CRYPTO_USER_API_HASH is not set
> # CONFIG_CRYPTO_USER_API_SKCIPHER is not set
> # CONFIG_CRYPTO_HW is not set
> # CONFIG_ASYMMETRIC_KEY_TYPE is not set
> CONFIG_HAVE_KVM=y
> CONFIG_HAVE_KVM_IRQCHIP=y
> CONFIG_HAVE_KVM_IRQ_ROUTING=y
> CONFIG_HAVE_KVM_EVENTFD=y
> CONFIG_KVM_APIC_ARCHITECTURE=y
> CONFIG_KVM_MMIO=y
> CONFIG_KVM_ASYNC_PF=y
> CONFIG_HAVE_KVM_MSI=y
> CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
> CONFIG_VIRTUALIZATION=y
> CONFIG_KVM=m
> CONFIG_KVM_INTEL=m
> CONFIG_KVM_AMD=m
> # CONFIG_BINARY_PRINTF is not set
> 
> #
> # Library routines
> #
> CONFIG_RAID6_PQ=m
> CONFIG_BITREVERSE=y
> CONFIG_GENERIC_STRNCPY_FROM_USER=y
> CONFIG_GENERIC_STRNLEN_USER=y
> CONFIG_GENERIC_FIND_FIRST_BIT=y
> CONFIG_GENERIC_PCI_IOMAP=y
> CONFIG_GENERIC_IOMAP=y
> CONFIG_GENERIC_IO=y
> CONFIG_CRC_CCITT=m
> CONFIG_CRC16=m
> # CONFIG_CRC_T10DIF is not set
> # CONFIG_CRC_ITU_T is not set
> CONFIG_CRC32=y
> # CONFIG_CRC32_SELFTEST is not set
> CONFIG_CRC32_SLICEBY8=y
> # CONFIG_CRC32_SLICEBY4 is not set
> # CONFIG_CRC32_SARWATE is not set
> # CONFIG_CRC32_BIT is not set
> # CONFIG_CRC7 is not set
> CONFIG_LIBCRC32C=m
> # CONFIG_CRC8 is not set
> CONFIG_ZLIB_INFLATE=y
> CONFIG_ZLIB_DEFLATE=m
> CONFIG_LZO_COMPRESS=m
> CONFIG_LZO_DECOMPRESS=y
> CONFIG_XZ_DEC=y
> CONFIG_XZ_DEC_X86=y
> CONFIG_XZ_DEC_POWERPC=y
> CONFIG_XZ_DEC_IA64=y
> CONFIG_XZ_DEC_ARM=y
> CONFIG_XZ_DEC_ARMTHUMB=y
> CONFIG_XZ_DEC_SPARC=y
> CONFIG_XZ_DEC_BCJ=y
> # CONFIG_XZ_DEC_TEST is not set
> CONFIG_DECOMPRESS_GZIP=y
> CONFIG_DECOMPRESS_BZIP2=y
> CONFIG_DECOMPRESS_LZMA=y
> CONFIG_DECOMPRESS_XZ=y
> CONFIG_DECOMPRESS_LZO=y
> CONFIG_TEXTSEARCH=y
> CONFIG_TEXTSEARCH_KMP=m
> CONFIG_TEXTSEARCH_BM=m
> CONFIG_TEXTSEARCH_FSM=m
> CONFIG_HAS_IOMEM=y
> CONFIG_HAS_IOPORT=y
> CONFIG_HAS_DMA=y
> CONFIG_CHECK_SIGNATURE=y
> CONFIG_CPU_RMAP=y
> CONFIG_DQL=y
> CONFIG_NLATTR=y
> CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
> CONFIG_LRU_CACHE=m
> # CONFIG_AVERAGE is not set
> # CONFIG_CORDIC is not set
> # CONFIG_DDR is not set
> CONFIG_OID_REGISTRY=m
> 
> REPORTING-BUGS 8.1: Software (add the output of the ver_linux script here)
> Linux server 3.10.12 #1 SMP Mon Sep 16 12:57:50 CEST 2013 x86_64
> Intel(R) Core(TM)2 Quad CPU @ 2.40GHz GenuineIntel GNU/Linux
>  
> Gnu C                  4.7.3
> Gnu make               3.82
> binutils               2.23.2
> util-linux             2.22.2
> mount                  debug
> module-init-tools      13
> e2fsprogs              1.42.7
> xfsprogs               3.1.10
> Linux C Library        2.17
> Dynamic linker (ldd)   2.17
> Procps                 3.3.6
> Net-tools              1.60_p20120127084908
> Kbd                    1.15.3wip
> Sh-utils               8.20
> Modules Loaded         netconsole configfs nfsd auth_rpcgss oid_registry nfs_acl lockd ipv6 tun it87 hwmon_vid sunrpc squashfs loop fuse raid1 coretemp kvm_intel kvm evdev uhci_hcd acpi_cpufreq i2c_i801 i2c_core mperf ehci_pci ehci_hcd usbcore processor usb_common thermal_sys button lpc_ich mfd_core hwmon xts gf128mul r8169 mii ahci libahci xfs crc32c libcrc32c libata sd_mod scsi_mod raid10 raid456 async_memcpy async_pq async_xor xor async_raid6_recov async_tx raid6_pq md_mod dm_crypt cbc aes_x86_64 pcrypt
> 
> REPORTING-BUGS 8.2: Processor information (from /proc/cpuinfo):
> processor       : 0
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 15
> model name      : Intel(R) Core(TM)2 Quad CPU           @ 2.40GHz
> stepping        : 7
> microcode       : 0x68
> cpu MHz         : 2400.000
> cache size      : 4096 KB
> physical id     : 0
> siblings        : 4
> core id         : 0
> cpu cores       : 4
> apicid          : 0
> initial apicid  : 0
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm lahf_lm dtherm tpr_shadow
> bogomips        : 4799.72
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 48 bits virtual
> power management:
> 
> processor       : 1
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 15
> model name      : Intel(R) Core(TM)2 Quad CPU           @ 2.40GHz
> stepping        : 7
> microcode       : 0x68
> cpu MHz         : 2400.000
> cache size      : 4096 KB
> physical id     : 0
> siblings        : 4
> core id         : 3
> cpu cores       : 4
> apicid          : 3
> initial apicid  : 3
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm lahf_lm dtherm tpr_shadow
> bogomips        : 4799.72
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 48 bits virtual
> power management:
> 
> processor       : 2
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 15
> model name      : Intel(R) Core(TM)2 Quad CPU           @ 2.40GHz
> stepping        : 7
> microcode       : 0x68
> cpu MHz         : 2400.000
> cache size      : 4096 KB
> physical id     : 0
> siblings        : 4
> core id         : 2
> cpu cores       : 4
> apicid          : 2
> initial apicid  : 2
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm lahf_lm dtherm tpr_shadow
> bogomips        : 4799.72
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 48 bits virtual
> power management:
> 
> processor       : 3
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 15
> model name      : Intel(R) Core(TM)2 Quad CPU           @ 2.40GHz
> stepping        : 7
> microcode       : 0x68
> cpu MHz         : 2400.000
> cache size      : 4096 KB
> physical id     : 0
> siblings        : 4
> core id         : 1
> cpu cores       : 4
> apicid          : 1
> initial apicid  : 1
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 10
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm lahf_lm dtherm tpr_shadow
> bogomips        : 4799.72
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 48 bits virtual
> power management:
> 
> REPORTING-BUGS 8.3: Module information (from /proc/modules):
> netconsole 6105 0 - Live 0xffffffffa07b0000
> configfs 19029 2 netconsole, Live 0xffffffffa07a6000
> nfsd 190447 13 - Live 0xffffffffa0768000
> auth_rpcgss 34580 1 nfsd, Live 0xffffffffa0759000
> oid_registry 1963 1 auth_rpcgss, Live 0xffffffffa0755000
> nfs_acl 1911 1 nfsd, Live 0xffffffffa0751000
> lockd 52609 1 nfsd, Live 0xffffffffa073c000
> ipv6 256830 74 - Live 0xffffffffa06e9000
> tun 16100 1 - Live 0xffffffffa06e1000
> it87 22822 0 - Live 0xffffffffa06d5000
> hwmon_vid 1964 1 it87, Live 0xffffffffa06d1000
> sunrpc 149164 23 nfsd,auth_rpcgss,nfs_acl,lockd, Live 0xffffffffa0699000
> squashfs 23286 1 - Live 0xffffffffa068f000
> loop 14893 2 - Live 0xffffffffa0686000
> fuse 62883 0 - Live 0xffffffffa066e000
> raid1 23503 1 - Live 0xffffffffa0664000
> coretemp 5430 0 - Live 0xffffffffa0650000
> kvm_intel 116078 0 - Live 0xffffffffa05bc000
> kvm 212134 1 kvm_intel, Live 0xffffffffa04a4000
> evdev 8237 0 - Live 0xffffffffa049d000
> uhci_hcd 17541 0 - Live 0xffffffffa046d000
> acpi_cpufreq 5971 0 - Live 0xffffffffa0461000
> i2c_i801 8359 0 - Live 0xffffffffa045a000
> i2c_core 16431 1 i2c_i801, Live 0xffffffffa044c000
> mperf 1043 1 acpi_cpufreq, Live 0xffffffffa0448000
> ehci_pci 3032 0 - Live 0xffffffffa0439000
> ehci_hcd 28622 1 ehci_pci, Live 0xffffffffa03ec000
> usbcore 114462 3 uhci_hcd,ehci_pci,ehci_hcd, Live 0xffffffffa029c000
> processor 26295 1 acpi_cpufreq, Live 0xffffffffa025b000
> usb_common 1456 1 usbcore, Live 0xffffffffa023b000
> thermal_sys 16544 1 processor, Live 0xffffffffa021f000
> button 4325 0 - Live 0xffffffffa0209000
> lpc_ich 12493 0 - Live 0xffffffffa0200000
> mfd_core 2449 1 lpc_ich, Live 0xffffffffa01fc000
> hwmon 1209 3 it87,coretemp,thermal_sys, Live 0xffffffffa01ec000
> xts 2810 2 - Live 0xffffffffa01e8000
> gf128mul 5439 1 xts, Live 0xffffffffa01e3000
> r8169 46315 0 - Live 0xffffffffa01b2000
> mii 3323 1 r8169, Live 0xffffffffa01ae000
> ahci 21466 18 - Live 0xffffffffa01a2000
> libahci 17494 1 ahci, Live 0xffffffffa0198000
> xfs 551617 3 - Live 0xffffffffa00f7000
> crc32c 1496 1 - Live 0xffffffffa00f3000
> libcrc32c 906 1 xfs, Live 0xffffffffa00ef000
> libata 135748 2 ahci,libahci, Live 0xffffffffa00bc000
> sd_mod 26438 24 - Live 0xffffffffa00b0000
> scsi_mod 114146 2 libata,sd_mod, Live 0xffffffffa0086000
> raid10 34865 1 - Live 0xffffffffa0079000
> raid456 48004 1 - Live 0xffffffffa0068000
> async_memcpy 822 1 raid456, Live 0xffffffffa0064000
> async_pq 1932 1 raid456, Live 0xffffffffa0060000
> async_xor 1257 2 raid456,async_pq, Live 0xffffffffa005c000
> xor 9881 1 async_xor, Live 0xffffffffa0056000
> async_raid6_recov 1169 1 raid456, Live 0xffffffffa0052000
> async_tx 1233 5 raid456,async_memcpy,async_pq,async_xor,async_raid6_recov, Live 0xffffffffa004e000
> raid6_pq 89031 2 async_pq,async_raid6_recov, Live 0xffffffffa0034000
> md_mod 88068 5 raid1,raid10,raid456, Live 0xffffffffa0015000
> dm_crypt 12857 2 - Live 0xffffffffa000d000
> cbc 2432 0 - Live 0xffffffffa0009000
> aes_x86_64 7223 4 - Live 0xffffffffa0004000
> pcrypt 4018 0 - Live 0xffffffffa0000000
> 
> REPORTING-BUGS 8.4: Loaded driver and hardware information (/proc/ioports, /proc/iomem)
> 0000-0cf7 : PCI Bus 0000:00
>   0000-001f : dma1
>   0020-0021 : pic1
>   0040-0043 : timer0
>   0050-0053 : timer1
>   0060-0060 : keyboard
>   0064-0064 : keyboard
>   0080-008f : dma page reg
>   00a0-00a1 : pic2
>   00c0-00df : dma2
>   00f0-00ff : fpu
>   0290-029f : pnp 00:00
>     0290-0294 : pnp 00:00
>     0295-0296 : it87
>       0295-0296 : it87
>   03c0-03df : vga+
>   03f8-03ff : serial
>   0400-047f : 0000:00:1f.0
>     0400-0403 : ACPI PM1a_EVT_BLK
>     0404-0405 : ACPI PM1a_CNT_BLK
>     0408-040b : ACPI PM_TMR
>     0410-0415 : ACPI CPU throttle
>     0420-042f : ACPI GPE0_BLK
>     0430-0433 : iTCO_wdt
>     0460-047f : iTCO_wdt
>   0480-04bf : gpio_ich
>     0480-04bf : 0000:00:1f.0
>   04d0-04d1 : pnp 00:00
>   0500-051f : 0000:00:1f.3
>     0500-051f : i801_smbus
>   0800-087f : pnp 00:00
>   0880-088f : pnp 00:00
> 0cf8-0cff : PCI conf1
> 0d00-ffff : PCI Bus 0000:00
>   a000-afff : PCI Bus 0000:01
>   b000-bfff : PCI Bus 0000:02
>     b000-b007 : 0000:02:00.1
>     b100-b103 : 0000:02:00.1
>     b200-b207 : 0000:02:00.1
>     b300-b303 : 0000:02:00.1
>     b400-b40f : 0000:02:00.1
>   c000-cfff : PCI Bus 0000:03
>     c000-c0ff : 0000:03:00.0
>       c000-c0ff : r8169
>   d000-dfff : PCI Bus 0000:04
>     d000-d0ff : 0000:04:00.0
>   e000-e01f : 0000:00:1a.0
>     e000-e01f : uhci_hcd
>   e100-e11f : 0000:00:1a.1
>     e100-e11f : uhci_hcd
>   e200-e21f : 0000:00:1d.0
>     e200-e21f : uhci_hcd
>   e300-e31f : 0000:00:1d.1
>     e300-e31f : uhci_hcd
>   e400-e41f : 0000:00:1d.2
>     e400-e41f : uhci_hcd
>   e500-e51f : 0000:00:1a.2
>     e500-e51f : uhci_hcd
>   e600-e607 : 0000:00:1f.2
>     e600-e607 : ahci
>   e700-e703 : 0000:00:1f.2
>     e700-e703 : ahci
>   e800-e807 : 0000:00:1f.2
>     e800-e807 : ahci
>   e900-e903 : 0000:00:1f.2
>     e900-e903 : ahci
>   ea00-ea1f : 0000:00:1f.2
>     ea00-ea1f : ahci
> 
> 00000100-00000fff : reserved
> 00001000-0009dbff : System RAM
> 0009dc00-0009f7ff : RAM buffer
> 0009f800-0009ffff : reserved
> 000a0000-000bffff : PCI Bus 0000:00
> 000c0000-000dffff : PCI Bus 0000:00
>   000c0000-000c7fff : Video ROM
>   000c8000-000c8fff : Adapter ROM
> 000f0000-000fffff : reserved
>   000f0000-000fffff : System ROM
> 00100000-f3edffff : System RAM
> f3ee0000-f3ee2fff : ACPI Non-volatile Storage
> f3ee3000-f3eeffff : ACPI Tables
> f3ef0000-f3efffff : reserved
> f3f00000-febfffff : PCI Bus 0000:00
>   f4000000-f7ffffff : PCI MMCONFIG 0000 [bus 00-3f]
>     f4000000-f7ffffff : reserved
>       f4000000-f7ffffff : pnp 00:0a
>   f8000000-f9ffffff : PCI Bus 0000:03
>     f9000000-f9000fff : 0000:03:00.0
>       f9000000-f9000fff : r8169
>   fa000000-fbffffff : PCI Bus 0000:04
>     fa000000-faffffff : 0000:04:00.0
>   fc000000-fc0fffff : PCI Bus 0000:02
>     fc000000-fc001fff : 0000:02:00.0
>       fc000000-fc001fff : ahci
>   fc100000-fc1003ff : 0000:00:1d.7
>     fc100000-fc1003ff : ehci_hcd
>   fc101000-fc1013ff : 0000:00:1a.7
>     fc101000-fc1013ff : ehci_hcd
>   fc102000-fc1027ff : 0000:00:1f.2
>     fc102000-fc1027ff : ahci
>   fc103000-fc1030ff : 0000:00:1f.3
>   fc200000-fc3fffff : PCI Bus 0000:01
>   fc400000-fc5fffff : PCI Bus 0000:01
>   fc600000-fc7fffff : PCI Bus 0000:02
>   fc800000-fcafffff : PCI Bus 0000:03
>     fc800000-fc80ffff : 0000:03:00.0
>   fd000000-fdffffff : PCI Bus 0000:04
>     fd000000-fdffffff : 0000:04:00.0
> fec00000-ffffffff : reserved
>   fec00000-fec003ff : IOAPIC 0
>   fed00000-fed003ff : HPET 0
>   fed10000-fed1dfff : pnp 00:0b
>   fed1f410-fed1f414 : iTCO_wdt
>   fed20000-fed8ffff : pnp 00:0b
>   fee00000-fee00fff : Local APIC
>     fee00000-fee00fff : pnp 00:0b
>   ffb00000-ffb7ffff : pnp 00:0b
>   fff00000-ffffffff : pnp 00:0b
> 100000000-10bffffff : System RAM
>   10b000000-10b26cc26 : Kernel code
>   10b26cc27-10b3bd47f : Kernel data
>   10b46f000-10b4fdfff : Kernel bss
> 
> REPORTING-BUGS 8.5: PCI information ('lspci -vvv' as root)
> 00:00.0 Host bridge: Intel Corporation 82G33/G31/P35/P31 Express DRAM Controller (rev 02)
>         Subsystem: Giga-byte Technology Device 5000
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
>         Latency: 0
>         Capabilities: [e0] Vendor Specific Information: Len=0b <?>
> 
> 00:1a.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #4 (rev 02) (prog-if 00 [UHCI])
>         Subsystem: Giga-byte Technology Device 5004
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 16
>         Region 4: I/O ports at e000 [size=32]
>         Capabilities: [50] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci_hcd
> 
> 00:1a.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #5 (rev 02) (prog-if 00 [UHCI])
>         Subsystem: Giga-byte Technology Device 5004
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 21
>         Region 4: I/O ports at e100 [size=32]
>         Capabilities: [50] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci_hcd
> 
> 00:1a.2 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6 (rev 02) (prog-if 00 [UHCI])
>         Subsystem: Giga-byte Technology Device 5004
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin C routed to IRQ 18
>         Region 4: I/O ports at e500 [size=32]
>         Capabilities: [50] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci_hcd
> 
> 00:1a.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #2 (rev 02) (prog-if 20 [EHCI])
>         Subsystem: Giga-byte Technology Device 5006
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin C routed to IRQ 18
>         Region 0: Memory at fc101000 (32-bit, non-prefetchable) [size=1K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: ehci-pci
>         Kernel modules: ehci_pci
> 
> 00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 1 (rev 02) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>         I/O behind bridge: 0000a000-0000afff
>         Memory behind bridge: fc200000-fc3fffff
>         Prefetchable memory behind bridge: 00000000fc400000-00000000fc5fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
>                         ExtTag- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
>                 LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <1us, L1 <4us
>                         ClockPM- Surprise- LLActRep+ BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
>                         Slot #16, PowerLimit 10.000W; Interlock- NoCompl-
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
>                         Changed: MRL- PresDet- LinkState-
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>         Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
>                 Address: fee0f00c  Data: 41a1
>         Capabilities: [90] Subsystem: Giga-byte Technology Device 5001
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100 v1] Virtual Channel
>                 Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
>                 Arb:    Fixed+ WRR32- WRR64- WRR128-
>                 Ctrl:   ArbSelect=Fixed
>                 Status: InProgress-
>                 VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>                         Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
>                         Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>                         Status: NegoPending- InProgress-
>         Capabilities: [180 v1] Root Complex Link
>                 Desc:   PortNumber=01 ComponentID=02 EltType=Config
>                 Link0:  Desc:   TargetPort=00 TargetComponent=02 AssocRCRB- LinkType=MemMapped LinkValid+
>                         Addr:   00000000fed1c000
>         Kernel driver in use: pcieport
> 
> 00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 5 (rev 02) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
>         I/O behind bridge: 0000b000-0000bfff
>         Memory behind bridge: fc000000-fc0fffff
>         Prefetchable memory behind bridge: 00000000fc600000-00000000fc7fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
>                         ExtTag- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
>                 LnkCap: Port #5, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <256ns, L1 <4us
>                         ClockPM- Surprise- LLActRep+ BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
>                         Slot #20, PowerLimit 10.000W; Interlock- NoCompl-
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
>                         Changed: MRL- PresDet+ LinkState+
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>         Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
>                 Address: fee0f00c  Data: 41b1
>         Capabilities: [90] Subsystem: Giga-byte Technology Device 5001
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100 v1] Virtual Channel
>                 Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
>                 Arb:    Fixed+ WRR32- WRR64- WRR128-
>                 Ctrl:   ArbSelect=Fixed
>                 Status: InProgress-
>                 VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>                         Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
>                         Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>                         Status: NegoPending- InProgress-
>         Capabilities: [180 v1] Root Complex Link
>                 Desc:   PortNumber=05 ComponentID=02 EltType=Config
>                 Link0:  Desc:   TargetPort=00 TargetComponent=02 AssocRCRB- LinkType=MemMapped LinkValid+
>                         Addr:   00000000fed1c000
>         Kernel driver in use: pcieport
> 
> 00:1c.5 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 6 (rev 02) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
>         I/O behind bridge: 0000c000-0000cfff
>         Memory behind bridge: f8000000-f9ffffff
>         Prefetchable memory behind bridge: 00000000fc800000-00000000fcafffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
>                         ExtTag- RBE+ FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
>                 LnkCap: Port #6, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <256ns, L1 <4us
>                         ClockPM- Surprise- LLActRep+ BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
>                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
>                         Slot #21, PowerLimit 10.000W; Interlock- NoCompl-
>                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
>                         Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
>                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
>                         Changed: MRL- PresDet+ LinkState+
>                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
>                 RootCap: CRSVisible-
>                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>         Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
>                 Address: fee0f00c  Data: 41c1
>         Capabilities: [90] Subsystem: Giga-byte Technology Device 5001
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100 v1] Virtual Channel
>                 Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
>                 Arb:    Fixed+ WRR32- WRR64- WRR128-
>                 Ctrl:   ArbSelect=Fixed
>                 Status: InProgress-
>                 VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>                         Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
>                         Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>                         Status: NegoPending- InProgress-
>         Capabilities: [180 v1] Root Complex Link
>                 Desc:   PortNumber=06 ComponentID=02 EltType=Config
>                 Link0:  Desc:   TargetPort=00 TargetComponent=02 AssocRCRB- LinkType=MemMapped LinkValid+
>                         Addr:   00000000fed1c000
>         Kernel driver in use: pcieport
> 
> 00:1d.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
>         Subsystem: Giga-byte Technology Device 5004
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 23
>         Region 4: I/O ports at e200 [size=32]
>         Capabilities: [50] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci_hcd
> 
> 00:1d.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
>         Subsystem: Giga-byte Technology Device 5004
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 19
>         Region 4: I/O ports at e300 [size=32]
>         Capabilities: [50] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci_hcd
> 
> 00:1d.2 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3 (rev 02) (prog-if 00 [UHCI])
>         Subsystem: Giga-byte Technology Device 5004
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin C routed to IRQ 18
>         Region 4: I/O ports at e400 [size=32]
>         Capabilities: [50] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci_hcd
> 
> 00:1d.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1 (rev 02) (prog-if 20 [EHCI])
>         Subsystem: Giga-byte Technology Device 5006
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 23
>         Region 0: Memory at fc100000 (32-bit, non-prefetchable) [size=1K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: ehci-pci
>         Kernel modules: ehci_pci
> 
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92) (prog-if 01 [Subtractive decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Bus: primary=00, secondary=04, subordinate=04, sec-latency=32
>         I/O behind bridge: 0000d000-0000dfff
>         Memory behind bridge: fa000000-fbffffff
>         Prefetchable memory behind bridge: 00000000fd000000-00000000fdffffff
>         Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [50] Subsystem: Giga-byte Technology Motherboard
> 
> 00:1f.0 ISA bridge: Intel Corporation 82801IR (ICH9R) LPC Interface Controller (rev 02)
>         Subsystem: Giga-byte Technology Device 5001
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Capabilities: [e0] Vendor Specific Information: Len=0c <?>
>         Kernel driver in use: lpc_ich
>         Kernel modules: lpc_ich
> 
> 00:1f.2 SATA controller: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH) 6 port SATA Controller [AHCI mode] (rev 02) (prog-if 01 [AHCI 1.0])
>         Subsystem: Giga-byte Technology Device b005
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 43
>         Region 0: I/O ports at e600 [size=8]
>         Region 1: I/O ports at e700 [size=4]
>         Region 2: I/O ports at e800 [size=8]
>         Region 3: I/O ports at e900 [size=4]
>         Region 4: I/O ports at ea00 [size=32]
>         Region 5: Memory at fc102000 (32-bit, non-prefetchable) [size=2K]
>         Capabilities: [80] MSI: Enable+ Count=1/16 Maskable- 64bit-
>                 Address: fee0f00c  Data: 41d1
>         Capabilities: [70] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
>                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=00000004
>         Capabilities: [b0] PCI Advanced Features
>                 AFCap: TP+ FLR+
>                 AFCtrl: FLR-
>                 AFStatus: TP-
>         Kernel driver in use: ahci
>         Kernel modules: ahci
> 
> 00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller (rev 02)
>         Subsystem: Giga-byte Technology Device 5001
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Interrupt: pin C routed to IRQ 18
>         Region 0: Memory at fc103000 (64-bit, non-prefetchable) [size=256]
>         Region 4: I/O ports at 0500 [size=32]
>         Kernel driver in use: i801_smbus
>         Kernel modules: i2c_i801
> 
> 02:00.0 SATA controller: JMicron Technology Corp. JMB363 SATA/IDE Controller (rev 02) (prog-if 01 [AHCI 1.0])
>         Subsystem: Giga-byte Technology Motherboard
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 16
>         Region 5: Memory at fc000000 (32-bit, non-prefetchable) [size=8K]
>         Capabilities: [68] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [50] Express (v1) Legacy Endpoint, MSI 01
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
>                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq+ AuxPwr- TransPend-
>                 LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 unlimited, L1 unlimited
>                         ClockPM- Surprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
>         Kernel driver in use: ahci
>         Kernel modules: ahci
> 
> 02:00.1 IDE interface: JMicron Technology Corp. JMB363 SATA/IDE Controller (rev 02) (prog-if 85 [Master SecO PriO])
>         Subsystem: Giga-byte Technology Motherboard
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Interrupt: pin B routed to IRQ 15
>         Region 0: I/O ports at b000 [size=8]
>         Region 1: I/O ports at b100 [size=4]
>         Region 2: I/O ports at b200 [size=8]
>         Region 3: I/O ports at b300 [size=4]
>         Region 4: I/O ports at b400 [size=16]
>         Capabilities: [68] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> 
> 03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168 PCI Express Gigabit Ethernet controller (rev 01)
>         Subsystem: Giga-byte Technology Motherboard
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 44
>         Region 0: I/O ports at c000 [size=256]
>         Region 2: Memory at f9000000 (64-bit, non-prefetchable) [size=4K]
>         [virtual] Expansion ROM at fc800000 [disabled] [size=64K]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [48] Vital Product Data
>                 Unknown small resource type 00, will not decode more.
>         Capabilities: [50] MSI: Enable+ Count=1/2 Maskable- 64bit+
>                 Address: 00000000fee0f00c  Data: 41e1
>         Capabilities: [60] Express (v1) Endpoint, MSI 00
>                 DevCap: MaxPayload 1024 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
>                         ExtTag+ AttnBtn+ AttnInd+ PwrInd+ RBE- FLReset-
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                         MaxPayload 128 bytes, MaxReadReq 4096 bytes
>                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 unlimited, L1 unlimited
>                         ClockPM- Surprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
>         Capabilities: [84] Vendor Specific Information: Len=4c <?>
>         Capabilities: [100 v1] Advanced Error Reporting
>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>                 AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
>         Capabilities: [12c v1] Virtual Channel
>                 Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
>                 Arb:    Fixed- WRR32- WRR64- WRR128-
>                 Ctrl:   ArbSelect=Fixed
>                 Status: InProgress-
>                 VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>                         Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
>                         Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
>                         Status: NegoPending- InProgress-
>         Capabilities: [148 v1] Device Serial Number 25-00-00-00-10-ec-81-68
>         Capabilities: [154 v1] Power Budgeting <?>
>         Kernel driver in use: r8169
>         Kernel modules: r8169
> 
> 04:00.0 VGA compatible controller: Tseng Labs Inc ET6000 (rev 30) (prog-if 00 [VGA controller])
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Interrupt: pin A routed to IRQ 12
>         Region 0: Memory at fa000000 (32-bit, non-prefetchable) [size=16M]
>         Region 1: I/O ports at d000 [size=256]
>         [virtual] Expansion ROM at fd000000 [disabled] [size=16M]
> 
> REPORTING-BUGS X.:
> /dev/sda
> smartctl 6.1 2013-03-16 r3800 [x86_64-linux-3.10.12] (local build)
> Copyright (C) 2002-13, Bruce Allen, Christian Franke, www.smartmontools.org
> 
> === START OF READ SMART DATA SECTION ===
> SMART Attributes Data Structure revision number: 10
> Vendor Specific SMART Attributes with Thresholds:
> ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
>   1 Raw_Read_Error_Rate     0x000f   113   099   006    Pre-fail  Always       -       52029832
>   3 Spin_Up_Time            0x0003   093   091   000    Pre-fail  Always       -       0
>   4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       28
>   5 Reallocated_Sector_Ct   0x0033   100   100   036    Pre-fail  Always       -       0
>   7 Seek_Error_Rate         0x000f   077   060   030    Pre-fail  Always       -       56370327
>   9 Power_On_Hours          0x0032   092   092   000    Old_age   Always       -       7410
>  10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
>  12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       26
> 183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
> 184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
> 187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
> 188 Command_Timeout         0x0032   100   100   000    Old_age   Always       -       0 0 0
> 189 High_Fly_Writes         0x003a   100   100   000    Old_age   Always       -       0
> 190 Airflow_Temperature_Cel 0x0022   074   059   045    Old_age   Always       -       26 (Min/Max 25/26)
> 191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       0
> 192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       17
> 193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       28
> 194 Temperature_Celsius     0x0022   026   041   000    Old_age   Always       -       26 (0 8 0 0 0)
> 197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
> 198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
> 199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0
> 240 Head_Flying_Hours       0x0000   100   253   000    Old_age   Offline      -       7401h+40m+39.436s
> 241 Total_LBAs_Written      0x0000   100   253   000    Old_age   Offline      -       15179411843
> 242 Total_LBAs_Read         0x0000   100   253   000    Old_age   Offline      -       30364572726
> 
> 
> 
> /dev/sdb
> smartctl 6.1 2013-03-16 r3800 [x86_64-linux-3.10.12] (local build)
> Copyright (C) 2002-13, Bruce Allen, Christian Franke, www.smartmontools.org
> 
> === START OF READ SMART DATA SECTION ===
> SMART Attributes Data Structure revision number: 10
> Vendor Specific SMART Attributes with Thresholds:
> ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
>   1 Raw_Read_Error_Rate     0x000f   101   099   006    Pre-fail  Always       -       3444008
>   3 Spin_Up_Time            0x0003   093   091   000    Pre-fail  Always       -       0
>   4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       28
>   5 Reallocated_Sector_Ct   0x0033   100   100   036    Pre-fail  Always       -       0
>   7 Seek_Error_Rate         0x000f   077   060   030    Pre-fail  Always       -       58291405
>   9 Power_On_Hours          0x0032   092   092   000    Old_age   Always       -       7410
>  10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
>  12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       26
> 183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
> 184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
> 187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
> 188 Command_Timeout         0x0032   100   099   000    Old_age   Always       -       1 1 1
> 189 High_Fly_Writes         0x003a   100   100   000    Old_age   Always       -       0
> 190 Airflow_Temperature_Cel 0x0022   074   058   045    Old_age   Always       -       26 (Min/Max 26/26)
> 191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       0
> 192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       17
> 193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       28
> 194 Temperature_Celsius     0x0022   026   042   000    Old_age   Always       -       26 (0 9 0 0 0)
> 197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
> 198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
> 199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0
> 240 Head_Flying_Hours       0x0000   100   253   000    Old_age   Offline      -       7401h+36m+45.571s
> 241 Total_LBAs_Written      0x0000   100   253   000    Old_age   Offline      -       15416367052
> 242 Total_LBAs_Read         0x0000   100   253   000    Old_age   Offline      -       30467752289
> 
> 
> 
> /dev/sdc
> smartctl 6.1 2013-03-16 r3800 [x86_64-linux-3.10.12] (local build)
> Copyright (C) 2002-13, Bruce Allen, Christian Franke, www.smartmontools.org
> 
> === START OF READ SMART DATA SECTION ===
> SMART Attributes Data Structure revision number: 10
> Vendor Specific SMART Attributes with Thresholds:
> ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
>   1 Raw_Read_Error_Rate     0x000f   118   099   006    Pre-fail  Always       -       175403864
>   3 Spin_Up_Time            0x0003   093   092   000    Pre-fail  Always       -       0
>   4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       42
>   5 Reallocated_Sector_Ct   0x0033   100   100   036    Pre-fail  Always       -       0
>   7 Seek_Error_Rate         0x000f   072   060   030    Pre-fail  Always       -       12941772715
>   9 Power_On_Hours          0x0032   092   092   000    Old_age   Always       -       7392
>  10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
>  12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       43
> 183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
> 184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
> 187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
> 188 Command_Timeout         0x0032   100   100   000    Old_age   Always       -       0 0 0
> 189 High_Fly_Writes         0x003a   065   065   000    Old_age   Always       -       35
> 190 Airflow_Temperature_Cel 0x0022   073   050   045    Old_age   Always       -       27 (Min/Max 27/28)
> 191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       0
> 192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       31
> 193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       42
> 194 Temperature_Celsius     0x0022   027   050   000    Old_age   Always       -       27 (0 11 0 0 0)
> 197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
> 198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
> 199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0
> 240 Head_Flying_Hours       0x0000   100   253   000    Old_age   Offline      -       7393h+04m+25.434s
> 241 Total_LBAs_Written      0x0000   100   253   000    Old_age   Offline      -       15115858985
> 242 Total_LBAs_Read         0x0000   100   253   000    Old_age   Offline      -       31286103359
> 
> 
> 
> /dev/sdd
> smartctl 6.1 2013-03-16 r3800 [x86_64-linux-3.10.12] (local build)
> Copyright (C) 2002-13, Bruce Allen, Christian Franke, www.smartmontools.org
> 
> === START OF READ SMART DATA SECTION ===
> SMART Attributes Data Structure revision number: 10
> Vendor Specific SMART Attributes with Thresholds:
> ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
>   1 Raw_Read_Error_Rate     0x000f   118   099   006    Pre-fail  Always       -       193340384
>   3 Spin_Up_Time            0x0003   093   091   000    Pre-fail  Always       -       0
>   4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       28
>   5 Reallocated_Sector_Ct   0x0033   100   100   036    Pre-fail  Always       -       0
>   7 Seek_Error_Rate         0x000f   077   060   030    Pre-fail  Always       -       4351148414
>   9 Power_On_Hours          0x0032   092   092   000    Old_age   Always       -       7410
>  10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
>  12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       26
> 183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
> 184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
> 187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
> 188 Command_Timeout         0x0032   100   099   000    Old_age   Always       -       2 2 2
> 189 High_Fly_Writes         0x003a   099   099   000    Old_age   Always       -       1
> 190 Airflow_Temperature_Cel 0x0022   072   051   045    Old_age   Always       -       28 (Min/Max 28/29)
> 191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       0
> 192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       17
> 193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       28
> 194 Temperature_Celsius     0x0022   028   049   000    Old_age   Always       -       28 (0 8 0 0 0)
> 197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
> 198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
> 199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0
> 240 Head_Flying_Hours       0x0000   100   253   000    Old_age   Offline      -       7401h+38m+16.728s
> 241 Total_LBAs_Written      0x0000   100   253   000    Old_age   Offline      -       15063356499
> 242 Total_LBAs_Read         0x0000   100   253   000    Old_age   Offline      -       31585014912
> 
> 
> 
> /dev/sde
> smartctl 6.1 2013-03-16 r3800 [x86_64-linux-3.10.12] (local build)
> Copyright (C) 2002-13, Bruce Allen, Christian Franke, www.smartmontools.org
> 
> === START OF READ SMART DATA SECTION ===
> SMART Attributes Data Structure revision number: 10
> Vendor Specific SMART Attributes with Thresholds:
> ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
>   1 Raw_Read_Error_Rate     0x000f   119   099   006    Pre-fail  Always       -       227406336
>   3 Spin_Up_Time            0x0003   094   091   000    Pre-fail  Always       -       0
>   4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       28
>   5 Reallocated_Sector_Ct   0x0033   100   100   036    Pre-fail  Always       -       0
>   7 Seek_Error_Rate         0x000f   077   060   030    Pre-fail  Always       -       58231250
>   9 Power_On_Hours          0x0032   092   092   000    Old_age   Always       -       7410
>  10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
>  12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       26
> 183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
> 184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
> 187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
> 188 Command_Timeout         0x0032   100   098   000    Old_age   Always       -       2 2 2
> 189 High_Fly_Writes         0x003a   097   097   000    Old_age   Always       -       3
> 190 Airflow_Temperature_Cel 0x0022   074   057   045    Old_age   Always       -       26 (Min/Max 26/26)
> 191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       0
> 192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       17
> 193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       28
> 194 Temperature_Celsius     0x0022   026   043   000    Old_age   Always       -       26 (0 9 0 0 0)
> 197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
> 198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
> 199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0
> 240 Head_Flying_Hours       0x0000   100   253   000    Old_age   Offline      -       7401h+43m+09.455s
> 241 Total_LBAs_Written      0x0000   100   253   000    Old_age   Offline      -       15287598878
> 242 Total_LBAs_Read         0x0000   100   253   000    Old_age   Offline      -       30617109958
> 
> 
> 
> /dev/sdf
> smartctl 6.1 2013-03-16 r3800 [x86_64-linux-3.10.12] (local build)
> Copyright (C) 2002-13, Bruce Allen, Christian Franke, www.smartmontools.org
> 
> === START OF READ SMART DATA SECTION ===
> SMART Attributes Data Structure revision number: 10
> Vendor Specific SMART Attributes with Thresholds:
> ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
>   1 Raw_Read_Error_Rate     0x000f   111   099   006    Pre-fail  Always       -       38402152
>   3 Spin_Up_Time            0x0003   093   091   000    Pre-fail  Always       -       0
>   4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       28
>   5 Reallocated_Sector_Ct   0x0033   100   100   036    Pre-fail  Always       -       8
>   7 Seek_Error_Rate         0x000f   077   060   030    Pre-fail  Always       -       4353610470
>   9 Power_On_Hours          0x0032   092   092   000    Old_age   Always       -       7410
>  10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
>  12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       26
> 183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
> 184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
> 187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
> 188 Command_Timeout         0x0032   100   099   000    Old_age   Always       -       1 1 1
> 189 High_Fly_Writes         0x003a   086   086   000    Old_age   Always       -       14
> 190 Airflow_Temperature_Cel 0x0022   075   053   045    Old_age   Always       -       25 (Min/Max 25/25)
> 191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       0
> 192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       17
> 193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       28
> 194 Temperature_Celsius     0x0022   025   047   000    Old_age   Always       -       25 (0 8 0 0 0)
> 197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
> 198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
> 199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0
> 240 Head_Flying_Hours       0x0000   100   253   000    Old_age   Offline      -       7401h+48m+23.389s
> 241 Total_LBAs_Written      0x0000   100   253   000    Old_age   Offline      -       15319843620
> 242 Total_LBAs_Read         0x0000   100   253   000    Old_age   Offline      -       31275159789
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
