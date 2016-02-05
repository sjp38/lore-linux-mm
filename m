Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B87ED4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 08:43:56 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id r129so27342273wmr.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 05:43:56 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id n187si44773945wmb.74.2016.02.05.05.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 05:43:55 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id g62so27837547wme.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 05:43:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1602042219460.22727@cbobk.fhfr.pm>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com>
 <alpine.LNX.2.00.1602042219460.22727@cbobk.fhfr.pm>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 5 Feb 2016 14:43:35 +0100
Message-ID: <CACT4Y+aBCt_pVK+SY9fRpRFU9KTVOChn_vs5pv_KFiUbkGCm4Q@mail.gmail.com>
Subject: Re: [PATCH] floppy: refactor open() flags handling (was Re: mm:
 uninterruptable tasks hanged on mmap_sem)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Thu, Feb 4, 2016 at 10:22 PM, Jiri Kosina <jikos@kernel.org> wrote:
> On Tue, 2 Feb 2016, Dmitry Vyukov wrote:
>
>> If the following program run in a parallel loop, eventually it leaves
>> hanged uninterruptable tasks on mmap_sem.
>>
>> [ 4074.740298] sysrq: SysRq : Show Locks Held
>> [ 4074.740780] Showing all locks held in the system:
>> ...
>> [ 4074.762133] 1 lock held by a.out/1276:
>> [ 4074.762427]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
>> __mm_populate+0x25c/0x350
>> [ 4074.763149] 1 lock held by a.out/1147:
>> [ 4074.763438]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816b3bbc>]
>> vm_mmap_pgoff+0x12c/0x1b0
>> [ 4074.764164] 1 lock held by a.out/1284:
>> [ 4074.764447]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
>> __mm_populate+0x25c/0x350
>> [ 4074.765287]
>>
>> They all look as follows:
>>
>> # cat /proc/1284/task/**/stack
>> [<ffffffff82c14d13>] call_rwsem_down_write_failed+0x13/0x20
>> [<ffffffff816b3bbc>] vm_mmap_pgoff+0x12c/0x1b0
>> [<ffffffff81700c58>] SyS_mmap_pgoff+0x208/0x580
>> [<ffffffff811aeeb6>] SyS_mmap+0x16/0x20
>> [<ffffffff86660276>] entry_SYSCALL_64_fastpath+0x16/0x7a
>> [<ffffffffffffffff>] 0xffffffffffffffff
>> [<ffffffff8164893e>] wait_on_page_bit+0x1de/0x210
>> [<ffffffff8165572b>] filemap_fault+0xfeb/0x14d0
>> [<ffffffff816e1972>] __do_fault+0x1b2/0x3e0
>> [<ffffffff816f080e>] handle_mm_fault+0x1b4e/0x49a0
>> [<ffffffff816ddae0>] __get_user_pages+0x2c0/0x11a0
>> [<ffffffff816df5a8>] populate_vma_page_range+0x198/0x230
>> [<ffffffff816df83b>] __mm_populate+0x1fb/0x350
>> [<ffffffff816f90c1>] do_mlock+0x291/0x360
>> [<ffffffff816f962b>] SyS_mlock2+0x4b/0x70
>> [<ffffffff86660276>] entry_SYSCALL_64_fastpath+0x16/0x7a
>> [<ffffffffffffffff>] 0xffffffffffffffff
>
> Dmitry,
>
> could you please feed the patch below (on top of the previous floppy fix)
> to your syzkaller machinery and test whether you are still able to
> reproduce the problem? It passess my local testing here.


Now that open exits early with EWOULDBLOCK, I guess the reproduced is
not doing anything particularly interesting. But FWIW it fixes the
crash for me :)




> Thanks!
>
>
>
>
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: [PATCH] floppy: refactor open() flags handling
>
> In case /dev/fdX is open with O_NDELAY / O_NONBLOCK, floppy_open() immediately
> succeeds, without performing any further media / controller preparations.
> That's "correct" wrt. the NODELAY flag, but is hardly correct wrt. the rest
> of the floppy driver, that is not really O_NONBLOCK ready, at all. Therefore
> it's not too surprising, that subsequent attempts to work with the
> filedescriptor produce bad results. Namely, syzkaller tool has been able
> to livelock mmap() on the returned fd to keep waiting on the page unlock
> bit forever.
>
> Fortunately, POSIX allows us to not support non-blocking behavior on fdX
> block device.
>
> Quite frankly, I'd have trouble defining what non-blocking behavior would
> be for floppies. Is waiting ages for the driver to actually succeed
> reading a sector blocking operation? Is waiting for drive motor to start
> blocking operation? How about in case of virtualized floppies?
>
> Given the fact that POSIX allows us to not support non-blocking behavior,
> and given the fact that such behavior would be difficult to define anyway,
> change the handling of FMODE_NDELAY in floppy_open() so that it returns
> EWOULDBLOCK.
>
> While at it, clean up a bit handling of !(mode & (FMODE_READ|FMODE_WRITE))
> case and return EINVAL instead of succeeding as well.
>
> Spotted by syzkaller tool.
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> NOT-YET-Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  drivers/block/floppy.c | 38 +++++++++++++++++++++++---------------
>  1 file changed, 23 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
> index b206115..50faf7f 100644
> --- a/drivers/block/floppy.c
> +++ b/drivers/block/floppy.c
> @@ -3663,6 +3663,15 @@ static int floppy_open(struct block_device *bdev, fmode_t mode)
>
>         opened_bdev[drive] = bdev;
>
> +       if (mode & FMODE_NDELAY) {
> +               res = -EWOULDBLOCK;
> +               goto out;
> +       }
> +       if (!(mode & (FMODE_READ|FMODE_WRITE))) {
> +               res = -EINVAL;
> +               goto out;
> +       }
> +
>         res = -ENXIO;
>
>         if (!floppy_track_buffer) {
> @@ -3706,21 +3715,20 @@ static int floppy_open(struct block_device *bdev, fmode_t mode)
>         if (UFDCS->rawcmd == 1)
>                 UFDCS->rawcmd = 2;
>
> -       if (!(mode & FMODE_NDELAY)) {
> -               if (mode & (FMODE_READ|FMODE_WRITE)) {
> -                       UDRS->last_checked = 0;
> -                       clear_bit(FD_OPEN_SHOULD_FAIL_BIT, &UDRS->flags);
> -                       check_disk_change(bdev);
> -                       if (test_bit(FD_DISK_CHANGED_BIT, &UDRS->flags))
> -                               goto out;
> -                       if (test_bit(FD_OPEN_SHOULD_FAIL_BIT, &UDRS->flags))
> -                               goto out;
> -               }
> -               res = -EROFS;
> -               if ((mode & FMODE_WRITE) &&
> -                   !test_bit(FD_DISK_WRITABLE_BIT, &UDRS->flags))
> -                       goto out;
> -       }
> +       UDRS->last_checked = 0;
> +       clear_bit(FD_OPEN_SHOULD_FAIL_BIT, &UDRS->flags);
> +       check_disk_change(bdev);
> +       if (test_bit(FD_DISK_CHANGED_BIT, &UDRS->flags))
> +               goto out;
> +       if (test_bit(FD_OPEN_SHOULD_FAIL_BIT, &UDRS->flags))
> +               goto out;
> +
> +       res = -EROFS;
> +
> +       if ((mode & FMODE_WRITE) &&
> +                       !test_bit(FD_DISK_WRITABLE_BIT, &UDRS->flags))
> +               goto out;
> +
>         mutex_unlock(&open_lock);
>         mutex_unlock(&floppy_mutex);
>         return 0;
>
> --
> Jiri Kosina
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
