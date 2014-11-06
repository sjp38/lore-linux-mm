Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 34CBF6B00BF
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 15:08:16 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x13so2095708wgg.19
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 12:08:15 -0800 (PST)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id w17si11379823wju.30.2014.11.06.12.08.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 12:08:15 -0800 (PST)
Received: by mail-wg0-f45.google.com with SMTP id x12so2130738wgg.18
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 12:08:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1412356087-16115-8-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
	<1412356087-16115-8-git-send-email-aarcange@redhat.com>
Date: Fri, 7 Nov 2014 00:08:13 +0400
Message-ID: <CALYGNiNWbAadvVzScWsgsdG5bGWir4q8oOWqbDg47C2+kk3=Mw@mail.gmail.com>
Subject: Re: [PATCH 07/17] mm: madvise MADV_USERFAULT: prepare vm_flags to
 allow more than 32bits
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-api@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\Dr. David Alan Gilbert\\" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

On Fri, Oct 3, 2014 at 9:07 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> We run out of 32bits in vm_flags, noop change for 64bit archs.

What? Again?
As I see there are some free bits: 0x200, 0x1000, 0x80000

I prefer to reserve 0x02000000 for VM_ARCH_2

>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  fs/proc/task_mmu.c       | 4 ++--
>  include/linux/huge_mm.h  | 4 ++--
>  include/linux/ksm.h      | 4 ++--
>  include/linux/mm_types.h | 2 +-
>  mm/huge_memory.c         | 2 +-
>  mm/ksm.c                 | 2 +-
>  mm/madvise.c             | 2 +-
>  mm/mremap.c              | 2 +-
>  8 files changed, 11 insertions(+), 11 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index c341568..ee1c3a2 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -532,11 +532,11 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
>         /*
>          * Don't forget to update Documentation/ on changes.
>          */
> -       static const char mnemonics[BITS_PER_LONG][2] = {
> +       static const char mnemonics[BITS_PER_LONG+1][2] = {
>                 /*
>                  * In case if we meet a flag we don't know about.
>                  */
> -               [0 ... (BITS_PER_LONG-1)] = "??",
> +               [0 ... (BITS_PER_LONG)] = "??",
>
>                 [ilog2(VM_READ)]        = "rd",
>                 [ilog2(VM_WRITE)]       = "wr",
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 63579cb..3aa10e0 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -121,7 +121,7 @@ extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
>  #error "hugepages can't be allocated by the buddy allocator"
>  #endif
>  extern int hugepage_madvise(struct vm_area_struct *vma,
> -                           unsigned long *vm_flags, int advice);
> +                           vm_flags_t *vm_flags, int advice);
>  extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
>                                     unsigned long start,
>                                     unsigned long end,
> @@ -183,7 +183,7 @@ static inline int split_huge_page(struct page *page)
>  #define split_huge_page_pmd_mm(__mm, __address, __pmd) \
>         do { } while (0)
>  static inline int hugepage_madvise(struct vm_area_struct *vma,
> -                                  unsigned long *vm_flags, int advice)
> +                                  vm_flags_t *vm_flags, int advice)
>  {
>         BUG();
>         return 0;
> diff --git a/include/linux/ksm.h b/include/linux/ksm.h
> index 3be6bb1..8b35253 100644
> --- a/include/linux/ksm.h
> +++ b/include/linux/ksm.h
> @@ -18,7 +18,7 @@ struct mem_cgroup;
>
>  #ifdef CONFIG_KSM
>  int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
> -               unsigned long end, int advice, unsigned long *vm_flags);
> +               unsigned long end, int advice, vm_flags_t *vm_flags);
>  int __ksm_enter(struct mm_struct *mm);
>  void __ksm_exit(struct mm_struct *mm);
>
> @@ -94,7 +94,7 @@ static inline int PageKsm(struct page *page)
>
>  #ifdef CONFIG_MMU
>  static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
> -               unsigned long end, int advice, unsigned long *vm_flags)
> +               unsigned long end, int advice, vm_flags_t *vm_flags)
>  {
>         return 0;
>  }
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 6e0b286..2c876d1 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -217,7 +217,7 @@ struct page_frag {
>  #endif
>  };
>
> -typedef unsigned long __nocast vm_flags_t;
> +typedef unsigned long long __nocast vm_flags_t;
>
>  /*
>   * A region containing a mapping of a non-memory backed file under NOMMU
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index d9a21d06..e913a19 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1942,7 +1942,7 @@ out:
>  #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
>
>  int hugepage_madvise(struct vm_area_struct *vma,
> -                    unsigned long *vm_flags, int advice)
> +                    vm_flags_t *vm_flags, int advice)
>  {
>         switch (advice) {
>         case MADV_HUGEPAGE:
> diff --git a/mm/ksm.c b/mm/ksm.c
> index fb75902..faf319e 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1736,7 +1736,7 @@ static int ksm_scan_thread(void *nothing)
>  }
>
>  int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
> -               unsigned long end, int advice, unsigned long *vm_flags)
> +               unsigned long end, int advice, vm_flags_t *vm_flags)
>  {
>         struct mm_struct *mm = vma->vm_mm;
>         int err;
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 0938b30..d5aee71 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -49,7 +49,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
>         struct mm_struct *mm = vma->vm_mm;
>         int error = 0;
>         pgoff_t pgoff;
> -       unsigned long new_flags = vma->vm_flags;
> +       vm_flags_t new_flags = vma->vm_flags;
>
>         switch (behavior) {
>         case MADV_NORMAL:
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 05f1180..fa7db87 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -239,7 +239,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>  {
>         struct mm_struct *mm = vma->vm_mm;
>         struct vm_area_struct *new_vma;
> -       unsigned long vm_flags = vma->vm_flags;
> +       vm_flags_t vm_flags = vma->vm_flags;
>         unsigned long new_pgoff;
>         unsigned long moved_len;
>         unsigned long excess = 0;
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
