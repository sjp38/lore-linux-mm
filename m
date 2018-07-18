Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCECC6B026E
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 19:30:40 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 31-v6so117531pld.6
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:30:40 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j67-v6si4536747pgc.186.2018.07.18.16.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 16:30:39 -0700 (PDT)
Subject: Re: [PATCHv5 09/19] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-10-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <202c809d-8720-8dbb-51f5-1018e947a62a@intel.com>
Date: Wed, 18 Jul 2018 16:30:35 -0700
MIME-Version: 1.0
In-Reply-To: <20180717112029.42378-10-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> An encrypted VMA will have KeyID stored in vma->vm_page_prot. This way
> we don't need to do anything special to setup encrypted page table
> entries

We don't do anything special for protection keys, either.  They just
work too.

> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index 99fff853c944..3731f7e08757 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -120,8 +120,21 @@
>   * protection key is treated like _PAGE_RW, for
>   * instance, and is *not* included in this mask since
>   * pte_modify() does modify it.
> + *
> + * They include the physical address and the memory encryption keyID.
> + * The paddr and the keyID never occupy the same bits at the same time.
> + * But, a given bit might be used for the keyID on one system and used for
> + * the physical address on another. As an optimization, we manage them in
> + * one unit here since their combination always occupies the same hardware
> + * bits. PTE_PFN_MASK_MAX stores combined mask.
> + *
> + * Cast PAGE_MASK to a signed type so that it is sign-extended if
> + * virtual addresses are 32-bits but physical addresses are larger
> + * (ie, 32-bit PAE).
>   */

Could you please make the comment block consistent?  You're a lot wider
than the comment above.

> -#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
> +#define PTE_PFN_MASK_MAX \
> +	(((signed long)PAGE_MASK) & ((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
> +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
>  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
>  			 _PAGE_SOFT_DIRTY)

Man, I'm not a fan of this.  This saves us from consuming 6 VM_HIGH bits
(which we are not short on).  But, at the cost of complexity.

Protection keys eat up PTE space and have an interface called
pkey_mprotect().  MKTME KeyIDs take up PTE space and will probably have
an interface called something_mprotect().  Yet, the implementations are
going to be _very_ different with pkeys being excluded from
_PAGE_CHG_MASK and KeyIDs being included.

I think you're saved here because we don't _actually_ do pte_modify() on
an existing PTE: we blow the old one away upon encrypted_mprotect() and
replace the PTE with a new one.

But, this is incompatible with any case where we want to change the
KeyID and keep the old PTE target.  With AES-XTS, I guess this is a safe
assumption, but it's worrying.

Are there scenarios where we want to keep PTE contents, but change the
KeyID?
