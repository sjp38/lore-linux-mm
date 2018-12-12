Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 29DD78E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 12:35:07 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q11so7801677otl.23
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:35:07 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f75si6983290oig.184.2018.12.12.09.35.05
        for <linux-mm@kvack.org>;
        Wed, 12 Dec 2018 09:35:05 -0800 (PST)
Date: Wed, 12 Dec 2018 17:34:57 +0000
From: Dave Martin <Dave.Martin@arm.com>
Subject: Re: [RFC][PATCH 2/3] arm64: Define
 Documentation/arm64/elf_at_flags.txt
Message-ID: <20181212173457.GA3505@e103592.cambridge.arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <20181210143044.12714-3-vincenzo.frascino@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210143044.12714-3-vincenzo.frascino@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>

On Mon, Dec 10, 2018 at 02:30:43PM +0000, Vincenzo Frascino wrote:
> On arm64 the TCR_EL1.TBI0 bit has been set since Linux 3.x hence
> the userspace (EL0) is allowed to set a non-zero value in the
> top byte but the resulting pointers are not allowed at the
> user-kernel syscall ABI boundary.
> 
> With the relaxed ABI proposed through this document, it is now possible
> to pass tagged pointers to the syscalls, when these pointers are in
> memory ranges obtained by an anonymous (MAP_ANONYMOUS) mmap() or brk().

What about other anonymous memory such as the process stack?

What about MAP_PRIVATE mappings of /dev/zero (i.e., oldskool "anonymous"
mappings)?

I wonder whether this should really say MAP_PRIVATE rather than
MAP_ANONYMOUS.  There are two requirements here:

 * the memory must be the exclusive property of a single process,
   otherwise tagging it on-the-fly could break some other process;

 * the memory should be regular memory, i.e., not something like a
   mapped device.  Since copy-on-write mappings of devices make little
   sense, and we want writes to devices to propagate to the hardware
   directly, MAP_PRIVATE doesn't make a lot of sense for such mappings.

MAP_ANONYMOUS | MAP_SHARED is theoretically possible, and we should
make sure that it does the expected thing.  Tagging such memory is
probably a bad idea, just like any other MAP_SHARED memory.

I'm assuming here that tagging some currently shared copy-on-write pages
would throw a page fault and trigger a copy, so that we end up tagging
the calling process's private copy of the page.

I also don't see how the above requirements conflict with regular file-
backed mappings (which would need to work if you want to be able to
tag objects in .bss or .data etc.)

> This change in the ABI requires a mechanism to inform the userspace
> that such an option is available.
> 
> This patch specifies and documents the way on which AT_FLAGS can be
> used to advertise this feature to the userspace.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> CC: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> ---
>  Documentation/arm64/elf_at_flags.txt | 111 +++++++++++++++++++++++++++
>  1 file changed, 111 insertions(+)
>  create mode 100644 Documentation/arm64/elf_at_flags.txt
> 
> diff --git a/Documentation/arm64/elf_at_flags.txt b/Documentation/arm64/elf_at_flags.txt
> new file mode 100644
> index 000000000000..153e657c058a
> --- /dev/null
> +++ b/Documentation/arm64/elf_at_flags.txt
> @@ -0,0 +1,111 @@
> +ARM64 ELF AT_FLAGS
> +==================
> +
> +This document describes the usage and semantics of AT_FLAGS on arm64.
> +
> +1. Introduction
> +---------------
> +
> +AT_FLAGS is part of the Auxiliary Vector, contains the flags and it
> +is currently set to zero by the kernel on arm64.
> +
> +The auxiliary vector can be accessed by the userspace using the
> +getauxval() API provided by the C library.
> +getauxval() returns an unsigned long and when a flag is present in
> +the AT_FLAGS, the corresponding bit in the returned value is set to 1.
> +
> +The AT_FLAGS with a "defined semantic" on arm64 are exposed to the
> +userspace via user API (uapi/asm/atflags.h).
> +The AT_FLAGS bits with "undefined semantics" are set to zero by default.
> +This means that the AT_FLAGS bits to which this document does not assign
> +an explicit meaning are to be intended reserved for future use.
> +The kernel will populate all such bits with zero until meanings are
> +assigned to them. If and when meanings are assigned, it is guaranteed
> +that they will not impact the functional operation of existing userspace
> +software. Userspace software should ignore any AT_FLAGS bit whose meaning
> +is not defined when the software is written.
> +
> +The userspace software can test for features by acquiring the AT_FLAGS
> +entry of the auxiliary vector, and testing whether a relevant flag
> +is set.
> +
> +Example of a userspace test function:
> +
> +bool feature_x_is_present(void)
> +{
> +	unsigned long at_flags = getauxval(AT_FLAGS);
> +	if (at_flags & FEATURE_X)
> +		return true;
> +
> +	return false;
> +}
> +
> +Where the software relies on a feature advertised by AT_FLAGS, it
> +should check that the feature is present before attempting to
> +use it.
> +
> +2. Features exposed via AT_FLAGS
> +--------------------------------
> +
> +bit[0]: ARM64_AT_FLAGS_SYSCALL_TBI
> +
> +    On arm64 the TCR_EL1.TBI0 bit has been set since Linux 3.x hence
> +    the userspace (EL0) is allowed to set a non-zero value in the top
> +    byte but the resulting pointers are not allowed at the user-kernel
> +    syscall ABI boundary.
> +    When bit[0] is set to 1 the kernel is advertising to the userspace
> +    that a relaxed ABI is supported hence this type of pointers are now
> +    allowed to be passed to the syscalls, when these pointers are in
> +    memory ranges obtained by anonymous (MAP_ANONYMOUS) mmap() or brk().

"TBI" is a slightly odd name.

The kernel seems not to be ignoring the top byte, otherwise how could
it make a difference whehter the memory is anonymous or something else?

(With memory tagging enabled, the top byte is also not architecturally
ignored.)

> +    In these cases the tag is preserved as the pointer goes through the
> +    kernel. Only when the kernel needs to check if a pointer is coming
> +    from userspace (i.e. access_ok()) an untag operation is required.

Does the last sentence belong here?  That's about kernel internals,
whereas the rest all seems user-facing.

> +
> +3. ARM64_AT_FLAGS_SYSCALL_TBI
> +-----------------------------
> +
> +When ARM64_AT_FLAGS_SYSCALL_TBI is enabled every syscalls can accept tagged
> +pointers, when these pointers are in memory ranges obtained by an anonymous
> +(MAP_ANONYMOUS) mmap() or brk().
> +
> +A definition of the meaning of tagged pointers on arm64 can be found in:
> +Documentation/arm64/tagged-pointers.txt.
> +
> +When a pointer does not are in a memory range obtained by an anonymous mmap()
> +or brk(), this can not be passed to a syscall if it is tagged.
> +
> +To be more explicit: a syscall can accept pointers whose memory range is
> +obtained by a non-anonymous mmap() or brk() if and only if the tag encoded in
> +the top-byte is 0x00.
> +
> +When a new syscall is added, this can accept tagged pointers if and only if
> +these pointers are in memory ranges obtained by an anonymous (MAP_ANONYMOUS)
> +mmap() or brk(). In all the other cases, the tag encoded in the top-byte is
> +expected to be 0x00.

Does this apply to kernel interfaces that are not syscalls?

And does it apply to ioctls in general (I think from discussions
elsewhere that it can't).

What about things that flow through the kernel, like an
si_value.sival_ptr that propagates from sigqueue(2) to the signal frame
of the signalled thread, or registered with the kernel via aio_read(2)?

This kind of thing is why I would like to define a set of rules for
making an educated guess about how the kernel should interpret
arbitrary arguments (in an ideal world).


With issues like this in the mix, it seems difficult to extract general
guarantees from ARM64_AT_FLAGS_SYSCALL_TBI.  If it means that just
certain specific uses of a few specific syscalls work with tagged
pointers, that may not be very useful by ifself?  It sounds like if
you are tagging memory at all, you suddenly need to port every random
library you're using.

[...]

Cheers
---Dave
