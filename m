Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2757F6B0254
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 09:17:09 -0400 (EDT)
Received: by lahh5 with SMTP id h5so5866189lah.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 06:17:08 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [95.108.253.251])
        by mx.google.com with ESMTPS id p5si904427lap.109.2015.07.14.06.17.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 06:17:06 -0700 (PDT)
Subject: [PATCH 1/2] mm/slub: fix slab double-free in case of duplicate
 sysfs filename
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 14 Jul 2015 16:17:04 +0300
Message-ID: <20150714131704.21442.17939.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

sysfs_slab_add() shouldn't call kobject_put at error path: this puts
last reference of kmem-cache kobject and frees it. Kmem cache will be
freed second time at error path in kmem_cache_create().

For example this happens when slub debug was enabled in runtime and
somebody creates new kmem cache:

# echo 1 | tee /sys/kernel/slab/*/sanity_checks
# modprobe configfs

"configfs_dir_cache" cannot be merged because existing slab have debug and
cannot create new slab because unique name ":t-0000096" already taken.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

---

[   56.648477] ------------[ cut here ]------------
[   56.648503] WARNING: CPU: 2 PID: 3087 at fs/sysfs/dir.c:31 sysfs_warn_dup+0x6a/0x80()
[   56.648504] sysfs: cannot create duplicate filename '/kernel/slab/:t-0000096'
[   56.648505] Modules linked in: configfs(+)
[   56.648514] CPU: 2 PID: 3087 Comm: modprobe Not tainted 4.2.0-rc2+ #109
[   56.648516] Hardware name: OpenStack Foundation OpenStack Nova, BIOS Bochs 01/01/2011
[   56.648517]  000000000000001f ffff88023184f998 ffffffff819d5bb0 0000000000000007
[   56.648520]  ffff88023184f9e8 ffff88023184f9d8 ffffffff8105d0e2 ffff8802348ca000
[   56.648523]  ffff8802348ca000 ffff8802348b0420 ffff880234c98558 0000000000000000
[   56.648526] Call Trace:
[   56.648555]  [<ffffffff819d5bb0>] dump_stack+0x4c/0x65
[   56.648565]  [<ffffffff8105d0e2>] warn_slowpath_common+0x92/0xd0
[   56.648567]  [<ffffffff8105d1c1>] warn_slowpath_fmt+0x41/0x50
[   56.648572]  [<ffffffff8123f5d0>] ? kernfs_path+0x50/0x70
[   56.648574]  [<ffffffff81242a5a>] sysfs_warn_dup+0x6a/0x80
[   56.648576]  [<ffffffff81242b37>] sysfs_create_dir_ns+0x77/0x80
[   56.648589]  [<ffffffff813aa021>] kobject_add_internal+0xa1/0x2d0
[   56.648591]  [<ffffffff813aa3a3>] kobject_init_and_add+0x63/0x90
[   56.648613]  [<ffffffff811a7a46>] sysfs_slab_add+0x76/0x1a0
[   56.648617]  [<ffffffff811a8fdb>] __kmem_cache_create+0x3eb/0x5a0
[   56.648620]  [<ffffffff811a71ab>] ? kmem_cache_alloc+0x1db/0x2e0
[   56.648624]  [<ffffffff811761c0>] kmem_cache_create+0x1e0/0x380
[   56.648626]  [<ffffffff811a778c>] ? kfree+0xec/0x330
[   56.648629]  [<ffffffffa0008023>] configfs_init+0x23/0x98 [configfs]
[   56.648631]  [<ffffffffa0008000>] ? 0xffffffffa0008000
[   56.648638]  [<ffffffff810002d1>] do_one_initcall+0x81/0x1b0
[   56.648641]  [<ffffffff811a6b26>] ? kmem_cache_alloc_trace+0x1d6/0x2e0
[   56.648648]  [<ffffffff810edaff>] do_init_module+0x5f/0x210
[   56.648650]  [<ffffffff810ef8af>] load_module+0x116f/0x17a0
[   56.648653]  [<ffffffff810eb930>] ? show_initstate+0x50/0x50
[   56.648655]  [<ffffffff810f0005>] SyS_init_module+0x125/0x150
[   56.648661]  [<ffffffff819e29ae>] entry_SYSCALL_64_fastpath+0x12/0x76
[   56.648662] ---[ end trace ceccd457b71b3f60 ]---
[   56.648667] ------------[ cut here ]------------
[   56.648670] WARNING: CPU: 2 PID: 3087 at lib/kobject.c:240 kobject_add_internal+0x25c/0x2d0()
[   56.648671] kobject_add_internal failed for :t-0000096 with -EEXIST, don't try to register things with the same name in the same directory.
[   56.648672] Modules linked in: configfs(+)
[   56.648674] CPU: 2 PID: 3087 Comm: modprobe Tainted: G        W       4.2.0-rc2+ #109
[   56.648675] Hardware name: OpenStack Foundation OpenStack Nova, BIOS Bochs 01/01/2011
[   56.648676]  00000000000000f0 ffff88023184f9f8 ffffffff819d5bb0 0000000000000007
[   56.648679]  ffff88023184fa48 ffff88023184fa38 ffffffff8105d0e2 0000000235c40aa8
[   56.648681]  00000000ffffffef ffff880234d8da78 0000000000000000 0000000000000000
[   56.648684] Call Trace:
[   56.648688]  [<ffffffff819d5bb0>] dump_stack+0x4c/0x65
[   56.648690]  [<ffffffff8105d0e2>] warn_slowpath_common+0x92/0xd0
[   56.648692]  [<ffffffff8105d1c1>] warn_slowpath_fmt+0x41/0x50
[   56.648694]  [<ffffffff813aa1dc>] kobject_add_internal+0x25c/0x2d0
[   56.648696]  [<ffffffff813aa3a3>] kobject_init_and_add+0x63/0x90
[   56.648698]  [<ffffffff811a7a46>] sysfs_slab_add+0x76/0x1a0
[   56.648700]  [<ffffffff811a8fdb>] __kmem_cache_create+0x3eb/0x5a0
[   56.648702]  [<ffffffff811a71ab>] ? kmem_cache_alloc+0x1db/0x2e0
[   56.648704]  [<ffffffff811761c0>] kmem_cache_create+0x1e0/0x380
[   56.648706]  [<ffffffff811a778c>] ? kfree+0xec/0x330
[   56.648709]  [<ffffffffa0008023>] configfs_init+0x23/0x98 [configfs]
[   56.648710]  [<ffffffffa0008000>] ? 0xffffffffa0008000
[   56.648712]  [<ffffffff810002d1>] do_one_initcall+0x81/0x1b0
[   56.648715]  [<ffffffff811a6b26>] ? kmem_cache_alloc_trace+0x1d6/0x2e0
[   56.648716]  [<ffffffff810edaff>] do_init_module+0x5f/0x210
[   56.648718]  [<ffffffff810ef8af>] load_module+0x116f/0x17a0
[   56.648720]  [<ffffffff810eb930>] ? show_initstate+0x50/0x50
[   56.648723]  [<ffffffff810f0005>] SyS_init_module+0x125/0x150
[   56.648725]  [<ffffffff819e29ae>] entry_SYSCALL_64_fastpath+0x12/0x76
[   56.648726] ---[ end trace ceccd457b71b3f61 ]---
[   56.648745] general protection fault: 0000 [#1] SMP
[   56.649035] Modules linked in: configfs(+)
[   56.649035] CPU: 2 PID: 3087 Comm: modprobe Tainted: G        W       4.2.0-rc2+ #109
[   56.649035] Hardware name: OpenStack Foundation OpenStack Nova, BIOS Bochs 01/01/2011
[   56.649035] task: ffff880235d70000 ti: ffff88023184c000 task.ti: ffff88023184c000
[   56.649035] RIP: 0010:[<ffffffff811a2907>]  [<ffffffff811a2907>] has_cpu_slab+0x17/0x30
[   56.649035] RSP: 0018:ffff88023184fb48  EFLAGS: 00010287
[   56.649035] RAX: 0000000000000001 RBX: ffff880234d8da00 RCX: 0000000000000000
[   56.649035] RDX: ffff10047498db00 RSI: ffff880234d8da00 RDI: 0000000000000000
[   56.649035] RBP: ffff88023184fb48 R08: 0000000000000000 R09: 0000000000000000
[   56.649035] R10: 0000000000000001 R11: 0000000000000000 R12: ffffffff811a28f0
[   56.649035] R13: ffffffff811a5b70 R14: 0000000000000001 R15: ffffffff81f2a048
[   56.649035] FS:  00007f3f44b16700(0000) GS:ffff88023fd00000(0000) knlGS:0000000000000000
[   56.649035] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   56.649035] CR2: 00007f3f44b09000 CR3: 00000000bb0e6000 CR4: 00000000000006e0
[   56.649035] Stack:
[   56.649035]  ffff88023184fba8 ffffffff810e9ae6 ffff880233faf680 ffff880200000000
[   56.649035]  0000000000000000 0000000000000000 ffff88023184fbb8 ffff880234d8da00
[   56.649035]  ffffffff81f2a050 0000000000000040 ffff8800bad34d00 0000000000000040
[   56.649035] Call Trace:
[   56.649035]  [<ffffffff810e9ae6>] on_each_cpu_cond+0x66/0xc0
[   56.649035]  [<ffffffff811a2f95>] flush_all+0x25/0x30
[   56.649035]  [<ffffffff811a8fee>] __kmem_cache_create+0x3fe/0x5a0
[   56.649035]  [<ffffffff811a71ab>] ? kmem_cache_alloc+0x1db/0x2e0
[   56.649035]  [<ffffffff811761c0>] kmem_cache_create+0x1e0/0x380
[   56.649035]  [<ffffffff811a778c>] ? kfree+0xec/0x330
[   56.649035]  [<ffffffffa0008023>] configfs_init+0x23/0x98 [configfs]
[   56.649035]  [<ffffffffa0008000>] ? 0xffffffffa0008000
[   56.649035]  [<ffffffff810002d1>] do_one_initcall+0x81/0x1b0
[   56.649035]  [<ffffffff811a6b26>] ? kmem_cache_alloc_trace+0x1d6/0x2e0
[   56.649035]  [<ffffffff810edaff>] do_init_module+0x5f/0x210
[   56.649035]  [<ffffffff810ef8af>] load_module+0x116f/0x17a0
[   56.649035]  [<ffffffff810eb930>] ? show_initstate+0x50/0x50
[   56.649035]  [<ffffffff810f0005>] SyS_init_module+0x125/0x150
[   56.649035]  [<ffffffff819e29ae>] entry_SYSCALL_64_fastpath+0x12/0x76
[   56.649035] Code: 89 c2 fa 66 66 90 66 66 90 48 89 d0 5d c3 66 0f 1f 44 00 00 48 63 ff 48 8b 16 55 48 03 14 fd 20 98 f2 81 48 89 e5 b8 01 00 00 00 <48> 83 7a 10 00 74 02 5d c3 48 83 7a 18 00 5d 0f 95 c0 c3 66 0f
[   56.649035] RIP  [<ffffffff811a2907>] has_cpu_slab+0x17/0x30
[   56.649035]  RSP <ffff88023184fb48>
[   56.702092] ---[ end trace ceccd457b71b3f62 ]---
[   56.703100] BUG: sleeping function called from invalid context at include/linux/sched.h:2727
[   56.704858] in_atomic(): 1, irqs_disabled(): 0, pid: 3087, name: modprobe
[   56.706276] INFO: lockdep is turned off.
[   56.707087] CPU: 2 PID: 3087 Comm: modprobe Tainted: G      D W       4.2.0-rc2+ #109
[   56.708710] Hardware name: OpenStack Foundation OpenStack Nova, BIOS Bochs 01/01/2011
[   56.710326]  ffffffff81caeb0a ffff88023184f8e8 ffffffff819d5bb0 ffffffff810bf0fe
[   56.711911]  ffff880235d70000 ffff88023184f918 ffffffff81085f48 ffffffff833ee142
[   56.713579]  0000000000000000 0000000000000aa7 ffffffff81caeb0a ffff88023184f948
[   56.715187] Call Trace:
[   56.715691]  [<ffffffff819d5bb0>] dump_stack+0x4c/0x65
[   56.716783]  [<ffffffff810bf0fe>] ? console_unlock+0x28e/0x4e0
[   56.717980]  [<ffffffff81085f48>] ___might_sleep+0x188/0x240
[   56.719125]  [<ffffffff8108604d>] __might_sleep+0x4d/0x90
[   56.720264]  [<ffffffff8106e1cf>] exit_signals+0x1f/0x130
[   56.721390]  [<ffffffff81081381>] ? blocking_notifier_call_chain+0x11/0x20
[   56.722759]  [<ffffffff8106012c>] do_exit+0xac/0xc10
[   56.723775]  [<ffffffff810c01b1>] ? kmsg_dump+0x111/0x190
[   56.724866]  [<ffffffff810c00bf>] ? kmsg_dump+0x1f/0x190
[   56.725942]  [<ffffffff81007282>] oops_end+0xa2/0xe0
[   56.726969]  [<ffffffff81007763>] die+0x53/0x80
[   56.727906]  [<ffffffff81003f1b>] do_general_protection+0xdb/0x160
[   56.729156]  [<ffffffff819e35f7>] ? native_iret+0x7/0x7
[   56.730178]  [<ffffffff811a28f0>] ? arch_local_irq_save+0x20/0x20
[   56.731415]  [<ffffffff811a5b70>] ? slab_cpuup_callback+0x110/0x110
[   56.732649]  [<ffffffff819e4828>] general_protection+0x28/0x30
[   56.733829]  [<ffffffff811a5b70>] ? slab_cpuup_callback+0x110/0x110
[   56.735057]  [<ffffffff811a28f0>] ? arch_local_irq_save+0x20/0x20
[   56.736297]  [<ffffffff811a2907>] ? has_cpu_slab+0x17/0x30
[   56.737412]  [<ffffffff810e9ae6>] on_each_cpu_cond+0x66/0xc0
[   56.738566]  [<ffffffff811a2f95>] flush_all+0x25/0x30
[   56.739572]  [<ffffffff811a8fee>] __kmem_cache_create+0x3fe/0x5a0
[   56.740849]  [<ffffffff811a71ab>] ? kmem_cache_alloc+0x1db/0x2e0
[   56.742026]  [<ffffffff811761c0>] kmem_cache_create+0x1e0/0x380
[   56.743222]  [<ffffffff811a778c>] ? kfree+0xec/0x330
[   56.744211]  [<ffffffffa0008023>] configfs_init+0x23/0x98 [configfs]
[   56.745497]  [<ffffffffa0008000>] ? 0xffffffffa0008000
[   56.746555]  [<ffffffff810002d1>] do_one_initcall+0x81/0x1b0
[   56.747728]  [<ffffffff811a6b26>] ? kmem_cache_alloc_trace+0x1d6/0x2e0
[   56.749310]  [<ffffffff810edaff>] do_init_module+0x5f/0x210
[   56.750467]  [<ffffffff810ef8af>] load_module+0x116f/0x17a0
[   56.751561]  [<ffffffff810eb930>] ? show_initstate+0x50/0x50
[   56.752762]  [<ffffffff810f0005>] SyS_init_module+0x125/0x150
[   56.753902]  [<ffffffff819e29ae>] entry_SYSCALL_64_fastpath+0x12/0x76
[   56.755220] note: modprobe[3087] exited with preempt_count 1
---
 mm/slub.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 816df0016555..4497cae6a914 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5181,7 +5181,7 @@ static int sysfs_slab_add(struct kmem_cache *s)
 	s->kobj.kset = cache_kset(s);
 	err = kobject_init_and_add(&s->kobj, &slab_ktype, NULL, "%s", name);
 	if (err)
-		goto out_put_kobj;
+		goto out;
 
 	err = sysfs_create_group(&s->kobj, &slab_attr_group);
 	if (err)
@@ -5208,8 +5208,6 @@ out:
 	return err;
 out_del_kobj:
 	kobject_del(&s->kobj);
-out_put_kobj:
-	kobject_put(&s->kobj);
 	goto out;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
