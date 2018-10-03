Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E30F6B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 13:33:06 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id n186-v6so4247980oig.13
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 10:33:06 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d11-v6si895536oif.188.2018.10.03.10.33.04
        for <linux-mm@kvack.org>;
        Wed, 03 Oct 2018 10:33:05 -0700 (PDT)
Date: Wed, 3 Oct 2018 18:32:57 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v7 7/8] arm64: update
 Documentation/arm64/tagged-pointers.txt
Message-ID: <20181003173256.GG12998@arrakis.emea.arm.com>
References: <cover.1538485901.git.andreyknvl@google.com>
 <47a464307d4df3c0cb65f88d1fe83f9a741dd74b.1538485901.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47a464307d4df3c0cb65f88d1fe83f9a741dd74b.1538485901.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Evgeniy Stepanov <eugenis@google.com>

On Tue, Oct 02, 2018 at 03:12:42PM +0200, Andrey Konovalov wrote:
> diff --git a/Documentation/arm64/tagged-pointers.txt b/Documentation/arm64/tagged-pointers.txt
> index a25a99e82bb1..ae877d185fdb 100644
> --- a/Documentation/arm64/tagged-pointers.txt
> +++ b/Documentation/arm64/tagged-pointers.txt
> @@ -17,13 +17,21 @@ this byte for application use.
>  Passing tagged addresses to the kernel
>  --------------------------------------
>  
> -All interpretation of userspace memory addresses by the kernel assumes
> -an address tag of 0x00.
> +Some initial work for supporting non-zero address tags passed to the
> +kernel has been done. As of now, the kernel supports tags in:

With my maintainer hat on, the above statement leads me to think this
new ABI is work in progress, so not yet suitable for upstream.

Also, how is user space supposed to know that it can now pass tagged
pointers into the kernel? An ABI change (or relaxation), needs to be
advertised by the kernel, usually via a new HWCAP bit (e.g. HWCAP_TBI).
Once we have a HWCAP bit in place, we need to be pretty clear about
which syscalls can and cannot cope with tagged pointers. The "as of now"
implies potential further relaxation which, again, would need to be
advertised to user in some (additional) way.

> -This includes, but is not limited to, addresses found in:
> +  - user fault addresses

While the kernel currently supports this in some way (by clearing the
tag exception entry, el0_da), the above implies (at least to me) that
sigcontext.fault_address would contain the tagged address. That's not
the case (unless I missed it in your patches).

> - - pointer arguments to system calls, including pointers in structures
> -   passed to system calls,
> +  - pointer arguments (including pointers in structures), which don't
> +    describe virtual memory ranges, passed to system calls

I think we need to be more precise here...

> +All other interpretations of userspace memory addresses by the kernel
> +assume an address tag of 0x00. This includes, but is not limited to,
> +addresses found in:
> +
> + - pointer arguments (including pointers in structures), which describe
> +   virtual memory ranges, passed to memory system calls (mmap, mprotect,
> +   etc.)

...and probably a full list here.

-- 
Catalin
