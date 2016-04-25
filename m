Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id A80D16B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 17:39:51 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id fn8so228866787igb.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:39:51 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id w7si5456429obv.26.2016.04.25.14.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 14:39:51 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id k142so191232383oib.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 14:39:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1461584223-9418-2-git-send-email-dsafonov@virtuozzo.com>
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1461584223-9418-1-git-send-email-dsafonov@virtuozzo.com> <1461584223-9418-2-git-send-email-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 25 Apr 2016 14:39:31 -0700
Message-ID: <CALCETrUkwLbPeucD30WiCUOndMo7-5o3wZtNRdbxj27mP2+_Wg@mail.gmail.com>
Subject: Re: [PATCHv8 2/2] selftest/x86: add mremap vdso test
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org

On Mon, Apr 25, 2016 at 4:37 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Should print on success:
> [root@localhost ~]# ./test_mremap_vdso_32
>         AT_SYSINFO_EHDR is 0xf773f000
> [NOTE]  Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
> [OK]
> Or segfault if landing was bad (before patches):
> [root@localhost ~]# ./test_mremap_vdso_32
>         AT_SYSINFO_EHDR is 0xf774f000
> [NOTE]  Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
> Segmentation fault (core dumped)

Acked-by: Andy Lutomirski <luto@amacapital.net>

Ingo, can you apply this?

>
> Cc: Shuah Khan <shuahkh@osg.samsung.com>
> Cc: linux-kselftest@vger.kernel.org
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
> ---
> v8: run test for x86_64 too;
>     removed fixed VDSO_SIZE - check EINVAL mremap return for partial remapping
> v5: initial version
>
>  tools/testing/selftests/x86/Makefile           |  2 +-
>  tools/testing/selftests/x86/test_mremap_vdso.c | 99 ++++++++++++++++++++++++++
>  2 files changed, 100 insertions(+), 1 deletion(-)
>  create mode 100644 tools/testing/selftests/x86/test_mremap_vdso.c
>
> diff --git a/tools/testing/selftests/x86/Makefile b/tools/testing/selftests/x86/Makefile
> index b47ebd170690..ba865f2efcce 100644
> --- a/tools/testing/selftests/x86/Makefile
> +++ b/tools/testing/selftests/x86/Makefile
> @@ -5,7 +5,7 @@ include ../lib.mk
>  .PHONY: all all_32 all_64 warn_32bit_failure clean
>
>  TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs syscall_nt ptrace_syscall \
> -                       check_initial_reg_state sigreturn ldt_gdt iopl
> +                       check_initial_reg_state sigreturn ldt_gdt iopl test_mremap_vdso
>  TARGETS_C_32BIT_ONLY := entry_from_vm86 syscall_arg_fault test_syscall_vdso unwind_vdso \
>                         test_FCMOV test_FCOMI test_FISTTP \
>                         vdso_restorer
> diff --git a/tools/testing/selftests/x86/test_mremap_vdso.c b/tools/testing/selftests/x86/test_mremap_vdso.c
> new file mode 100644
> index 000000000000..831e2e0107d9
> --- /dev/null
> +++ b/tools/testing/selftests/x86/test_mremap_vdso.c
> @@ -0,0 +1,99 @@
> +/*
> + * 32-bit test to check vdso mremap.
> + *
> + * Copyright (c) 2016 Dmitry Safonov
> + * Suggested-by: Andrew Lutomirski
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + */
> +/*
> + * Can be built statically:
> + * gcc -Os -Wall -static -m32 test_mremap_vdso.c
> + */
> +#define _GNU_SOURCE
> +#include <stdio.h>
> +#include <errno.h>
> +#include <unistd.h>
> +#include <string.h>
> +
> +#include <sys/mman.h>
> +#include <sys/auxv.h>
> +#include <sys/syscall.h>
> +
> +#define PAGE_SIZE      4096
> +
> +static int try_to_remap(void *vdso_addr, unsigned long size)
> +{
> +       void *dest_addr, *new_addr;
> +
> +       dest_addr = mmap(0, size, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
> +       if (dest_addr == MAP_FAILED) {
> +               printf("[WARN]\tmmap failed (%d): %m\n", errno);
> +               return 0;
> +       }
> +
> +       printf("[NOTE]\tMoving vDSO: [%p, %#lx] -> [%p, %#lx]\n",
> +               vdso_addr, (unsigned long)vdso_addr + size,
> +               dest_addr, (unsigned long)dest_addr + size);
> +       fflush(stdout);
> +
> +       new_addr = mremap(vdso_addr, size, size,
> +                       MREMAP_FIXED|MREMAP_MAYMOVE, dest_addr);
> +       if ((unsigned long)new_addr == (unsigned long)-1) {
> +               munmap(dest_addr, size);
> +               if (errno == EINVAL) {
> +                       printf("[NOTE]\tvDSO partial move failed, will try with bigger size\n");
> +                       return -1; /* retry with larger */
> +               }
> +               printf("[FAIL]\tmremap failed (%d): %m\n", errno);
> +               return 1;
> +       }
> +
> +       return 0;
> +
> +}
> +
> +int main(int argc, char **argv, char **envp)
> +{
> +       unsigned long auxval;
> +       const char *ok_string = "[OK]\n";
> +       int ret = -1;
> +       unsigned long vdso_size = PAGE_SIZE;
> +
> +       auxval = getauxval(AT_SYSINFO_EHDR);
> +       printf("\tAT_SYSINFO_EHDR is %#lx\n", auxval);
> +       if (!auxval || auxval == -ENOENT) {
> +               printf("[WARN]\tgetauxval failed\n");
> +               return 0;
> +       }
> +
> +       /* simpler than parsing ELF header */
> +       while(ret < 0) {
> +               ret = try_to_remap((void *)auxval, vdso_size);
> +               vdso_size += PAGE_SIZE;
> +       }
> +
> +       if (!ret)
> +#if defined(__i386__)
> +               asm volatile ("int $0x80" : :
> +                       "a" (__NR_write), "b" (STDOUT_FILENO),
> +                       "c" (ok_string), "d" (strlen(ok_string)));
> +
> +       asm volatile ("int $0x80" : : "a" (__NR_exit), "b" (!!ret));
> +#else
> +               asm volatile ("syscall" : :
> +                       "a" (__NR_write), "D" (STDOUT_FILENO),
> +                       "S" (ok_string), "d" (strlen(ok_string)));
> +
> +       asm volatile ("syscall" : : "a" (__NR_exit), "D" (!!ret));
> +#endif
> +
> +       return 0;
> +}
> --
> 2.8.0
>



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
