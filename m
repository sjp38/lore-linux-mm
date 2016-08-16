Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8E06B025F
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 12:18:29 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so158444386pab.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 09:18:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m89si32720105pfk.254.2016.08.16.09.18.28
        for <linux-mm@kvack.org>;
        Tue, 16 Aug 2016 09:18:28 -0700 (PDT)
Date: Tue, 16 Aug 2016 17:18:24 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] arm64: Introduce execute-only page access permissions
Message-ID: <20160816161824.GB7609@e104818-lin.cambridge.arm.com>
References: <1470937490-7375-1-git-send-email-catalin.marinas@arm.com>
 <CAGXu5jJTuJ+k948BU4rDGF=tHv54TR0JQVTbcVvzp=NtfQrL9Q@mail.gmail.com>
 <20160815104751.GC22320@e104818-lin.cambridge.arm.com>
 <CAGXu5jJTeta2OnL8KKHesG_HdeCvcXtaqjAir1cUvyfivaQeuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJTeta2OnL8KKHesG_HdeCvcXtaqjAir1cUvyfivaQeuQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Mon, Aug 15, 2016 at 10:45:09AM -0700, Kees Cook wrote:
> On Mon, Aug 15, 2016 at 3:47 AM, Catalin Marinas
> <catalin.marinas@arm.com> wrote:
> > On Fri, Aug 12, 2016 at 11:23:03AM -0700, Kees Cook wrote:
> >> On Thu, Aug 11, 2016 at 10:44 AM, Catalin Marinas
> >> <catalin.marinas@arm.com> wrote:
> >> > The ARMv8 architecture allows execute-only user permissions by clearing
> >> > the PTE_UXN and PTE_USER bits. However, the kernel running on a CPU
> >> > implementation without User Access Override (ARMv8.2 onwards) can still
> >> > access such page, so execute-only page permission does not protect
> >> > against read(2)/write(2) etc. accesses. Systems requiring such
> >> > protection must enable features like SECCOMP.
> >>
> >> So, UAO CPUs will bypass this protection in userspace if using
> >> read/write on a memory-mapped file?
> >
> > It's the other way around. CPUs prior to ARMv8.2 (when UAO was
> > introduced) or with the CONFIG_ARM64_UAO disabled can still access
> > user execute-only memory regions while running in kernel mode via the
> > copy_*_user, (get|put)_user etc. routines. So a way user can bypass this
> > protection is by using such address as argument to read/write file
> > operations.
> 
> Ah, okay. So exec-only for _userspace_ will always work, but exec-only
> for _kernel_ will only work on ARMv8.2 with CONFIG_ARM64_UAO?

Yes (mostly). With UAO, we changed the user access routines in the
kernel to use the LDTR/STTR instructions which always behave
unprivileged even when executed in kernel mode (unless the UAO bit is
set to override this restriction, needed for set_fs(KERNEL_DS)).

Even with UAO, we still have two cases where the kernel cannot perform
unprivileged accesses (LDTR/STTR) since they don't have an exclusives
equivalent (LDXR/STXR). These are in-user futex atomic ops and the SWP
emulation for 32-bit binaries (armv8_deprecated.c). But these require
write permission, so they would always fault even when running in the
kernel. futex_atomic_cmpxchg_inatomic() is able to return the old value
without a write (if it differs from "oldval") but it doesn't look like
such value could leak to user space.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
