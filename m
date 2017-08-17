Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D32776B02F4
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 05:10:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y44so8309185wrd.13
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 02:10:07 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id z2si2712750edl.466.2017.08.17.02.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 02:10:06 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id y67so7268757wrb.3
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 02:10:06 -0700 (PDT)
Date: Thu, 17 Aug 2017 11:10:03 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 09/14] x86/mm: Handle boot-time paging mode switching
 at early boot
Message-ID: <20170817091003.qls64kolj7iec3qc@gmail.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
 <20170808125415.78842-10-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808125415.78842-10-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> This patch adds detection of 5-level paging at boot-time and adjusts
> virtual memory layout and folds p4d page table layer if needed.
> 
> We have to make X86_5LEVEL dependant on SPARSEMEM_VMEMMAP.
> !SPARSEMEM_VMEMMAP configuration doesn't work well with variable
> MAX_PHYSMEM_BITS.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/Kconfig                        |  1 +
>  arch/x86/boot/compressed/kaslr.c        | 13 +++++--
>  arch/x86/entry/entry_64.S               | 12 +++++++
>  arch/x86/include/asm/page_64_types.h    | 13 +++----
>  arch/x86/include/asm/pgtable_64_types.h | 35 +++++++++++--------
>  arch/x86/include/asm/processor.h        |  2 +-
>  arch/x86/include/asm/sparsemem.h        |  9 ++---
>  arch/x86/kernel/head64.c                | 60 ++++++++++++++++++++++++++-------
>  arch/x86/kernel/head_64.S               | 18 ++++++----
>  arch/x86/kernel/setup.c                 |  5 ++-
>  arch/x86/mm/dump_pagetables.c           |  8 +++--
>  arch/x86/mm/kaslr.c                     | 13 ++++---
>  12 files changed, 129 insertions(+), 60 deletions(-)

Please also split this patch up some more, into as many individual (but 
bisectable) changes as possible.

> diff --git a/arch/x86/include/asm/sparsemem.h b/arch/x86/include/asm/sparsemem.h
> index 1f5bee2c202f..ba67afd870b7 100644
> --- a/arch/x86/include/asm/sparsemem.h
> +++ b/arch/x86/include/asm/sparsemem.h
> @@ -26,13 +26,8 @@
>  # endif
>  #else /* CONFIG_X86_32 */
>  # define SECTION_SIZE_BITS	27 /* matt - 128 is convenient right now */
> -# ifdef CONFIG_X86_5LEVEL
> -#  define MAX_PHYSADDR_BITS	52
> -#  define MAX_PHYSMEM_BITS	52
> -# else
> -#  define MAX_PHYSADDR_BITS	44
> -#  define MAX_PHYSMEM_BITS	46
> -# endif
> +# define MAX_PHYSADDR_BITS	(p4d_folded ? 44 : 52)
> +# define MAX_PHYSMEM_BITS	(p4d_folded ? 46 : 52)
>  #endif

The kernel code size impact of these de-constification changes should be measured, 
double checked and documented as well. We are adding all kinds of overhead to 
(what I expect to be) commonly used kernels, let's do it carefully.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
