Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8716883093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 11:24:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so36864136wml.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 08:24:53 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id z9si14205100wjj.105.2016.08.25.08.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 08:24:52 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id o80so77737166wme.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 08:24:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160825103042.GA12599@arm.com>
References: <1470937490-7375-1-git-send-email-catalin.marinas@arm.com>
 <CAGXu5jJTuJ+k948BU4rDGF=tHv54TR0JQVTbcVvzp=NtfQrL9Q@mail.gmail.com>
 <20160815104751.GC22320@e104818-lin.cambridge.arm.com> <CAGXu5jJTeta2OnL8KKHesG_HdeCvcXtaqjAir1cUvyfivaQeuQ@mail.gmail.com>
 <20160816161824.GB7609@e104818-lin.cambridge.arm.com> <20160825103042.GA12599@arm.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 25 Aug 2016 11:24:50 -0400
Message-ID: <CAGXu5jKA-OByV9R4HFV1WSMQc+vfrCs-Rkb9SCYn9kA7tbB=Fw@mail.gmail.com>
Subject: Re: [PATCH] arm64: Introduce execute-only page access permissions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Thu, Aug 25, 2016 at 6:30 AM, Will Deacon <will.deacon@arm.com> wrote:
> On Tue, Aug 16, 2016 at 05:18:24PM +0100, Catalin Marinas wrote:
>> On Mon, Aug 15, 2016 at 10:45:09AM -0700, Kees Cook wrote:
>> > On Mon, Aug 15, 2016 at 3:47 AM, Catalin Marinas
>> > <catalin.marinas@arm.com> wrote:
>> > > On Fri, Aug 12, 2016 at 11:23:03AM -0700, Kees Cook wrote:
>> > >> On Thu, Aug 11, 2016 at 10:44 AM, Catalin Marinas
>> > >> <catalin.marinas@arm.com> wrote:
>> > >> > The ARMv8 architecture allows execute-only user permissions by clearing
>> > >> > the PTE_UXN and PTE_USER bits. However, the kernel running on a CPU
>> > >> > implementation without User Access Override (ARMv8.2 onwards) can still
>> > >> > access such page, so execute-only page permission does not protect
>> > >> > against read(2)/write(2) etc. accesses. Systems requiring such
>> > >> > protection must enable features like SECCOMP.
>> > >>
>> > >> So, UAO CPUs will bypass this protection in userspace if using
>> > >> read/write on a memory-mapped file?
>> > >
>> > > It's the other way around. CPUs prior to ARMv8.2 (when UAO was
>> > > introduced) or with the CONFIG_ARM64_UAO disabled can still access
>> > > user execute-only memory regions while running in kernel mode via the
>> > > copy_*_user, (get|put)_user etc. routines. So a way user can bypass this
>> > > protection is by using such address as argument to read/write file
>> > > operations.
>> >
>> > Ah, okay. So exec-only for _userspace_ will always work, but exec-only
>> > for _kernel_ will only work on ARMv8.2 with CONFIG_ARM64_UAO?
>>
>> Yes (mostly). With UAO, we changed the user access routines in the
>> kernel to use the LDTR/STTR instructions which always behave
>> unprivileged even when executed in kernel mode (unless the UAO bit is
>> set to override this restriction, needed for set_fs(KERNEL_DS)).
>>
>> Even with UAO, we still have two cases where the kernel cannot perform
>> unprivileged accesses (LDTR/STTR) since they don't have an exclusives
>> equivalent (LDXR/STXR). These are in-user futex atomic ops and the SWP
>> emulation for 32-bit binaries (armv8_deprecated.c). But these require
>> write permission, so they would always fault even when running in the
>> kernel. futex_atomic_cmpxchg_inatomic() is able to return the old value
>> without a write (if it differs from "oldval") but it doesn't look like
>> such value could leak to user space.
>
> If this was an issue, couldn't we add a dummy LDTR before the LDXR, and
> have the fixup handler return -EFAULT?
>
> Either way, this series looks technically fine to me:
>
> Reviewed-by: Will Deacon <will.deacon@arm.com>
>
> but it would be good for some security-focussed person (Hi, Kees!) to
> comment on whether or not this is useful, given the caveats you've
> described. If it is, I can queue it for 4.9.

Hi!

It is a good building block for frustrating ROP attacks or other
things that rely on memory content exposure. It's still unclear to me
how much traction it'll get until the devices that support it are
widely in the hands of people, but I'd rather have the infrastructure
available than not. :)

-Kees


-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
