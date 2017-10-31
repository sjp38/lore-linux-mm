Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 924816B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:20:51 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h70so43489871ioi.5
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:20:51 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f78sor968053ita.133.2017.10.31.06.20.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 06:20:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <001a114a6b20cafb9c055cd73f86@google.com>
References: <001a114a6b20cafb9c055cd73f86@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 31 Oct 2017 16:20:27 +0300
Message-ID: <CACT4Y+aCV2wEP2yAh7qDtmuTt55DMEQGXzumxR6iXqitjuruiw@mail.gmail.com>
Subject: Re: possible deadlock in __synchronize_srcu
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+b8ff4d5c3fa77f2e2f0f9be34e6b2795ffc3c65e@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs@googlegroups.com, kasan-dev <kasan-dev@googlegroups.com>

On Tue, Oct 31, 2017 at 3:54 PM, syzbot
<bot+b8ff4d5c3fa77f2e2f0f9be34e6b2795ffc3c65e@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 9506597de2cde02d48c11d5c250250b9143f59f7
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.

Another reincarnation of:
https://groups.google.com/d/msg/syzkaller-bugs/PCeHYAmw-TQ/TKMoo6xhAgAJ

#syz dup: possible deadlock in process_one_work



> ======================================================
> WARNING: possible circular locking dependency detected
> 4.13.0-rc6-next-20170824+ #8 Not tainted
> ------------------------------------------------------
> kworker/u4:2/57 is trying to acquire lock:
>  ((complete)&rcu.completion){+.+.}, at: [<ffffffff815afff5>]
> __synchronize_srcu+0x1b5/0x250 kernel/rcu/srcutree.c:898
>
> but task is already holding lock:
>  (slab_mutex){+.+.}, at: [<ffffffff8192b730>] kmem_cache_destroy+0x30/0x250
> mm/slab_common.c:821
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> -> #3 (slab_mutex){+.+.}:
>        check_prevs_add kernel/locking/lockdep.c:2020 [inline]
>        validate_chain kernel/locking/lockdep.c:2469 [inline]
>        __lock_acquire+0x3286/0x4620 kernel/locking/lockdep.c:3498
>        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
>        __mutex_lock_common kernel/locking/mutex.c:756 [inline]
>        __mutex_lock+0x16f/0x1870 kernel/locking/mutex.c:893
>        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
>        kmem_cache_create+0x39/0x2a0 mm/slab_common.c:435
>        ptlock_cache_init+0x24/0x2d mm/memory.c:4632
>        pgtable_init include/linux/mm.h:1756 [inline]
>        mm_init init/main.c:504 [inline]
>        start_kernel+0x3d4/0x7ad init/main.c:569
>        x86_64_start_reservations+0x2a/0x2c arch/x86/kernel/head64.c:381
>        x86_64_start_kernel+0x13c/0x149 arch/x86/kernel/head64.c:362
>        verify_cpu+0x0/0xfb
>
> -> #2 (memcg_cache_ids_sem){.+.+}:
>        check_prevs_add kernel/locking/lockdep.c:2020 [inline]
>        validate_chain kernel/locking/lockdep.c:2469 [inline]
>        __lock_acquire+0x3286/0x4620 kernel/locking/lockdep.c:3498
>        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
>        down_read+0x96/0x150 kernel/locking/rwsem.c:23
>        memcg_get_cache_ids+0x10/0x20 mm/memcontrol.c:274
>        list_lru_destroy+0x96/0x490 mm/list_lru.c:573
>        deactivate_locked_super+0x94/0xd0 fs/super.c:315
>        deactivate_super+0x141/0x1b0 fs/super.c:339
>        cleanup_mnt+0xb2/0x150 fs/namespace.c:1113
>        mntput_no_expire+0x6e0/0xa90 fs/namespace.c:1179
>        mntput fs/namespace.c:1189 [inline]
>        kern_unmount+0x9c/0xd0 fs/namespace.c:2934
>        pid_ns_release_proc+0x37/0x50 fs/proc/root.c:231
>        proc_cleanup_work+0x19/0x20 kernel/pid_namespace.c:79
>        process_one_work+0xbfd/0x1be0 kernel/workqueue.c:2098
>        worker_thread+0x223/0x1860 kernel/workqueue.c:2233
>        kthread+0x39c/0x470 kernel/kthread.c:231
>        ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>
> -> #1 ((&ns->proc_work)){+.+.}:
>        process_one_work+0xba5/0x1be0 kernel/workqueue.c:2095
>        worker_thread+0x223/0x1860 kernel/workqueue.c:2233
>        kthread+0x39c/0x470 kernel/kthread.c:231
>        ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>        0xffffffffffffffff
>
> -> #0 ((complete)&rcu.completion){+.+.}:
>        check_prev_add+0x865/0x1520 kernel/locking/lockdep.c:1894
>        check_prevs_add kernel/locking/lockdep.c:2020 [inline]
>        validate_chain kernel/locking/lockdep.c:2469 [inline]
>        __lock_acquire+0x3286/0x4620 kernel/locking/lockdep.c:3498
>        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
>        complete_acquire include/linux/completion.h:39 [inline]
>        __wait_for_common kernel/sched/completion.c:108 [inline]
>        wait_for_common kernel/sched/completion.c:122 [inline]
>        wait_for_completion+0xc8/0x770 kernel/sched/completion.c:143
>        __synchronize_srcu+0x1b5/0x250 kernel/rcu/srcutree.c:898
>        synchronize_srcu_expedited kernel/rcu/srcutree.c:923 [inline]
>        synchronize_srcu+0x1a3/0x560 kernel/rcu/srcutree.c:974
>        quarantine_remove_cache+0xd7/0xf0 mm/kasan/quarantine.c:327
>        kasan_cache_shutdown+0x9/0x10 mm/kasan/kasan.c:381
>        shutdown_cache+0x15/0x1b0 mm/slab_common.c:531
>        kmem_cache_destroy+0x236/0x250 mm/slab_common.c:829
>        tipc_server_stop+0x13f/0x190 net/tipc/server.c:636
>        tipc_topsrv_stop+0x1fe/0x350 net/tipc/subscr.c:390
>        tipc_exit_net+0x15/0x40 net/tipc/core.c:96
>        ops_exit_list.isra.6+0xae/0x150 net/core/net_namespace.c:142
>        cleanup_net+0x5c7/0xb60 net/core/net_namespace.c:483
>        process_one_work+0xbfd/0x1be0 kernel/workqueue.c:2098
>        worker_thread+0x223/0x1860 kernel/workqueue.c:2233
>        kthread+0x39c/0x470 kernel/kthread.c:231
>        ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>
> other info that might help us debug this:
>
> Chain exists of:
>   (complete)&rcu.completion --> memcg_cache_ids_sem --> slab_mutex
>
>  Possible unsafe locking scenario:
>
>        CPU0                    CPU1
>        ----                    ----
>   lock(slab_mutex);
>                                lock(memcg_cache_ids_sem);
>                                lock(slab_mutex);
>   lock((complete)&rcu.completion);
>
>  *** DEADLOCK ***
>
> 5 locks held by kworker/u4:2/57:
>  #0:  ("%s""netns"){.+.+}, at: [<ffffffff81464534>] __write_once_size
> include/linux/compiler.h:305 [inline]
>  #0:  ("%s""netns"){.+.+}, at: [<ffffffff81464534>] atomic64_set
> arch/x86/include/asm/atomic64_64.h:33 [inline]
>  #0:  ("%s""netns"){.+.+}, at: [<ffffffff81464534>] atomic_long_set
> include/asm-generic/atomic-long.h:56 [inline]
>  #0:  ("%s""netns"){.+.+}, at: [<ffffffff81464534>] set_work_data
> kernel/workqueue.c:617 [inline]
>  #0:  ("%s""netns"){.+.+}, at: [<ffffffff81464534>]
> set_work_pool_and_clear_pending kernel/workqueue.c:644 [inline]
>  #0:  ("%s""netns"){.+.+}, at: [<ffffffff81464534>]
> process_one_work+0xad4/0x1be0 kernel/workqueue.c:2090
>  #1:  (net_cleanup_work){+.+.}, at: [<ffffffff8146458c>]
> process_one_work+0xb2c/0x1be0 kernel/workqueue.c:2094
>  #2:  (net_mutex){+.+.}, at: [<ffffffff83e50bc7>] cleanup_net+0x247/0xb60
> net/core/net_namespace.c:449
>  #3:  (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff8192b722>]
> get_online_cpus include/linux/cpu.h:126 [inline]
>  #3:  (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff8192b722>]
> kmem_cache_destroy+0x22/0x250 mm/slab_common.c:818
>  #4:  (slab_mutex){+.+.}, at: [<ffffffff8192b730>]
> kmem_cache_destroy+0x30/0x250 mm/slab_common.c:821
>
> stack backtrace:
> CPU: 1 PID: 57 Comm: kworker/u4:2 Not tainted 4.13.0-rc6-next-20170824+ #8
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Workqueue: netns cleanup_net
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  print_circular_bug+0x503/0x710 kernel/locking/lockdep.c:1259
>  check_prev_add+0x865/0x1520 kernel/locking/lockdep.c:1894
>  check_prevs_add kernel/locking/lockdep.c:2020 [inline]
>  validate_chain kernel/locking/lockdep.c:2469 [inline]
>  __lock_acquire+0x3286/0x4620 kernel/locking/lockdep.c:3498
>  lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
>  complete_acquire include/linux/completion.h:39 [inline]
>  __wait_for_common kernel/sched/completion.c:108 [inline]
>  wait_for_common kernel/sched/completion.c:122 [inline]
>  wait_for_completion+0xc8/0x770 kernel/sched/completion.c:143
>  __synchronize_srcu+0x1b5/0x250 kernel/rcu/srcutree.c:898
>  synchronize_srcu_expedited kernel/rcu/srcutree.c:923 [inline]
>  synchronize_srcu+0x1a3/0x560 kernel/rcu/srcutree.c:974
>  quarantine_remove_cache+0xd7/0xf0 mm/kasan/quarantine.c:327
>  kasan_cache_shutdown+0x9/0x10 mm/kasan/kasan.c:381
>  shutdown_cache+0x15/0x1b0 mm/slab_common.c:531
>  kmem_cache_destroy+0x236/0x250 mm/slab_common.c:829
>  tipc_server_stop+0x13f/0x190 net/tipc/server.c:636
>  tipc_topsrv_stop+0x1fe/0x350 net/tipc/subscr.c:390
>  tipc_exit_net+0x15/0x40 net/tipc/core.c:96
>  ops_exit_list.isra.6+0xae/0x150 net/core/net_namespace.c:142
>  cleanup_net+0x5c7/0xb60 net/core/net_namespace.c:483
>  process_one_work+0xbfd/0x1be0 kernel/workqueue.c:2098
>  worker_thread+0x223/0x1860 kernel/workqueue.c:2233
>  kthread+0x39c/0x470 kernel/kthread.c:231
>  ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
> QAT: Invalid ioctl
> QAT: Invalid ioctl
> QAT: Invalid ioctl
> QAT: Invalid ioctl
> TCP: request_sock_TCP: Possible SYN flooding on port 20012. Sending cookies.
> Check SNMP counters.
> sctp: [Deprecated]: syz-executor6 (pid 4597) Use of int in max_burst socket
> option deprecated.
> Use struct sctp_assoc_value instead
> audit: type=1326 audit(1503608734.272:8): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=4680 comm="syz-executor3"
> exe="/root/syz-executor3" sig=31 arch=c000003e syscall=202 compat=0
> ip=0x4512e9 code=0xffff0000
> audit: type=1326 audit(1503608734.367:9): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=4680 comm="syz-executor3"
> exe="/root/syz-executor3" sig=31 arch=c000003e syscall=202 compat=0
> ip=0x4512e9 code=0xffff0000
> sctp: [Deprecated]: syz-executor3 (pid 4928) Use of int in max_burst socket
> option.
> Use struct sctp_assoc_value instead
> sctp: [Deprecated]: syz-executor3 (pid 4928) Use of int in max_burst socket
> option.
> Use struct sctp_assoc_value instead
> TCP: request_sock_TCP: Possible SYN flooding on port 20020. Sending cookies.
> Check SNMP counters.
> mmap: syz-executor7 (5066): VmData 1892352 exceed data ulimit 1. Update
> limits or use boot option ignore_rlimit_data.
> nla_parse: 7 callbacks suppressed
> netlink: 5 bytes leftover after parsing attributes in process
> `syz-executor7'.
> IPv6: NLM_F_REPLACE set, but no existing node found!
> netlink: 5 bytes leftover after parsing attributes in process
> `syz-executor7'.
> ptm ptm1: ldisc open failed (-12), clearing slot 1
> IPv6: NLM_F_REPLACE set, but no existing node found!
> netlink: 3 bytes leftover after parsing attributes in process
> `syz-executor6'.
> netlink: 3 bytes leftover after parsing attributes in process
> `syz-executor6'.
> netlink: 3 bytes leftover after parsing attributes in process
> `syz-executor6'.
> device lo entered promiscuous mode
> netlink: 3 bytes leftover after parsing attributes in process
> `syz-executor6'.
> netlink: 3 bytes leftover after parsing attributes in process
> `syz-executor6'.
> netlink: 3 bytes leftover after parsing attributes in process
> `syz-executor6'.
> device lo entered promiscuous mode
> dccp_invalid_packet: invalid packet type
> dccp_invalid_packet: invalid packet type
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=65535
> sclass=netlink_route_socket pig=5222 comm=syz-executor3
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=65535
> sclass=netlink_route_socket pig=5222 comm=syz-executor3
> pit: kvm: requested 2514 ns i8254 timer period limited to 500000 ns
> pit: kvm: requested 2514 ns i8254 timer period limited to 500000 ns
> netlink: 8 bytes leftover after parsing attributes in process
> `syz-executor5'.
> netlink: 5 bytes leftover after parsing attributes in process
> `syz-executor5'.
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=3131
> sclass=netlink_xfrm_socket pig=5545 comm=syz-executor4
> SELinux: unrecognized netlink message: protocol=6 nlmsg_type=3131
> sclass=netlink_xfrm_socket pig=5545 comm=syz-executor4
> sctp: [Deprecated]: syz-executor3 (pid 5561) Use of struct sctp_assoc_value
> in delayed_ack socket option.
> Use struct sctp_sack_info instead
> sctp: [Deprecated]: syz-executor3 (pid 5561) Use of struct sctp_assoc_value
> in delayed_ack socket option.
> Use struct sctp_sack_info instead
> audit: type=1326 audit(1503608738.163:10): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=5622 comm="syz-executor5"
> exe="/root/syz-executor5" sig=31 arch=c000003e syscall=202 compat=0
> ip=0x4512e9 code=0xffff0000
> capability: warning: `syz-executor0' uses deprecated v2 capabilities in a
> way that may be insecure
> audit: type=1326 audit(1503608738.292:11): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=5622 comm="syz-executor5"
> exe="/root/syz-executor5" sig=31 arch=c000003e syscall=202 compat=0
> ip=0x4512e9 code=0xffff0000
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=1025
> sclass=netlink_route_socket pig=5659 comm=syz-executor1
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=1025
> sclass=netlink_route_socket pig=5684 comm=syz-executor1
> Assertion failed! net/irda/ircomm/ircomm_core.c:ircomm_flow_request:475 self
> != NULL
> QAT: Invalid ioctl
> QAT: Invalid ioctl
> audit: type=1326 audit(1503608739.537:12): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=5936 comm="syz-executor5"
> exe="/root/syz-executor5" sig=31 arch=c000003e syscall=202 compat=0
> ip=0x4512e9 code=0xffff0000
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=65535
> sclass=netlink_route_socket pig=5979 comm=syz-executor4
> tc_ctl_action: received NO action attribs
> SELinux: unrecognized netlink message: protocol=0 nlmsg_type=65535
> sclass=netlink_route_socket pig=5979 comm=syz-executor4
> sock: sock_set_timeout: `syz-executor2' (pid 5997) tries to set negative
> timeout
> sock: sock_set_timeout: `syz-executor2' (pid 5997) tries to set negative
> timeout
> tc_ctl_action: received NO action attribs
> sctp: [Deprecated]: syz-executor1 (pid 6154) Use of int in max_burst socket
> option deprecated.
> Use struct sctp_assoc_value instead
> sctp: [Deprecated]: syz-executor1 (pid 6156) Use of int in max_burst socket
> option deprecated.
> Use struct sctp_assoc_value instead
> QAT: Invalid ioctl
> SELinux:  unknown mount option
> SELinux:  unknown mount option
> QAT: Invalid ioctl
> audit: type=1326 audit(1503608741.554:13): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=6438 comm="syz-executor2"
> exe="/root/syz-executor2" sig=31 arch=c000003e syscall=202 compat=0
> ip=0x4512e9 code=0xffff0000
> audit: type=1326 audit(1503608741.579:14): auid=4294967295 uid=0 gid=0
> ses=4294967295 subj=kernel pid=6438 comm="syz-executor2"
> exe="/root/syz-executor2" sig=31 arch=c000003e syscall=202 compat=0
> ip=0x4512e9 code=0xffff0000
> PF_BRIDGE: RTM_NEWNEIGH with unknown ifindex
> *** Guest State ***
> CR0: actual=0x0000000080000031, shadow=0x0000000060000011,
> gh_mask=fffffffffffffff7
> CR4: actual=0x0000000000006154, shadow=0x0000000000004164,
> gh_mask=fffffffffffff871
> CR3 = 0x00000000fffbc000
> RSP = 0x0000000000000f80  RIP = 0x0000000000000000
> RFLAGS=0x00000002         DR7 = 0x0000000000000400
> Sysenter RSP=0000000000000f80 CS:RIP=0050:0000000000002810
> CS:   sel=0x0000, attr=0x0409b, limit=0x000fffff, base=0x0000000000000000
> DS:   sel=0x0038, attr=0x04093, limit=0x000fffff, base=0x0000000000000000
> SS:   sel=0x0038, attr=0x04093, limit=0x000fffff, base=0x0000000000000000
> ES:   sel=0x0038, attr=0x04093, limit=0x000fffff, base=0x0000000000000000
> FS:   sel=0x0038, attr=0x04093, limit=0x000fffff, base=0x0000000000000000
> GS:   sel=0x0038, attr=0x04093, limit=0x000fffff, base=0x0000000000000000
> GDTR:                           limit=0x000007ff, base=0x0000000000001000
> LDTR: sel=0x0008, attr=0x04082, limit=0x000007ff, base=0x0000000000001800
> IDTR:                           limit=0x000001ff, base=0x0000000000003800
> TR:   sel=0x0000, attr=0x0008b, limit=0x0000ffff, base=0x0000000000000000
> EFER =     0x0000000000000001  PAT = 0x0007040600070406
> DebugCtl = 0x0000000000000000  DebugExceptions = 0x0000000000000000
> Interruptibility = 00000000  ActivityState = 00000000
> *** Host State ***
> RIP = 0xffffffff811b6277  RSP = 0xffff8801c8a074c8
> CS=0010 SS=0018 DS=0000 ES=0000 FS=0000 GS=0000 TR=0040
> FSBase=00007f51db980700 GSBase=ffff8801db200000 TRBase=ffff8801db223100
> GDTBase=ffffffffff577000 IDTBase=ffffffffff57b000
> CR0=0000000080050033 CR3=00000001cf27f000 CR4=00000000001426f0
> Sysenter RSP=0000000000000000 CS:RIP=0010:ffffffff84d9d0a0
> EFER = 0x0000000000000d01  PAT = 0x0000000000000000
> *** Control State ***
> PinBased=0000003f CPUBased=b699edfa SecondaryExec=0000004a
> EntryControls=0000d1ff ExitControls=0023efff
> ExceptionBitmap=00060042 PFECmask=00000000 PFECmatch=00000000
> VMEntry: intr_info=00000000 errcode=00000000 ilen=00000000
> VMExit: intr_info=00000000 errcode=00000000 ilen=00000000
>         reason=80000021 qualification=0000000000000000
> IDTVectoring: info=00000000 errcode=00000000
> TSC Offset = 0xffffffd760e51039
> EPT pointer = 0x00000001d8af001e
> PF_BRIDGE: RTM_NEWNEIGH with unknown ifindex
> nla_parse: 28 callbacks suppressed
> netlink: 5 bytes leftover after parsing attributes in process
> `syz-executor2'.
> netlink: 5 bytes leftover after parsing attributes in process
> `syz-executor2'.
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
> Note: all commands must start from beginning of the line.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/001a114a6b20cafb9c055cd73f86%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
