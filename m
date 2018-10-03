Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 022116B0269
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 16:21:34 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u86-v6so6274339qku.5
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 13:21:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e27-v6si1359837qte.213.2018.10.03.13.21.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 13:21:32 -0700 (PDT)
Date: Wed, 3 Oct 2018 22:21:46 +0200
From: Eugene Syromiatnikov <esyr@redhat.com>
Subject: Re: [RFC PATCH v4 4/9] mm/mmap: Add IBT bitmap size to address space
 limit check
Message-ID: <20181003202146.GG32759@asgard.redhat.com>
References: <20180921150553.21016-1-yu-cheng.yu@intel.com>
 <20180921150553.21016-5-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921150553.21016-5-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 08:05:48AM -0700, Yu-cheng Yu wrote:
> The indirect branch tracking legacy bitmap takes a large address
> space.  This causes may_expand_vm() failure on the address limit
> check.  For a IBT-enabled task, add the bitmap size to the
> address limit.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/uapi/asm/resource.h |  5 +++++
>  include/uapi/asm-generic/resource.h  |  3 +++
>  mm/mmap.c                            | 12 +++++++++++-
>  3 files changed, 19 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/include/uapi/asm/resource.h b/arch/x86/include/uapi/asm/resource.h
> index 04bc4db8921b..0741b2a6101a 100644
> --- a/arch/x86/include/uapi/asm/resource.h
> +++ b/arch/x86/include/uapi/asm/resource.h
> @@ -1 +1,6 @@
> +/* SPDX-License-Identifier: GPL-2.0+ WITH Linux-syscall-note */
> +#ifdef CONFIG_X86_INTEL_CET
> +#define rlimit_as_extra() current->thread.cet.ibt_bitmap_size
> +#endif

Does this really belong to UAPI?

> +
>  #include <asm-generic/resource.h>
> diff --git a/include/uapi/asm-generic/resource.h b/include/uapi/asm-generic/resource.h
> index f12db7a0da64..8a7608a09700 100644
> --- a/include/uapi/asm-generic/resource.h
> +++ b/include/uapi/asm-generic/resource.h
> @@ -58,5 +58,8 @@
>  # define RLIM_INFINITY		(~0UL)
>  #endif
>  
> +#ifndef rlimit_as_extra
> +#define rlimit_as_extra() 0
> +#endif

And this?

>  #endif /* _UAPI_ASM_GENERIC_RESOURCE_H */
> diff --git a/mm/mmap.c b/mm/mmap.c
> index fa581ced3f56..397b8cb0b0af 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3237,7 +3237,17 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>   */
>  bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
>  {
> -	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
> +	unsigned long as_limit = rlimit(RLIMIT_AS);
> +	unsigned long as_limit_plus = as_limit + rlimit_as_extra();
> +
> +	/* as_limit_plus overflowed */
> +	if (as_limit_plus < as_limit)
> +		as_limit_plus = RLIM_INFINITY;
> +
> +	if (as_limit_plus > as_limit)
> +		as_limit = as_limit_plus;
> +
> +	if (mm->total_vm + npages > as_limit >> PAGE_SHIFT)

I wonder, how realistic a scenario where a userspace application enables IBT,
configures a huge prefetchable IO memory region (that just ignores bits
of offset beyond 16, for example), and start repeatedly loading a legacy
library there at different linear addresses.

>  		return false;
>  
>  	if (is_data_mapping(flags) &&
> -- 
> 2.17.1
> 
