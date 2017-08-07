Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 591D56B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:21:27 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s21so893834oie.5
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:21:27 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id k27si3907507oiy.141.2017.08.07.11.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:21:26 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id 76so816949ith.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:21:26 -0700 (PDT)
Message-ID: <1502130081.1803.6.camel@gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
From: Daniel Micay <danielmicay@gmail.com>
Date: Mon, 07 Aug 2017 14:21:21 -0400
In-Reply-To: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
References: 
	<CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
Cc: Kostya Serebryany <kcc@google.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>

On Mon, 2017-08-07 at 19:24 +0200, Dmitry Vyukov wrote:
> Hello,
> 
> The recent "binfmt_elf: use ELF_ET_DYN_BASE only for PIE" patch:
> https://github.com/torvalds/linux/commit/eab09532d40090698b05a07c1c87f
> 39fdbc5fab5
> breaks user-space AddressSanitizer. AddressSanitizer makes assumptions
> about address space layout for substantial performance gains. There
> are multiple people complaining about this already:
> https://github.com/google/sanitizers/issues/837
> https://twitter.com/kayseesee/status/894594085608013825
> https://bugzilla.kernel.org/show_bug.cgi?id=196537
> AddressSanitizer maps shadow memory at [0x00007fff7000-0x10007fff7fff]
> expecting that non-pie binaries will be below 2GB and pie
> binaries/modules will be at 0x55 or 0x7f. This is not the first time
> kernel address space shuffling breaks sanitizers. The last one was the
> move to 0x55.
> 
> Is it possible to make this change less aggressive and keep the
> executable under 2G?

Using < 4G will break Android's usage of 32-bit mappings for ART, and I
think it's fair for them to assume the initial 32-bit space to be unused
with PIE since they control the libc init code, linker, etc. I expect
there are other users of MAP_32BIT / manual low addr mappings that may
break if that area is used / fragmented too.

Starting the PIE base below 4G would be a break to the userspace ABI for
code that is otherwise properly position independent with PIE but uses
the 32-bit address space range in a special way. It also wouldn't solve
the problem here since the range of 64-bit ASLR shifts is very large, so
even if the initial value is 4M it can still be placed above 2G.

The Linux kernel's executable randomization has been broken for a while
since the executable range overlapping with the mmap range and it ends
up falling back to losing the randomization in some cases. It needs to
be lower in the address space to fix that. It doesn't need to be all the
way near the bottom, but it results in less fragmentation to do it that
way.

> In future please be mindful of user-space sanitizers and talk to
> address-sanitizer@googlegroups.com before shuffling address space.

ASan chooses to hard-wire the address range for performance instead of
making it dynamic. I think it was always clearly broken to have it
generate code that isn't position independent when the compiler is being
passed -fPIC or -fPIE. It could have been made dynamic for those while
using the optimized technique for position dependent executables. The
needed address space could even be reserved as part of the executable.

Even without this recent PIE base move, ASan is broken with larger than
default vm.mmap_rnd_bits / vm.mmap_rnd_compat_bits values. It's also
broken with various supported arm64 address space configurations.

Here's an earlier issue filed about this problem with PaX:

https://github.com/google/sanitizers/issues/228

It was closed as WONTFIX 4 years ago, and now mainline has a port of
their design for executable base randomization. PaX UDEREF for x86_64
isn't upstream (yet) and that's also incompatible, since it makes the
address space smaller.

The PIE base change can likely be adjusted to use a high enough address
to leave space for ASan while not usually colliding with the mmap base
range (ignoring non-default stack rlimit possibilities). However, the
problem isn't going to go away as long as ASan is hard-wiring a range
for PIC / PIE code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
