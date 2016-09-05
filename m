From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v2 07/20] x86: Provide general kernel support for
 memory encryption
Date: Mon, 5 Sep 2016 10:48:17 +0200
Message-ID: <20160905084817.GB18856@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223646.29880.28794.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160822223646.29880.28794.stgit@tlendack-t1.amdoffice.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.>
List-Id: linux-mm.kvack.org

On Mon, Aug 22, 2016 at 05:36:46PM -0500, Tom Lendacky wrote:
> Adding general kernel support for memory encryption includes:
> - Modify and create some page table macros to include the Secure Memory
>   Encryption (SME) memory encryption mask
> - Update kernel boot support to call an SME routine that checks for and
>   sets the SME capability (the SME routine will grow later and for now
>   is just a stub routine)
> - Update kernel boot support to call an SME routine that encrypts the
>   kernel (the SME routine will grow later and for now is just a stub
>   routine)
> - Provide an SME initialization routine to update the protection map with
>   the memory encryption mask so that it is used by default
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---

...

> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index f1218f5..a01f0e1 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -3,6 +3,7 @@
>  
>  #include <linux/const.h>
>  #include <asm/page_types.h>
> +#include <asm/mem_encrypt.h>
>  
>  #define FIRST_USER_ADDRESS	0UL
>  
> @@ -121,9 +122,9 @@
>  
>  #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
>  
> -#define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
> +#define __PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
>  			 _PAGE_ACCESSED | _PAGE_DIRTY)

Hmm, so this naming looks confusing and error-prone: the only difference
is a single "_".

How about this instead:

#define _PAGE_TABLE_NO_ENC	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
	  			 _PAGE_ACCESSED | _PAGE_DIRTY)

#define _PAGE_TABLE (_PAGE_TABLE_NO_ENC | _PAGE_ENC)

Or call it _PAGE_TABLE_BASE or whatever.

Ditto for __KERNPG_TABLE.

This way you can differentiate between the two and use the _NO_ENC one
to define _PAGE_TABLE. And it will be absolutely clear when you use the
_NO_ENC one, what you mean and that you don't want to have the enc mask
in the PTE.

Should be less confusing IMO too.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
