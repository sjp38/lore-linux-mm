Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA636B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 06:19:49 -0500 (EST)
Received: by pabur14 with SMTP id ur14so102879537pab.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 03:19:49 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id rr8si7888358pab.51.2015.12.14.03.19.48
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 03:19:48 -0800 (PST)
Date: Mon, 14 Dec 2015 11:19:49 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v6 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
Message-ID: <20151214111949.GD6992@arm.com>
References: <1449856338-30984-1-git-send-email-dcashman@android.com>
 <1449856338-30984-2-git-send-email-dcashman@android.com>
 <1449856338-30984-3-git-send-email-dcashman@android.com>
 <1449856338-30984-4-git-send-email-dcashman@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449856338-30984-4-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de, jonathanh@nvidia.com

Hi Daniel,

On Fri, Dec 11, 2015 at 09:52:17AM -0800, Daniel Cashman wrote:
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
>  arch/arm64/Kconfig   | 33 +++++++++++++++++++++++++++++++++
>  arch/arm64/mm/mmap.c |  8 ++++++--
>  2 files changed, 39 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 871f217..0cc9c24 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -51,6 +51,8 @@ config ARM64
>  	select HAVE_ARCH_JUMP_LABEL
>  	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
>  	select HAVE_ARCH_KGDB
> +	select HAVE_ARCH_MMAP_RND_BITS
> +	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
>  	select HAVE_ARCH_SECCOMP_FILTER
>  	select HAVE_ARCH_TRACEHOOK
>  	select HAVE_BPF_JIT
> @@ -104,6 +106,37 @@ config ARCH_PHYS_ADDR_T_64BIT
>  config MMU
>  	def_bool y
>  
> +config ARCH_MMAP_RND_BITS_MIN
> +       default 14 if ARM64_64K_PAGES
> +       default 16 if ARM64_16K_PAGES
> +       default 18
> +
> +# max bits determined by the following formula:
> +#  VA_BITS - PAGE_SHIFT - 3

Now that we have this comment, I think we can drop the unsupported
combinations from the list below. That means we just end up with:

> +config ARCH_MMAP_RND_BITS_MAX
> +       default 19 if ARM64_VA_BITS=36
> +       default 24 if ARM64_VA_BITS=39
> +       default 27 if ARM64_VA_BITS=42
> +       default 30 if ARM64_VA_BITS=47
> +       default 29 if ARM64_VA_BITS=48 && ARM64_64K_PAGES
> +       default 31 if ARM64_VA_BITS=48 && ARM64_16K_PAGES
> +       default 33 if ARM64_VA_BITS=48

With that:

  Acked-by: Will Deacon <will.deacon@arm.com>

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
