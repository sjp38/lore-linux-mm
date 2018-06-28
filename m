Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 785206B000A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 06:51:22 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id w15-v6so3227120otk.12
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:51:22 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w84-v6si761637oie.274.2018.06.28.03.51.21
        for <linux-mm@kvack.org>;
        Thu, 28 Jun 2018 03:51:21 -0700 (PDT)
Date: Thu, 28 Jun 2018 11:51:06 +0100
From: Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
Message-ID: <20180628105057.GA26019@e103592.cambridge.arm.com>
References: <cover.1530018818.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1530018818.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Tue, Jun 26, 2018 at 03:15:10PM +0200, Andrey Konovalov wrote:
> This patchset adds a new mode to KASAN [1], which is called KHWASAN
> (Kernel HardWare assisted Address SANitizer).
> 
> The plan is to implement HWASan [2] for the kernel with the incentive,
> that it's going to have comparable to KASAN performance, but in the same
> time consume much less memory, trading that off for somewhat imprecise
> bug detection and being supported only for arm64.
> 
> The overall idea of the approach used by KHWASAN is the following:
> 
> 1. By using the Top Byte Ignore arm64 CPU feature, we can store pointer
>    tags in the top byte of each kernel pointer.

[...]

This is a change from the current situation, so the kernel may be
making implicit assumptions about the top byte of kernel addresses.

Randomising the top bits may cause things like address conversions and
pointer arithmetic to break.

For example, (q - p) will not produce the expected result if q and p
have different tags.

Conversions, such as between pointer and pfn, may also go wrong if not
appropriately masked.

There are also potential pointer comparison and aliasing issues if
the tag bits are ever stripped or modified.


What was your approach to tracking down all the points in the code
where we have a potential issue?

(I haven't dug through the series in detail yet, so this may be
answered somewhere already...)

Cheers
---Dave
