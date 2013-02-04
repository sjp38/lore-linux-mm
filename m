Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 693656B0002
	for <linux-mm@kvack.org>; Sun,  3 Feb 2013 21:37:03 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kp1so285825pab.17
        for <linux-mm@kvack.org>; Sun, 03 Feb 2013 18:37:02 -0800 (PST)
Date: Mon, 4 Feb 2013 10:36:46 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: CPU hotplug hang due to "swap: make each swap partition have one
 address_space"
Message-ID: <20130204023646.GA321@kernel.org>
References: <510C9DE9.9040207@wwwdotorg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <510C9DE9.9040207@wwwdotorg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Cc: Shaohua Li <shli@fusionio.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Joseph Lo <josephl@nvidia.com>

On Fri, Feb 01, 2013 at 10:02:33PM -0700, Stephen Warren wrote:
> Shaohua,
> 
> In next-20130128, commit 174f064 "swap: make each swap partition have
> one address_space" (from the mm/akpm tree) appears causes a hang/RCU
> stall for me when hot-unplugging a CPU.

does this one work for you?
http://marc.info/?l=linux-mm&m=135929599505624&w=2
Or try a more recent linux-next. The patch is in akpm's tree.

Thanks,
Shaohua 

> I'm running on a quad-core ARM system, and hot-unplugging a CPU using:
> 
> echo 0 > /sys/devices/system/cpu/cpu2/online
> 
> CONFIG_SWAP is enabled, but I don't have any swap devices activated.
> 
> If I either disable CONFIG_SWAP, or revert commit 174f064, then CPU
> hotplug works fine for me.
> 
> I read through the patch and didn't see anything obvious, but I'm not
> remotely familiar with the code in question.
> 
> Do you have any idea what might be wrong? Thanks.
> 
> The RCU stall kernel log is:
> 
> > [   36.152471] CPU2: shutdown
> > [   57.151682] INFO: rcu_sched self-detected stall on CPU { 1}  (t=2100 jiffies g=4294966997 c=4294966996 q=1)
> > [   57.164730] [<c0014658>] (unwind_backtrace+0x0/0xf8) from [<c0080c4c>] (rcu_check_callbacks+0x360/0x81c)
> > [   57.177468] [<c0080c4c>] (rcu_check_callbacks+0x360/0x81c) from [<c002f4b0>] (update_process_times+0x38/0x64)
> > [   57.182152] INFO: rcu_sched detected stalls on CPUs/tasks: { 1} (detected by 3, t=2103 jiffies, g=4294966997, c=4294966996, q=1)
> > [   57.182154] Task dump for CPU 1:
> > [   57.182162] sh              R running      0   569    568 0x00000002
> > [   57.182200] [<c04d9bdc>] (__schedule+0x33c/0x6ac) from [<c000df40>] (__irq_svc+0x40/0x70)
> > [   57.182211] [<c000df40>] (__irq_svc+0x40/0x70) from [<c04dae04>] (_raw_spin_unlock_irqrestore+0x28/0x50)
> > [   57.182221] [<c04dae04>] (_raw_spin_unlock_irqrestore+0x28/0x50) from [<c04d4660>] (percpu_counter_hotcpu_callback+0x68/0x9c)
> > [   57.182235] [<c04d4660>] (percpu_counter_hotcpu_callback+0x68/0x9c) from [<c00430f8>] (notifier_call_chain+0x44/0x84)
> > [   57.182246] [<c00430f8>] (notifier_call_chain+0x44/0x84) from [<c0025fa8>] (__cpu_notify+0x28/0x44)
> > [   57.182255] [<c0025fa8>] (__cpu_notify+0x28/0x44) from [<c0026104>] (cpu_notify_nofail+0x8/0x14)
> > [   57.182276] [<c0026104>] (cpu_notify_nofail+0x8/0x14) from [<c04cf134>] (_cpu_down+0xf8/0x25c)
> > [   57.182286] [<c04cf134>] (_cpu_down+0xf8/0x25c) from [<c04cf2bc>] (cpu_down+0x24/0x40)
> > [   57.182296] [<c04cf2bc>] (cpu_down+0x24/0x40) from [<c04d0958>] (store_online+0x30/0x78)
> > [   57.182317] [<c04d0958>] (store_online+0x30/0x78) from [<c027367c>] (dev_attr_store+0x18/0x24)
> > [   57.182332] [<c027367c>] (dev_attr_store+0x18/0x24) from [<c0115770>] (sysfs_write_file+0x168/0x198)
> > [   57.182354] [<c0115770>] (sysfs_write_file+0x168/0x198) from [<c00c4414>] (vfs_write+0x9c/0x140)
> > [   57.182364] [<c00c4414>] (vfs_write+0x9c/0x140) from [<c00c46a0>] (sys_write+0x3c/0x70)
> > [   57.182374] [<c00c46a0>] (sys_write+0x3c/0x70) from [<c000e2c0>] (ret_fast_syscall+0x0/0x30)
> > [   57.404633] [<c002f4b0>] (update_process_times+0x38/0x64) from [<c0064798>] (tick_sched_timer+0x44/0x74)
> > [   57.418340] [<c0064798>] (tick_sched_timer+0x44/0x74) from [<c0041440>] (__run_hrtimer.isra.15+0x58/0x114)
> > [   57.432362] [<c0041440>] (__run_hrtimer.isra.15+0x58/0x114) from [<c0041d94>] (hrtimer_interrupt+0x100/0x290)
> > [   57.446620] [<c0041d94>] (hrtimer_interrupt+0x100/0x290) from [<c0013bfc>] (twd_handler+0x2c/0x40)
> > [   57.459981] [<c0013bfc>] (twd_handler+0x2c/0x40) from [<c007bdb4>] (handle_percpu_devid_irq+0x64/0x80)
> > [   57.473749] [<c007bdb4>] (handle_percpu_devid_irq+0x64/0x80) from [<c007887c>] (generic_handle_irq+0x20/0x30)
> > [   57.488197] [<c007887c>] (generic_handle_irq+0x20/0x30) from [<c000eb74>] (handle_IRQ+0x38/0x94)
> > [   57.501559] [<c000eb74>] (handle_IRQ+0x38/0x94) from [<c00086d8>] (gic_handle_irq+0x28/0x5c)
> > [   57.514610] [<c00086d8>] (gic_handle_irq+0x28/0x5c) from [<c000df40>] (__irq_svc+0x40/0x70)
> > [   57.527606] Exception stack(0xed57be58 to 0xed57bea0)
> > [   57.537292] be40:                                                       c06e5c50 20000113
> > [   57.550216] be60: 00000000 55ec55ec 00000000 00000000 00000002 c06ea074 c06daf08 c06e5c50
> > [   57.563134] be80: 00000000 00015ef8 00000000 ed57bea0 c04d4660 c04dae04 40000113 ffffffff
> > [   57.576119] [<c000df40>] (__irq_svc+0x40/0x70) from [<c04dae04>] (_raw_spin_unlock_irqrestore+0x28/0x50)
> > [   57.590515] [<c04dae04>] (_raw_spin_unlock_irqrestore+0x28/0x50) from [<c04d4660>] (percpu_counter_hotcpu_callback+0x68/0x9c)
> > [   57.606765] [<c04d4660>] (percpu_counter_hotcpu_callback+0x68/0x9c) from [<c00430f8>] (notifier_call_chain+0x44/0x84)
> > [   57.622320] [<c00430f8>] (notifier_call_chain+0x44/0x84) from [<c0025fa8>] (__cpu_notify+0x28/0x44)
> > [   57.636338] [<c0025fa8>] (__cpu_notify+0x28/0x44) from [<c0026104>] (cpu_notify_nofail+0x8/0x14)
> > [   57.650161] [<c0026104>] (cpu_notify_nofail+0x8/0x14) from [<c04cf134>] (_cpu_down+0xf8/0x25c)
> > [   57.663859] [<c04cf134>] (_cpu_down+0xf8/0x25c) from [<c04cf2bc>] (cpu_down+0x24/0x40)
> > [   57.676850] [<c04cf2bc>] (cpu_down+0x24/0x40) from [<c04d0958>] (store_online+0x30/0x78)
> > [   57.690010] [<c04d0958>] (store_online+0x30/0x78) from [<c027367c>] (dev_attr_store+0x18/0x24)
> > [   57.703767] [<c027367c>] (dev_attr_store+0x18/0x24) from [<c0115770>] (sysfs_write_file+0x168/0x198)
> > [   57.717948] [<c0115770>] (sysfs_write_file+0x168/0x198) from [<c00c4414>] (vfs_write+0x9c/0x140)
> > [   57.731866] [<c00c4414>] (vfs_write+0x9c/0x140) from [<c00c46a0>] (sys_write+0x3c/0x70)
> > [   57.744841] [<c00c46a0>] (sys_write+0x3c/0x70) from [<c000e2c0>] (ret_fast_syscall+0x0/0x30)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
