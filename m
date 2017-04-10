Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F291E6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 17:38:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h15so3535996wmd.1
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:38:15 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id r20si14198108wrb.259.2017.04.10.14.38.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 14:38:14 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id x75so11874349wma.1
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:38:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1490821682-23228-1-git-send-email-mike.kravetz@oracle.com>
References: <1490821682-23228-1-git-send-email-mike.kravetz@oracle.com>
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Mon, 10 Apr 2017 23:38:13 +0200
Message-ID: <CAOMGZ=Gtt=d7EqEoe=dxqB0H-YWHUDJMHyYHfseWE2rSxhBFwg@mail.gmail.com>
Subject: Re: [PATCH RESEND] mm/hugetlb: Don't call region_abort if region_chg fails
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 29 March 2017 at 23:08, Mike Kravetz <mike.kravetz@oracle.com> wrote:
> Changes to hugetlbfs reservation maps is a two step process.  The first
> step is a call to region_chg to determine what needs to be changed, and
> prepare that change.  This should be followed by a call to call to
> region_add to commit the change, or region_abort to abort the change.
>
> The error path in hugetlb_reserve_pages called region_abort after a
> failed call to region_chg.  As a result, the adds_in_progress counter
> in the reservation map is off by 1.  This is caught by a VM_BUG_ON
> in resv_map_release when the reservation map is freed.
>
> syzkaller fuzzer found this bug, that resulted in the following:
>
>  kernel BUG at mm/hugetlb.c:742!
>  Call Trace:
>   hugetlbfs_evict_inode+0x7b/0xa0 fs/hugetlbfs/inode.c:493
>   evict+0x481/0x920 fs/inode.c:553
>   iput_final fs/inode.c:1515 [inline]
>   iput+0x62b/0xa20 fs/inode.c:1542
>   hugetlb_file_setup+0x593/0x9f0 fs/hugetlbfs/inode.c:1306
>   newseg+0x422/0xd30 ipc/shm.c:575
>   ipcget_new ipc/util.c:285 [inline]
>   ipcget+0x21e/0x580 ipc/util.c:639
>   SYSC_shmget ipc/shm.c:673 [inline]
>   SyS_shmget+0x158/0x230 ipc/shm.c:657
>   entry_SYSCALL_64_fastpath+0x1f/0xc2
>  RIP: resv_map_release+0x265/0x330 mm/hugetlb.c:742
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> ---
>  mm/hugetlb.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c7025c1..c65d45c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4233,7 +4233,9 @@ int hugetlb_reserve_pages(struct inode *inode,
>         return 0;
>  out_err:
>         if (!vma || vma->vm_flags & VM_MAYSHARE)
> -               region_abort(resv_map, from, to);
> +               /* Don't call region_abort if region_chg failed */
> +               if (chg >= 0)
> +                       region_abort(resv_map, from, to);
>         if (vma && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
>                 kref_put(&resv_map->refs, resv_map_release);
>         return ret;

Hi guys,

I'm running into this on latest linus/master:

kernel BUG at mm/hugetlb.c:742!
invalid opcode: 0000 [#1] SMP KASAN
CPU: 3 PID: 20281 Comm: syz-executor0 Not tainted 4.11.0-rc6 #335
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
Ubuntu-1.8.2-1ubuntu1 04/01/2014
task: ffff880064f30dc0 task.stack: ffff880065b38000
RIP: 0010:resv_map_release+0x1cb/0x270
RSP: 0018:ffff880065b3fc38 EFLAGS: 00010287
RAX: 0000000000010000 RBX: ffff88006b5fe418 RCX: ffffc90001b52000
RDX: 00000000000005de RSI: ffffffff8172026b RDI: ffff88006b5fe410
RBP: ffff880065b3fc78 R08: ffff880065b3f958 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: dffffc0000000000
R13: ffff88006b5fe418 R14: ffff88006b5fe418 R15: ffff88006b5fe418
FS:  00007f21647c5700(0000) GS:ffff88006d100000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000460750 CR3: 000000005d123000 CR4: 00000000000006e0
Call Trace:
 hugetlbfs_evict_inode+0x80/0xa0
 ? hugetlbfs_setattr+0x3c0/0x3c0
 evict+0x24a/0x620
 iput+0x48f/0x8c0
 dentry_unlink_inode+0x31f/0x4d0
 __dentry_kill+0x292/0x5e0
 dput+0x730/0x830
 __fput+0x438/0x720
 ____fput+0x1a/0x20
 task_work_run+0xfe/0x180
 exit_to_usermode_loop+0x133/0x150
 syscall_return_slowpath+0x184/0x1c0
 entry_SYSCALL_64_fastpath+0xab/0xad

To reproduce:

mmap(0, 0x2000, 0, 0x40031, 0xffffffffffffffffULL, 0x8000000000000000ULL);

Curiously enough, it's the patch from this thread (i.e. commit
ff8c0c53c47530ffea82c22a0a6df6332b56c957) that introduces it,
according to git bisect. Reverting the commit from linus/master fixes
the problem.

Also found by syzcaller (no fault injections this time).


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
