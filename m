Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id A7F0A6B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 17:58:58 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so1225525eek.30
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 14:58:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si5075474eep.317.2014.04.23.14.58.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 14:58:55 -0700 (PDT)
Date: Wed, 23 Apr 2014 23:58:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Kernel crash triggered by dd to file with memcg, worst on btrfs
Message-ID: <20140423215852.GA6651@dhcp22.suse.cz>
References: <20140416174210.GA11486@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416174210.GA11486@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

[CCing Vladimir]

On Wed 16-04-14 18:42:10, Richard Davies wrote:
> Hi all,
> 
> I have a test case in which I can often crash an entire machine by running
> dd to a file with a memcg with relatively generous limits. This is
> simplified from real world problems with heavy disk i/o inside containers.
> 
> The crashes are easy to trigger when dding to create a file on btrfs. On
> ext3, typically there is just an error in the kernel log, although
> occasionally it also crashes.
> 
> I'm not a kernel developer, but I'm happy to help with any further debugging
> or try patches.
> 
> [I have also just reported a different but similar bug with untar in a memcg
> http://marc.info/?l=linux-mm&m=139766321822891 That one is not btrfs-linked]
> 
> 
> To replicate on Linux 3.14.0, run the following 8 commands:
> 
> # mkdir -p /sys/fs/cgroup/test/
> # cat /sys/fs/cgroup/cpuset.cpus > /sys/fs/cgroup/test/cpuset.cpus
> # cat /sys/fs/cgroup/cpuset.mems > /sys/fs/cgroup/test/cpuset.mems
> # echo $((1<<30)) >/sys/fs/cgroup/test/memory.limit_in_bytes
> # echo $((1<<30)) >/sys/fs/cgroup/test/memory.memsw.limit_in_bytes
> # echo $((1<<28)) >/sys/fs/cgroup/test/memory.kmem.limit_in_bytes

Does this happen even if no kmem limit is specified?
The kmem limit would explain allocation failures for ext3 logged bellow
but I would be interested about the "Thread overran stack, or stack
corrupted" message reported for btrfs. The stack doesn't seem very deep
there. I would expect some issues in the writeback path during the limit
reclaim but this looks quite innocent. Rulling out kmem accounting would
be a good first step though . (I am keepinng the full email for Vladimir)

> # echo $$ > /sys/fs/cgroup/test/tasks
> # dd if=/dev/zero of=./crashme bs=2M
> 
> and leave until several GB of data have been written.
> 
> When running into a btrfs filesystem, this dd crashes the entire machine
> about 50% of the time for me, generating a console log as copied below. If
> the initial dd is running smoothly, I can often get it to crash by stopping
> the dd with ctrl-c and starting it again with a different output file,
> perhaps repeating this a few times.
> 
> When running into an ext3 filesystem, this dd typically doesn't crash the
> machine but just output errors in the kernel log as copied below.
> Occasionally it will still crash.
> 
> 
> I am happy to help with extra information on kernel configuration, but I
> hope that the above is sufficient for others to replicate. I'm also happy to
> try suggestions and patches.
> 
> Thanks in advance for your help,
> 
> Richard.
> 
> 
> Ext3 kernel error log
> =====================
> 
> 17:20:05 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> 17:20:05 kernel:  cache: ext4_extent_status(2:test), object size: 40, buffer size: 40, default order: 0, min order: 0
> 17:20:05 kernel:  node 0: slabs: 375, objs: 38250, free: 0
> 17:20:05 kernel:  node 1: slabs: 128, objs: 13056, free: 0
> (many times)

This looks like the kmem limit has been reached and all the further
allocation fails.

> Btrfs kernel console crash log
> ==============================
> 
> BUG: unable to handle kernel paging request at fffffffe36a55230
> IP: [<ffffffff810f5055>] cpuacct_charge+0x35/0x58
> PGD 1b5d067 PUD 0
> Thread overran stack, or stack corrupted

This is really unexpected. Especially when the stack dumped bellow is
not a usual suspect. This is a simple interrupt handler which handles
hrtimer and this shouldn't overflow the stack...

> Oops: 0000 [#1] PREEMPT SMP
> Modules linked in:
> CPU: 6 PID: 5729 Comm: dd Not tainted 3.14.0-elastic #1
> Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
> task: ffff88040a6fdac0 ti: ffff8800d69cc000 task.ti: ffff8800d69cc000
> RIP: 0010:[<ffffffff810f5055>]  [<ffffffff810f5055>] cpuacct_charge+0x35/0x58
> RSP: 0018:ffff880827d03d88  EFLAGS: 00010002
> RAX: 000060f7d80032d0 RBX: ffff88040a6fdac0 RCX: ffffffffd69cc148
> RDX: ffff88081191a180 RSI: 00000000000ebb99 RDI: ffff88040a6fdac0
> RBP: ffff880827d03da8 R08: 0000000000000000 R09: ffff880827ffc348
> R10: ffff880827ffc2a0 R11: ffff880827ffc340 R12: ffffffffd69cc148
> R13: 00000000000ebb99 R14: fffffffffffebb99 R15: ffff88040a6fdac0
> FS:  00007f508b54e6f0(0000) GS:ffff880827d00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: fffffffe36a55230 CR3: 000000080e9d2000 CR4: 00000000000007e0
> Stack:
>  0000000000000000 ffff88040a6fdac0 ffff880810fe2800 00000000000ebb99
>  ffff880827d03dd8 ffffffff810ebbb3 ffff88040a6fdb28 ffff880810fe2800
>  ffff880827d11bc0 0000000000000000 ffff880827d03e28 ffffffff810eeaaf
> Call Trace:
>  <IRQ>
>  [<ffffffff810ebbb3>] update_curr+0xc2/0x11e
>  [<ffffffff810eeaaf>] task_tick_fair+0x3d/0x631
>  [<ffffffff810e5bb7>] scheduler_tick+0x57/0xba
>  [<ffffffff81108eaf>] ? tick_nohz_handler+0xcf/0xcf
>  [<ffffffff810cb73d>] update_process_times+0x55/0x66
>  [<ffffffff81108f2b>] tick_sched_timer+0x7c/0x9b
>  [<ffffffff810dd0d2>] __run_hrtimer+0x57/0xcc
>  [<ffffffff810dd4c7>] hrtimer_interrupt+0xd0/0x1db
>  [<ffffffff810e761b>] ? __vtime_account_system+0x2d/0x31
>  [<ffffffff8105f8c1>] local_apic_timer_interrupt+0x53/0x58
>  [<ffffffff81060475>] smp_apic_timer_interrupt+0x3e/0x51
>  [<ffffffff8186299d>] apic_timer_interrupt+0x6d/0x80
>  <EOI>
> Code: 54 53 48 89 fb 48 83 ec 08 48 8b 47 08 4c 63 60 18 e8 84 8c 00 00 48 8b 83 a0 06 00 00 4c 89 e1 48 8b 50 48 48 8b 82 80 00 00 00 <48> 03 04 cd f0 47 bf 81 4c 01 28 48 8b 52 40 48 85 d2 75 e5 e8
> RIP  [<ffffffff810f5055>] cpuacct_charge+0x35/0x58
>  RSP <ffff880827d03d88>
> CR2: fffffffe36a55230
> ---[ end trace b449af50c3a0711c ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
