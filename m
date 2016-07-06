Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5971D828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 10:04:12 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id e3so439699896qkd.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:04:12 -0700 (PDT)
Received: from mail-vk0-x22a.google.com (mail-vk0-x22a.google.com. [2607:f8b0:400c:c05::22a])
        by mx.google.com with ESMTPS id 31si909828uaw.127.2016.07.06.07.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 07:04:11 -0700 (PDT)
Received: by mail-vk0-x22a.google.com with SMTP id b192so6187050vke.0
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:04:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160628113539.13606-2-dsafonov@virtuozzo.com>
References: <20160628113539.13606-1-dsafonov@virtuozzo.com> <20160628113539.13606-2-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 6 Jul 2016 07:03:48 -0700
Message-ID: <CALCETrVMk35yej228NTMnP1Y2iHo=U54nTkzbiwO5ba-MQT7NQ@mail.gmail.com>
Subject: Re: [PATCHv10 1/2] x86/vdso: add mremap hook to vm_special_mapping
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Lutomirski <luto@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On Tue, Jun 28, 2016 at 4:35 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
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

Acked-by: Andy Lutomirski <luto@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
