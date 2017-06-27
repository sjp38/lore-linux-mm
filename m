Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1B536B02FA
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 19:13:10 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g86so29156773iod.14
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:13:10 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id 82si476372ioq.48.2017.06.27.16.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 16:13:09 -0700 (PDT)
Received: by mail-io0-x22d.google.com with SMTP id h64so26591515iod.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 16:13:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1497544976-7856-8-git-send-email-s.mesoraca16@gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com> <1497544976-7856-8-git-send-email-s.mesoraca16@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 27 Jun 2017 16:13:08 -0700
Message-ID: <CAGXu5jJ+GHJSgoHk3Vmf=JueVgwkP6ZSVm5kkMbCGBySp2VqmA@mail.gmail.com>
Subject: Re: [RFC v2 7/9] Trampoline emulation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-security-module <linux-security-module@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Jun 15, 2017 at 9:42 AM, Salvatore Mesoraca
<s.mesoraca16@gmail.com> wrote:
> Some programs need to generate part of their code at runtime. Luckily
> enough, in some cases they only generate well-known code sequences (the
> "trampolines") that can be easily recognized and emulated by the kernel.
> This way WX Protection can still be active, so a potential attacker won't
> be able to generate arbitrary sequences of code, but just those that are
> explicitly allowed. This is not ideal, but it's still better than having WX
> Protection completely disabled.
> In particular S.A.R.A. is able to recognize trampolines used by GCC for
> nested C functions and libffi's trampolines.
> This feature is implemented only on x86_32 and x86_64.
> The assembly sequences used here were originally obtained from PaX source
> code.

See below about the language grsecurity has asked people to use in commit logs.

>
> Signed-off-by: Salvatore Mesoraca <s.mesoraca16@gmail.com>
> ---
>  security/sara/Kconfig               |  17 ++++
>  security/sara/include/trampolines.h | 171 ++++++++++++++++++++++++++++++++++++
>  security/sara/wxprot.c              | 140 +++++++++++++++++++++++++++++
>  3 files changed, 328 insertions(+)
>  create mode 100644 security/sara/include/trampolines.h
>
> diff --git a/security/sara/Kconfig b/security/sara/Kconfig
> index 6c74069..f406805 100644
> --- a/security/sara/Kconfig
> +++ b/security/sara/Kconfig
> @@ -96,6 +96,23 @@ choice
>                   Documentation/security/SARA.rst.
>  endchoice
>
> +config SECURITY_SARA_WXPROT_EMUTRAMP
> +       bool "Enable emulation for some types of trampolines"
> +       depends on SECURITY_SARA_WXPROT
> +       depends on X86
> +       default y
> +       help
> +         Some programs and libraries need to execute special small code
> +         snippets from non-executable memory pages.
> +         Most notable examples are the GCC and libffi trampolines.
> +         This features make it possible to execute those trampolines even
> +         if they reside in non-executable memory pages.
> +         This features need to be enabled on a per-executable basis
> +         via user-space utilities.
> +         See Documentation/security/SARA.rst. for further information.
> +
> +         If unsure, answer y.
> +
>  config SECURITY_SARA_WXPROT_DISABLED
>         bool "WX protection will be disabled at boot."
>         depends on SECURITY_SARA_WXPROT
> diff --git a/security/sara/include/trampolines.h b/security/sara/include/trampolines.h
> new file mode 100644
> index 0000000..eab0a85
> --- /dev/null
> +++ b/security/sara/include/trampolines.h
> @@ -0,0 +1,171 @@
> +/*
> + * S.A.R.A. Linux Security Module
> + *
> + * Copyright (C) 2017 Salvatore Mesoraca <s.mesoraca16@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2, as
> + * published by the Free Software Foundation.
> + *
> + * Assembly sequences used here were copied from
> + * PaX patch by PaX Team <pageexec@freemail.hu>

Given this copying, please include the grsecurity/PaX copyright notice
too. Please see the recommendations here:
http://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project/Get_Involved

> + *
> + */
> +
> +#ifndef __SARA_TRAMPOLINES_H
> +#define __SARA_TRAMPOLINES_H
> +#ifdef CONFIG_SECURITY_SARA_WXPROT_EMUTRAMP
> +
> +
> +/* x86_32 */
> +
> +
> +struct libffi_trampoline_x86_32 {
> +       unsigned char mov;
> +       unsigned int addr1;
> +       unsigned char jmp;
> +       unsigned int addr2;
> +} __packed;
> +
> +struct gcc_trampoline_x86_32_type1 {
> +       unsigned char mov1;
> +       unsigned int addr1;
> +       unsigned char mov2;
> +       unsigned int addr2;
> +       unsigned short jmp;
> +} __packed;
> +
> +struct gcc_trampoline_x86_32_type2 {
> +       unsigned char mov;
> +       unsigned int addr1;
> +       unsigned char jmp;
> +       unsigned int addr2;
> +} __packed;
> +
> +union trampolines_x86_32 {
> +       struct libffi_trampoline_x86_32 lf;
> +       struct gcc_trampoline_x86_32_type1 g1;
> +       struct gcc_trampoline_x86_32_type2 g2;
> +};
> +
> +#define is_valid_libffi_trampoline_x86_32(UNION)       \
> +       (UNION.lf.mov == 0xB8 &&                        \
> +       UNION.lf.jmp == 0xE9)
> +
> +#define emulate_libffi_trampoline_x86_32(UNION, REGS) do {     \
> +       (REGS)->ax = UNION.lf.addr1;                            \
> +       (REGS)->ip = (unsigned int) ((REGS)->ip +               \
> +                                    UNION.lf.addr2 +           \
> +                                    sizeof(UNION.lf));         \
> +} while (0)
> +
> +#define is_valid_gcc_trampoline_x86_32_type1(UNION, REGS)      \
> +       (UNION.g1.mov1 == 0xB9 &&                               \
> +       UNION.g1.mov2 == 0xB8 &&                                \
> +       UNION.g1.jmp == 0xE0FF &&                               \
> +       REGS->ip > REGS->sp)
> +
> +#define emulate_gcc_trampoline_x86_32_type1(UNION, REGS) do {  \
> +       (REGS)->cx = UNION.g1.addr1;                            \
> +       (REGS)->ax = UNION.g1.addr2;                            \
> +       (REGS)->ip = UNION.g1.addr2;                            \
> +} while (0)
> +
> +#define is_valid_gcc_trampoline_x86_32_type2(UNION, REGS)      \
> +       (UNION.g2.mov == 0xB9 &&                                \
> +       UNION.g2.jmp == 0xE9 &&                                 \
> +       REGS->ip > REGS->sp)
> +
> +#define emulate_gcc_trampoline_x86_32_type2(UNION, REGS) do {  \
> +       (REGS)->cx = UNION.g2.addr1;                            \
> +       (REGS)->ip = (unsigned int) ((REGS)->ip +               \
> +                                    UNION.g2.addr2 +           \
> +                                    sizeof(UNION.g2));         \
> +} while (0)

These all seem like they need to live in arch/x86/... somewhere rather
than in the LSM, but maybe this isn't needed on other architectures?
This seems to be very arch and compiler specific...

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
