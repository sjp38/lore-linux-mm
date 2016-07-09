Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53F0E828E1
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 13:03:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so30724650wma.3
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 10:03:27 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id kd10si2991491wjb.143.2016.07.09.10.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 10:03:26 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id f65so19761428wmi.0
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 10:03:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu_F03ncqT2wWFte2bFWQ7tSruL0ZaxTBLT9_NEs-1SioQ@mail.gmail.com>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <b113b487-acc6-24b8-d58c-425d3c884f4c@redhat.com> <CAKv+Gu_F03ncqT2wWFte2bFWQ7tSruL0ZaxTBLT9_NEs-1SioQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Sat, 9 Jul 2016 10:03:24 -0700
Message-ID: <CAGXu5jJLH9kSxiR9=pHnHvv00UCJRCcrB_Juj=9ROyDxB0wK6A@mail.gmail.com>
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Laura Abbott <labbott@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Sat, Jul 9, 2016 at 1:25 AM, Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
> On 9 July 2016 at 04:22, Laura Abbott <labbott@redhat.com> wrote:
>> On 07/06/2016 03:25 PM, Kees Cook wrote:
>>>
>>> Hi,
>>>
>>> This is a start of the mainline port of PAX_USERCOPY[1]. After I started
>>> writing tests (now in lkdtm in -next) for Casey's earlier port[2], I
>>> kept tweaking things further and further until I ended up with a whole
>>> new patch series. To that end, I took Rik's feedback and made a number
>>> of other changes and clean-ups as well.
>>>
>>> Based on my understanding, PAX_USERCOPY was designed to catch a few
>>> classes of flaws around the use of copy_to_user()/copy_from_user(). These
>>> changes don't touch get_user() and put_user(), since these operate on
>>> constant sized lengths, and tend to be much less vulnerable. There
>>> are effectively three distinct protections in the whole series,
>>> each of which I've given a separate CONFIG, though this patch set is
>>> only the first of the three intended protections. (Generally speaking,
>>> PAX_USERCOPY covers what I'm calling CONFIG_HARDENED_USERCOPY (this) and
>>> CONFIG_HARDENED_USERCOPY_WHITELIST (future), and PAX_USERCOPY_SLABS covers
>>> CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC (future).)
>>>
>>> This series, which adds CONFIG_HARDENED_USERCOPY, checks that objects
>>> being copied to/from userspace meet certain criteria:
>>> - if address is a heap object, the size must not exceed the object's
>>>   allocated size. (This will catch all kinds of heap overflow flaws.)
>>> - if address range is in the current process stack, it must be within the
>>>   current stack frame (if such checking is possible) or at least entirely
>>>   within the current process's stack. (This could catch large lengths that
>>>   would have extended beyond the current process stack, or overflows if
>>>   their length extends back into the original stack.)
>>> - if the address range is part of kernel data, rodata, or bss, allow it.
>>> - if address range is page-allocated, that it doesn't span multiple
>>>   allocations.
>>> - if address is within the kernel text, reject it.
>>> - everything else is accepted
>>>
>>> The patches in the series are:
>>> - The core copy_to/from_user() checks, without the slab object checks:
>>>         1- mm: Hardened usercopy
>>> - Per-arch enablement of the protection:
>>>         2- x86/uaccess: Enable hardened usercopy
>>>         3- ARM: uaccess: Enable hardened usercopy
>>>         4- arm64/uaccess: Enable hardened usercopy
>>>         5- ia64/uaccess: Enable hardened usercopy
>>>         6- powerpc/uaccess: Enable hardened usercopy
>>>         7- sparc/uaccess: Enable hardened usercopy
>>> - The heap allocator implementation of object size checking:
>>>         8- mm: SLAB hardened usercopy support
>>>         9- mm: SLUB hardened usercopy support
>>>
>>> Some notes:
>>>
>>> - This is expected to apply on top of -next which contains fixes for the
>>>   position of _etext on both arm and arm64.
>>>
>>> - I couldn't detect a measurable performance change with these features
>>>   enabled. Kernel build times were unchanged, hackbench was unchanged,
>>>   etc. I think we could flip this to "on by default" at some point.
>>>
>>> - The SLOB support extracted from grsecurity seems entirely broken. I
>>>   have no idea what's going on there, I spent my time testing SLAB and
>>>   SLUB. Having someone else look at SLOB would be nice, but this series
>>>   doesn't depend on it.
>>>
>>> Additional features that would be nice, but aren't blocking this series:
>>>
>>> - Needs more architecture support for stack frame checking (only x86 now).
>>>
>>>
>>
>> Even with the SLUB fixup I'm still seeing this blow up on my arm64 system.
>> This is a
>> Fedora rawhide kernel + the patches
>>
>> [ 0.666700] usercopy: kernel memory exposure attempt detected from
>> fffffc0008b4dd58 (<kernel text>) (8 bytes)
>> [ 0.666720] CPU: 2 PID: 79 Comm: modprobe Tainted: G        W
>> 4.7.0-0.rc6.git1.1.hardenedusercopy.fc25.aarch64 #1
>> [ 0.666733] Hardware name: AppliedMicro Mustang/Mustang, BIOS 1.1.0 Nov 24
>> 2015
>> [ 0.666744] Call trace:
>> [ 0.666756] [<fffffc0008088a20>] dump_backtrace+0x0/0x1e8
>> [ 0.666765] [<fffffc0008088c2c>] show_stack+0x24/0x30
>> [ 0.666775] [<fffffc0008455344>] dump_stack+0xa4/0xe0
>> [ 0.666785] [<fffffc000828d874>] __check_object_size+0x6c/0x230
>> [ 0.666795] [<fffffc00083a5748>] create_elf_tables+0x74/0x420
>> [ 0.666805] [<fffffc00082fb1f0>] load_elf_binary+0x828/0xb70
>> [ 0.666814] [<fffffc0008298b4c>] search_binary_handler+0xb4/0x240
>> [ 0.666823] [<fffffc0008299864>] do_execveat_common+0x63c/0x950
>> [ 0.666832] [<fffffc0008299bb4>] do_execve+0x3c/0x50
>> [ 0.666841] [<fffffc00080e3720>] call_usermodehelper_exec_async+0xe8/0x148
>> [ 0.666850] [<fffffc0008084a80>] ret_from_fork+0x10/0x50
>>
>> This happens on every call to execve. This seems to be the first
>> copy_to_user in
>> create_elf_tables. I didn't get a chance to debug and I'm going out of town
>> all of next week so all I have is the report unfortunately. config attached.
>>
>
> This is a known issue, and a fix is already queued for v4.8 in the arm64 tree:
>
> 9fdc14c55c arm64: mm: fix location of _etext [0]
>
> which moves _etext up in the linker script so that it does not cover .rodata

Oops, I missed this reply, sorry for the redundant answer. :)

> ARM was suffering from the same problem, and Kees proposed a fix for
> it. I don't know what the status of that patch is, though.

This is also in -next "ARM: 8583/1: mm: fix location of _etext".

> Note that on arm64, we have
>
>   #define ELF_PLATFORM            ("aarch64")
>
> which explains why k_platform points into .rodata in this case. On
> ARM, it points to a writable string (as the code quoted by Rik shows),
> so there it will likely explode elsewhere without the linker script
> fix.
>
> [0] https://git.kernel.org/cgit/linux/kernel/git/arm64/linux.git/commit/?h=for-next/core&id=9fdc14c55c

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
