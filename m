Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3DC66B0292
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 10:07:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id m19so5997018wrb.6
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:07:32 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 22si765041wrv.234.2017.08.16.07.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 16 Aug 2017 07:07:31 -0700 (PDT)
Date: Wed, 16 Aug 2017 16:07:21 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: possible circular locking dependency
 mmap_sem/cpu_hotplug_lock.rw_sem
In-Reply-To: <20170807140947.nhfz2gel6wytl6ia@shodan.usersys.redhat.com>
Message-ID: <alpine.DEB.2.20.1708161605050.1987@nanos>
References: <20170807140947.nhfz2gel6wytl6ia@shodan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Savkov <asavkov@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Mon, 7 Aug 2017, Artem Savkov wrote:

+Cc mm folks ...

> Hello,
> 
> After commit fc8dffd "cpu/hotplug: Convert hotplug locking to percpu rwsem"
> the following lockdep splat started showing up on some systems while running
> ltp's madvise06 test (right after first dirty_pages call [1]).
>
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/madvise/madvise06.c#L136
> 
> [21002.630252] ======================================================
> [21002.637148] WARNING: possible circular locking dependency detected
> [21002.644045] 4.13.0-rc3-next-20170807 #12 Not tainted
> [21002.649583] ------------------------------------------------------
> [21002.656492] a.out/4771 is trying to acquire lock:
> [21002.661742]  (cpu_hotplug_lock.rw_sem){++++++}, at: [<ffffffff812b4668>] drain_all_stock.part.35+0x18/0x140
> [21002.672629] 
> [21002.672629] but task is already holding lock:
> [21002.679137]  (&mm->mmap_sem){++++++}, at: [<ffffffff8106eb35>] __do_page_fault+0x175/0x530
> [21002.688371] 
> [21002.688371] which lock already depends on the new lock.
> [21002.688371] 
> [21002.697505] 
> [21002.697505] the existing dependency chain (in reverse order) is:
> [21002.705856] 
> [21002.705856] -> #3 (&mm->mmap_sem){++++++}:
> [21002.712080]        lock_acquire+0xc9/0x230
> [21002.716661]        __might_fault+0x70/0xa0
> [21002.721241]        _copy_to_user+0x23/0x70
> [21002.725814]        filldir+0xa7/0x110
> [21002.729988]        xfs_dir2_sf_getdents.isra.10+0x20c/0x2c0 [xfs]
> [21002.736840]        xfs_readdir+0x1fa/0x2c0 [xfs]
> [21002.742042]        xfs_file_readdir+0x30/0x40 [xfs]
> [21002.747485]        iterate_dir+0x17a/0x1a0
> [21002.752057]        SyS_getdents+0xb0/0x160
> [21002.756638]        entry_SYSCALL_64_fastpath+0x1f/0xbe
> [21002.762371] 
> [21002.762371] -> #2 (&type->i_mutex_dir_key#3){++++++}:
> [21002.769661]        lock_acquire+0xc9/0x230
> [21002.774239]        down_read+0x51/0xb0
> [21002.778429]        lookup_slow+0xde/0x210
> [21002.782903]        walk_component+0x160/0x250
> [21002.787765]        link_path_walk+0x1a6/0x610
> [21002.792625]        path_openat+0xe4/0xd50
> [21002.797100]        do_filp_open+0x91/0x100
> [21002.801673]        file_open_name+0xf5/0x130
> [21002.806429]        filp_open+0x33/0x50
> [21002.810620]        kernel_read_file_from_path+0x39/0x80
> [21002.816459]        _request_firmware+0x39f/0x880
> [21002.821610]        request_firmware_direct+0x37/0x50
> [21002.827151]        request_microcode_fw+0x64/0xe0
> [21002.832401]        reload_store+0xf7/0x180
> [21002.836974]        dev_attr_store+0x18/0x30
> [21002.841641]        sysfs_kf_write+0x44/0x60
> [21002.846318]        kernfs_fop_write+0x113/0x1a0
> [21002.851374]        __vfs_write+0x37/0x170
> [21002.855849]        vfs_write+0xc7/0x1c0
> [21002.860128]        SyS_write+0x58/0xc0
> [21002.864313]        do_syscall_64+0x6c/0x1f0
> [21002.868973]        return_from_SYSCALL_64+0x0/0x7a
> [21002.874317] 
> [21002.874317] -> #1 (microcode_mutex){+.+.+.}:
> [21002.880748]        lock_acquire+0xc9/0x230
> [21002.885322]        __mutex_lock+0x88/0x960
> [21002.889894]        mutex_lock_nested+0x1b/0x20
> [21002.894854]        microcode_init+0xbb/0x208
> [21002.899617]        do_one_initcall+0x51/0x1a9
> [21002.904481]        kernel_init_freeable+0x208/0x2a7
> [21002.909922]        kernel_init+0xe/0x104
> [21002.914298]        ret_from_fork+0x2a/0x40
> [21002.918867] 
> [21002.918867] -> #0 (cpu_hotplug_lock.rw_sem){++++++}:
> [21002.926058]        __lock_acquire+0x153c/0x1550
> [21002.931112]        lock_acquire+0xc9/0x230
> [21002.935688]        cpus_read_lock+0x4b/0x90
> [21002.940353]        drain_all_stock.part.35+0x18/0x140
> [21002.945987]        try_charge+0x3ab/0x6e0
> [21002.950460]        mem_cgroup_try_charge+0x7f/0x2c0
> [21002.955902]        shmem_getpage_gfp+0x25f/0x1050
> [21002.961149]        shmem_fault+0x96/0x200
> [21002.965621]        __do_fault+0x1e/0xa0
> [21002.969905]        __handle_mm_fault+0x9c3/0xe00
> [21002.975056]        handle_mm_fault+0x16e/0x380
> [21002.980013]        __do_page_fault+0x24a/0x530
> [21002.984968]        do_page_fault+0x30/0x80
> [21002.989537]        page_fault+0x28/0x30
> [21002.993812] 
> [21002.993812] other info that might help us debug this:
> [21002.993812] 
> [21003.002744] Chain exists of:
> [21003.002744]   cpu_hotplug_lock.rw_sem --> &type->i_mutex_dir_key#3 --> &mm->mmap_sem
> [21003.002744] 
> [21003.016238]  Possible unsafe locking scenario:
> [21003.016238] 
> [21003.022843]        CPU0                    CPU1
> [21003.027896]        ----                    ----
> [21003.032948]   lock(&mm->mmap_sem);
> [21003.036741]                                lock(&type->i_mutex_dir_key#3);
> [21003.044419]                                lock(&mm->mmap_sem);
> [21003.051025]   lock(cpu_hotplug_lock.rw_sem);
> [21003.055788] 
> [21003.055788]  *** DEADLOCK ***
> [21003.055788] 
> [21003.062393] 2 locks held by a.out/4771:
> [21003.066675]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8106eb35>] __do_page_fault+0x175/0x530
> [21003.076391]  #1:  (percpu_charge_mutex){+.+...}, at: [<ffffffff812b4c97>] try_charge+0x397/0x6e0
> [21003.086198] 
> [21003.086198] stack backtrace:
> [21003.091059] CPU: 6 PID: 4771 Comm: a.out Not tainted 4.13.0-rc3-next-20170807 #12
> [21003.099409] Hardware name: Dell Inc. PowerEdge M520/0DW6GX, BIOS 2.4.2 02/03/2015
> [21003.107766] Call Trace:
> [21003.110495]  dump_stack+0x85/0xc9
> [21003.114190]  print_circular_bug+0x1f9/0x207
> [21003.118854]  __lock_acquire+0x153c/0x1550
> [21003.123327]  lock_acquire+0xc9/0x230
> [21003.127313]  ? drain_all_stock.part.35+0x18/0x140
> [21003.132563]  cpus_read_lock+0x4b/0x90
> [21003.136652]  ? drain_all_stock.part.35+0x18/0x140
> [21003.141900]  drain_all_stock.part.35+0x18/0x140
> [21003.146954]  try_charge+0x3ab/0x6e0
> [21003.150846]  mem_cgroup_try_charge+0x7f/0x2c0
> [21003.155705]  shmem_getpage_gfp+0x25f/0x1050
> [21003.160374]  shmem_fault+0x96/0x200
> [21003.164263]  ? __lock_acquire+0x2fb/0x1550
> [21003.168832]  ? __lock_acquire+0x2fb/0x1550
> [21003.173402]  __do_fault+0x1e/0xa0
> [21003.177097]  __handle_mm_fault+0x9c3/0xe00
> [21003.181669]  handle_mm_fault+0x16e/0x380
> [21003.186045]  ? handle_mm_fault+0x49/0x380
> [21003.190518]  __do_page_fault+0x24a/0x530
> [21003.194895]  do_page_fault+0x30/0x80
> [21003.198883]  page_fault+0x28/0x30
> [21003.202593] RIP: 0033:0x400886
> [21003.205998] RSP: 002b:00007fff81d84d20 EFLAGS: 00010206
> [21003.211827] RAX: 00007fc763bb7000 RBX: 0000000000000000 RCX: 0000000000001000
> [21003.219789] RDX: 0000000006362000 RSI: 0000000019000000 RDI: 00007fc75d855000
> [21003.227751] RBP: 00007fff81d84d50 R08: ffffffffffffffff R09: 0000000000000000
> [21003.235713] R10: 00007fff81d84a30 R11: 00007fc7769445d0 R12: 0000000000400750
> [21003.243681] R13: 00007fff81d84f70 R14: 0000000000000000 R15: 0000000000000000
> 
> -- 
> Regards,
>   Artem
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
