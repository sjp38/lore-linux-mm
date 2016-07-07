Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32F986B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 13:27:06 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so15286655lfa.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 10:27:06 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id 184si4354971wml.128.2016.07.07.10.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 10:27:04 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id a66so40430358wme.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 10:27:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <577E04FF.1090000@de.ibm.com>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org> <577E04FF.1090000@de.ibm.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Jul 2016 13:27:03 -0400
Message-ID: <CAGXu5jLiqNWHR09StBirH3c3ZHpwnpPOBRE40BGwWBJES5kpBw@mail.gmail.com>
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, Jul 7, 2016 at 3:30 AM, Christian Borntraeger
<borntraeger@de.ibm.com> wrote:
> On 07/07/2016 12:25 AM, Kees Cook wrote:
>> Hi,
>>
>> This is a start of the mainline port of PAX_USERCOPY[1]. After I started
>> writing tests (now in lkdtm in -next) for Casey's earlier port[2], I
>> kept tweaking things further and further until I ended up with a whole
>> new patch series. To that end, I took Rik's feedback and made a number
>> of other changes and clean-ups as well.
>>
>> Based on my understanding, PAX_USERCOPY was designed to catch a few
>> classes of flaws around the use of copy_to_user()/copy_from_user(). These
>> changes don't touch get_user() and put_user(), since these operate on
>> constant sized lengths, and tend to be much less vulnerable. There
>> are effectively three distinct protections in the whole series,
>> each of which I've given a separate CONFIG, though this patch set is
>> only the first of the three intended protections. (Generally speaking,
>> PAX_USERCOPY covers what I'm calling CONFIG_HARDENED_USERCOPY (this) and
>> CONFIG_HARDENED_USERCOPY_WHITELIST (future), and PAX_USERCOPY_SLABS covers
>> CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC (future).)
>>
>> This series, which adds CONFIG_HARDENED_USERCOPY, checks that objects
>> being copied to/from userspace meet certain criteria:
>> - if address is a heap object, the size must not exceed the object's
>>   allocated size. (This will catch all kinds of heap overflow flaws.)
>> - if address range is in the current process stack, it must be within the
>>   current stack frame (if such checking is possible) or at least entirely
>>   within the current process's stack. (This could catch large lengths that
>>   would have extended beyond the current process stack, or overflows if
>>   their length extends back into the original stack.)
>> - if the address range is part of kernel data, rodata, or bss, allow it.
>> - if address range is page-allocated, that it doesn't span multiple
>>   allocations.
>> - if address is within the kernel text, reject it.
>> - everything else is accepted
>>
>> The patches in the series are:
>> - The core copy_to/from_user() checks, without the slab object checks:
>>       1- mm: Hardened usercopy
>> - Per-arch enablement of the protection:
>>       2- x86/uaccess: Enable hardened usercopy
>>       3- ARM: uaccess: Enable hardened usercopy
>>       4- arm64/uaccess: Enable hardened usercopy
>>       5- ia64/uaccess: Enable hardened usercopy
>>       6- powerpc/uaccess: Enable hardened usercopy
>>       7- sparc/uaccess: Enable hardened usercopy
>
> Was there a reason why you did not change s390?

No reason -- just didn't have a good build setup for testing it.
(Everything but arm64 was already in grsecurity, and I was able to
build-test arm64 when I added it there.) I would love to include s390
too!

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
