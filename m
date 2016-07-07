Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A48E6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 13:37:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i4so21729943wmg.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 10:37:45 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id y75si3996437wmc.75.2016.07.07.10.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 10:37:44 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id z126so157403555wme.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 10:37:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <3418914.byvl8Wuxlf@wuerfel>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <1467843928-29351-2-git-send-email-keescook@chromium.org> <3418914.byvl8Wuxlf@wuerfel>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Jul 2016 13:37:43 -0400
Message-ID: <CAGXu5jLyBfqXJKxohHiZgztRVrFyqwbta1W_Dw6KyyGM3LzshQ@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, PaX Team <pageexec@freemail.hu>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>

On Thu, Jul 7, 2016 at 4:01 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wednesday, July 6, 2016 3:25:20 PM CEST Kees Cook wrote:
>> This is the start of porting PAX_USERCOPY into the mainline kernel. This
>> is the first set of features, controlled by CONFIG_HARDENED_USERCOPY. The
>> work is based on code by PaX Team and Brad Spengler, and an earlier port
>> from Casey Schaufler. Additional non-slab page tests are from Rik van Riel.
>>
>> This patch contains the logic for validating several conditions when
>> performing copy_to_user() and copy_from_user() on the kernel object
>> being copied to/from:
>> - address range doesn't wrap around
>> - address range isn't NULL or zero-allocated (with a non-zero copy size)
>> - if on the slab allocator:
>>   - object size must be less than or equal to copy size (when check is
>>     implemented in the allocator, which appear in subsequent patches)
>> - otherwise, object must not span page allocations
>> - if on the stack
>>   - object must not extend before/after the current process task
>>   - object must be contained by the current stack frame (when there is
>>     arch/build support for identifying stack frames)
>> - object must not overlap with kernel text
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>
> Nice!
>
> I have a few further thoughts, most of which have probably been
> considered before:
>
>> +static inline const char *check_bogus_address(const void *ptr, unsigned long n)
>> +{
>> +     /* Reject if object wraps past end of memory. */
>> +     if (ptr + n < ptr)
>> +             return "<wrapped address>";
>> +
>> +     /* Reject if NULL or ZERO-allocation. */
>> +     if (ZERO_OR_NULL_PTR(ptr))
>> +             return "<null>";
>> +
>> +     return NULL;
>> +}
>
> This checks against address (void*)16, but I guess on most architectures the
> lowest possible kernel address is much higher. While there may not be much
> that to exploit if the expected kernel address points to userland, forbidding
> any obviously incorrect address that is outside of the kernel may be easier.
>
> Even on architectures like s390 that start the kernel memory at (void *)0x0,
> the lowest address to which we may want to do a copy_to_user would be much
> higher than (void*)0x16.

Yeah, that's worth exploring, but given the shenanigans around
set_fs(), I'd like to leave this as-is, and we can add to these checks
as we remove as much of the insane usage of set_fs().

>> +
>> +     /* Allow kernel rodata region (if not marked as Reserved). */
>> +     if (ptr >= (const void *)__start_rodata &&
>> +         end <= (const void *)__end_rodata)
>> +             return NULL;
>
> Should we explicitly forbid writing to rodata, or is it enough to
> rely on page protection here?

Hm, interesting. That's a very small check to add. My knee-jerk is to
just leave it up to page protection. I'm on the fence. :)

>
>> +     /* Allow kernel bss region (if not marked as Reserved). */
>> +     if (ptr >= (const void *)__bss_start &&
>> +         end <= (const void *)__bss_stop)
>> +             return NULL;
>
> accesses to .data/.rodata/.bss are probably not performance critical,
> so we could go further here and check the kallsyms table to ensure
> that we are not spanning multiple symbols here.

Oh, interesting! Yeah, would you be willing to put together that patch
and test it? I wonder if there are any cases where there are
legitimate usercopys across multiple symbols.

> For stuff that is performance critical, should there be a way to
> opt out of the checks, or do we assume it already uses functions
> that avoid the checks? I looked at the file and network I/O path
> briefly and they seem to use kmap_atomic() to get to the user pages
> at least in some of the common cases (but I may well be missing
> important ones).

I don't want to start with an exemption here, so until such a case is
found, I'd rather leave this as-is. That said, the primary protection
here tends to be buggy lengths (which is why put/get_user() is
untouched). For constant-sized copies, some checks could be skipped.
In the second part of this protection (what I named
CONFIG_HARDENED_USERCOPY_WHITELIST in the RFC version of this series),
there are cases where we want to skip the whitelist checking since it
is for a constant-sized copy the code understands is okay to pull out
of an otherwise disallowed allocator object.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
