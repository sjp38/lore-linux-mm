Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF9D6B0007
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 14:13:06 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i12-v6so1160703pgt.13
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 11:13:06 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m37-v6si3333020plg.491.2018.06.13.11.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 11:13:05 -0700 (PDT)
Subject: Re: [PATCHv3 07/17] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-8-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8c31f6d2-6512-2726-763e-6dd1cbb0350a@intel.com>
Date: Wed, 13 Jun 2018 11:13:03 -0700
MIME-Version: 1.0
In-Reply-To: <20180612143915.68065-8-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> Encrypted VMA will have KeyID stored in vma->vm_page_prot. This way we

"An encrypted VMA..."

> don't need to do anything special to setup encrypted page table entries
> and don't need to reserve space for KeyID in a VMA.
> 
> This patch changes _PAGE_CHG_MASK to include KeyID bits. Otherwise they
> are going to be stripped from vm_page_prot on the first pgprot_modify().
> 
> Define PTE_PFN_MASK_MAX similar to PTE_PFN_MASK but based on
> __PHYSICAL_MASK_SHIFT. This way we include whole range of bits
> architecturally available for PFN without referencing physical_mask and
> mktme_keyid_mask variables.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/include/asm/pgtable_types.h | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index 1e5a40673953..e8ebe760b88d 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -121,8 +121,13 @@
>   * protection key is treated like _PAGE_RW, for
>   * instance, and is *not* included in this mask since
>   * pte_modify() does modify it.
> + *
> + * It includes full range of PFN bits regardless if they were claimed for KeyID
> + * or not: we want to preserve KeyID on pte_modify() and pgprot_modify().
>   */
> -#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
> +#define PTE_PFN_MASK_MAX \
> +	(((signed long)PAGE_MASK) & ((1ULL << __PHYSICAL_MASK_SHIFT) - 1))

"signed long" is really unusual to see.  Was that intentional?

> +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
>  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
>  			 _PAGE_SOFT_DIRTY)
>  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)

This makes me a bit nervous.  We have some places (here) where we
pretend that the KeyID is part of the paddr and then other places like
pte_pfn() where it's not.

Seems like something that will come back to bite us.
