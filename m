Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 869238E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 21:46:09 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w24so3849556otk.22
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 18:46:09 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s5si27539609oif.185.2019.01.09.18.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 18:46:06 -0800 (PST)
Message-Id: <201901100245.x0A2jaTw040087@www262.sakura.ne.jp>
Subject: Re: WARNING: locking bug in =?ISO-2022-JP?B?bG9ja19kb3duZ3JhZGU=?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 10 Jan 2019 11:45:36 +0900
References: <d61e0a3e-a71e-9e42-7a56-d6fcfc0f6b63@I-love.SAKURA.ne.jp> <864e2d6b-f471-cc04-311f-473da43b409a@redhat.com>
In-Reply-To: <864e2d6b-f471-cc04-311f-473da43b409a@redhat.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, peterz@infradead.org, "mingo@redhat.com" <mingo@redhat.com>, Yang Shi <yang.shi@linux.alibaba.com>, syzbot <syzbot+53383ae265fb161ef488@syzkaller.appspotmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, boqun.feng@gmail.com

OK. I noticed that when downgrade_write() warning is printed, there is always
another lockdep warning in progress at the same moment. And I confirmed that
downgrade_write() is confused by __debug_locks_off() called by concurrently
triggered lockdep warning. In other words, since another lockdep warning calls
__debug_locks_off(), downgrade_write() is making decisions based on "no longer
maintained dependency".

----------------------------------------
#include <linux/module.h>
#include <linux/sched.h>
#include <linux/rwsem.h>

static int __init test_init(void)
{
        struct rw_semaphore *sem = &current->mm->mmap_sem;
        static DECLARE_RWSEM(test_lock);

        down_read(sem);
        down_read(&test_lock);
        down_read(&test_lock);
        up_read(&test_lock);
        up_read(&test_lock);
        up_read(sem);
        return -EINVAL;
}

module_init(test_init);
MODULE_LICENSE("GPL");
----------------------------------------

----------------------------------------
[   40.822909][ T9174] test: loading out-of-tree module taints kernel.
[   40.827870][ T9174] 
[   40.828504][ T9174] ============================================
[   40.830253][ T9174] WARNING: possible recursive locking detected
[   40.831922][ T9174] 5.0.0-rc1-next-20190109 #269 Tainted: G           O     
[   40.833832][ T9174] --------------------------------------------
[   40.835461][ T9174] insmod/9174 is trying to acquire lock:
[   40.836871][ T9174] 000000007dbea5ef (test_lock){.+.+}, at: test_init+0x3c/0x1000 [test]
[   40.838936][ T9174] 
[   40.838936][ T9174] but task is already holding lock:
[   40.840827][ T9174] 000000007dbea5ef (test_lock){.+.+}, at: test_init+0x30/0x1000 [test]
[   40.842962][ T9174] 
[   40.842962][ T9174] other info that might help us debug this:
[   40.844979][ T9174]  Possible unsafe locking scenario:
[   40.844979][ T9174] 
[   40.847031][ T9174]        CPU0
[   40.847923][ T9174]        ----
[   40.848741][ T9174]   lock(test_lock);
[   40.849786][ T9174]   lock(test_lock);
[   40.850860][ T9174] 
[   40.850860][ T9174]  *** DEADLOCK ***
[   40.850860][ T9174] 
[   40.852892][ T9174]  May be due to missing lock nesting notation
[   40.852892][ T9174] 
[   40.855000][ T9174] 2 locks held by insmod/9174:
[   40.856187][ T9174]  #0: 000000008f7a8ad1 (&mm->mmap_sem){++++}, at: test_init+0x24/0x1000 [test]
[   40.858441][ T9174]  #1: 000000007dbea5ef (test_lock){.+.+}, at: test_init+0x30/0x1000 [test]
[   40.860784][ T9174] 
[   40.860784][ T9174] stack backtrace:
[   40.862253][ T9174] CPU: 1 PID: 9174 Comm: insmod Kdump: loaded Tainted: G           O      5.0.0-rc1-next-20190109 #269
[   40.865225][ T9174] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[   40.868304][ T9174] Call Trace:
[   40.869127][ T9174]  dump_stack+0x67/0x95
[   40.870274][ T9174]  __lock_acquire+0x1073/0x1260
[   40.871555][ T9174]  lock_acquire+0xd3/0x210
[   40.872657][ T9174]  ? test_init+0x3c/0x1000 [test]
[   40.873912][ T9174]  down_read+0x47/0xa0
[   40.874927][ T9174]  ? test_init+0x3c/0x1000 [test]
[   40.876222][ T9174]  test_init+0x3c/0x1000 [test]
[   40.877432][ T9174]  ? 0xffffffffc03ff000
[   40.878854][ T9174]  do_one_initcall+0x72/0x395
[   40.880625][ T9174]  ? rcu_read_lock_sched_held+0x8c/0xa0
[   40.882965][ T9174]  ? kmem_cache_alloc_trace+0x2b5/0x360
[   40.884734][ T9174]  do_init_module+0x5b/0x1ef
[   40.886265][ T9174]  load_module+0x17ed/0x1d10
[   40.887800][ T9174]  ? __symbol_put+0x90/0x90
[   40.889315][ T9174]  ? kernel_read+0x2c/0x40
[   40.890976][ T9174]  __do_sys_finit_module+0xa9/0x100
[   40.892648][ T9174]  __x64_sys_finit_module+0x15/0x20
[   40.894315][ T9174]  do_syscall_64+0x4a/0x180
[   40.895848][ T9174]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   40.897756][ T9174] RIP: 0033:0x7f2ccd0c11c9
[   40.899229][ T9174] Code: 01 00 48 81 c4 80 00 00 00 e9 f1 fe ff ff 0f 1f 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 97 dc 2c 00 f7 d8 64 89 01 48
[   40.906285][ T9174] RSP: 002b:00007fff3f992348 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[   40.909468][ T9174] RAX: ffffffffffffffda RBX: 0000000000bcb1f0 RCX: 00007f2ccd0c11c9
[   40.912444][ T9174] RDX: 0000000000000000 RSI: 000000000041a94e RDI: 0000000000000003
[   40.915459][ T9174] RBP: 000000000041a94e R08: 0000000000000000 R09: 00007fff3f9924e8
[   40.917978][ T9174] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[   40.920434][ T9174] R13: 0000000000bca130 R14: 0000000000000000 R15: 0000000000000000
[   41.305025][ T9174] mmap_sem: hlock->read=1 count=-4294967295 current=ffffa3f06d423840, owner=ffffa3f06d423840
[   41.308093][ T9174] ------------[ cut here ]------------
[   41.309878][ T9174] downgrading a read lock
[   41.309884][ T9174] WARNING: CPU: 1 PID: 9174 at kernel/locking/lockdep.c:3572 lock_downgrade+0xe5/0x240
[   41.314382][ T9174] Modules linked in: vmw_balloon pcspkr sg vmw_vmci i2c_piix4 ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_nat_ipv4 nf_nat nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables xfs libcrc32c sd_mod sr_mod cdrom serio_raw ata_generic pata_acpi vmwgfx drm_kms_helper ahci syscopyarea libahci sysfillrect sysimgblt e1000 fb_sys_fops mptspi ttm scsi_transport_spi mptscsih drm mptbase i2c_core ata_piix libata
[   41.332426][ T9174] CPU: 1 PID: 9174 Comm: insmod Kdump: loaded Tainted: G           O      5.0.0-rc1-next-20190109 #269
[   41.335600][ T9174] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[   41.338867][ T9174] RIP: 0010:lock_downgrade+0xe5/0x240
[   41.340989][ T9174] Code: 48 85 c0 74 13 49 8d 56 90 48 05 b8 00 00 00 48 39 c2 0f 84 35 01 00 00 48 c7 c7 36 70 df 9e 31 c0 4c 89 4d c0 e8 cb c7 f9 ff <0f> 0b 8b 55 cc 4c 8b 4d c0 41 0f b6 41 32 4d 89 79 08 44 89 e6 48
[   41.346977][ T9174] RSP: 0018:ffffbbbf007d7e00 EFLAGS: 00010086
[   41.349340][ T9174] RAX: 0000000000000000 RBX: ffffa3f06d423840 RCX: ffffffffa0049040
[   41.351999][ T9174] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffffffff9e0ddd22
[   41.354449][ T9174] RBP: ffffbbbf007d7e40 R08: 0000000000000000 R09: 6572206120676e69
[   41.357085][ T9174] R10: 72206120676e6964 R11: 0000000000000001 R12: 0000000000000002
[   41.359517][ T9174] R13: 0000000000000246 R14: ffffa3f0737f0968 R15: ffffffff9e1e9008
[   41.362154][ T9174] FS:  00007f2ccdbee740(0000) GS:ffffa3f07a600000(0000) knlGS:0000000000000000
[   41.365009][ T9174] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   41.367247][ T9174] CR2: 00007f2ccd122250 CR3: 0000000131f6e004 CR4: 00000000003606e0
[   41.369726][ T9174] Call Trace:
[   41.371284][ T9174]  downgrade_write+0x15/0x90
[   41.372939][ T9174]  __do_munmap+0x378/0x3c0
[   41.374557][ T9174]  __vm_munmap+0x76/0xd0
[   41.376401][ T9174]  __x64_sys_munmap+0x27/0x30
[   41.378079][ T9174]  do_syscall_64+0x4a/0x180
[   41.379711][ T9174]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   41.381940][ T9174] RIP: 0033:0x7f2ccd0c13f7
[   41.383564][ T9174] Code: 64 89 02 48 83 c8 ff eb 9c 48 8b 15 93 da 2c 00 f7 d8 64 89 02 e9 6a ff ff ff 66 0f 1f 84 00 00 00 00 00 b8 0b 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 69 da 2c 00 f7 d8 64 89 01 48
[   41.389435][ T9174] RSP: 002b:00007fff3f992378 EFLAGS: 00000206 ORIG_RAX: 000000000000000b
[   41.392384][ T9174] RAX: ffffffffffffffda RBX: 0000000000bcb300 RCX: 00007f2ccd0c13f7
[   41.394929][ T9174] RDX: 0000000000000000 RSI: 00000000000011c8 RDI: 00007f2ccdc06000
[   41.397432][ T9174] RBP: 0000000000000000 R08: 000000000040acd0 R09: 0000000000000000
[   41.400105][ T9174] R10: 00007fff3f991da0 R11: 0000000000000206 R12: 0000000000bca010
[   41.402693][ T9174] R13: 00007fff3f9924e0 R14: 0000000000000000 R15: 0000000000000000
[   41.405218][ T9174] irq event stamp: 4607
[   41.409414][ T9174] hardirqs last  enabled at (4607): [<ffffffff9e20ec47>] __slab_alloc.isra.84.constprop.90+0x5e/0x77
[   41.412696][ T9174] hardirqs last disabled at (4606): [<ffffffff9e20ec08>] __slab_alloc.isra.84.constprop.90+0x1f/0x77
[   41.416069][ T9174] softirqs last  enabled at (4528): [<ffffffff9e5fee8f>] peernet2id+0x4f/0x80
[   41.418737][ T9174] softirqs last disabled at (4526): [<ffffffff9e5fee71>] peernet2id+0x31/0x80
[   41.421542][ T9174] ---[ end trace 6db2652247cd6a11 ]---
----------------------------------------

If I do

 static inline int __debug_locks_off(void)
 {
-	return xchg(&debug_locks, 0);
+	return 1;
 }

then downgrade_write() warning is no longer printed by the reproducer (though
other lockdep warnings are printed because dependency is no longer correct).

----------------------------------------
[   34.554580][ T9173] test: loading out-of-tree module taints kernel.
[   34.559029][ T9173] 
[   34.559656][ T9173] ============================================
[   34.561416][ T9173] WARNING: possible recursive locking detected
[   34.563008][ T9173] 5.0.0-rc1-next-20190109+ #270 Tainted: G           O     
[   34.565045][ T9173] --------------------------------------------
[   34.566619][ T9173] insmod/9173 is trying to acquire lock:
[   34.568127][ T9173] 00000000cf012899 (test_lock){.+.+}, at: test_init+0x3c/0x1000 [test]
[   34.570594][ T9173] 
[   34.570594][ T9173] but task is already holding lock:
[   34.573474][ T9173] 00000000cf012899 (test_lock){.+.+}, at: test_init+0x30/0x1000 [test]
[   34.575650][ T9173] 
[   34.575650][ T9173] other info that might help us debug this:
[   34.577843][ T9173]  Possible unsafe locking scenario:
[   34.577843][ T9173] 
[   34.579813][ T9173]        CPU0
[   34.580707][ T9173]        ----
[   34.581576][ T9173]   lock(test_lock);
[   34.582604][ T9173]   lock(test_lock);
[   34.583630][ T9173] 
[   34.583630][ T9173]  *** DEADLOCK ***
[   34.583630][ T9173] 
[   34.585840][ T9173]  May be due to missing lock nesting notation
[   34.585840][ T9173] 
[   34.588127][ T9173] 2 locks held by insmod/9173:
[   34.589406][ T9173]  #0: 00000000d68054a9 (&mm->mmap_sem){++++}, at: test_init+0x24/0x1000 [test]
[   34.591822][ T9173]  #1: 00000000cf012899 (test_lock){.+.+}, at: test_init+0x30/0x1000 [test]
[   34.594205][ T9173] 
[   34.594205][ T9173] stack backtrace:
[   34.595789][ T9173] CPU: 1 PID: 9173 Comm: insmod Kdump: loaded Tainted: G           O      5.0.0-rc1-next-20190109+ #270
[   34.598773][ T9173] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[   34.602109][ T9173] Call Trace:
[   34.603046][ T9173]  dump_stack+0x67/0x95
[   34.604783][ T9173]  __lock_acquire+0x1073/0x1260
[   34.606529][ T9173]  lock_acquire+0xd3/0x210
[   34.608203][ T9173]  ? test_init+0x3c/0x1000 [test]
[   34.609972][ T9173]  down_read+0x47/0xa0
[   34.611451][ T9173]  ? test_init+0x3c/0x1000 [test]
[   34.613228][ T9173]  test_init+0x3c/0x1000 [test]
[   34.614849][ T9173]  ? 0xffffffffc01d0000
[   34.616458][ T9173]  do_one_initcall+0x72/0x395
[   34.618000][ T9173]  ? rcu_read_lock_sched_held+0x8c/0xa0
[   34.619922][ T9173]  ? kmem_cache_alloc_trace+0x2b5/0x360
[   34.621843][ T9173]  do_init_module+0x5b/0x1ef
[   34.623527][ T9173]  load_module+0x17ed/0x1d10
[   34.625295][ T9173]  ? __symbol_put+0x90/0x90
[   34.627035][ T9173]  ? kernel_read+0x2c/0x40
[   34.628717][ T9173]  __do_sys_finit_module+0xa9/0x100
[   34.630384][ T9173]  __x64_sys_finit_module+0x15/0x20
[   34.632125][ T9173]  do_syscall_64+0x4a/0x180
[   34.633612][ T9173]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   34.635548][ T9173] RIP: 0033:0x7f5b50e1f1c9
[   34.637082][ T9173] Code: 01 00 48 81 c4 80 00 00 00 e9 f1 fe ff ff 0f 1f 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 97 dc 2c 00 f7 d8 64 89 01 48
[   34.643337][ T9173] RSP: 002b:00007ffcee219f68 EFLAGS: 00000202 ORIG_RAX: 0000000000000139
[   34.645825][ T9173] RAX: ffffffffffffffda RBX: 00000000011631f0 RCX: 00007f5b50e1f1c9
[   34.648340][ T9173] RDX: 0000000000000000 RSI: 000000000041a94e RDI: 0000000000000003
[   34.650841][ T9173] RBP: 000000000041a94e R08: 0000000000000000 R09: 00007ffcee21a108
[   34.653287][ T9173] R10: 0000000000000003 R11: 0000000000000202 R12: 0000000000000000
[   34.655978][ T9173] R13: 0000000001162130 R14: 0000000000000000 R15: 0000000000000000
[   34.659756][ T9173] 
[   34.661520][ T9173] =====================================
[   34.663790][ T9173] WARNING: bad unlock balance detected!
[   34.665636][ T9173] 5.0.0-rc1-next-20190109+ #270 Tainted: G           O     
[   34.667902][ T9173] -------------------------------------
[   34.669595][ T9173] insmod/9173 is trying to release lock (test_lock) at:
[   34.672164][ T9173] [<ffffffffc01d0054>] test_init+0x54/0x1000 [test]
[   34.674384][ T9173] but there are no more locks to release!
[   34.676195][ T9173] 
[   34.676195][ T9173] other info that might help us debug this:
[   34.679053][ T9173] 1 lock held by insmod/9173:
[   34.680569][ T9173]  #0: 00000000d68054a9 (&mm->mmap_sem){++++}, at: test_init+0x24/0x1000 [test]
[   34.683362][ T9173] 
[   34.683362][ T9173] stack backtrace:
[   34.685567][ T9173] CPU: 1 PID: 9173 Comm: insmod Kdump: loaded Tainted: G           O      5.0.0-rc1-next-20190109+ #270
[   34.689164][ T9173] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
[   34.692636][ T9173] Call Trace:
[   34.694044][ T9173]  dump_stack+0x67/0x95
[   34.695444][ T9173]  ? test_init+0x54/0x1000 [test]
[   34.697031][ T9173]  print_unlock_imbalance_bug+0xec/0x100
[   34.698899][ T9173]  ? test_init+0x54/0x1000 [test]
[   34.700489][ T9173]  lock_release+0x230/0x4c0
[   34.702119][ T9173]  up_read+0x1a/0xa0
[   34.703521][ T9173]  test_init+0x54/0x1000 [test]
[   34.705069][ T9173]  ? 0xffffffffc01d0000
[   34.706727][ T9173]  do_one_initcall+0x72/0x395
[   34.708233][ T9173]  ? rcu_read_lock_sched_held+0x8c/0xa0
[   34.710167][ T9173]  ? kmem_cache_alloc_trace+0x2b5/0x360
[   34.711885][ T9173]  do_init_module+0x5b/0x1ef
[   34.713538][ T9173]  load_module+0x17ed/0x1d10
[   34.715027][ T9173]  ? __symbol_put+0x90/0x90
[   34.716494][ T9173]  ? kernel_read+0x2c/0x40
[   34.718226][ T9173]  __do_sys_finit_module+0xa9/0x100
[   34.719924][ T9173]  __x64_sys_finit_module+0x15/0x20
[   34.721734][ T9173]  do_syscall_64+0x4a/0x180
[   34.723199][ T9173]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   34.725136][ T9173] RIP: 0033:0x7f5b50e1f1c9
[   34.726770][ T9173] Code: 01 00 48 81 c4 80 00 00 00 e9 f1 fe ff ff 0f 1f 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 97 dc 2c 00 f7 d8 64 89 01 48
[   34.732837][ T9173] RSP: 002b:00007ffcee219f68 EFLAGS: 00000202 ORIG_RAX: 0000000000000139
[   34.738479][ T9173] RAX: ffffffffffffffda RBX: 00000000011631f0 RCX: 00007f5b50e1f1c9
[   34.741078][ T9173] RDX: 0000000000000000 RSI: 000000000041a94e RDI: 0000000000000003
[   34.743495][ T9173] RBP: 000000000041a94e R08: 0000000000000000 R09: 00007ffcee21a108
[   34.746043][ T9173] R10: 0000000000000003 R11: 0000000000000202 R12: 0000000000000000
[   34.748450][ T9173] R13: 0000000001162130 R14: 0000000000000000 R15: 0000000000000000
----------------------------------------
