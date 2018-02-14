Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACB0D6B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 04:46:02 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id w19so1668098pgv.4
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 01:46:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si7924259pgv.124.2018.02.14.01.46.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Feb 2018 01:46:01 -0800 (PST)
Subject: Re: [PATCH 19/31] x86/mm/pae: Populate valid user PGD entries
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-20-git-send-email-joro@8bytes.org>
From: Juergen Gross <jgross@suse.com>
Message-ID: <3913f255-7309-58c5-b6c3-39cf0e29a844@suse.com>
Date: Wed, 14 Feb 2018 10:45:53 +0100
MIME-Version: 1.0
In-Reply-To: <1518168340-9392-20-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On 09/02/18 10:25, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
> 
> Generic page-table code populates all non-leaf entries with
> _KERNPG_TABLE bits set. This is fine for all paging modes
> except PAE.
> 
> In PAE mode only a subset of the bits is allowed to be set.
> Make sure we only set allowed bits by masking out the
> reserved bits.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/include/asm/pgtable_types.h | 26 ++++++++++++++++++++++++--
>  1 file changed, 24 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index 3696398..5027470 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -50,6 +50,7 @@
>  #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
>  #define _PAGE_SOFTW1	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW1)
>  #define _PAGE_SOFTW2	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW2)
> +#define _PAGE_SOFTW3	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW3)
>  #define _PAGE_PAT	(_AT(pteval_t, 1) << _PAGE_BIT_PAT)
>  #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
>  #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
> @@ -267,14 +268,35 @@ typedef struct pgprot { pgprotval_t pgprot; } pgprot_t;
>  
>  typedef struct { pgdval_t pgd; } pgd_t;
>  
> +#ifdef CONFIG_X86_PAE
> +
> +/*
> + * PHYSICAL_PAGE_MASK might be non-constant when SME is compiled in, so we can't
> + * use it here.
> + */
> +#define PGD_PAE_PHYS_MASK	(((1ULL << __PHYSICAL_MASK_SHIFT)-1) & PAGE_MASK)

I think PAGE_MASK is a 32 bit value here, so you are chopping off
the high physical address bits.

With that corrected the kernel is coming up as Xen PV guest.


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
