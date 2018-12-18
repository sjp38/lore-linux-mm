Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 372708E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 10:03:52 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 75so15402324pfq.8
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 07:03:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o19sor23513498pll.44.2018.12.18.07.03.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 07:03:50 -0800 (PST)
MIME-Version: 1.0
References: <cover.1544445454.git.andreyknvl@google.com> <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com> <20181212150230.GH65138@arrakis.emea.arm.com>
In-Reply-To: <20181212150230.GH65138@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 18 Dec 2018 16:03:38 +0100
Message-ID: <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgenii Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Dec 12, 2018 at 4:02 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> Hi Andrey,
>
> On Wed, Dec 12, 2018 at 03:23:25PM +0100, Andrey Konovalov wrote:
> > On Mon, Dec 10, 2018 at 3:31 PM Vincenzo Frascino
> > <vincenzo.frascino@arm.com> wrote:
> > > On arm64 the TCR_EL1.TBI0 bit has been set since Linux 3.x hence
> > > the userspace (EL0) is allowed to set a non-zero value in the top
> > > byte but the resulting pointers are not allowed at the user-kernel
> > > syscall ABI boundary.
> > >
> > > This patchset proposes a relaxation of the ABI and a mechanism to
> > > advertise it to the userspace via an AT_FLAGS.
> > >
> > > The rationale behind the choice of AT_FLAGS is that the Unix System V
> > > ABI defines AT_FLAGS as "flags", leaving some degree of freedom in
> > > interpretation.
> > > There are two previous attempts of using AT_FLAGS in the Linux Kernel
> > > for different reasons: the first was more generic and was used to expose
> > > the support for the GNU STACK NX feature [1] and the second was done for
> > > the MIPS architecture and was used to expose the support of "MIPS ABI
> > > Extension for IEEE Std 754 Non-Compliant Interlinking" [2].
> > > Both the changes are currently _not_ merged in mainline.
> > > The only architecture that reserves some of the bits in AT_FLAGS is
> > > currently MIPS, which introduced the concept of platform specific ABI
> > > (psABI) reserving the top-byte [3].
> > >
> > > When ARM64_AT_FLAGS_SYSCALL_TBI is set the kernel is advertising
> > > to the userspace that a relaxed ABI is supported hence this type
> > > of pointers are now allowed to be passed to the syscalls when they are
> > > in memory ranges obtained by anonymous mmap() or brk().
> > >
> > > The userspace _must_ verify that the flag is set before passing tagged
> > > pointers to the syscalls allowed by this relaxation.
> > >
> > > More in general, exposing the ARM64_AT_FLAGS_SYSCALL_TBI flag and mandating
> > > to the software to check that the feature is present, before using the
> > > associated functionality, it provides a degree of control on the decision
> > > of disabling such a feature in future without consequently breaking the
> > > userspace.
> [...]
> > Acked-by: Andrey Konovalov <andreyknvl@google.com>
>
> Thanks for the ack. However, if we go ahead with this ABI proposal it
> means that your patches need to be reworked to allow a non-zero top byte
> in all syscalls, including mmap() and friends, ioctl(). There are ABI
> concerns in either case but I'd rather have this discussion in the open.
> It doesn't necessarily mean that I endorse this proposal, I would like
> feedback and not just from kernel developers but user space ones.
>
> The summary of our internal discussions (mostly between kernel
> developers) is that we can't properly describe a user ABI that covers
> future syscalls or syscall extensions while not all syscalls accept
> tagged pointers. So we tweaked the requirements slightly to only allow
> tagged pointers back into the kernel *if* the originating address is
> from an anonymous mmap() or below sbrk(0). This should cover some of the
> ioctls or getsockopt(TCP_ZEROCOPY_RECEIVE) where the user passes a
> pointer to a buffer obtained via mmap() on the device operations.
>
> (sorry for not being clear on what Vincenzo's proposal implies)

OK, I see. So I need to make the following changes to my patchset AFAIU.

1. Make sure that we only allow tagged user addresses that originate
from an anonymous mmap() or below sbrk(0). How exactly should this
check be performed?

2. Allow tagged addressed passed to memory syscalls (as long as (1) is
satisfied). Do I understand correctly that this means that I need to
locate all find_vma() callers outside of mm/ and fix them up as well?
