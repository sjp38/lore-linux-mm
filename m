Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 69B586B0389
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 02:42:30 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id d8so54691418uaa.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 23:42:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o185sor1289394vka.9.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Mar 2017 23:42:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170228154201.GH5816@redhat.com>
References: <CACT4Y+YgntApw9WMLZwF_ncF4JQdA2FNHDpzM+8hb_FpCuuC_g@mail.gmail.com>
 <20170228154201.GH5816@redhat.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 3 Mar 2017 08:42:08 +0100
Message-ID: <CACT4Y+Y5k0=6ZHC=eWanud+OE8VQYe9Nc0u6Xvnr9CkV2aEziA@mail.gmail.com>
Subject: Re: mm: fault in __do_fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, syzkaller <syzkaller@googlegroups.com>

On Tue, Feb 28, 2017 at 4:42 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hello Dmitry,
>
> On Tue, Feb 28, 2017 at 03:04:53PM +0100, Dmitry Vyukov wrote:
>> Hello,
>>
>> The following program triggers GPF in __do_fault:
>> https://gist.githubusercontent.com/dvyukov/27345737fca18d92ef761e7fa08aec9b/raw/d99d02511d0bf9a8d6f6bd9c79d373a26924e974/gistfile1.txt
>
> Can you verify this fix:


Applied the patch on bots.


> From a65381bc86d2963713b6a9c4a73cded7dd184282 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Tue, 28 Feb 2017 16:36:59 +0100
> Subject: [PATCH 1/1] userfaultfd: shmem: __do_fault requires VM_FAULT_NOPAGE
>
> __do_fault assumes vmf->page has been initialized and is valid if
> VM_FAULT_NOPAGE is not returned by vma->vm_ops->fault(vma, vmf).
>
> handle_userfault() in turn should return VM_FAULT_NOPAGE if it doesn't
> return VM_FAULT_SIGBUS or VM_FAULT_RETRY (the other two
> possibilities).
>
> This VM_FAULT_NOPAGE case is only invoked when signal are pending and
> it didn't matter for anonymous memory before. It only started to
> matter since shmem was introduced. hugetlbfs also takes a different
> path and doesn't exercise __do_fault.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  fs/userfaultfd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index fb6d02b..de28f43 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -500,7 +500,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
>                          * in such case.
>                          */
>                         down_read(&mm->mmap_sem);
> -                       ret = 0;
> +                       ret = VM_FAULT_NOPAGE;
>                 }
>         }
>
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
