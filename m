Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F11CE6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 20:08:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g26-v6so3797586pfo.7
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 17:08:09 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b205-v6si12791200pfb.358.2018.07.30.17.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 17:08:08 -0700 (PDT)
Message-ID: <1532995683.27283.12.camel@linux.intel.com>
Subject: Re: [PATCHv5 08/19] x86/mm: Introduce variables to store number,
 shift and mask of KeyIDs
From: Kai Huang <kai.huang@linux.intel.com>
Date: Tue, 31 Jul 2018 12:08:03 +1200
In-Reply-To: <20180717112029.42378-9-kirill.shutemov@linux.intel.com>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
	 <20180717112029.42378-9-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2018-07-17 at 14:20 +0300, Kirill A. Shutemov wrote:
> mktme_nr_keyids holds number of KeyIDs available for MKTME, excluding
> KeyID zero which used by TME. MKTME KeyIDs start from 1.
> 
> mktme_keyid_shift holds shift of KeyID within physical address.
> 
> mktme_keyid_mask holds mask to extract KeyID from physical address.

Sorry to bring this up, but AMD SME already introduced sme_me_mask, and
__sme_{set/clr} in linux/mem_encrypt.h, should we try to merge MKTME
and SME to have common variables, and reuse mem_encrypt.h? IMHO
sme_me_mask is sort of equivalent to'keyID=1'. And w/ different names
for SME and MKTME, in other components which want to use memory
encryption (ex, DMA API), we have to have explict code to distinguish
MKTME and SME IMO, which is not good.

Thanks,
-Kai
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/include/asm/mktme.h | 16 ++++++++++++++++
>  arch/x86/kernel/cpu/intel.c  | 12 ++++++++----
>  arch/x86/mm/Makefile         |  2 ++
>  arch/x86/mm/mktme.c          |  5 +++++
>  4 files changed, 31 insertions(+), 4 deletions(-)
>  create mode 100644 arch/x86/include/asm/mktme.h
>  create mode 100644 arch/x86/mm/mktme.c
> 
> diff --git a/arch/x86/include/asm/mktme.h
> b/arch/x86/include/asm/mktme.h
> new file mode 100644
> index 000000000000..df31876ec48c
> --- /dev/null
> +++ b/arch/x86/include/asm/mktme.h
> @@ -0,0 +1,16 @@
> +#ifndef	_ASM_X86_MKTME_H
> +#define	_ASM_X86_MKTME_H
> +
> +#include <linux/types.h>
> +
> +#ifdef CONFIG_X86_INTEL_MKTME
> +extern phys_addr_t mktme_keyid_mask;
> +extern int mktme_nr_keyids;
> +extern int mktme_keyid_shift;
> +#else
> +#define mktme_keyid_mask	((phys_addr_t)0)
> +#define mktme_nr_keyids		0
> +#define mktme_keyid_shift	0
> +#endif
> +
> +#endif
> diff --git a/arch/x86/kernel/cpu/intel.c
> b/arch/x86/kernel/cpu/intel.c
> index bf2caf9d52dd..efc9e9fc47d4 100644
> --- a/arch/x86/kernel/cpu/intel.c
> +++ b/arch/x86/kernel/cpu/intel.c
> @@ -573,6 +573,9 @@ static void detect_tme(struct cpuinfo_x86 *c)
>  
>  #ifdef CONFIG_X86_INTEL_MKTME
>  	if (mktme_status == MKTME_ENABLED && nr_keyids) {
> +		mktme_nr_keyids = nr_keyids;
> +		mktme_keyid_shift = c->x86_phys_bits - keyid_bits;
> +
>  		/*
>  		 * Mask out bits claimed from KeyID from physical
> address mask.
>  		 *
> @@ -580,10 +583,8 @@ static void detect_tme(struct cpuinfo_x86 *c)
>  		 * and number of bits claimed for KeyID is 6, bits
> 51:46 of
>  		 * physical address is unusable.
>  		 */
> -		phys_addr_t keyid_mask;
> -
> -		keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1, c-
> >x86_phys_bits - keyid_bits);
> -		physical_mask &= ~keyid_mask;
> +		mktme_keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1,
> mktme_keyid_shift);
> +		physical_mask &= ~mktme_keyid_mask;
>  	} else {
>  		/*
>  		 * Reset __PHYSICAL_MASK.
> @@ -591,6 +592,9 @@ static void detect_tme(struct cpuinfo_x86 *c)
>  		 * between CPUs.
>  		 */
>  		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> +		mktme_keyid_mask = 0;
> +		mktme_keyid_shift = 0;
> +		mktme_nr_keyids = 0;
>  	}
>  #endif
>  
> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> index 4b101dd6e52f..4ebee899c363 100644
> --- a/arch/x86/mm/Makefile
> +++ b/arch/x86/mm/Makefile
> @@ -53,3 +53,5 @@ obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+
> = pti.o
>  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
>  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
>  obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
> +
> +obj-$(CONFIG_X86_INTEL_MKTME)	+= mktme.o
> diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> new file mode 100644
> index 000000000000..467f1b26c737
> --- /dev/null
> +++ b/arch/x86/mm/mktme.c
> @@ -0,0 +1,5 @@
> +#include <asm/mktme.h>
> +
> +phys_addr_t mktme_keyid_mask;
> +int mktme_nr_keyids;
> +int mktme_keyid_shift;
