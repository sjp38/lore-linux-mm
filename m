From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 07/28] x86: Provide general kernel support for
 memory encryption
Date: Mon, 20 Feb 2017 19:38:23 +0100
Message-ID: <20170220183823.k7bsg77wbb4xyc2s@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154332.19244.55451.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170216154332.19244.55451.stgit@tlendack-t1.amdoffice.net>
Sender: linux-arch-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Feb 16, 2017 at 09:43:32AM -0600, Tom Lendacky wrote:
> Adding general kernel support for memory encryption includes:
> - Modify and create some page table macros to include the Secure Memory
>   Encryption (SME) memory encryption mask
> - Modify and create some macros for calculating physical and virtual
>   memory addresses
> - Provide an SME initialization routine to update the protection map with
>   the memory encryption mask so that it is used by default
> - #undef CONFIG_AMD_MEM_ENCRYPT in the compressed boot path
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

...

> +#define __sme_pa(x)		(__pa((x)) | sme_me_mask)
> +#define __sme_pa_nodebug(x)	(__pa_nodebug((x)) | sme_me_mask)
> +
>  #else	/* !CONFIG_AMD_MEM_ENCRYPT */
>  
>  #ifndef sme_me_mask
> @@ -35,6 +42,13 @@ static inline bool sme_active(void)
>  }
>  #endif
>  
> +static inline void __init sme_early_init(void)
> +{
> +}
> +
> +#define __sme_pa		__pa
> +#define __sme_pa_nodebug	__pa_nodebug

One more thing - in the !CONFIG_AMD_MEM_ENCRYPT case, sme_me_mask is 0
so you don't need to define __sme_pa* again.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
