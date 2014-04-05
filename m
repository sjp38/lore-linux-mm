Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7B86B0031
	for <linux-mm@kvack.org>; Sat,  5 Apr 2014 11:21:01 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so4802768pbb.28
        for <linux-mm@kvack.org>; Sat, 05 Apr 2014 08:21:01 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b5si5981416pbq.276.2014.04.05.08.21.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 05 Apr 2014 08:21:00 -0700 (PDT)
Message-ID: <53401F56.5090507@oracle.com>
Date: Sat, 05 Apr 2014 11:20:54 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: slub: gpf in deactivate_slab
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com> <20140325165247.GA7519@dhcp22.suse.cz> <alpine.DEB.2.10.1403251205140.24534@nuc> <5331B9C8.7080106@oracle.com> <alpine.DEB.2.10.1403251308590.26471@nuc> <53321CB6.5050706@oracle.com> <alpine.DEB.2.10.1403261042360.2057@nuc>
In-Reply-To: <alpine.DEB.2.10.1403261042360.2057@nuc>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/26/2014 11:43 AM, Christoph Lameter wrote:
> On Tue, 25 Mar 2014, Sasha Levin wrote:
> 
>> I'm not sure if there's anything special about this cache, codewise it's
>> created as follows:
>>
>>
>>         inode_cachep = kmem_cache_create("inode_cache",
>>                                          sizeof(struct inode),
>>                                          0,
>>                                          (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
>>                                          SLAB_MEM_SPREAD),
>>                                          init_once);
>>
>>
>> I'd be happy to dig up any other info required, I'm just not too sure
>> what you mean by options for the cache?
> 
> Slab parameters can be change in /sys/kernel/slab/inode. Any debug
> parameters active? More information about what was actually going on when
> the gpf occured?

Unfortunately I've been unable to reproduce the issue to get more debug info
out of it. However, I've hit something that seems to be somewhat similar
to that:

[ 1035.176692] BUG: unable to handle kernel paging request at ffff8801377e4000
[ 1035.177893] IP: memset (arch/x86/lib/memset_64.S:105)
[ 1035.178651] PGD 3d91c067 PUD 102f7ff067 PMD 102f643067 PTE 80000001377e4060
[ 1035.179740] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1035.180063] Dumping ftrace buffer:
[ 1035.180063]    (ftrace buffer empty)
[ 1035.180063] Modules linked in:
[ 1035.180063] CPU: 2 PID: 27857 Comm: modprobe Not tainted 3.14.0-next-20140403-sasha-00019-g7474aa9-dirty #376
[ 1035.180063] task: ffff8800a1918000 ti: ffff8800a4650000 task.ti: ffff8800a4650000
[ 1035.180063] RIP: memset (arch/x86/lib/memset_64.S:105)
[ 1035.180063] RSP: 0018:ffff8800a4651b60  EFLAGS: 00010046
[ 1035.180063] RAX: bbbbbbbbbbbbbbbb RBX: ffff88007d852ec0 RCX: 0000000000000000
[ 1035.180063] RDX: 0000000000000008 RSI: 00000000000000bb RDI: ffff8801377e4000
[ 1035.180063] RBP: ffff8800a4651b88 R08: 0000000000000001 R09: 0000000000000000
[ 1035.180063] R10: ffff8801377e4000 R11: ffffffffffffffce R12: ffff8801377e3000
[ 1035.180063] R13: 00000000000000bb R14: ffff8801377e3000 R15: ffffffffffffffff
[ 1035.180063] FS:  00007f2e098d6700(0000) GS:ffff8801abc00000(0000) knlGS:0000000000000000
[ 1035.180063] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1035.180063] CR2: ffff8801377e4000 CR3: 000000061feec000 CR4: 00000000000006a0
[ 1035.193166] DR0: 0000000000696000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1035.193166] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 1035.193166] Stack:
[ 1035.193166]  ffffffffb62dabee ffff8800a4651b78 ffff88007d852ec0 ffff8801377e3000
[ 1035.193166]  ffffea0004ddf8c0 ffff8800a4651ba8 ffffffffb62db1c0 ffff88007d852ec0
[ 1035.193166]  ffff8801377e3000 ffff8800a4651be8 ffffffffb62dd1a6 ffff8800a4651bd8
[ 1035.193166] Call Trace:
[ 1035.193166] ? init_object (mm/slub.c:679)
[ 1035.193166] setup_object.isra.34 (mm/slub.c:1071 mm/slub.c:1399)
[ 1035.193166] new_slab (mm/slub.c:286 mm/slub.c:1439)
[ 1035.193166] __slab_alloc (mm/slub.c:2203 mm/slub.c:2363)
[ 1035.193166] ? kmem_cache_alloc (mm/slub.c:2469 mm/slub.c:2480 mm/slub.c:2485)
[ 1035.193166] ? getname_flags (fs/namei.c:145)
[ 1035.193166] ? get_parent_ip (kernel/sched/core.c:2472)
[ 1035.193166] kmem_cache_alloc (mm/slub.c:2469 mm/slub.c:2480 mm/slub.c:2485)
[ 1035.193166] ? getname_flags (fs/namei.c:145)
[ 1035.193166] getname_flags (fs/namei.c:145)
[ 1035.193166] user_path_at_empty (fs/namei.c:2121)
[ 1035.193166] ? kvm_clock_read (arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[ 1035.193166] ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[ 1035.193166] ? sched_clock_local (kernel/sched/clock.c:214)
[ 1035.193166] ? vtime_account_user (kernel/sched/cputime.c:687)
[ 1035.193166] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[ 1035.193166] ? put_lock_stats.isra.12 (arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[ 1035.193166] user_path_at (fs/namei.c:2137)
[ 1035.193166] vfs_fstatat (fs/stat.c:107)
[ 1035.193166] ? context_tracking_user_exit (arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:182 (discriminator 2))
[ 1035.193166] vfs_stat (fs/stat.c:124)
[ 1035.193166] SYSC_newstat (fs/stat.c:272)
[ 1035.193166] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[ 1035.193166] ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
[ 1035.193166] ? tracesys (arch/x86/kernel/entry_64.S:738)
[ 1035.193166] SyS_newstat (fs/stat.c:267)
[ 1035.193166] tracesys (arch/x86/kernel/entry_64.S:749)
[ 1035.193166] Code: 89 47 28 48 89 47 30 48 89 47 38 48 8d 7f 40 75 d8 0f 1f 84 00 00 00 00 00 89 d1 83 e1 38 74 14 c1 e9 03 66 0f 1f 44 00 00 ff c9 <48> 89 07 48 8d 7f 08 75 f5 83 e2 07 74 0a ff ca 88 07 48 8d 7f
[ 1035.193166] RIP memset (arch/x86/lib/memset_64.S:105)
[ 1035.193166]  RSP <ffff8800a4651b60>
[ 1035.193166] CR2: ffff8801377e4000


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
