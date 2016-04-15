Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEF46B007E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 04:47:24 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hb4so124080627pac.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 01:47:24 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0090.outbound.protection.outlook.com. [104.47.2.90])
        by mx.google.com with ESMTPS id p9si1354219paa.62.2016.04.15.01.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 01:47:23 -0700 (PDT)
Subject: Re: [PATCHv2] x86/vdso: add mremap hook to vm_special_mapping
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460651571-10545-1-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrUhDvdyJV53Am2sgefyMJmHs5u1voOM2N76Si7BTtJWaQ@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <5710AA59.1010001@virtuozzo.com>
Date: Fri, 15 Apr 2016 11:46:17 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrUhDvdyJV53Am2sgefyMJmHs5u1voOM2N76Si7BTtJWaQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>

On 04/15/2016 01:58 AM, Andy Lutomirski wrote:
> On Thu, Apr 14, 2016 at 9:32 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> Add possibility for userspace 32-bit applications to move
>> vdso mapping. Previously, when userspace app called
>> mremap for vdso, in return path it would land on previous
>> address of vdso page, resulting in segmentation violation.
>> Now it lands fine and returns to userspace with remapped vdso.
>> This will also fix context.vdso pointer for 64-bit, which does not
>> affect the user of vdso after mremap by now, but this may change.
>>
>> Renamed and moved text_mapping structure declaration inside
>> map_vdso, as it used only there and now it complement
>> vvar_mapping variable.
>>
>> There is still problem for remapping vdso in 32-bit glibc applications:
>> linker relocates addresses for syscalls on vdso page, so
>> you need to relink with the new addresses. Or the next syscall
>> through glibc may fail:
>>    Program received signal SIGSEGV, Segmentation fault.
>>    #0  0xf7fd9b80 in __kernel_vsyscall ()
>>    #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6
>>
>> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
>> ---
>> v2: added __maybe_unused for pt_regs in vdso_mremap
>>
>>   arch/x86/entry/vdso/vma.c | 33 ++++++++++++++++++++++++++++-----
>>   include/linux/mm_types.h  |  3 +++
>>   mm/mmap.c                 | 10 ++++++++++
>>   3 files changed, 41 insertions(+), 5 deletions(-)
>>
>> diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
>> index 10f704584922..7e261e2554c8 100644
>> --- a/arch/x86/entry/vdso/vma.c
>> +++ b/arch/x86/entry/vdso/vma.c
>> @@ -12,6 +12,7 @@
>>   #include <linux/random.h>
>>   #include <linux/elf.h>
>>   #include <linux/cpu.h>
>> +#include <linux/ptrace.h>
>>   #include <asm/pvclock.h>
>>   #include <asm/vgtod.h>
>>   #include <asm/proto.h>
>> @@ -98,10 +99,26 @@ static int vdso_fault(const struct vm_special_mapping *sm,
>>          return 0;
>>   }
>>
>> -static const struct vm_special_mapping text_mapping = {
>> -       .name = "[vdso]",
>> -       .fault = vdso_fault,
>> -};
>> +static int vdso_mremap(const struct vm_special_mapping *sm,
>> +                     struct vm_area_struct *new_vma)
>> +{
>> +       struct pt_regs __maybe_unused *regs = current_pt_regs();
>> +
>> +#if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
>> +       /* Fixing userspace landing - look at do_fast_syscall_32 */
>> +       if (regs->ip == (unsigned long)current->mm->context.vdso +
>> +                       vdso_image_32.sym_int80_landing_pad
>> +#ifdef CONFIG_IA32_EMULATION
>> +               && current_thread_info()->status & TS_COMPAT
>> +#endif
> Instead of ifdef, use the (grossly misnamed) is_ia32_task() helper for
> this, please.
Thanks, will do
>
>> +          )
>> +               regs->ip = new_vma->vm_start +
>> +                       vdso_image_32.sym_int80_landing_pad;
>> +#endif
>> +       new_vma->vm_mm->context.vdso = (void __user *)new_vma->vm_start;
> Can you arrange for the mremap call to fail if the old mapping gets
> split?  This might be as simple as confirming that the new mapping's
> length is what we expect it to be and, if it isn't, returning -EINVAL.
Sure.
>
> If anyone things that might break some existing application (which is
> quite unlikely), then we could allow mremap to succeed but skip the
> part where we change context.vdso and rip.
>
>> +
>> +       return 0;
>> +}
>>
>>   static int vvar_fault(const struct vm_special_mapping *sm,
>>                        struct vm_area_struct *vma, struct vm_fault *vmf)
>> @@ -162,6 +179,12 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
>>          struct vm_area_struct *vma;
>>          unsigned long addr, text_start;
>>          int ret = 0;
>> +
>> +       static const struct vm_special_mapping vdso_mapping = {
>> +               .name = "[vdso]",
>> +               .fault = vdso_fault,
>> +               .mremap = vdso_mremap,
>> +       };
> Why did you add this instead of modifying text_mapping?
I moved text_mapping inside map_vdso function, as it's used
only there. Then I thought that vdso_mapping is better
naming for it as it complement vvar_mapping (goes right after).
If it's necessary, I will preserve naming.
>
> --Andy


-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
