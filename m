Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 944F92802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 07:47:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 13so118758917pgg.8
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 04:47:34 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0129.outbound.protection.outlook.com. [104.47.2.129])
        by mx.google.com with ESMTPS id w8si5814627pfj.27.2017.06.30.04.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 04:47:33 -0700 (PDT)
Subject: Re: [PATCH] mm/memory-hotplug: Switch locking to a percpu rwsem
References: <alpine.DEB.2.20.1706291803380.1861@nanos>
 <20170630092747.GD22917@dhcp22.suse.cz>
 <alpine.DEB.2.20.1706301210210.1748@nanos>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <3f2395c6-bbe0-23c1-fe06-d17ffbf619c3@virtuozzo.com>
Date: Fri, 30 Jun 2017 14:49:24 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706301210210.1748@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>



On 06/30/2017 01:15 PM, Thomas Gleixner wrote:
> On Fri, 30 Jun 2017, Michal Hocko wrote:
>> So I like this simplification a lot! Even if we can get rid of the
>> stop_machine eventually this patch would be an improvement. A short
>> comment on why the per-cpu semaphore over the regular one is better
>> would be nice.
> 
> Yes, will add one.
> 
> The main point is that the current locking construct is evading lockdep due
> to the ability to support recursive locking, which I did not observe so
> far.
> 

Like this?


[  131.022567] ============================================
[  131.023034] WARNING: possible recursive locking detected
[  131.023034] 4.12.0-rc7-next-20170630 #10 Not tainted
[  131.023034] --------------------------------------------
[  131.023034] bash/2266 is trying to acquire lock:
[  131.023034]  (cpu_hotplug_lock.rw_sem){++++++}, at: [<ffffffff8117fcd2>] lru_add_drain_all+0x42/0x190
[  131.023034] 
               but task is already holding lock:
[  131.023034]  (cpu_hotplug_lock.rw_sem){++++++}, at: [<ffffffff811d5489>] mem_hotplug_begin+0x9/0x20
[  131.023034] 
               other info that might help us debug this:
[  131.023034]  Possible unsafe locking scenario:

[  131.023034]        CPU0
[  131.023034]        ----
[  131.023034]   lock(cpu_hotplug_lock.rw_sem);
[  131.023034]   lock(cpu_hotplug_lock.rw_sem);
[  131.023034] 
                *** DEADLOCK ***

[  131.023034]  May be due to missing lock nesting notation

[  131.023034] 8 locks held by bash/2266:
[  131.023034]  #0:  (sb_writers#8){.+.+.+}, at: [<ffffffff811e81f8>] vfs_write+0x1a8/0x1d0
[  131.023034]  #1:  (&of->mutex){+.+.+.}, at: [<ffffffff81274b2c>] kernfs_fop_write+0xfc/0x1b0
[  131.023034]  #2:  (s_active#48){.+.+.+}, at: [<ffffffff81274b34>] kernfs_fop_write+0x104/0x1b0
[  131.023034]  #3:  (device_hotplug_lock){+.+.+.}, at: [<ffffffff816d4810>] lock_device_hotplug_sysfs+0x10/0x40
[  131.023034]  #4:  (cpu_hotplug_lock.rw_sem){++++++}, at: [<ffffffff811d5489>] mem_hotplug_begin+0x9/0x20
[  131.023034]  #5:  (mem_hotplug_lock.rw_sem){++++++}, at: [<ffffffff810ada81>] percpu_down_write+0x21/0x110
[  131.023034]  #6:  (&dev->mutex){......}, at: [<ffffffff816d5bd5>] device_offline+0x45/0xb0
[  131.023034]  #7:  (lock#3){+.+...}, at: [<ffffffff8117fccd>] lru_add_drain_all+0x3d/0x190
[  131.023034] 
               stack backtrace:
[  131.023034] CPU: 0 PID: 2266 Comm: bash Not tainted 4.12.0-rc7-next-20170630 #10
[  131.023034] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
[  131.023034] Call Trace:
[  131.023034]  dump_stack+0x85/0xc7
[  131.023034]  __lock_acquire+0x1747/0x17a0
[  131.023034]  ? lru_add_drain_all+0x3d/0x190
[  131.023034]  ? __mutex_lock+0x218/0x940
[  131.023034]  ? trace_hardirqs_on+0xd/0x10
[  131.023034]  lock_acquire+0x103/0x200
[  131.023034]  ? lock_acquire+0x103/0x200
[  131.023034]  ? lru_add_drain_all+0x42/0x190
[  131.023034]  cpus_read_lock+0x3d/0x80
[  131.023034]  ? lru_add_drain_all+0x42/0x190
[  131.023034]  lru_add_drain_all+0x42/0x190
[  131.023034]  __offline_pages.constprop.25+0x5de/0x870
[  131.023034]  offline_pages+0xc/0x10
[  131.023034]  memory_subsys_offline+0x43/0x70
[  131.023034]  device_offline+0x83/0xb0
[  131.023034]  store_mem_state+0xdb/0xe0
[  131.023034]  dev_attr_store+0x13/0x20
[  131.023034]  sysfs_kf_write+0x40/0x50
[  131.023034]  kernfs_fop_write+0x130/0x1b0
[  131.023034]  __vfs_write+0x23/0x130
[  131.023034]  ? rcu_read_lock_sched_held+0x6d/0x80
[  131.023034]  ? rcu_sync_lockdep_assert+0x2a/0x50
[  131.023034]  ? __sb_start_write+0xd4/0x1c0
[  131.023034]  ? vfs_write+0x1a8/0x1d0
[  131.023034]  vfs_write+0xc8/0x1d0
[  131.023034]  SyS_write+0x44/0xa0
[  131.023034]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[  131.023034] RIP: 0033:0x7fb6b54ac310
[  131.023034] RSP: 002b:00007ffcb7b123e8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
[  131.023034] RAX: ffffffffffffffda RBX: 00007fb6b5767640 RCX: 00007fb6b54ac310
[  131.023034] RDX: 0000000000000008 RSI: 00007fb6b5e2d000 RDI: 0000000000000001
[  131.023034] RBP: 0000000000000007 R08: 00007fb6b57687a0 R09: 00007fb6b5e23700
[  131.023034] R10: 0000000000000098 R11: 0000000000000246 R12: 0000000000000007
[  131.023034] R13: 000000000173e9f0 R14: 0000000000000000 R15: 0000000000491569


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
