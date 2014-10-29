Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 76D5590008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 13:14:50 -0400 (EDT)
Received: by mail-yk0-f172.google.com with SMTP id q9so1498527ykb.3
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 10:14:50 -0700 (PDT)
Received: from mail-yh0-x231.google.com (mail-yh0-x231.google.com. [2607:f8b0:4002:c01::231])
        by mx.google.com with ESMTPS id 33si4943878yho.106.2014.10.29.10.14.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 10:14:49 -0700 (PDT)
Received: by mail-yh0-f49.google.com with SMTP id t59so778548yho.36
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 10:14:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1414600520-7664-6-git-send-email-aarcange@redhat.com>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
	<1414600520-7664-6-git-send-email-aarcange@redhat.com>
Date: Wed, 29 Oct 2014 10:14:49 -0700
Message-ID: <CAJu=L5_kp51ik5ptMe4dRuJHpM269YsPOx97LSS0M61+b3i4=Q@mail.gmail.com>
Subject: Re: [PATCH 5/5] mm: gup: kvm use get_user_pages_unlocked
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\Dr. David Alan Gilbert\\" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Wed Oct 29 2014 at 9:35:34 AM Andrea Arcangeli <aarcange@redhat.com> wrote:
>
> Use the more generic get_user_pages_unlocked which has the additional
> benefit of passing FAULT_FLAG_ALLOW_RETRY at the very first page fault
> (which allows the first page fault in an unmapped area to be always
> able to block indefinitely by being allowed to release the mmap_sem).
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/kvm_host.h | 11 -----------
>  virt/kvm/async_pf.c      |  2 +-
>  virt/kvm/kvm_main.c      | 50 ++++--------------------------------------------
>  3 files changed, 5 insertions(+), 58 deletions(-)
>
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index ea53b04..82c67da 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -199,17 +199,6 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, unsigned long hva,
>  int kvm_async_pf_wakeup_all(struct kvm_vcpu *vcpu);
>  #endif
>
> -/*
> - * Carry out a gup that requires IO. Allow the mm to relinquish the mmap
> - * semaphore if the filemap/swap has to wait on a page lock. pagep == NULL
> - * controls whether we retry the gup one more time to completion in that case.
> - * Typically this is called after a FAULT_FLAG_RETRY_NOWAIT in the main tdp
> - * handler.
> - */
> -int kvm_get_user_page_io(struct task_struct *tsk, struct mm_struct *mm,
> -                        unsigned long addr, bool write_fault,
> -                        struct page **pagep);
> -
>  enum {
>         OUTSIDE_GUEST_MODE,
>         IN_GUEST_MODE,
> diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
> index 5ff7f7f..44660ae 100644
> --- a/virt/kvm/async_pf.c
> +++ b/virt/kvm/async_pf.c
> @@ -80,7 +80,7 @@ static void async_pf_execute(struct work_struct *work)
>
>         might_sleep();
>
> -       kvm_get_user_page_io(NULL, mm, addr, 1, NULL);
> +       get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL);
>         kvm_async_page_present_sync(vcpu, apf);
>
>         spin_lock(&vcpu->async_pf.lock);
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 25ffac9..78236ad 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -1134,43 +1134,6 @@ static int get_user_page_nowait(struct task_struct *tsk, struct mm_struct *mm,
>         return __get_user_pages(tsk, mm, start, 1, flags, page, NULL, NULL);
>  }
>
> -int kvm_get_user_page_io(struct task_struct *tsk, struct mm_struct *mm,
> -                        unsigned long addr, bool write_fault,
> -                        struct page **pagep)
> -{
> -       int npages;
> -       int locked = 1;
> -       int flags = FOLL_TOUCH | FOLL_HWPOISON |
> -                   (pagep ? FOLL_GET : 0) |
> -                   (write_fault ? FOLL_WRITE : 0);
> -
> -       /*
> -        * If retrying the fault, we get here *not* having allowed the filemap
> -        * to wait on the page lock. We should now allow waiting on the IO with
> -        * the mmap semaphore released.
> -        */
> -       down_read(&mm->mmap_sem);
> -       npages = __get_user_pages(tsk, mm, addr, 1, flags, pagep, NULL,
> -                                 &locked);
> -       if (!locked) {
> -               VM_BUG_ON(npages);
> -
> -               if (!pagep)
> -                       return 0;
> -
> -               /*
> -                * The previous call has now waited on the IO. Now we can
> -                * retry and complete. Pass TRIED to ensure we do not re
> -                * schedule async IO (see e.g. filemap_fault).
> -                */
> -               down_read(&mm->mmap_sem);
> -               npages = __get_user_pages(tsk, mm, addr, 1, flags | FOLL_TRIED,
> -                                         pagep, NULL, NULL);
> -       }
> -       up_read(&mm->mmap_sem);
> -       return npages;
> -}
> -
>  static inline int check_user_page_hwpoison(unsigned long addr)
>  {
>         int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
> @@ -1233,15 +1196,10 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
>                 npages = get_user_page_nowait(current, current->mm,
>                                               addr, write_fault, page);
>                 up_read(&current->mm->mmap_sem);
> -       } else {
> -               /*
> -                * By now we have tried gup_fast, and possibly async_pf, and we
> -                * are certainly not atomic. Time to retry the gup, allowing
> -                * mmap semaphore to be relinquished in the case of IO.
> -                */
> -               npages = kvm_get_user_page_io(current, current->mm, addr,
> -                                             write_fault, page);
> -       }
> +       } else

Braces here, per coding style.

Other than that:
Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>

>
> +               npages = __get_user_pages_unlocked(current, current->mm, addr, 1,
> +                                                  write_fault, 0, page,
> +                                                  FOLL_TOUCH|FOLL_HWPOISON);
>         if (npages != 1)
>                 return npages;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
