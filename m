Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD35A6B0038
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:59:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m17so16235317pgu.19
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:59:22 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w70si13156001pfk.109.2017.12.12.09.59.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 09:59:21 -0800 (PST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DD136204EE
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 17:59:20 +0000 (UTC)
Received: by mail-it0-f53.google.com with SMTP id r6so363212itr.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:59:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171212173334.345422294@linutronix.de>
References: <20171212173221.496222173@linutronix.de> <20171212173334.345422294@linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 12 Dec 2017 09:58:58 -0800
Message-ID: <CALCETrWHQW19G2J2hCS4ZG_U5knG-0RBzruioQzojqWr6ceTBg@mail.gmail.com>
Subject: Re: [patch 13/16] x86/ldt: Introduce LDT write fault handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
>
> When the LDT is mapped RO, the CPU will write fault the first time it uses
> a segment descriptor in order to set the ACCESS bit (for some reason it
> doesn't always observe that it already preset). Catch the fault and set the
> ACCESS bit in the handler.
>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>  arch/x86/include/asm/mmu_context.h |    7 +++++++
>  arch/x86/kernel/ldt.c              |   30 ++++++++++++++++++++++++++++++
>  arch/x86/mm/fault.c                |   19 +++++++++++++++++++
>  3 files changed, 56 insertions(+)
>
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -76,6 +76,11 @@ static inline void init_new_context_ldt(
>  int ldt_dup_context(struct mm_struct *oldmm, struct mm_struct *mm);
>  void ldt_exit_user(struct pt_regs *regs);
>  void destroy_context_ldt(struct mm_struct *mm);
> +bool __ldt_write_fault(unsigned long address);
> +static inline bool ldt_is_active(struct mm_struct *mm)
> +{
> +       return mm && mm->context.ldt != NULL;
> +}
>  #else  /* CONFIG_MODIFY_LDT_SYSCALL */
>  static inline void init_new_context_ldt(struct task_struct *task,
>                                         struct mm_struct *mm) { }
> @@ -86,6 +91,8 @@ static inline int ldt_dup_context(struct
>  }
>  static inline void ldt_exit_user(struct pt_regs *regs) { }
>  static inline void destroy_context_ldt(struct mm_struct *mm) { }
> +static inline bool __ldt_write_fault(unsigned long address) { return false; }
> +static inline bool ldt_is_active(struct mm_struct *mm)  { return false; }
>  #endif
>
>  static inline void load_mm_ldt(struct mm_struct *mm, struct task_struct *tsk)
> --- a/arch/x86/kernel/ldt.c
> +++ b/arch/x86/kernel/ldt.c
> @@ -82,6 +82,36 @@ static void ldt_install_mm(struct mm_str
>         mutex_unlock(&mm->context.lock);
>  }
>
> +/*
> + * ldt_write_fault() already checked whether there is an ldt installed in
> + * __do_page_fault(), so it's safe to access it here because interrupts are
> + * disabled and any ipi which would change it is blocked until this
> + * returns.  The underlying page mapping cannot change as long as the ldt
> + * is the active one in the context.
> + *
> + * The fault error code is X86_PF_WRITE | X86_PF_PROT and checked in
> + * __do_page_fault() already. This happens when a segment is selected and
> + * the CPU tries to set the accessed bit in desc_struct.type because the
> + * LDT entries are mapped RO. Set it manually.
> + */
> +bool __ldt_write_fault(unsigned long address)
> +{
> +       struct ldt_struct *ldt = current->mm->context.ldt;
> +       unsigned long start, end, entry;
> +       struct desc_struct *desc;
> +
> +       start = (unsigned long) ldt->entries;
> +       end = start + ldt->nr_entries * LDT_ENTRY_SIZE;
> +
> +       if (address < start || address >= end)
> +               return false;
> +
> +       desc = (struct desc_struct *) ldt->entries;
> +       entry = (address - start) / LDT_ENTRY_SIZE;
> +       desc[entry].type |= 0x01;

You have another patch that unconditionally sets the accessed bit on
installation.  What gives?

Also, this patch is going to die a horrible death if IRET ever hits
this condition.  Or load gs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
