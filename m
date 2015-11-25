Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE6F6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 23:40:04 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so45831373pab.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 20:40:03 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id x3si31281168pas.51.2015.11.24.20.40.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 20:40:03 -0800 (PST)
Message-ID: <1448426400.3762.11.camel@ellerman.id.au>
Subject: Re: [PATCH v3 1/4] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 25 Nov 2015 15:40:00 +1100
In-Reply-To: <1447888808-31571-2-git-send-email-dcashman@android.com>
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
	 <1447888808-31571-2-git-send-email-dcashman@android.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>, linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com

On Wed, 2015-11-18 at 15:20 -0800, Daniel Cashman wrote:

> From: dcashman <dcashman@google.com>
> 
> ASLR currently only uses 8 bits to generate the random offset for the
> mmap base address on 32 bit architectures. This value was chosen to
> prevent a poorly chosen value from dividing the address space in such
> a way as to prevent large allocations. This may not be an issue on all
> platforms. Allow the specification of a minimum number of bits so that
> platforms desiring greater ASLR protection may determine where to place
> the trade-off.

...

> diff --git a/arch/Kconfig b/arch/Kconfig
> index 4e949e5..141823f 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -511,6 +511,70 @@ config ARCH_HAS_ELF_RANDOMIZE
>  	  - arch_mmap_rnd()
>  	  - arch_randomize_brk()
>  
> +config HAVE_ARCH_MMAP_RND_BITS
> +	bool
> +	help
> +	  An arch should select this symbol if it supports setting a variable
> +	  number of bits for use in establishing the base address for mmap
> +	  allocations and provides values for both:
> +	  - ARCH_MMAP_RND_BITS_MIN
> +	  - ARCH_MMAP_RND_BITS_MAX
> +
> +config ARCH_MMAP_RND_BITS_MIN
> +	int
> +
> +config ARCH_MMAP_RND_BITS_MAX
> +	int
> +
> +config ARCH_MMAP_RND_BITS_DEFAULT
> +	int
> +
> +config ARCH_MMAP_RND_BITS
> +	int "Number of bits to use for ASLR of mmap base address" if EXPERT
> +	range ARCH_MMAP_RND_BITS_MIN ARCH_MMAP_RND_BITS_MAX
> +	default ARCH_MMAP_RND_BITS_DEFAULT if ARCH_MMAP_RND_BITS_DEFAULT

Here you support a default which is separate from the minimum.

> +	default ARCH_MMAP_RND_BITS_MIN
> +	depends on HAVE_ARCH_MMAP_RND_BITS

...
> +
> +config ARCH_MMAP_RND_COMPAT_BITS
> +	int "Number of bits to use for ASLR of mmap base address for compatible applications" if EXPERT
> +	range ARCH_MMAP_RND_COMPAT_BITS_MIN ARCH_MMAP_RND_COMPAT_BITS_MAX
> +	default ARCH_MMAP_RND_COMPAT_BITS_MIN

But here you don't.

Just forgot?

I'd like to have a default which is separate from the minimum. That way we can
have a default which is reasonably large, but allow it to be lowered easily if
anything breaks.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
