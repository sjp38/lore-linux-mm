Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E58428024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:37:31 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z12so10114883pgv.6
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:37:31 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v12si2443345pgo.67.2018.01.16.14.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 14:37:30 -0800 (PST)
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 94A7F217A3
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 22:37:29 +0000 (UTC)
Received: by mail-io0-f179.google.com with SMTP id b198so15926858iof.6
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:37:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1801162117330.2366@nanos>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-3-git-send-email-joro@8bytes.org> <alpine.DEB.2.20.1801162117330.2366@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 16 Jan 2018 14:37:08 -0800
Message-ID: <CALCETrVaaGywcHoZ=QCYCLKrkiH2sN9T7dX+=m-iPZKp3pSXWg@mail.gmail.com>
Subject: Re: [PATCH 02/16] x86/entry/32: Enter the kernel via trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Joerg Roedel <joro@8bytes.org>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 12:30 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Tue, 16 Jan 2018, Joerg Roedel wrote:
>> @@ -89,13 +89,9 @@ static inline void refresh_sysenter_cs(struct thread_struct *thread)
>>  /* This is used when switching tasks or entering/exiting vm86 mode. */
>>  static inline void update_sp0(struct task_struct *task)
>>  {
>> -     /* On x86_64, sp0 always points to the entry trampoline stack, which is constant: */
>> -#ifdef CONFIG_X86_32
>> -     load_sp0(task->thread.sp0);
>> -#else
>> +     /* sp0 always points to the entry trampoline stack, which is constant: */
>>       if (static_cpu_has(X86_FEATURE_XENPV))
>>               load_sp0(task_top_of_stack(task));
>> -#endif
>>  }
>>
>>  #endif /* _ASM_X86_SWITCH_TO_H */
>> diff --git a/arch/x86/kernel/asm-offsets_32.c b/arch/x86/kernel/asm-offsets_32.c
>> index 654229bac2fc..7270dd834f4b 100644
>> --- a/arch/x86/kernel/asm-offsets_32.c
>> +++ b/arch/x86/kernel/asm-offsets_32.c
>> @@ -47,9 +47,11 @@ void foo(void)
>>       BLANK();
>>
>>       /* Offset from the sysenter stack to tss.sp0 */
>> -     DEFINE(TSS_sysenter_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
>> +     DEFINE(TSS_sysenter_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp1) -
>>              offsetofend(struct cpu_entry_area, entry_stack_page.stack));

I was going to say that this is just too magical.  The convention is
that STRUCT_member refers to "member" of "STRUCT".  Here you're
encoding a more complicated calculation.  How about putting just the
needed offsets in asm_offsets and putting the actual calculation in
the asm code or a header.

>>
>> +     OFFSET(TSS_sp1, tss_struct, x86_tss.sp1);

This belongs in asm_offsets.c.  Just move the asm_offsets_64.c version
there and call it a day.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
