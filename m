Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C848E6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 11:47:00 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id w144so83498101oiw.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 08:47:00 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0122.outbound.protection.outlook.com. [104.47.2.122])
        by mx.google.com with ESMTPS id 73si495766otu.116.2017.02.06.08.46.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 08:46:59 -0800 (PST)
Subject: Re: [PATCHv4 0/5] Fix compatible mmap() return pointer over 4Gb
References: <20170130120432.6716-1-dsafonov@virtuozzo.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <d68658cf-2526-d643-86dd-ef6b947a5ffc@virtuozzo.com>
Date: Mon, 6 Feb 2017 19:46:55 +0300
MIME-Version: 1.0
In-Reply-To: <20170130120432.6716-1-dsafonov@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>
Cc: 0x7f454c46@gmail.com, x86@kernel.org, linux-mm@kvack.org, Shuah Khan <shuah@kernel.org>, linux-kselftest@vger.kernel.org

On 01/30/2017 03:04 PM, Dmitry Safonov wrote:
> Changes since v3:
> - fixed usage of 64-bit random mask for 32-bit mm->mmap_compat_base,
>   during introducing mmap_compat{_legacy,}_base
>
> Changes since v2:
> - don't distinguish native and compat tasks by TIF_ADDR32,
>   introduced mmap_compat{_legacy,}_base which allows to treat them
>   the same
> - fixed kbuild errors
>
> Changes since v1:
> - Recalculate mmap_base instead of using max possible virtual address
>   for compat/native syscall. That will make policy for allocation the
>   same in 32-bit binaries and in 32-bit syscalls in 64-bit binaries.
>   I need this because sys_mmap() in restored 32-bit process shouldn't
>   hit the stack area.
> - Fixed mmap() with MAP_32BIT flag in the same usecases
> - used in_compat_syscall() helper rather TS_COMPAT check (Andy noticed)
> - introduced find_top() helper as suggested by Andy to simplify code
> - fixed test error-handeling: it checked the result of sys_mmap() with
>   MMAP_FAILED, which is not correct, as it calls raw syscall - now
>   checks return value to be aligned to PAGE_SIZE.
>
> Description from v1 [2]:
>
> A fix for bug in mmap() that I referenced in [1].
> Also selftest for it.

Gentle ping. Any thought on this?

>
> [1]: https://marc.info/?l=linux-kernel&m=148311451525315
> [2]: https://marc.info/?l=linux-kernel&m=148415888707662
>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Borislav Petkov <bp@suse.de>
> Cc: x86@kernel.org
> Cc: linux-mm@kvack.org
>
> Dmitry Safonov (5):
>   x86/mm: split arch_mmap_rnd() on compat/native versions
>   x86/mm: introduce mmap{,_legacy}_base
>   x86/mm: fix 32-bit mmap() for 64-bit ELF
>   x86/mm: check in_compat_syscall() instead TIF_ADDR32 for
>     mmap(MAP_32BIT)
>   selftests/x86: add test to check compat mmap() return addr
>
>  arch/Kconfig                                   |   7 +
>  arch/x86/Kconfig                               |   1 +
>  arch/x86/include/asm/elf.h                     |   4 +-
>  arch/x86/include/asm/processor.h               |   3 +-
>  arch/x86/kernel/sys_x86_64.c                   |  32 +++-
>  arch/x86/mm/mmap.c                             |  89 +++++++----
>  include/linux/mm_types.h                       |   5 +
>  tools/testing/selftests/x86/Makefile           |   2 +-
>  tools/testing/selftests/x86/test_compat_mmap.c | 208 +++++++++++++++++++++++++
>  9 files changed, 311 insertions(+), 40 deletions(-)
>  create mode 100644 tools/testing/selftests/x86/test_compat_mmap.c
>


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
