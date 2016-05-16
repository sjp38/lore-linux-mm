Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3DFB6B025E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 05:39:55 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id sq19so167138599igc.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 02:39:55 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0092.outbound.protection.outlook.com. [104.47.0.92])
        by mx.google.com with ESMTPS id v7si11240317obo.72.2016.05.16.02.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 May 2016 02:39:55 -0700 (PDT)
Subject: Re: [PATCHv8 resend 1/2] x86/vdso: add mremap hook to
 vm_special_mapping
References: <1462886951-23376-1-git-send-email-dsafonov@virtuozzo.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <79f9fe67-a343-43b8-0933-a79461900c1b@virtuozzo.com>
Date: Mon, 16 May 2016 12:38:37 +0300
MIME-Version: 1.0
In-Reply-To: <1462886951-23376-1-git-send-email-dsafonov@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: luto@amacapital.net, tglx@linutronix.de, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com

On 05/10/2016 04:29 PM, Dmitry Safonov wrote:
> Add possibility for userspace 32-bit applications to move
> vdso mapping. Previously, when userspace app called
> mremap for vdso, in return path it would land on previous
> address of vdso page, resulting in segmentation violation.
> Now it lands fine and returns to userspace with remapped vdso.
> This will also fix context.vdso pointer for 64-bit, which does not
> affect the user of vdso after mremap by now, but this may change.
>
> As suggested by Andy, return EINVAL for mremap that splits vdso image.
>
> Renamed and moved text_mapping structure declaration inside
> map_vdso, as it used only there and now it complement
> vvar_mapping variable.
>
> There is still problem for remapping vdso in glibc applications:
> linker relocates addresses for syscalls on vdso page, so
> you need to relink with the new addresses. Or the next syscall
> through glibc may fail:
>   Program received signal SIGSEGV, Segmentation fault.
>   #0  0xf7fd9b80 in __kernel_vsyscall ()
>   #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6
>
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
> Acked-by: Andy Lutomirski <luto@kernel.org>
> ---
> v8: add WARN_ON_ONCE on current->mm != new_vma->vm_mm
> v7: build fix
> v6: moved vdso_image_32 check and fixup code into vdso_fix_landing function
>     with ifdefs around
> v5: as Andy suggested, add a check that new_vma->vm_mm and current->mm are
>     the same, also check not only in_ia32_syscall() but image == &vdso_image_32
> v4: drop __maybe_unused & use image from mm->context instead vdso_image_32
> v3: as Andy suggested, return EINVAL in case of splitting vdso blob on mremap;
>     used is_ia32_task instead of ifdefs
> v2: added __maybe_unused for pt_regs in vdso_mremap

Ping?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
