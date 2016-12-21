Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 063266B038F
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 04:40:49 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id b202so379665883oii.3
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 01:40:49 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id p48si12939443otc.137.2016.12.21.01.40.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Dec 2016 01:40:48 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [RFC]arm64: soft lockup on smp_call_function_many()
Message-ID: <ab158a3c-ea0a-5be2-5bd6-4b36f63e14b6@huawei.com>
Date: Wed, 21 Dec 2016 17:37:25 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, xiexiuqi@hauwei.com

The kernel version is 4.1.34. From the log, we can the pc at function
csd_lock_wait().

We have backport the
commit 8053871d0f7f("smp: Fix smp_call_function_single_async() locking").
So the function is:
static void csd_lock_wait(struct call_single_data *csd)
{
         while (smp_load_acquire(&csd->flags) & CSD_FLAG_LOCK)
                 cpu_relax();
}

Any comment is more than welcome!

Thanks,
Yisheng Xie

-----------
[ 1376.188273] NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s! [kworker/u64:0:6]
[ 1376.206461]
[ 1376.218555] CPU: 1 PID: 6 Comm: kworker/u64:0 Tainted: G            E   4.1.34 #2
[ 1376.237292] Hardware name: Huawei Taishan 2180 /BC11SPCC, BIOS 1.31 06/23/2016
[ 1376.256541] task: ffff802fb9383d40 ti: ffff802fb93c0000 task.ti: ffff802fb93c0000
[ 1376.275552] PC is at smp_call_function_many+0x29c/0x308
[ 1376.293554] LR is at smp_call_function_many+0x268/0x308
[ 1376.311766] pc : [<ffff80000015032c>] lr : [<ffff8000001502f8>] pstate: 80000145
[ 1376.332359] sp : ffff802fb93c3920
[ 1376.349112]
[ 1376.364204] Kernel panic - not syncing: softlockup: hung tasks
[ 1376.384471] CPU: 1 PID: 6 Comm: kworker/u64:0 Tainted: G            EL  4.1.34 #2
[ 1376.406785] Hardware name: Huawei Taishan 2180 /BC11SPCC, BIOS 1.31 06/23/2016
[ 1376.428938] Workqueue: cpuset_migrate_mm cpuset_migrate_mm_workfn
[ 1376.450385] Call trace:
[ 1376.468097] [<ffff80000008ade0>] dump_backtrace+0x0/0x1a0
[ 1376.490023] [<ffff80000008afa0>] show_stack+0x20/0x28
[ 1376.512143] [<ffff800000aa2e78>] dump_stack+0x98/0xb8
[ 1376.533792] [<ffff800000a9fa0c>] panic+0x10c/0x26c
[ 1376.555317] [<ffff800000188430>] watchdog+0x0/0x40
[ 1376.576680] [<ffff800000139850>] __run_hrtimer+0x78/0x298
[ 1376.598112] [<ffff800000139d40>] hrtimer_interrupt+0x108/0x278
[ 1376.620450] [<ffff8000008bdf60>] arch_timer_handler_phys+0x38/0x48
[ 1376.644011] [<ffff8000001258b8>] handle_percpu_devid_irq+0x90/0x238
[ 1376.666911] [<ffff800000120848>] generic_handle_irq+0x40/0x58
[ 1376.689875] [<ffff800000120bc0>] __handle_domain_irq+0x68/0xc0
[ 1376.713403] [<ffff80000008265c>] gic_handle_irq+0xc4/0x1c8
[ 1376.736030] Exception stack(0xffff802fb93c3790 to 0xffff802fb93c38d0)
[ 1376.759750] 3780:                                   0000000000001000 0001000000000000
[ 1376.786014] 37a0: ffff802fb93c3920 ffff80000015032c 0000000080000145 0000000000000001
[ 1376.813028] 37c0: ffff80000014f958 0000000000000000 ffff8000010c8cf8 0000000000000000
[ 1376.840077] 37e0: ffff803fbffc5460 ffff803fbffc5448 000000000000001f ffff8000010c7700
[ 1376.868191] 3800: 000000000000001f ffffffff80000000 0000000000000000 0000000000000000
[ 1376.895959] 3820: 0000000000000002 ffff80000055a118 ffff800000231bb0 0000000000000001
[ 1376.923610] 3840: ffff803fbffe6bc0 0008000000000000 0000000000000000 003b31c87bc2eeba
[ 1376.951284] 3860: ffff80000014f330 0000ffff88dee338 0000ffffefb156e0 ffff802fffebf3c0
[ 1376.978782] 3880: ffff802fffebf3c8 ffff8000010c7000 ffff8000010c8cf8 ffff8000010a1380
[ 1377.006734] 38a0: 0000000000000001 ffff80000014f958 0000000000000000 ffff8000010c8cf8
[ 1377.034031] 38c0: 0000000000000080 ffff802fb93c3920
[ 1377.058023] [<ffff80000008381c>] el1_irq+0x9c/0x140
[ 1377.082904] [<ffff800000150474>] kick_all_cpus_sync+0x34/0x40
[ 1377.103398] [<ffff8000000a085c>] pmdp_splitting_flush+0x5c/0x98
[ 1377.123805] [<ffff800000249d90>] split_huge_page_to_list+0xd8/0xa90
[ 1377.146433] [<ffff80000024b18c>] __split_huge_page_pmd+0xf4/0x330
[ 1377.168313] [<ffff800000231d78>] queue_pages_pte_range+0x1c8/0x1d0
[ 1377.193749] [<ffff80000021f9b0>] __walk_page_range+0x158/0x380
[ 1377.215375] [<ffff80000021fc58>] walk_page_range+0x80/0x100
[ 1377.237044] [<ffff800000231ab4>] queue_pages_range+0x94/0xb8
[ 1377.257681] [<ffff800000232de0>] do_migrate_pages+0x1d0/0x250
[ 1377.278889] [<ffff8000001675f0>] cpuset_migrate_mm_workfn+0x30/0x50
[ 1377.298235] [<ffff8000000e6d30>] process_one_work+0x150/0x430
[ 1377.317808] [<ffff8000000e7158>] worker_thread+0x148/0x4b8
[ 1377.337583] [<ffff8000000ed6e8>] kthread+0x100/0x118
[ 1377.357541] SMP: stopping secondary CPUs
[ 1377.376114] SMP: stopping secondary CPUs
[ 1378.445112] SMP: failed to stop secondary CPUs 0-31
[ 1378.467717] Get irq acitve state failed.
[ 1378.487833] Get irq acitve state failed.
[ 1378.507885] Get irq acitve state failed.
[ 1378.524965] Get irq acitve state failed.
[ 1378.541685] Get irq acitve state failed.
[ 1378.557528] Get irq acitve state failed.
[ 1378.575082] Get irq acitve state failed.
[ 1378.591459] Get irq acitve state failed.
[ 1378.606292] Get irq acitve state failed.
[ 1378.620450] Get irq acitve state failed.
[ 1378.635056] Get irq acitve state failed.
[ 1378.649346] Get irq acitve state failed.
[ 1378.664147] Get irq acitve state failed.
[ 1378.678135] Get irq acitve state failed.
[ 1378.690731] Get irq acitve state failed.
[ 1378.704672] Get irq acitve state failed.
[ 1378.717086] Starting crashdump kernel...
[ 1378.729146] ------------[ cut here ]------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
