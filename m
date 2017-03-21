Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 572266B0378
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 13:31:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o126so324744796pfb.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:31:41 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30132.outbound.protection.outlook.com. [40.107.3.132])
        by mx.google.com with ESMTPS id q4si22037506plb.147.2017.03.21.10.31.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 10:31:40 -0700 (PDT)
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <43DEF3C4-B248-4720-8088-415C043B74BF@zytor.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <588170c1-5188-d4da-b2db-8e335db98f48@virtuozzo.com>
Date: Tue, 21 Mar 2017 20:27:58 +0300
MIME-Version: 1.0
In-Reply-To: <43DEF3C4-B248-4720-8088-415C043B74BF@zytor.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On 03/21/2017 08:27 PM, hpa@zytor.com wrote:
> On March 21, 2017 9:37:12 AM PDT, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> After my changes to mmap(), its code now relies on the bitness of
>> performing syscall. According to that, it chooses the base of
>> allocation:
>> mmap_base for 64-bit mmap() and mmap_compat_base for 32-bit syscall.
>> It was done by:
>>  commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
>> 32-bit mmap()").
>>
>> The code afterwards relies on in_compat_syscall() returning true for
>> 32-bit syscalls. It's usually so while we're in context of application
>> that does 32-bit syscalls. But during exec() it is not valid for x32
>> ELF.
>> The reason is that the application hasn't yet done any syscall, so x32
>> bit has not being set.
>> That results in -ENOMEM for x32 ELF files as there fired BAD_ADDR()
>> in elf_map(), that is called from do_execve()->load_elf_binary().
>> For i386 ELFs it works as SET_PERSONALITY() sets TS_COMPAT flag.
>>
>> I suggest to set x32 bit before first return to userspace, during
>> setting personality at exec(). This way we can rely on
>> in_compat_syscall() during exec().
>>
>> Fixes: commit 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for
>> 32-bit mmap()")
>> Cc: 0x7f454c46@gmail.com
>> Cc: linux-mm@kvack.org
>> Cc: Andrei Vagin <avagin@gmail.com>
>> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
>> Cc: Borislav Petkov <bp@suse.de>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: x86@kernel.org
>> Cc: H. Peter Anvin <hpa@zytor.com>
>> Cc: Andy Lutomirski <luto@kernel.org>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Reported-by: Adam Borowski <kilobyte@angband.pl>
>> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
>> ---
>> v2:
>> - specifying mmap() allocation path which failed during exec()
>> - fix comment style
>>
>> arch/x86/kernel/process_64.c | 10 ++++++++--
>> 1 file changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/kernel/process_64.c
>> b/arch/x86/kernel/process_64.c
>> index d6b784a5520d..d3d4d9abcaf8 100644
>> --- a/arch/x86/kernel/process_64.c
>> +++ b/arch/x86/kernel/process_64.c
>> @@ -519,8 +519,14 @@ void set_personality_ia32(bool x32)
>> 		if (current->mm)
>> 			current->mm->context.ia32_compat = TIF_X32;
>> 		current->personality &= ~READ_IMPLIES_EXEC;
>> -		/* in_compat_syscall() uses the presence of the x32
>> -		   syscall bit flag to determine compat status */
>> +		/*
>> +		 * in_compat_syscall() uses the presence of the x32
>> +		 * syscall bit flag to determine compat status.
>> +		 * On the bitness of syscall relies x86 mmap() code,
>> +		 * so set x32 syscall bit right here to make
>> +		 * in_compat_syscall() work during exec().
>> +		 */
>> +		task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
>> 		current->thread.status &= ~TS_COMPAT;
>> 	} else {
>> 		set_thread_flag(TIF_IA32);
>
> You also need to clear the bit for an x32 -> x86-64 exec.  Otherwise it seems okay to me.

Oh, indeed!
Thanks for catching, I'll send v3 with it.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
