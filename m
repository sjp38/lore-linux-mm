Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 362136B0005
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 14:55:23 -0400 (EDT)
Received: by mail-vb0-f48.google.com with SMTP id fc21so1316770vbb.35
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 11:55:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1356050997-2688-5-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
	<1356050997-2688-5-git-send-email-walken@google.com>
Date: Sun, 10 Mar 2013 20:55:21 +0200
Message-ID: <CA+ydwtqD67m9_JLCNwvdP72rko93aTkVgC-aK4TacyyM5DoCTA@mail.gmail.com>
Subject: Re: [PATCH 4/9] mm: use mm_populate() for blocking remap_file_pages()
From: Tommi Rantala <tt.rantala@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

2012/12/21 Michel Lespinasse <walken@google.com>:
> Signed-off-by: Michel Lespinasse <walken@google.com>

Hello, this patch introduced the following bug, seen while fuzzing with trinity:

[  396.825414] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000050
[  396.826013] IP: [<ffffffff81176efb>] sys_remap_file_pages+0xbb/0x3e0
[  396.826013] PGD 61e65067 PUD 3fb4067 PMD 0
[  396.826013] Oops: 0000 [#8] SMP
[  396.826013] CPU 0
[  396.826013] Pid: 27553, comm: trinity-child53 Tainted: G      D W
 3.9.0-rc1+ #108 Bochs Bochs
[  396.826013] RIP: 0010:[<ffffffff81176efb>]  [<ffffffff81176efb>]
sys_remap_file_pages+0xbb/0x3e0
[  396.826013] RSP: 0018:ffff880071a23f08  EFLAGS: 00010246
[  396.826013] RAX: 0000000000000000 RBX: ffffffff00000000 RCX: 0000000000000001
[  396.826013] RDX: 0000000000000000 RSI: ffffffff00000000 RDI: ffff8800679657c0
[  396.826013] RBP: ffff880071a23f78 R08: 0000000000000002 R09: 0000000000000000
[  396.826013] R10: 0000000026dad294 R11: 0000000000000000 R12: 0000000000000000
[  396.826013] R13: ffff880067965870 R14: ffffffffffffffea R15: 0000000000000000
[  396.826013] FS:  00007f6691a57700(0000) GS:ffff88007f800000(0000)
knlGS:0000000000000000
[  396.826013] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  396.826013] CR2: 0000000000000050 CR3: 0000000068ab3000 CR4: 00000000000006f0
[  396.826013] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  396.826013] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  396.826013] Process trinity-child53 (pid: 27553, threadinfo
ffff880071a22000, task ffff88006a360000)
[  396.826013] Stack:
[  396.826013]  0000000000000000 ffffffff810f33b6 0000000000000035
0000000000000000
[  396.826013]  000000000000f000 0000000000000000 0000000026dad294
ffff8800679657c0
[  396.826013]  a80006367e000000 ffffffff00000000 00000000000006c0
00000000000000d8
[  396.826013] Call Trace:
[  396.826013]  [<ffffffff810f33b6>] ? trace_hardirqs_on_caller+0x16/0x1f0
[  396.826013]  [<ffffffff81faf169>] system_call_fastpath+0x16/0x1b
[  396.826013] Code: 43 e3 00 48 8b 45 a8 25 00 00 01 00 48 89 45 b8
48 8b 7d c8 48 89 de e8 74 9b 00 00 48 85 c0 49 89 c7 75 1c 49 c7 c6
ea ff ff ff <48> 8b 14 25 50 00 00 00 44 89 f0 e9 7f 02 00 00 0f 1f 44
00 00
[  396.826013] RIP  [<ffffffff81176efb>] sys_remap_file_pages+0xbb/0x3e0
[  396.826013]  RSP <ffff880071a23f08>
[  396.826013] CR2: 0000000000000050
[  396.876275] ---[ end trace 0444599b5c1ba02b ]---

> ---
>  mm/fremap.c |   22 ++++++----------------
>  1 files changed, 6 insertions(+), 16 deletions(-)
>
> diff --git a/mm/fremap.c b/mm/fremap.c
> index 2db886e31044..b42e32171530 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -129,6 +129,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
>         struct vm_area_struct *vma;
>         int err = -EINVAL;
>         int has_write_lock = 0;
> +       vm_flags_t vm_flags;
>
>         if (prot)
>                 return err;
> @@ -228,30 +229,16 @@ get_write_lock:
>                 /*
>                  * drop PG_Mlocked flag for over-mapped range
>                  */
> -               vm_flags_t saved_flags = vma->vm_flags;
>                 if (!has_write_lock)
>                         goto get_write_lock;
> +               vm_flags = vma->vm_flags;
>                 munlock_vma_pages_range(vma, start, start + size);
> -               vma->vm_flags = saved_flags;
> +               vma->vm_flags = vm_flags;
>         }
>
>         mmu_notifier_invalidate_range_start(mm, start, start + size);
>         err = vma->vm_ops->remap_pages(vma, start, size, pgoff);
>         mmu_notifier_invalidate_range_end(mm, start, start + size);
> -       if (!err) {
> -               if (vma->vm_flags & VM_LOCKED) {
> -                       /*
> -                        * might be mapping previously unmapped range of file
> -                        */
> -                       mlock_vma_pages_range(vma, start, start + size);
> -               } else if (!(flags & MAP_NONBLOCK)) {
> -                       if (unlikely(has_write_lock)) {
> -                               downgrade_write(&mm->mmap_sem);
> -                               has_write_lock = 0;
> -                       }
> -                       make_pages_present(start, start+size);
> -               }
> -       }
>
>         /*
>          * We can't clear VM_NONLINEAR because we'd have to do
> @@ -260,10 +247,13 @@ get_write_lock:
>          */
>
>  out:
> +       vm_flags = vma->vm_flags;

When find_vma() fails, vma is NULL here.

>         if (likely(!has_write_lock))
>                 up_read(&mm->mmap_sem);
>         else
>                 up_write(&mm->mmap_sem);
> +       if (!err && ((vm_flags & VM_LOCKED) || !(flags & MAP_NONBLOCK)))
> +               mm_populate(start, size);
>
>         return err;
>  }
> --
> 1.7.7.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
