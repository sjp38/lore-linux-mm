Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC5886B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 07:35:33 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m2so262752797ioa.3
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 04:35:33 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0107.outbound.protection.outlook.com. [157.56.112.107])
        by mx.google.com with ESMTPS id t59si2619145ota.67.2016.04.22.04.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Apr 2016 04:35:32 -0700 (PDT)
Subject: Re: [PATCHv5 3/3] selftest/x86: add mremap vdso 32-bit test
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460987025-30360-1-git-send-email-dsafonov@virtuozzo.com>
 <1460987025-30360-3-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrWQcokGjFb81wzfcOdHFDaHakwwwMFi5uF_5zeF6Hp9yw@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <571A0C3F.8090807@virtuozzo.com>
Date: Fri, 22 Apr 2016 14:34:23 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrWQcokGjFb81wzfcOdHFDaHakwwwMFi5uF_5zeF6Hp9yw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org

On 04/21/2016 11:01 PM, Andy Lutomirski wrote:
> On Mon, Apr 18, 2016 at 6:43 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> Should print on success:
>> [root@localhost ~]# ./test_mremap_vdso_32
>>          AT_SYSINFO_EHDR is 0xf773f000
>> [NOTE]  Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
>> [OK]
>> Or segfault if landing was bad (before patches):
>> [root@localhost ~]# ./test_mremap_vdso_32
>>          AT_SYSINFO_EHDR is 0xf774f000
>> [NOTE]  Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
>> Segmentation fault (core dumped)
>>
>> Cc: Shuah Khan <shuahkh@osg.samsung.com>
>> Cc: linux-kselftest@vger.kernel.org
>> Suggested-by: Andy Lutomirski <luto@kernel.org>
>> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
>> ---
>> v5: initial version
>>
>>   tools/testing/selftests/x86/Makefile           |  2 +-
>>   tools/testing/selftests/x86/test_mremap_vdso.c | 72 ++++++++++++++++++++++++++
>>   2 files changed, 73 insertions(+), 1 deletion(-)
>>   create mode 100644 tools/testing/selftests/x86/test_mremap_vdso.c
>>
>> diff --git a/tools/testing/selftests/x86/Makefile b/tools/testing/selftests/x86/Makefile
>> index b47ebd170690..c7162b511ab0 100644
>> --- a/tools/testing/selftests/x86/Makefile
>> +++ b/tools/testing/selftests/x86/Makefile
>> @@ -7,7 +7,7 @@ include ../lib.mk
>>   TARGETS_C_BOTHBITS := single_step_syscall sysret_ss_attrs syscall_nt ptrace_syscall \
>>                          check_initial_reg_state sigreturn ldt_gdt iopl
>>   TARGETS_C_32BIT_ONLY := entry_from_vm86 syscall_arg_fault test_syscall_vdso unwind_vdso \
>> -                       test_FCMOV test_FCOMI test_FISTTP \
>> +                       test_FCMOV test_FCOMI test_FISTTP test_mremap_vdso \
>>                          vdso_restorer
>>
>>   TARGETS_C_32BIT_ALL := $(TARGETS_C_BOTHBITS) $(TARGETS_C_32BIT_ONLY)
>> diff --git a/tools/testing/selftests/x86/test_mremap_vdso.c b/tools/testing/selftests/x86/test_mremap_vdso.c
>> new file mode 100644
>> index 000000000000..a470790e2118
>> --- /dev/null
>> +++ b/tools/testing/selftests/x86/test_mremap_vdso.c
>> @@ -0,0 +1,72 @@
>> +/*
>> + * 32-bit test to check vdso mremap.
>> + *
>> + * Copyright (c) 2016 Dmitry Safonov
>> + * Suggested-by: Andrew Lutomirski
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms and conditions of the GNU General Public License,
>> + * version 2, as published by the Free Software Foundation.
>> + *
>> + * This program is distributed in the hope it will be useful, but
>> + * WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
>> + * General Public License for more details.
>> + */
>> +/*
>> + * Can be built statically:
>> + * gcc -Os -Wall -static -m32 test_mremap_vdso.c
>> + */
>> +#define _GNU_SOURCE
>> +#include <stdio.h>
>> +#include <errno.h>
>> +#include <unistd.h>
>> +#include <string.h>
>> +
>> +#include <sys/mman.h>
>> +#include <sys/auxv.h>
>> +#include <sys/syscall.h>
>> +
>> +#if !defined(__i386__)
>> +int main(int argc, char **argv, char **envp)
>> +{
>> +       printf("[SKIP]\tNot a 32-bit x86 userspace\n");
>> +       return 0;
> What's wrong with testing on 64-bit systems?

Ok, will drop this.

>> +}
>> +#else
>> +
>> +#define PAGE_SIZE      4096
>> +#define VDSO_SIZE      PAGE_SIZE
> The vdso is frequently bigger than a page.

Ok, will enlarge this. Are two pages big enough?

>> +
>> +int main(int argc, char **argv, char **envp)
>> +{
>> +       unsigned long vdso_addr, dest_addr;
>> +       void *new_addr;
>> +       const char *ok_string = "[OK]\n";
>> +
>> +       vdso_addr = getauxval(AT_SYSINFO_EHDR);
>> +       printf("\tAT_SYSINFO_EHDR is 0x%lx\n", vdso_addr);
>> +       if (!vdso_addr || vdso_addr == -ENOENT) {
>> +               printf("[FAIL]\tgetauxval failed\n");
>> +               return 1;
> Let's make this [WARN] and return 0.  The vdso is optional, and
> getauxval is missing on many systems.

Ok

>> +       }
>> +
>> +       /* to low for stack, to high for lib/data/code mappings */
>> +       dest_addr = 0x0a000000;
> This could be make reliable -- map a big enough area PROT_NONE and use
> that address.

Oh, that's good, will do.

>> +       printf("[NOTE]\tMoving vDSO: [%lx, %lx] -> [%lx, %lx]\n",
>> +               vdso_addr, vdso_addr + VDSO_SIZE,
>> +               dest_addr, dest_addr + VDSO_SIZE);
> fflush(stdout), please, for the benefit of test harnesses that use pipes.

Will add.

>> +       new_addr = mremap((void *)vdso_addr, VDSO_SIZE, VDSO_SIZE,
>> +                       MREMAP_FIXED|MREMAP_MAYMOVE, dest_addr);
>> +       if ((unsigned long)new_addr == (unsigned long)-1) {
>> +               printf("[FAIL]\tmremap failed (%d): %m\n", errno);
>> +               return 1;
>> +       }
>> +
>> +       asm volatile ("int $0x80" : : "a" (__NR_write), "b" (STDOUT_FILENO),
>> +                       "c" (ok_string), "d" (strlen(ok_string)));
>> +       asm volatile ("int $0x80" : : "a" (__NR_exit), "b" (0));
>> +
>> +       return 0;
>> +}
>> +#endif
>> --
>> 2.8.0
>>
>
>


-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
