Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B54D6B03A0
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:09:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m28so107633526pgn.14
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:09:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 1si3719032pgt.210.2017.03.28.03.09.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Mar 2017 03:09:00 -0700 (PDT)
Subject: Re: [PATCH] mm: Remove pointless might_sleep() in remove_vm_area().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170324161732.GA23110@bombadil.infradead.org>
	<0eceef23-a20c-bca7-2153-b9b5baf1f1d8@virtuozzo.com>
	<f1c0b9ec-c0c8-502c-c7f0-fe692c73ab04@vmware.com>
	<201703272329.AIE32232.LtVSOOOFFQJFHM@I-love.SAKURA.ne.jp>
	<4a4f546c-4a92-1cea-14b6-bf3a8725b0e8@virtuozzo.com>
In-Reply-To: <4a4f546c-4a92-1cea-14b6-bf3a8725b0e8@virtuozzo.com>
Message-Id: <201703281907.EDE73998.FOOFVJFMQLHtSO@I-love.SAKURA.ne.jp>
Date: Tue, 28 Mar 2017 19:07:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, thellstrom@vmware.com, willy@infradead.org
Cc: linux-mm@kvack.org, hch@lst.de, jszhang@marvell.com, joelaf@google.com, chris@chris-wilson.co.uk, joaodias@google.com, tglx@linutronix.de, hpa@zytor.com, mingo@elte.hu, dri-devel@lists.freedesktop.org, airlied@linux.ie, linux-security-module@vger.kernel.org

Andrey Ryabinin wrote:
> It's safe to call vfree() from rcu callback as in any other interrupt context.
> Commits you listed bellow didn't change anything in that respect.
> They made impossible to call vfree() under stuff like preempt_disable()/spin_lock()

I still cannot catch. According to test results shown below, calling vfree() from
RCU callback is permitted but calling vfree() from RCU read section is no longer
permitted.

---------- test.c ----------
#include <linux/module.h>
static int test_init(void)
{
        rcu_read_lock();
        might_sleep();
        rcu_read_unlock();
        return -EINVAL;
}
module_init(test_init);
MODULE_LICENSE("GPL");
---------- test.c ----------

[   49.729561] test: loading out-of-tree module taints kernel.
[   49.738211] test: module verification failed: signature and/or required key missing - tainting kernel

[   49.757855] ===============================
[   49.764038] [ ERR: suspicious RCU usage.  ]
[   49.767222] 4.11.0-rc4+ #210 Tainted: G           OE
[   49.770216] -------------------------------
[   49.772668] ./include/linux/rcupdate.h:521 Illegal context switch in RCU read-side critical section!
[   49.777915]
other info that might help us debug this:

[   49.782562]
rcu_scheduler_active = 2, debug_locks = 0
[   49.786336] 1 lock held by insmod/2332:
[   49.788596]  #0:  (rcu_read_lock){......}, at: [<ffffffffc07c7005>] test_init+0x5/0x1000 [test]
[   49.793632]
stack backtrace:
[   49.796190] CPU: 2 PID: 2332 Comm: insmod Tainted: G           OE   4.11.0-rc4+ #210
[   49.798830] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   49.802213] Call Trace:
[   49.803010]  dump_stack+0x85/0xc9
[   49.804079]  lockdep_rcu_suspicious+0xe7/0x120
[   49.805503]  ___might_sleep+0xac/0x250
[   49.806704]  __might_sleep+0x4a/0x90
[   49.807852]  ? 0xffffffffc07c7000
[   49.808921]  test_init+0x5c/0x1000 [test]
[   49.810212]  ? test_init+0x5/0x1000 [test]
[   49.811526]  do_one_initcall+0x51/0x1c0
[   49.813014]  ? do_init_module+0x27/0x1fc
[   49.814370]  ? rcu_read_lock_sched_held+0x98/0xa0
[   49.815882]  ? kmem_cache_alloc_trace+0x278/0x2e0
[   49.817389]  ? do_init_module+0x27/0x1fc
[   49.818651]  do_init_module+0x60/0x1fc
[   49.819880]  load_module+0x23b4/0x2a00
[   49.821087]  ? __symbol_put+0x70/0x70
[   49.822271]  ? vfs_read+0x12b/0x180
[   49.823401]  SYSC_finit_module+0xa6/0xf0
[   49.824667]  SyS_finit_module+0xe/0x10
[   49.825894]  do_syscall_64+0x6c/0x200
[   49.827074]  entry_SYSCALL64_slow_path+0x25/0x25
[   49.829239] RIP: 0033:0x7fdeb1f52bf9
[   49.830540] RSP: 002b:00007fff1f355b28 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[   49.833255] RAX: ffffffffffffffda RBX: 00000000014e71f0 RCX: 00007fdeb1f52bf9
[   49.835586] RDX: 0000000000000000 RSI: 000000000041a2d8 RDI: 0000000000000003
[   49.838370] RBP: 000000000041a2d8 R08: 0000000000000000 R09: 00007fff1f355cc8
[   49.841099] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[   49.843994] R13: 00000000014e6130 R14: 0000000000000000 R15: 0000000000000000
[   49.846756] BUG: sleeping function called from invalid context at /data/linux/akari/test.c:5
[   49.850727] in_atomic(): 1, irqs_disabled(): 0, pid: 2332, name: insmod
[   49.853353] INFO: lockdep is turned off.
[   49.855088] CPU: 2 PID: 2332 Comm: insmod Tainted: G           OE   4.11.0-rc4+ #210
[   49.858013] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   49.861940] Call Trace:
[   49.863217]  dump_stack+0x85/0xc9
[   49.864744]  ___might_sleep+0x184/0x250
[   49.866420]  __might_sleep+0x4a/0x90
[   49.868003]  ? 0xffffffffc07c7000
[   49.869502]  test_init+0x5c/0x1000 [test]
[   49.871236]  ? test_init+0x5/0x1000 [test]
[   49.872983]  do_one_initcall+0x51/0x1c0
[   49.874796]  ? do_init_module+0x27/0x1fc
[   49.876486]  ? rcu_read_lock_sched_held+0x98/0xa0
[   49.878413]  ? kmem_cache_alloc_trace+0x278/0x2e0
[   49.880330]  ? do_init_module+0x27/0x1fc
[   49.882006]  do_init_module+0x60/0x1fc
[   49.883623]  load_module+0x23b4/0x2a00
[   49.885225]  ? __symbol_put+0x70/0x70
[   49.886784]  ? vfs_read+0x12b/0x180
[   49.888291]  SYSC_finit_module+0xa6/0xf0
[   49.890025]  SyS_finit_module+0xe/0x10
[   49.891611]  do_syscall_64+0x6c/0x200
[   49.893168]  entry_SYSCALL64_slow_path+0x25/0x25
[   49.895027] RIP: 0033:0x7fdeb1f52bf9
[   49.896561] RSP: 002b:00007fff1f355b28 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[   49.899355] RAX: ffffffffffffffda RBX: 00000000014e71f0 RCX: 00007fdeb1f52bf9
[   49.902020] RDX: 0000000000000000 RSI: 000000000041a2d8 RDI: 0000000000000003
[   49.904683] RBP: 000000000041a2d8 R08: 0000000000000000 R09: 00007fff1f355cc8
[   49.907510] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[   49.910180] R13: 00000000014e6130 R14: 0000000000000000 R15: 0000000000000000

---------- test.c ----------
#include <linux/module.h>
#include <linux/sched.h>
static int test_init(void)
{
        static DEFINE_SPINLOCK(lock);
        rcu_read_lock();
        spin_lock(&lock);
        cond_resched_lock(&lock);
        spin_unlock(&lock);
        rcu_read_unlock();
        return -EINVAL;
}
module_init(test_init);
MODULE_LICENSE("GPL");
---------- test.c ----------

[   66.548461] test: loading out-of-tree module taints kernel.
[   66.551894] test: module verification failed: signature and/or required key missing - tainting kernel

[   66.560299] ===============================
[   66.562838] [ ERR: suspicious RCU usage.  ]
[   66.565395] 4.11.0-rc4+ #210 Tainted: G           OE
[   66.568494] -------------------------------
[   66.571012] ./include/linux/rcupdate.h:521 Illegal context switch in RCU read-side critical section!
[   66.576384]
other info that might help us debug this:

[   66.579234]
rcu_scheduler_active = 2, debug_locks = 0
[   66.581505] 2 locks held by insmod/2336:
[   66.582897]  #0:  (rcu_read_lock){......}, at: [<ffffffffc0543005>] test_init+0x5/0x1000 [test]
[   66.586253]  #1:  (lock#4){+.+...}, at: [<ffffffffc0543055>] test_init+0x55/0x1000 [test]
[   66.589135]
stack backtrace:
[   66.590919] CPU: 0 PID: 2336 Comm: insmod Tainted: G           OE   4.11.0-rc4+ #210
[   66.593842] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   66.597716] Call Trace:
[   66.598598]  dump_stack+0x85/0xc9
[   66.599749]  lockdep_rcu_suspicious+0xe7/0x120
[   66.601289]  ___might_sleep+0xac/0x250
[   66.602585]  ? 0xffffffffc0543000
[   66.603735]  test_init+0x6b/0x1000 [test]
[   66.605121]  ? test_init+0x5/0x1000 [test]
[   66.606520]  do_one_initcall+0x51/0x1c0
[   66.607850]  ? do_init_module+0x27/0x1fc
[   66.609245]  ? rcu_read_lock_sched_held+0x98/0xa0
[   66.610855]  ? kmem_cache_alloc_trace+0x278/0x2e0
[   66.612489]  ? do_init_module+0x27/0x1fc
[   66.613868]  do_init_module+0x60/0x1fc
[   66.615195]  load_module+0x23b4/0x2a00
[   66.616512]  ? __symbol_put+0x70/0x70
[   66.617816]  ? vfs_read+0x12b/0x180
[   66.619074]  SYSC_finit_module+0xa6/0xf0
[   66.620455]  SyS_finit_module+0xe/0x10
[   66.621780]  do_syscall_64+0x6c/0x200
[   66.623067]  entry_SYSCALL64_slow_path+0x25/0x25
[   66.624937] RIP: 0033:0x7f6e6702bbf9
[   66.626206] RSP: 002b:00007ffdc94c3588 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[   66.628901] RAX: ffffffffffffffda RBX: 00000000007421f0 RCX: 00007f6e6702bbf9
[   66.631373] RDX: 0000000000000000 RSI: 000000000041a2d8 RDI: 0000000000000003
[   66.634430] RBP: 000000000041a2d8 R08: 0000000000000000 R09: 00007ffdc94c3728
[   66.637428] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[   66.640422] R13: 0000000000741130 R14: 0000000000000000 R15: 0000000000000000
[   66.643430] BUG: sleeping function called from invalid context at /data/linux/akari/test.c:8
[   66.646779] in_atomic(): 1, irqs_disabled(): 0, pid: 2336, name: insmod
[   66.649484] INFO: lockdep is turned off.
[   66.651284] CPU: 0 PID: 2336 Comm: insmod Tainted: G           OE   4.11.0-rc4+ #210
[   66.654377] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   66.658592] Call Trace:
[   66.659939]  dump_stack+0x85/0xc9
[   66.661562]  ___might_sleep+0x184/0x250
[   66.663385]  ? 0xffffffffc0543000
[   66.664967]  test_init+0x6b/0x1000 [test]
[   66.666812]  ? test_init+0x5/0x1000 [test]
[   66.668636]  do_one_initcall+0x51/0x1c0
[   66.670399]  ? do_init_module+0x27/0x1fc
[   66.672170]  ? rcu_read_lock_sched_held+0x98/0xa0
[   66.674256]  ? kmem_cache_alloc_trace+0x278/0x2e0
[   66.676308]  ? do_init_module+0x27/0x1fc
[   66.678056]  do_init_module+0x60/0x1fc
[   66.679728]  load_module+0x23b4/0x2a00
[   66.681428]  ? __symbol_put+0x70/0x70
[   66.683100]  ? vfs_read+0x12b/0x180
[   66.684720]  SYSC_finit_module+0xa6/0xf0
[   66.686422]  SyS_finit_module+0xe/0x10
[   66.688109]  do_syscall_64+0x6c/0x200
[   66.689776]  entry_SYSCALL64_slow_path+0x25/0x25
[   66.692052] RIP: 0033:0x7f6e6702bbf9
[   66.693687] RSP: 002b:00007ffdc94c3588 EFLAGS: 00000206 ORIG_RAX: 0000000000000139
[   66.696577] RAX: ffffffffffffffda RBX: 00000000007421f0 RCX: 00007f6e6702bbf9
[   66.699432] RDX: 0000000000000000 RSI: 000000000041a2d8 RDI: 0000000000000003
[   66.702261] RBP: 000000000041a2d8 R08: 0000000000000000 R09: 00007ffdc94c3728
[   66.705076] R10: 0000000000000003 R11: 0000000000000206 R12: 0000000000000000
[   66.707990] R13: 0000000000741130 R14: 0000000000000000 R15: 0000000000000000



Also, if we try below change like suggested at
http://lkml.kernel.org/r/20170323152949.GA29134@bombadil.infradead.org ,
we get below warnings.
Aren't there vfree()/kvfree() users who are not ready to handle these changes?

----------
diff --git a/mm/util.c b/mm/util.c
index 656dc5e..2a2ef72 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -331,6 +331,12 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
 
 void kvfree(const void *addr)
 {
+	/* Detect errors before kvmalloc() falls back to vmalloc(). */
+	if (addr) {
+		WARN_ON(in_nmi());
+		if (likely(!in_interrupt()))
+			might_sleep();
+	}
 	if (is_vmalloc_addr(addr))
 		vfree(addr);
 	else
----------

[   23.635540] BUG: sleeping function called from invalid context at mm/util.c:338
[   23.638701] in_atomic(): 1, irqs_disabled(): 0, pid: 478, name: kworker/0:1H
[   23.641516] 3 locks held by kworker/0:1H/478:
[   23.643476]  #0:  ("xfs-log/%s"mp->m_fsname){.+.+..}, at: [<ffffffffb20d1e64>] process_one_work+0x194/0x6c0
[   23.647176]  #1:  ((&bp->b_ioend_work)){+.+...}, at: [<ffffffffb20d1e64>] process_one_work+0x194/0x6c0
[   23.650939]  #2:  (&(&pag->pagb_lock)->rlock){+.+...}, at: [<ffffffffc02b42ee>] xfs_extent_busy_clear+0x9e/0xe0 [xfs]
[   23.655132] CPU: 0 PID: 478 Comm: kworker/0:1H Not tainted 4.11.0-rc4+ #212
[   23.657974] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   23.662041] Workqueue: xfs-log/sda1 xfs_buf_ioend_work [xfs]
[   23.664463] Call Trace:
[   23.665866]  dump_stack+0x85/0xc9
[   23.667538]  ___might_sleep+0x184/0x250
[   23.669371]  __might_sleep+0x4a/0x90
[   23.671137]  kvfree+0x41/0x90
[   23.672748]  xfs_extent_busy_clear_one+0x51/0x190 [xfs]
[   23.675110]  xfs_extent_busy_clear+0xbb/0xe0 [xfs]
[   23.677278]  xlog_cil_committed+0x241/0x420 [xfs]
[   23.679431]  xlog_state_do_callback+0x170/0x2d0 [xfs]
[   23.681717]  xlog_state_done_syncing+0x7f/0xa0 [xfs]
[   23.683971]  ? xfs_buf_ioend_work+0x15/0x20 [xfs]
[   23.686112]  xlog_iodone+0x86/0xc0 [xfs]
[   23.688007]  xfs_buf_ioend+0xd3/0x440 [xfs]
[   23.689999]  xfs_buf_ioend_work+0x15/0x20 [xfs]
[   23.692060]  process_one_work+0x21c/0x6c0
[   23.694177]  ? process_one_work+0x194/0x6c0
[   23.696120]  worker_thread+0x137/0x4b0
[   23.697973]  kthread+0x10f/0x150
[   23.699607]  ? process_one_work+0x6c0/0x6c0
[   23.701561]  ? kthread_create_on_node+0x70/0x70
[   23.703617]  ret_from_fork+0x31/0x40

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
