Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76CF56B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 05:51:38 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 190so158056873iow.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 02:51:38 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0099.outbound.protection.outlook.com. [104.47.0.99])
        by mx.google.com with ESMTPS id e1si1812196oex.95.2016.05.19.02.51.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 May 2016 02:51:37 -0700 (PDT)
Subject: Re: [PATCHv9 0/2] mremap vDSO for 32-bit
References: <1463487232-4377-1-git-send-email-dsafonov@virtuozzo.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <e1637788-6060-cbe4-1411-ccdb42ba38b8@virtuozzo.com>
Date: Thu, 19 May 2016 12:50:20 +0300
MIME-Version: 1.0
In-Reply-To: <1463487232-4377-1-git-send-email-dsafonov@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: luto@amacapital.net, tglx@linutronix.de, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com

On 05/17/2016 03:13 PM, Dmitry Safonov wrote:
> The first patch adds support of mremapping 32-bit vDSO.
> One could move vDSO vma before this patch, but fast syscalls
> on moved vDSO hasn't been working. It's because of code that
> relies on mm->context.vdso pointer.
> So all this code is just fixup for that pointer on moving.
> (Also adds preventing for splitting vDSO vma).
> As Andy notted, 64-bit vDSO mremap also has worked only by a chance
> before this patches.
> The second patch adds a test for the new functionality.
>
> I need possibility to move vDSO in CRIU - on restore we need
> to choose vma's position:
> - if vDSO blob of restoring application is the same as the kernel has,
>   we need to move it on the same place;
> - if it differs, we need to choose place that wasn't tooken by other
>   vma of restoring application and than add jump trampolines to it
>   from the place of vDSO in restoring application.
>
> CRIU code now relies on possibility on x86_64 to mremap vDSO.
> Without this patch that may be broken in future.
> And as I work on C/R of compatible 32-bit applications on x86_64,
> I need mremap to work also for 32-bit vDSO. Which does not work,
> because of context.vdso pointer mentioned above.
>
> Changes:
> v9: Added cover-letter with changelog and reasons for patches
> v8: Add WARN_ON_ONCE on current->mm != new_vma->vm_mm;
>     run test for x86_64 too;
>     removed fixed VDSO_SIZE - check EINVAL mremap return for partial remapping
> v7: Build fix
> v6: Moved vdso_image_32 check and fixup code into vdso_fix_landing function
>     with ifdefs around
> v5: As Andy suggested, add a check that new_vma->vm_mm and current->mm are
>     the same, also check not only in_ia32_syscall() but image == &vdso_image_32;
>     added test for mremapping vDSO
> v4: Drop __maybe_unused & use image from mm->context instead vdso_image_32
> v3: As Andy suggested, return EINVAL in case of splitting vdso blob on mremap;
>     used is_ia32_task instead of ifdefs
> v2: Added __maybe_unused for pt_regs in vdso_mremap

Ping?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
