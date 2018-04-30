Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3566B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 14:43:36 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l47-v6so4993199qtk.21
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 11:43:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i9sor4418698qkm.57.2018.04.30.11.43.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 11:43:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1523975611-15978-25-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com> <1523975611-15978-25-git-send-email-ldufour@linux.vnet.ibm.com>
From: Punit Agrawal <punitagrawal@gmail.com>
Date: Mon, 30 Apr 2018 19:43:13 +0100
Message-ID: <CAD4BONd5DZiKkGPGaYqEcVb+YubVDy43MNNQ8_yztDHWpf0Y7w@mail.gmail.com>
Subject: Re: [PATCH v10 24/25] x86/mm: add speculative pagefault handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi Laurent,

I am looking to add support for speculative page fault handling to
arm64 (effectively porting this patch) and had a few questions.
Apologies if I've missed an obvious explanation for my queries. I'm
jumping in bit late to the discussion.

On Tue, Apr 17, 2018 at 3:33 PM, Laurent Dufour
<ldufour@linux.vnet.ibm.com> wrote:
> From: Peter Zijlstra <peterz@infradead.org>
>
> Try a speculative fault before acquiring mmap_sem, if it returns with
> VM_FAULT_RETRY continue with the mmap_sem acquisition and do the
> traditional fault.
>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>
> [Clearing of FAULT_FLAG_ALLOW_RETRY is now done in
>  handle_speculative_fault()]
> [Retry with usual fault path in the case VM_ERROR is returned by
>  handle_speculative_fault(). This allows signal to be delivered]
> [Don't build SPF call if !CONFIG_SPECULATIVE_PAGE_FAULT]
> [Try speculative fault path only for multi threaded processes]
> [Try reuse to the VMA fetch during the speculative path in case of retry]
> [Call reuse_spf_or_find_vma()]
> [Handle memory protection key fault]
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  arch/x86/mm/fault.c | 42 ++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 38 insertions(+), 4 deletions(-)
>
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 73bd8c95ac71..59f778386df5 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1220,7 +1220,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>         struct mm_struct *mm;
>         int fault, major = 0;
>         unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> -       u32 pkey;
> +       u32 pkey, *pt_pkey = &pkey;
>
>         tsk = current;
>         mm = tsk->mm;
> @@ -1310,6 +1310,30 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>                 flags |= FAULT_FLAG_INSTRUCTION;
>
>         /*
> +        * Do not try speculative page fault for kernel's pages and if
> +        * the fault was due to protection keys since it can't be resolved.
> +        */
> +       if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT) &&
> +           !(error_code & X86_PF_PK)) {

You can simplify this condition by dropping the IS_ENABLED() check as
you already provide an alternate implementation of
handle_speculative_fault() when CONFIG_SPECULATIVE_PAGE_FAULT is not
defined.

> +               fault = handle_speculative_fault(mm, address, flags, &vma);
> +               if (fault != VM_FAULT_RETRY) {
> +                       perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, address);
> +                       /*
> +                        * Do not advertise for the pkey value since we don't
> +                        * know it.
> +                        * This is not a matter as we checked for X86_PF_PK
> +                        * earlier, so we should not handle pkey fault here,
> +                        * but to be sure that mm_fault_error() callees will
> +                        * not try to use it, we invalidate the pointer.
> +                        */
> +                       pt_pkey = NULL;
> +                       goto done;
> +               }
> +       } else {
> +               vma = NULL;
> +       }

The else part can be dropped if vma is initialised to NULL when it is
declared at the top of the function.

> +
> +       /*
>          * When running in the kernel we expect faults to occur only to
>          * addresses in user space.  All other faults represent errors in
>          * the kernel and should generate an OOPS.  Unfortunately, in the
> @@ -1342,7 +1366,8 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>                 might_sleep();
>         }
>
> -       vma = find_vma(mm, address);
> +       if (!vma || !can_reuse_spf_vma(vma, address))
> +               vma = find_vma(mm, address);

Is there a measurable benefit from reusing the vma?

Dropping the vma reference unconditionally after speculative page
fault handling gets rid of the implicit state when "vma != NULL"
(increased ref-count). I found it a bit confusing to follow.

>         if (unlikely(!vma)) {
>                 bad_area(regs, error_code, address);
>                 return;
> @@ -1409,8 +1434,15 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>                 if (flags & FAULT_FLAG_ALLOW_RETRY) {
>                         flags &= ~FAULT_FLAG_ALLOW_RETRY;
>                         flags |= FAULT_FLAG_TRIED;
> -                       if (!fatal_signal_pending(tsk))
> +                       if (!fatal_signal_pending(tsk)) {
> +                               /*
> +                                * Do not try to reuse this vma and fetch it
> +                                * again since we will release the mmap_sem.
> +                                */
> +                               if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT))
> +                                       vma = NULL;

Regardless of the above comment, can the vma be reset here unconditionally?

Thanks,
Punit
