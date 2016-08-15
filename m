Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D987D6B0005
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 06:47:56 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so98678809pac.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 03:47:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g63si26158973pfg.227.2016.08.15.03.47.55
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 03:47:55 -0700 (PDT)
Date: Mon, 15 Aug 2016 11:47:52 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: Introduce execute-only page access permissions
Message-ID: <20160815104751.GC22320@e104818-lin.cambridge.arm.com>
References: <1470937490-7375-1-git-send-email-catalin.marinas@arm.com>
 <CAGXu5jJTuJ+k948BU4rDGF=tHv54TR0JQVTbcVvzp=NtfQrL9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJTuJ+k948BU4rDGF=tHv54TR0JQVTbcVvzp=NtfQrL9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Aug 12, 2016 at 11:23:03AM -0700, Kees Cook wrote:
> On Thu, Aug 11, 2016 at 10:44 AM, Catalin Marinas
> <catalin.marinas@arm.com> wrote:
> > The ARMv8 architecture allows execute-only user permissions by clearing
> > the PTE_UXN and PTE_USER bits. However, the kernel running on a CPU
> > implementation without User Access Override (ARMv8.2 onwards) can still
> > access such page, so execute-only page permission does not protect
> > against read(2)/write(2) etc. accesses. Systems requiring such
> > protection must enable features like SECCOMP.
> 
> So, UAO CPUs will bypass this protection in userspace if using
> read/write on a memory-mapped file?

It's the other way around. CPUs prior to ARMv8.2 (when UAO was
introduced) or with the CONFIG_ARM64_UAO disabled can still access
user execute-only memory regions while running in kernel mode via the
copy_*_user, (get|put)_user etc. routines. So a way user can bypass this
protection is by using such address as argument to read/write file
operations.

I don't think mmap() is an issue since such region is already mapped, so
it would require mprotect(). As for the latter, it would most likely be
restricted (probably together with read/write) SECCOMP.

> I'm just trying to make sure I understand the bypass scenario. And is
> this something that can be fixed? If we add exec-only, I feel like it
> shouldn't have corner case surprises. :)

I think we need better understanding of the usage scenarios for
exec-only. IIUC (from those who first asked me for this feature), it is
an additional protection on top of ASLR to prevent an untrusted entity
from scanning the memory for ROP/JOP gadgets. An instrumented compiler
would avoid generating the literal pool in the same section as the
executable code, thus allowing the instructions to be mapped as
executable-only. It's not clear to me how such untrusted code ends up
scanning the memory, maybe relying on other pre-existent bugs (buffer
under/overflows). I assume if such code is allowed to do system calls,
all bets are off already.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
