Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39C106B0005
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 13:45:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i140so131252950qke.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 10:45:12 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id a62si16296122wmc.78.2016.08.15.10.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 10:45:11 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id i5so117601781wmg.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 10:45:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160815104751.GC22320@e104818-lin.cambridge.arm.com>
References: <1470937490-7375-1-git-send-email-catalin.marinas@arm.com>
 <CAGXu5jJTuJ+k948BU4rDGF=tHv54TR0JQVTbcVvzp=NtfQrL9Q@mail.gmail.com> <20160815104751.GC22320@e104818-lin.cambridge.arm.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 15 Aug 2016 10:45:09 -0700
Message-ID: <CAGXu5jJTeta2OnL8KKHesG_HdeCvcXtaqjAir1cUvyfivaQeuQ@mail.gmail.com>
Subject: Re: [PATCH] arm64: Introduce execute-only page access permissions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Mon, Aug 15, 2016 at 3:47 AM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> On Fri, Aug 12, 2016 at 11:23:03AM -0700, Kees Cook wrote:
>> On Thu, Aug 11, 2016 at 10:44 AM, Catalin Marinas
>> <catalin.marinas@arm.com> wrote:
>> > The ARMv8 architecture allows execute-only user permissions by clearing
>> > the PTE_UXN and PTE_USER bits. However, the kernel running on a CPU
>> > implementation without User Access Override (ARMv8.2 onwards) can still
>> > access such page, so execute-only page permission does not protect
>> > against read(2)/write(2) etc. accesses. Systems requiring such
>> > protection must enable features like SECCOMP.
>>
>> So, UAO CPUs will bypass this protection in userspace if using
>> read/write on a memory-mapped file?
>
> It's the other way around. CPUs prior to ARMv8.2 (when UAO was
> introduced) or with the CONFIG_ARM64_UAO disabled can still access
> user execute-only memory regions while running in kernel mode via the
> copy_*_user, (get|put)_user etc. routines. So a way user can bypass this
> protection is by using such address as argument to read/write file
> operations.

Ah, okay. So exec-only for _userspace_ will always work, but exec-only
for _kernel_ will only work on ARMv8.2 with CONFIG_ARM64_UAO?

> I don't think mmap() is an issue since such region is already mapped, so
> it would require mprotect(). As for the latter, it would most likely be
> restricted (probably together with read/write) SECCOMP.
>
>> I'm just trying to make sure I understand the bypass scenario. And is
>> this something that can be fixed? If we add exec-only, I feel like it
>> shouldn't have corner case surprises. :)
>
> I think we need better understanding of the usage scenarios for
> exec-only. IIUC (from those who first asked me for this feature), it is
> an additional protection on top of ASLR to prevent an untrusted entity
> from scanning the memory for ROP/JOP gadgets. An instrumented compiler
> would avoid generating the literal pool in the same section as the
> executable code, thus allowing the instructions to be mapped as
> executable-only. It's not clear to me how such untrusted code ends up
> scanning the memory, maybe relying on other pre-existent bugs (buffer
> under/overflows). I assume if such code is allowed to do system calls,
> all bets are off already.

Yeah, the "block gadget scanning" tends to be the largest reason for
this. That kind of scanning is usually the result of a wild buffer
read of some kind. It's obviously most useful for "unknown" builds,
but still has value even for Distro-style kernels since they're
updated so regularly that automated attacks must keep an ever-growing
mapping of kernels to target.

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
