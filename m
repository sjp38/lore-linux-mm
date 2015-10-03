Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8F541680DC6
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 16:09:16 -0400 (EDT)
Received: by oixx17 with SMTP id x17so73709169oix.0
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 13:09:16 -0700 (PDT)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id c22si9167578oib.95.2015.10.03.13.09.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Oct 2015 13:09:15 -0700 (PDT)
Received: by obbbh8 with SMTP id bh8so104252572obb.0
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 13:09:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <COL130-W38E921DBAB9CFCFCC45F73B94A0@phx.gbl>
References: <COL130-W38E921DBAB9CFCFCC45F73B94A0@phx.gbl>
Date: Sat, 3 Oct 2015 22:09:15 +0200
Message-ID: <CAFLxGvyFeyV+kNoD5+4jzfid5dgkZP0uhhQ7Q7Dk-ObDJq4ByA@mail.gmail.com>
Subject: Re: [PATCH] mm/mmap.c: Remove redundant vma looping
From: Richard Weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "asha.levin@oracle.com" <asha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On Sat, Oct 3, 2015 at 9:38 PM, Chen Gang <xili_gchen_5257@hotmail.com> wrote:
> From 36dbcc145819655682f80efd49e72b01515b4e9a Mon Sep 17 00:00:00 2001
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> Date: Sun, 4 Oct 2015 03:22:41 +0800
> Subject: [PATCH] mm/mmap.c: Remove redundant vma looping
>
> vma->vm_file->f_mapping and vma->anon_vma are shared with the same vma
> looping, so merge them.
>
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  mm/mmap.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 8393580..f7c1631 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3201,9 +3201,7 @@ int mm_take_all_locks(struct mm_struct *mm)
>                         goto out_unlock;
>                 if (vma->vm_file && vma->vm_file->f_mapping)
>                         vm_lock_mapping(mm, vma->vm_file->f_mapping);
> -       }
>
> -       for (vma = mm->mmap; vma; vma = vma->vm_next) {
>                 if (signal_pending(current))
>                         goto out_unlock;
>                 if (vma->anon_vma)

With that change you're reintroducing an issue.
Please see:
commit 7cd5a02f54f4c9d16cf7fdffa2122bc73bb09b43
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Mon Aug 11 09:30:25 2008 +0200

    mm: fix mm_take_all_locks() locking order

    Lockdep spotted:

    =======================================================
    [ INFO: possible circular locking dependency detected ]
    2.6.27-rc1 #270
    -------------------------------------------------------
    qemu-kvm/2033 is trying to acquire lock:
     (&inode->i_data.i_mmap_lock){----}, at: [<ffffffff802996cc>]
mm_take_all_locks+0xc2/0xea

    but task is already holding lock:
     (&anon_vma->lock){----}, at: [<ffffffff8029967a>]
mm_take_all_locks+0x70/0xea

    which lock already depends on the new lock.


git blame often explains funky code. :-)

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
