Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id CCB696B025E
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 17:55:37 -0400 (EDT)
Received: by qkdv3 with SMTP id v3so3826611qkd.3
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 14:55:37 -0700 (PDT)
Received: from mail.catern.com (catern.com. [104.131.201.120])
        by mx.google.com with ESMTPS id d13si7533213qka.37.2015.07.23.14.55.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 14:55:36 -0700 (PDT)
From: Spencer Baugh <sbaugh@catern.com>
Subject: [PATCH] mm: add resched points to remap_pmd_range/ioremap_pmd_range
Date: Thu, 23 Jul 2015 14:54:33 -0700
Message-Id: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>
Cc: Joern Engel <joern@purestorage.com>, Spencer Baugh <Spencer.baugh@purestorage.com>, Spencer Baugh <sbaugh@catern.com>

From: Joern Engel <joern@logfs.org>

Mapping large memory spaces can be slow and prevent high-priority
realtime threads from preempting lower-priority threads for a long time.
In my case it was a 256GB mapping causing at least 950ms scheduler
delay.  Problem detection is ratelimited and depends on interrupts
happening at the right time, so actual delay is likely worse.

------------[ cut here ]------------
WARNING: at arch/x86/kernel/irq.c:182 do_IRQ+0x126/0x140()
Thread not rescheduled for 36 jiffies
CPU: 14 PID: 6684 Comm: foo Tainted: G           O 3.10.59+
 0000000000000009 ffff883f7fbc3ee0 ffffffff8163a12c ffff883f7fbc3f18
 ffffffff8103f131 ffff887f48275ac0 0000000000000012 000000000000007c
 0000000000000000 ffff887f5bc11fd8 ffff883f7fbc3f78 ffffffff8103f19c
Call Trace:
 <IRQ>  [<ffffffff8163a12c>] dump_stack+0x19/0x1b
 [<ffffffff8103f131>] warn_slowpath_common+0x61/0x80
 [<ffffffff8103f19c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff810bd917>] ? rcu_irq_exit+0x77/0xc0
 [<ffffffff8164a556>] do_IRQ+0x126/0x140
 [<ffffffff816407ef>] common_interrupt+0x6f/0x6f
 <EOI>  [<ffffffff810fde68>] ? set_pageblock_migratetype+0x28/0x30
 [<ffffffff8126da37>] ? clear_page_c_e+0x7/0x10
 [<ffffffff811004b3>] ? get_page_from_freelist+0x5b3/0x880
 [<ffffffff81100863>] __alloc_pages_nodemask+0xe3/0x810
 [<ffffffff8126f48b>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff81138206>] alloc_pages_current+0x86/0x120
 [<ffffffff810fc02e>] __get_free_pages+0xe/0x50
 [<ffffffff81034e85>] pte_alloc_one_kernel+0x15/0x20
 [<ffffffff8111b6cd>] __pte_alloc_kernel+0x1d/0xf0
 [<ffffffff8126531c>] ioremap_page_range+0x2cc/0x320
 [<ffffffff81031619>] __ioremap_caller+0x1e9/0x2b0
 [<ffffffff810316f7>] ioremap_nocache+0x17/0x20
 [<ffffffff81275b45>] pci_iomap+0x55/0xb0
 [<ffffffffa007f29a>] vfio_pci_mmap+0x1ea/0x210 [vfio_pci]
 [<ffffffffa0025173>] vfio_device_fops_mmap+0x23/0x30 [vfio]
 [<ffffffff81124ed8>] mmap_region+0x3d8/0x5e0
 [<ffffffff811253e5>] do_mmap_pgoff+0x305/0x3c0
 [<ffffffff8126f3f3>] ? call_rwsem_down_write_failed+0x13/0x20
 [<ffffffff81111677>] vm_mmap_pgoff+0x67/0xa0
 [<ffffffff811237e2>] SyS_mmap_pgoff+0x272/0x2e0
 [<ffffffff810067e2>] SyS_mmap+0x22/0x30
 [<ffffffff81648c59>] system_call_fastpath+0x16/0x1b
---[ end trace 6b0a8d2341444bdd ]---
------------[ cut here ]------------
WARNING: at arch/x86/kernel/irq.c:182 do_IRQ+0x126/0x140()
Thread not rescheduled for 95 jiffies
CPU: 14 PID: 6684 Comm: foo Tainted: G        W  O 3.10.59+
 0000000000000009 ffff883f7fbc3ee0 ffffffff8163a12c ffff883f7fbc3f18
 ffffffff8103f131 ffff887f48275ac0 000000000000002f 000000000000007c
 0000000000000000 00007fadd1e00000 ffff883f7fbc3f78 ffffffff8103f19c
Call Trace:
 <IRQ>  [<ffffffff8163a12c>] dump_stack+0x19/0x1b
 [<ffffffff8103f131>] warn_slowpath_common+0x61/0x80
 [<ffffffff8103f19c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff810bd917>] ? rcu_irq_exit+0x77/0xc0
 [<ffffffff8164a556>] do_IRQ+0x126/0x140
 [<ffffffff816407ef>] common_interrupt+0x6f/0x6f
 <EOI>  [<ffffffff81640483>] ? _raw_spin_lock+0x13/0x30
 [<ffffffff8111b621>] __pte_alloc+0x31/0xc0
 [<ffffffff8111feac>] remap_pfn_range+0x45c/0x470
 [<ffffffffa007f1f8>] vfio_pci_mmap+0x148/0x210 [vfio_pci]
 [<ffffffffa0025173>] vfio_device_fops_mmap+0x23/0x30 [vfio]
 [<ffffffff81124ed8>] mmap_region+0x3d8/0x5e0
 [<ffffffff811253e5>] do_mmap_pgoff+0x305/0x3c0
 [<ffffffff8126f3f3>] ? call_rwsem_down_write_failed+0x13/0x20
 [<ffffffff81111677>] vm_mmap_pgoff+0x67/0xa0
 [<ffffffff811237e2>] SyS_mmap_pgoff+0x272/0x2e0
 [<ffffffff810067e2>] SyS_mmap+0x22/0x30
 [<ffffffff81648c59>] system_call_fastpath+0x16/0x1b
---[ end trace 6b0a8d2341444bde ]---
------------[ cut here ]------------
WARNING: at arch/x86/kernel/irq.c:182 do_IRQ+0x126/0x140()
Thread not rescheduled for 45 jiffies
CPU: 18 PID: 21726 Comm: foo Tainted: G           O 3.10.59+
 0000000000000009 ffff88203f203ee0 ffffffff8163a13c ffff88203f203f18
 ffffffff8103f131 ffff881ec5f1ad60 0000000000000016 000000000000006e
 0000000000000000 ffffc939a6dd8000 ffff88203f203f78 ffffffff8103f19c
Call Trace:
 <IRQ>  [<ffffffff8163a13c>] dump_stack+0x19/0x1b
 [<ffffffff8103f131>] warn_slowpath_common+0x61/0x80
 [<ffffffff8103f19c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff810bd917>] ? rcu_irq_exit+0x77/0xc0
 [<ffffffff8164a556>] do_IRQ+0x126/0x140
 [<ffffffff816407ef>] common_interrupt+0x6f/0x6f
 <EOI>  [<ffffffff81640861>] ? retint_restore_args+0x13/0x13
 [<ffffffff810346c7>] ? free_memtype+0x87/0x150
 [<ffffffff8112bb46>] ? vunmap_page_range+0x1e6/0x2a0
 [<ffffffff8112c5e1>] remove_vm_area+0x51/0x70
 [<ffffffff810318a7>] iounmap+0x67/0xa0
 [<ffffffff812757e5>] pci_iounmap+0x35/0x40
 [<ffffffffa00973da>] vfio_pci_release+0x9a/0x150 [vfio_pci]
 [<ffffffffa0065cbc>] vfio_device_fops_release+0x1c/0x40 [vfio]
 [<ffffffff8114d82b>] __fput+0xdb/0x220
 [<ffffffff8114d97e>] ____fput+0xe/0x10
 [<ffffffff810614ac>] task_work_run+0xbc/0xe0
 [<ffffffff81043d0e>] do_exit+0x3ce/0xe50
 [<ffffffff8104557f>] do_group_exit+0x3f/0xa0
 [<ffffffff81054769>] get_signal_to_deliver+0x1a9/0x5b0
 [<ffffffff810023f8>] do_signal+0x48/0x5e0
 [<ffffffff81056778>] ? k_getrusage+0x368/0x3d0
 [<ffffffff810736e2>] ? default_wake_function+0x12/0x20
 [<ffffffff816471c0>] ? kprobe_flush_task+0xc0/0x150
 [<ffffffff81070684>] ? finish_task_switch+0xc4/0xe0
 [<ffffffff810029f5>] do_notify_resume+0x65/0x80
 [<ffffffff8164098e>] retint_signal+0x4d/0x9f
---[ end trace 3506c05e4a0af3e5 ]---

Signed-off-by: Joern Engel <joern@logfs.org>
Signed-off-by: Spencer Baugh <sbaugh@catern.com>
---
 lib/ioremap.c | 1 +
 mm/memory.c   | 1 +
 mm/vmalloc.c  | 1 +
 3 files changed, 3 insertions(+)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 86c8911..d38e46d 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -90,6 +90,7 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
 
 		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
 			return -ENOMEM;
+		cond_resched();
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 388dcf9..1541880 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1656,6 +1656,7 @@ static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
 		if (remap_pte_range(mm, pmd, addr, next,
 				pfn + (addr >> PAGE_SHIFT), prot))
 			return -ENOMEM;
+		cond_resched();
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2faaa29..d503c8e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -80,6 +80,7 @@ static void vunmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end)
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		vunmap_pte_range(pmd, addr, next);
+		cond_resched();
 	} while (pmd++, addr = next, addr != end);
 }
 
-- 
2.5.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
