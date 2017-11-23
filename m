Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 076C26B0069
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:56:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c83so17282514pfj.11
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:56:01 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j25si17614689pfh.255.2017.11.23.07.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 07:56:00 -0800 (PST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 215FA219A0
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 15:56:00 +0000 (UTC)
Received: by mail-it0-f41.google.com with SMTP id 187so8812278iti.5
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:56:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ecccf06a-5791-f105-c080-01af351c0bc4@linux.intel.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com> <20171123003459.C0FF167A@viggo.jf.intel.com>
 <CALCETrWM7OytAXOP9Jb1Ss0=75bGB-XSCLounC2z7xauG6CABQ@mail.gmail.com> <ecccf06a-5791-f105-c080-01af351c0bc4@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 23 Nov 2017 07:55:38 -0800
Message-ID: <CALCETrW+4eZ9fq0=8P+QTg+AYP1aLAFQhQ8S=iGzV8ZCCWH2uA@mail.gmail.com>
Subject: Re: [PATCH 11/23] x86, kaiser: map entry stack variables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, Nov 23, 2017 at 7:37 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 11/22/2017 07:31 PM, Andy Lutomirski wrote:
>> On Wed, Nov 22, 2017 at 4:34 PM, Dave Hansen
>> <dave.hansen@linux.intel.com> wrote:
>>>
>>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>>
>>> There are times where the kernel is entered but there is not a
>>> safe stack, like at SYSCALL entry.  To obtain a safe stack, the
>>> per-cpu variables 'rsp_scratch' and 'cpu_current_top_of_stack'
>>> are used to save the old %rsp value and to find where the kernel
>>> stack should start.
>>>
>>> You can not directly manipulate the CR3 register.  You can only
>>> 'MOV' to it from another register, which means a register must be
>>> clobbered in order to do any CR3 manipulation.  User-mapping
>>> these variables allows us to obtain a safe stack and use it for
>>> temporary storage *before* CR3 is switched.
>>>
>>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>>> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
>>> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
>>> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
>>> Cc: Richard Fellner <richard.fellner@student.tugraz.at>
>>> Cc: Andy Lutomirski <luto@kernel.org>
>>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>>> Cc: Kees Cook <keescook@google.com>
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Cc: x86@kernel.org
>>> ---
>>>
>>>  b/arch/x86/kernel/cpu/common.c |    2 +-
>>>  b/arch/x86/kernel/process_64.c |    2 +-
>>>  2 files changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff -puN arch/x86/kernel/cpu/common.c~kaiser-user-map-stack-helper-vars arch/x86/kernel/cpu/common.c
>>> --- a/arch/x86/kernel/cpu/common.c~kaiser-user-map-stack-helper-vars    2017-11-22 15:45:50.128619736 -0800
>>> +++ b/arch/x86/kernel/cpu/common.c      2017-11-22 15:45:50.134619736 -0800
>>> @@ -1524,7 +1524,7 @@ EXPORT_PER_CPU_SYMBOL(__preempt_count);
>>>   * the top of the kernel stack.  Use an extra percpu variable to track the
>>>   * top of the kernel stack directly.
>>>   */
>>> -DEFINE_PER_CPU(unsigned long, cpu_current_top_of_stack) =
>>> +DEFINE_PER_CPU_USER_MAPPED(unsigned long, cpu_current_top_of_stack) =
>>>         (unsigned long)&init_thread_union + THREAD_SIZE;
>>
>> This is in an x86_32-only section and should be dropped, I think.
>
> It's used in entry_SYSCALL_64 (see below).  But I do think it's safe to
> drop now.  We switch before we use it.
>
>>> diff -puN arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars arch/x86/kernel/process_64.c
>>> --- a/arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars    2017-11-22 15:45:50.130619736 -0800
>>> +++ b/arch/x86/kernel/process_64.c      2017-11-22 15:45:50.134619736 -0800
>>> @@ -59,7 +59,7 @@
>>>  #include <asm/unistd_32_ia32.h>
>>>  #endif
>>>
>>> -__visible DEFINE_PER_CPU(unsigned long, rsp_scratch);
>>> +__visible DEFINE_PER_CPU_USER_MAPPED(unsigned long, rsp_scratch);
>>>
>> This shouldn't be needed any more either.
>
> What about this hunk?  It touches rsp_scratch before switching:
>
> @@ -207,9 +210,16 @@ ENTRY(entry_SYSCALL_64)
>
>         swapgs
>         movq    %rsp, PER_CPU_VAR(rsp_scratch)
> -       movq    PER_CPU_VAR(cpu_current_top_of_stack), %rsp
>
> -       TRACE_IRQS_OFF
> +       /*
> +        * The kernel CR3 is needed to map the process stack, but we
> +        * need a scratch register to be able to load CR3.  %rsp is
> +        * clobberable right now, so use it as a scratch register.
> +        * %rsp will be look crazy here for a couple instructions.
> +        */
> +       SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
> +
> +       movq    PER_CPU_VAR(cpu_current_top_of_stack), %rsp
>
>

I'm surprised that boots, since that hunk won't execute at all.  I
think you should move that code into the trampoline.  (Check my latest
tree -- I think it's a bit off in Ingo's tree.)  I've effectively
split SYSCALL64 into two separate paths: entry_SYSCALL_64 (with stack
switching off) and entry_SYSCALL_64_trampoline (with stack switching
on).  The entire point of the trampoline was to get a way to access
some data that varies per cpu without needing access to traditional
%gs-based percpu data.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
