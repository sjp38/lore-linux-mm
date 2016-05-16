Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id F17AC6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 07:15:21 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e63so352932826iod.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 04:15:21 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0124.outbound.protection.outlook.com. [157.55.234.124])
        by mx.google.com with ESMTPS id k90si3759102otc.107.2016.05.16.04.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 May 2016 04:15:21 -0700 (PDT)
Subject: Re: [PATCHv8 resend 1/2] x86/vdso: add mremap hook to
 vm_special_mapping
References: <1462886951-23376-1-git-send-email-dsafonov@virtuozzo.com>
 <79f9fe67-a343-43b8-0933-a79461900c1b@virtuozzo.com>
 <20160516105429.GA20440@gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <d7ae8fe4-2177-8dc0-6087-bb64d74907f9@virtuozzo.com>
Date: Mon, 16 May 2016 14:14:03 +0300
MIME-Version: 1.0
In-Reply-To: <20160516105429.GA20440@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, luto@amacapital.net, tglx@linutronix.de, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com

On 05/16/2016 01:54 PM, Ingo Molnar wrote:
>
> * Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>
>> On 05/10/2016 04:29 PM, Dmitry Safonov wrote:
>>> Add possibility for userspace 32-bit applications to move
>>> vdso mapping. Previously, when userspace app called
>>> mremap for vdso, in return path it would land on previous
>>> address of vdso page, resulting in segmentation violation.
>>> Now it lands fine and returns to userspace with remapped vdso.
>>> This will also fix context.vdso pointer for 64-bit, which does not
>>> affect the user of vdso after mremap by now, but this may change.
>>>
>>> As suggested by Andy, return EINVAL for mremap that splits vdso image.
>>>
>>> Renamed and moved text_mapping structure declaration inside
>>> map_vdso, as it used only there and now it complement
>>> vvar_mapping variable.
>>>
>>> There is still problem for remapping vdso in glibc applications:
>>> linker relocates addresses for syscalls on vdso page, so
>>> you need to relink with the new addresses. Or the next syscall
>>> through glibc may fail:
>>>  Program received signal SIGSEGV, Segmentation fault.
>>>  #0  0xf7fd9b80 in __kernel_vsyscall ()
>>>  #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6
>>>
>>> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
>>> Acked-by: Andy Lutomirski <luto@kernel.org>
>>> ---
>>> v8: add WARN_ON_ONCE on current->mm != new_vma->vm_mm
>>> v7: build fix
>>> v6: moved vdso_image_32 check and fixup code into vdso_fix_landing function
>>>    with ifdefs around
>>> v5: as Andy suggested, add a check that new_vma->vm_mm and current->mm are
>>>    the same, also check not only in_ia32_syscall() but image == &vdso_image_32
>>> v4: drop __maybe_unused & use image from mm->context instead vdso_image_32
>>> v3: as Andy suggested, return EINVAL in case of splitting vdso blob on mremap;
>>>    used is_ia32_task instead of ifdefs
>>> v2: added __maybe_unused for pt_regs in vdso_mremap
>>
>> Ping?
>
> There's no 0/2 boilerplate explaining the background of the changes - why do you
> want to mremap() the vDSO?

Thanks for the answer.

Well, one could move vdso vma before this patch, but doing fast
syscalls through it will not work because of code relying on
mm->context.vdso pointer.
So all this code is just fixup for that pointer on moving.
(Also adds preventing for splitting vdso vma).
As Andy notted, vDSO mremap for !i386 tasks also worked only by a chance
before this patch.

I need to move vdso vma in CRIU - on restore we need to choose it's
position:
- if vDSO blob of restoring application is the same as the kernel has,
we need to move it on the same place;
- if it differs, we need to choose place that wasn't tooken by other
vma of restoring application and add jump trampolines to it from the
place of vDSO in restoring application.
And CRIU code now relies on possibility on x86_64 to mremap vDSO.
Without this patch that may be broken in future.
And as I work on C/R of compatible 32-bit applications on x86_64,
I need this to work also for 32-bit vDSO. Which does not work,
because of pointer mentioned above.

Thanks,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
