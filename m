Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B4BC96B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 02:24:06 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 133so58868106itu.17
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 23:24:06 -0700 (PDT)
Received: from out0-158.mail.aliyun.com (out0-158.mail.aliyun.com. [140.205.0.158])
        by mx.google.com with ESMTP id f16si3560709plj.212.2017.03.26.23.24.05
        for <linux-mm@kvack.org>;
        Sun, 26 Mar 2017 23:24:05 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1490477850-7944-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1490477850-7944-1-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [PATCH v2] hugetlbfs: initialize shared policy as part of inode allocation
Date: Mon, 27 Mar 2017 14:24:00 +0800
Message-ID: <016101d2a6c2$b98e9080$2cabb180$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: 'Dmitry Vyukov' <dvyukov@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Michal Hocko' <mhocko@suse.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>


On March 26, 2017 5:38 AM Mike Kravetz wrote:
> 
> Any time after inode allocation, destroy_inode can be called.  The
> hugetlbfs inode contains a shared_policy structure, and
> mpol_free_shared_policy is unconditionally called as part of
> hugetlbfs_destroy_inode.  Initialize the policy as part of inode
> allocation so that any quick (error path) calls to destroy_inode
> will be handed an initialized policy.
> 
> syzkaller fuzzer found this bug, that resulted in the following:
> 
> BUG: KASAN: user-memory-access in atomic_inc
> include/asm-generic/atomic-instrumented.h:87 [inline] at addr
> 000000131730bd7a
> BUG: KASAN: user-memory-access in __lock_acquire+0x21a/0x3a80
> kernel/locking/lockdep.c:3239 at addr 000000131730bd7a
> Write of size 4 by task syz-executor6/14086
> CPU: 3 PID: 14086 Comm: syz-executor6 Not tainted 4.11.0-rc3+ #364
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x1b8/0x28d lib/dump_stack.c:52
>  kasan_report_error mm/kasan/report.c:291 [inline]
>  kasan_report.part.2+0x34a/0x480 mm/kasan/report.c:316
>  kasan_report+0x21/0x30 mm/kasan/report.c:303
>  check_memory_region_inline mm/kasan/kasan.c:326 [inline]
>  check_memory_region+0x137/0x190 mm/kasan/kasan.c:333
>  kasan_check_write+0x14/0x20 mm/kasan/kasan.c:344
>  atomic_inc include/asm-generic/atomic-instrumented.h:87 [inline]
>  __lock_acquire+0x21a/0x3a80 kernel/locking/lockdep.c:3239
>  lock_acquire+0x1ee/0x590 kernel/locking/lockdep.c:3762
>  __raw_write_lock include/linux/rwlock_api_smp.h:210 [inline]
>  _raw_write_lock+0x33/0x50 kernel/locking/spinlock.c:295
>  mpol_free_shared_policy+0x43/0xb0 mm/mempolicy.c:2536
>  hugetlbfs_destroy_inode+0xca/0x120 fs/hugetlbfs/inode.c:952
>  alloc_inode+0x10d/0x180 fs/inode.c:216
>  new_inode_pseudo+0x69/0x190 fs/inode.c:889
>  new_inode+0x1c/0x40 fs/inode.c:918
>  hugetlbfs_get_inode+0x40/0x420 fs/hugetlbfs/inode.c:734
>  hugetlb_file_setup+0x329/0x9f0 fs/hugetlbfs/inode.c:1282
>  newseg+0x422/0xd30 ipc/shm.c:575
>  ipcget_new ipc/util.c:285 [inline]
>  ipcget+0x21e/0x580 ipc/util.c:639
>  SYSC_shmget ipc/shm.c:673 [inline]
>  SyS_shmget+0x158/0x230 ipc/shm.c:657
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> 
> Analysis provided by Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> v2: Remove now redundant initialization in hugetlbfs_get_root
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
