Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 016036B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 10:29:25 -0400 (EDT)
Received: by qgev79 with SMTP id v79so70329651qge.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 07:29:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 89si2983490qku.59.2015.09.25.07.29.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 07:29:24 -0700 (PDT)
Date: Fri, 25 Sep 2015 16:26:18 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Multiple potential races on vma->vm_flags
Message-ID: <20150925142618.GA16703@redhat.com>
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com> <55EC9221.4040603@oracle.com> <20150907114048.GA5016@node.dhcp.inet.fi> <55F0D5B2.2090205@oracle.com> <20150910083605.GB9526@node.dhcp.inet.fi> <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com> <20150911103959.GA7976@node.dhcp.inet.fi> <alpine.LSU.2.11.1509111734480.7660@eggly.anvils> <55F8572D.8010409@oracle.com> <560319E4.2060808@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560319E4.2060808@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrey Konovalov <andreyknvl@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On 09/23, Sasha Levin wrote:
>
> Another similar trace where we see a problem during process exit:
>
> [1922964.887922] kasan: GPF could be caused by NULL-ptr deref or user memory accessgeneral protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
> [1922964.890234] Modules linked in:
> [1922964.890844] CPU: 1 PID: 21477 Comm: trinity-c161 Tainted: G        W       4.3.0-rc2-next-20150923-sasha-00079-gec04207-dirty #2569
> [1922964.892584] task: ffff880251858000 ti: ffff88009f258000 task.ti: ffff88009f258000
> [1922964.893723] RIP: acct_collect (kernel/acct.c:542)

   530  void acct_collect(long exitcode, int group_dead)
   531  {
   532          struct pacct_struct *pacct = &current->signal->pacct;
   533          cputime_t utime, stime;
   534          unsigned long vsize = 0;
   535
   536          if (group_dead && current->mm) {
   537                  struct vm_area_struct *vma;
   538
   539                  down_read(&current->mm->mmap_sem);
   540                  vma = current->mm->mmap;
   541                  while (vma) {
   542                          vsize += vma->vm_end - vma->vm_start; // !!!!!!!!!!!!
   543                          vma = vma->vm_next;
   544                  }
   545                  up_read(&current->mm->mmap_sem);
   546          }


> [1922964.895105] RSP: 0000:ffff88009f25f908  EFLAGS: 00010207
> [1922964.895935] RAX: dffffc0000000000 RBX: 2ce0ffffffffffff RCX: 0000000000000000
> [1922964.897008] RDX: ffff2152b153ffff RSI: 059c200000000000 RDI: 2ce1000000000007
> [1922964.898091] RBP: ffff88009f25f9e8 R08: 0000000000000001 R09: 00000000000003ef
> [1922964.899178] R10: ffffed014d7a3a01 R11: 0000000000000001 R12: ffff880082b485c0
> [1922964.901643] R13: ffff2152b153ffff R14: 1ffff10013e4bf24 R15: ffff88009f25f9c0
...
>    0:   02 00                   add    (%rax),%al
>    2:   0f 85 9d 05 00 00       jne    0x5a5
>    8:   48 8b 1b                mov    (%rbx),%rbx
>    b:   48 85 db                test   %rbx,%rbx
>    e:   0f 84 7b 05 00 00       je     0x58f

Probably "mov (%rbx),%rbx" is "vma = mm->mmap",

>   14:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
>   1b:   fc ff df
>   1e:   31 d2                   xor    %edx,%edx
>   20:   48 8d 7b 08             lea    0x8(%rbx),%rdi

and this loads the addr of vma->vm_end for kasan,

>   24:   48 89 fe                mov    %rdi,%rsi
>   27:   48 c1 ee 03             shr    $0x3,%rsi
>   2b:*  80 3c 06 00             cmpb   $0x0,(%rsi,%rax,1)               <-- trapping instruction

which reporst the error. But in this case this is not NULL-deref,
note that $rbx = 2ce0ffffffffffff and this is below __PAGE_OFFSET
(but above TASK_SIZE_MAX). It seems it is not even canonical. In
any case this odd value can't be valid.

Again, looks like mm->mmap pointer was corrupted. Perhaps you can
re-test with the stupid patch below. But unlikely it will help. If
mm was freed we would probably see something else.

Oleg.
---

--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -672,6 +672,7 @@ struct mm_struct *mm_alloc(void)
 void __mmdrop(struct mm_struct *mm)
 {
 	BUG_ON(mm == &init_mm);
+	BUG_ON(atomic_read(&mm->mm_users));
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
