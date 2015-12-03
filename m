Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4F16B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 07:17:16 -0500 (EST)
Received: by padhx2 with SMTP id hx2so68556691pad.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 04:17:16 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d28si11792942pfj.87.2015.12.03.04.17.15
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 04:17:15 -0800 (PST)
Date: Thu, 3 Dec 2015 12:17:12 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v5 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
Message-ID: <20151203121712.GE11337@arm.com>
References: <1449000658-11475-1-git-send-email-dcashman@android.com>
 <1449000658-11475-2-git-send-email-dcashman@android.com>
 <1449000658-11475-3-git-send-email-dcashman@android.com>
 <1449000658-11475-4-git-send-email-dcashman@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449000658-11475-4-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de

Hi Daniel,

On Tue, Dec 01, 2015 at 12:10:57PM -0800, Daniel Cashman wrote:
> From: dcashman <dcashman@google.com>
> 
> arm64: arch_mmap_rnd() uses STACK_RND_MASK to generate the
> random offset for the mmap base address.  This value represents a
> compromise between increased ASLR effectiveness and avoiding
> address-space fragmentation. Replace it with a Kconfig option, which
> is sensibly bounded, so that platform developers may choose where to
> place this compromise. Keep default values as new minimums.
> 
> Signed-off-by: Daniel Cashman <dcashman@android.com>
> ---
>  arch/arm64/Kconfig   | 31 +++++++++++++++++++++++++++++++
>  arch/arm64/mm/mmap.c |  8 ++++++--
>  2 files changed, 37 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 871f217..fb57649 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -51,6 +51,8 @@ config ARM64
>  	select HAVE_ARCH_JUMP_LABEL
>  	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
>  	select HAVE_ARCH_KGDB
> +	select HAVE_ARCH_MMAP_RND_BITS if MMU
> +	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if MMU && COMPAT

You can drop the 'if MMU' bits, since we don't support !MMU on arm64.

>  	select HAVE_ARCH_SECCOMP_FILTER
>  	select HAVE_ARCH_TRACEHOOK
>  	select HAVE_BPF_JIT
> @@ -104,6 +106,35 @@ config ARCH_PHYS_ADDR_T_64BIT
>  config MMU
>  	def_bool y
>  
> +config ARCH_MMAP_RND_BITS_MIN
> +       default 15 if ARM64_64K_PAGES
> +       default 17 if ARM64_16K_PAGES
> +       default 19

Is this correct? We currently have a mask of 0x3ffff, so that's 18 bits.

> +config ARCH_MMAP_RND_BITS_MAX
> +       default 19 if ARM64_VA_BITS=36
> +       default 20 if ARM64_64K_PAGES && ARM64_VA_BITS=39
> +       default 22 if ARM64_16K_PAGES && ARM64_VA_BITS=39
> +       default 24 if ARM64_VA_BITS=39
> +       default 23 if ARM64_64K_PAGES && ARM64_VA_BITS=42
> +       default 25 if ARM64_16K_PAGES && ARM64_VA_BITS=42
> +       default 27 if ARM64_VA_BITS=42
> +       default 30 if ARM64_VA_BITS=47
> +       default 29 if ARM64_64K_PAGES && ARM64_VA_BITS=48
> +       default 31 if ARM64_16K_PAGES && ARM64_VA_BITS=48
> +       default 33 if ARM64_VA_BITS=48
> +       default 15 if ARM64_64K_PAGES
> +       default 17 if ARM64_16K_PAGES
> +       default 19

Could you add a comment above this with the formula
(VA_BITS - PAGE_SHIFT - 3), please, so that we can update this easily in
the future if we need to?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
