Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id DDFC88E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:23:38 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id y19so17356584ioq.1
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 06:23:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor1848369iok.1.2018.12.12.06.23.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 06:23:37 -0800 (PST)
MIME-Version: 1.0
References: <cover.1544445454.git.andreyknvl@google.com> <20181210143044.12714-1-vincenzo.frascino@arm.com>
In-Reply-To: <20181210143044.12714-1-vincenzo.frascino@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 12 Dec 2018 15:23:25 +0100
Message-ID: <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Evgenii Stepanov <eugenis@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>

On Mon, Dec 10, 2018 at 3:31 PM Vincenzo Frascino
<vincenzo.frascino@arm.com> wrote:
>
> On arm64 the TCR_EL1.TBI0 bit has been set since Linux 3.x hence
> the userspace (EL0) is allowed to set a non-zero value in the top
> byte but the resulting pointers are not allowed at the user-kernel
> syscall ABI boundary.
>
> This patchset proposes a relaxation of the ABI and a mechanism to
> advertise it to the userspace via an AT_FLAGS.
>
> The rationale behind the choice of AT_FLAGS is that the Unix System V
> ABI defines AT_FLAGS as "flags", leaving some degree of freedom in
> interpretation.
> There are two previous attempts of using AT_FLAGS in the Linux Kernel
> for different reasons: the first was more generic and was used to expose
> the support for the GNU STACK NX feature [1] and the second was done for
> the MIPS architecture and was used to expose the support of "MIPS ABI
> Extension for IEEE Std 754 Non-Compliant Interlinking" [2].
> Both the changes are currently _not_ merged in mainline.
> The only architecture that reserves some of the bits in AT_FLAGS is
> currently MIPS, which introduced the concept of platform specific ABI
> (psABI) reserving the top-byte [3].
>
> When ARM64_AT_FLAGS_SYSCALL_TBI is set the kernel is advertising
> to the userspace that a relaxed ABI is supported hence this type
> of pointers are now allowed to be passed to the syscalls when they are
> in memory ranges obtained by anonymous mmap() or brk().
>
> The userspace _must_ verify that the flag is set before passing tagged
> pointers to the syscalls allowed by this relaxation.
>
> More in general, exposing the ARM64_AT_FLAGS_SYSCALL_TBI flag and mandating
> to the software to check that the feature is present, before using the
> associated functionality, it provides a degree of control on the decision
> of disabling such a feature in future without consequently breaking the
> userspace.
>
> The change required a modification of the elf common code, because in Linux
> the AT_FLAGS are currently set to zero by default by the kernel.
>
> The newly added flag has been verified on arm64 using the code below.
> #include <stdio.h>
> #include <stdbool.h>
> #include <sys/auxv.h>
>
> #define ARM64_AT_FLAGS_SYSCALL_TBI     (1 << 0)
>
> bool arm64_syscall_tbi_is_present(void)
> {
>         unsigned long at_flags = getauxval(AT_FLAGS);
>         if (at_flags & ARM64_AT_FLAGS_SYSCALL_TBI)
>                 return true;
>
>         return false;
> }
>
> void main()
> {
>         if (arm64_syscall_tbi_is_present())
>                 printf("ARM64_AT_FLAGS_SYSCALL_TBI is present\n");
> }
>
> This patchset should be merged together with [4].
>
> [1] https://patchwork.ozlabs.org/patch/579578/
> [2] https://lore.kernel.org/patchwork/cover/618280/
> [3] ftp://www.linux-mips.org/pub/linux/mips/doc/ABI/psABI_mips3.0.pdf
> [4] https://patchwork.kernel.org/cover/10674351/
>
> ABI References:
> ---------------
> Sco SysV ABI: http://www.sco.com/developers/gabi/2003-12-17/contents.html
> PowerPC AUXV: http://openpowerfoundation.org/wp-content/uploads/resources/leabi/content/dbdoclet.50655242_98651.html
> AMD64 ABI: https://www.cs.tufts.edu/comp/40-2012f/readings/amd64-abi.pdf
> x86 ABI: https://www.uclibc.org/docs/psABI-i386.pdf
> MIPS ABI: ftp://www.linux-mips.org/pub/linux/mips/doc/ABI/psABI_mips3.0.pdf
> ARM ABI: http://infocenter.arm.com/help/topic/com.arm.doc.ihi0044f/IHI0044F_aaelf.pdf
> SPARC ABI: http://math-atlas.sourceforge.net/devel/assembly/abi_sysV_sparc.pdf
>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Robin Murphy <robin.murphy@arm.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Kate Stewart <kstewart@linuxfoundation.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Shuah Khan <shuah@kernel.org>
> Cc: Chintan Pandya <cpandya@codeaurora.org>
> Cc: Jacob Bramley <Jacob.Bramley@arm.com>
> Cc: Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Lee Smith <Lee.Smith@arm.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>,
> Cc: Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>
> Cc: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
> Cc: Evgeniy Stepanov <eugenis@google.com>
> CC: Alexander Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
>
> Vincenzo Frascino (3):
>   elf: Make AT_FLAGS arch configurable
>   arm64: Define Documentation/arm64/elf_at_flags.txt
>   arm64: elf: Advertise relaxed ABI
>
>  Documentation/arm64/elf_at_flags.txt  | 111 ++++++++++++++++++++++++++
>  arch/arm64/include/asm/atflags.h      |   7 ++
>  arch/arm64/include/asm/elf.h          |   5 ++
>  arch/arm64/include/uapi/asm/atflags.h |   8 ++
>  fs/binfmt_elf.c                       |   6 +-
>  fs/binfmt_elf_fdpic.c                 |   6 +-
>  fs/compat_binfmt_elf.c                |   5 ++
>  7 files changed, 146 insertions(+), 2 deletions(-)
>  create mode 100644 Documentation/arm64/elf_at_flags.txt
>  create mode 100644 arch/arm64/include/asm/atflags.h
>  create mode 100644 arch/arm64/include/uapi/asm/atflags.h
>
> --
> 2.19.2
>

Acked-by: Andrey Konovalov <andreyknvl@google.com>
