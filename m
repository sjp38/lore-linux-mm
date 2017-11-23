Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA196B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:37:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i123so19275810pgd.2
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:37:38 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t64si16033052pgc.697.2017.11.23.07.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 07:37:37 -0800 (PST)
Subject: Re: [PATCH 11/23] x86, kaiser: map entry stack variables
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003459.C0FF167A@viggo.jf.intel.com>
 <CALCETrWM7OytAXOP9Jb1Ss0=75bGB-XSCLounC2z7xauG6CABQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <ecccf06a-5791-f105-c080-01af351c0bc4@linux.intel.com>
Date: Thu, 23 Nov 2017 07:37:33 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrWM7OytAXOP9Jb1Ss0=75bGB-XSCLounC2z7xauG6CABQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/22/2017 07:31 PM, Andy Lutomirski wrote:
> On Wed, Nov 22, 2017 at 4:34 PM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>>
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>
>> There are times where the kernel is entered but there is not a
>> safe stack, like at SYSCALL entry.  To obtain a safe stack, the
>> per-cpu variables 'rsp_scratch' and 'cpu_current_top_of_stack'
>> are used to save the old %rsp value and to find where the kernel
>> stack should start.
>>
>> You can not directly manipulate the CR3 register.  You can only
>> 'MOV' to it from another register, which means a register must be
>> clobbered in order to do any CR3 manipulation.  User-mapping
>> these variables allows us to obtain a safe stack and use it for
>> temporary storage *before* CR3 is switched.
>>
>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
>> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
>> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
>> Cc: Richard Fellner <richard.fellner@student.tugraz.at>
>> Cc: Andy Lutomirski <luto@kernel.org>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> Cc: Kees Cook <keescook@google.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: x86@kernel.org
>> ---
>>
>>  b/arch/x86/kernel/cpu/common.c |    2 +-
>>  b/arch/x86/kernel/process_64.c |    2 +-
>>  2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff -puN arch/x86/kernel/cpu/common.c~kaiser-user-map-stack-helper-vars arch/x86/kernel/cpu/common.c
>> --- a/arch/x86/kernel/cpu/common.c~kaiser-user-map-stack-helper-vars    2017-11-22 15:45:50.128619736 -0800
>> +++ b/arch/x86/kernel/cpu/common.c      2017-11-22 15:45:50.134619736 -0800
>> @@ -1524,7 +1524,7 @@ EXPORT_PER_CPU_SYMBOL(__preempt_count);
>>   * the top of the kernel stack.  Use an extra percpu variable to track the
>>   * top of the kernel stack directly.
>>   */
>> -DEFINE_PER_CPU(unsigned long, cpu_current_top_of_stack) =
>> +DEFINE_PER_CPU_USER_MAPPED(unsigned long, cpu_current_top_of_stack) =
>>         (unsigned long)&init_thread_union + THREAD_SIZE;
> 
> This is in an x86_32-only section and should be dropped, I think.

It's used in entry_SYSCALL_64 (see below).  But I do think it's safe to
drop now.  We switch before we use it.

>> diff -puN arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars arch/x86/kernel/process_64.c
>> --- a/arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars    2017-11-22 15:45:50.130619736 -0800
>> +++ b/arch/x86/kernel/process_64.c      2017-11-22 15:45:50.134619736 -0800
>> @@ -59,7 +59,7 @@
>>  #include <asm/unistd_32_ia32.h>
>>  #endif
>>
>> -__visible DEFINE_PER_CPU(unsigned long, rsp_scratch);
>> +__visible DEFINE_PER_CPU_USER_MAPPED(unsigned long, rsp_scratch);
>>
> This shouldn't be needed any more either.

What about this hunk?  It touches rsp_scratch before switching:

@@ -207,9 +210,16 @@ ENTRY(entry_SYSCALL_64)

        swapgs
        movq    %rsp, PER_CPU_VAR(rsp_scratch)
-       movq    PER_CPU_VAR(cpu_current_top_of_stack), %rsp

-       TRACE_IRQS_OFF
+       /*
+        * The kernel CR3 is needed to map the process stack, but we
+        * need a scratch register to be able to load CR3.  %rsp is
+        * clobberable right now, so use it as a scratch register.
+        * %rsp will be look crazy here for a couple instructions.
+        */
+       SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
+
+       movq    PER_CPU_VAR(cpu_current_top_of_stack), %rsp


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
