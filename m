From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 04/28] x86: Handle reduction in physical address
 size with SME
Date: Fri, 17 Feb 2017 12:04:32 +0100
Message-ID: <20170217110432.tgi4cnkl22vyspk5@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154253.19244.70114.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170216154253.19244.70114.stgit@tlendack-t1.amdoffice.net>
Sender: linux-doc-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Feb 16, 2017 at 09:42:54AM -0600, Tom Lendacky wrote:
> When System Memory Encryption (SME) is enabled, the physical address
> space is reduced. Adjust the x86_phys_bits value to reflect this
> reduction.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/cpu/common.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
> index b33bc06..358208d7 100644
> --- a/arch/x86/kernel/cpu/common.c
> +++ b/arch/x86/kernel/cpu/common.c
> @@ -771,11 +771,15 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
>  			u64 msr;
>  
>  			/*
> -			 * For SME, BIOS support is required. If BIOS has not
> -			 * enabled SME don't advertise the feature.
> +			 * For SME, BIOS support is required. If BIOS has
> +			 * enabled SME adjust x86_phys_bits by the SME
> +			 * physical address space reduction value. If BIOS
> +			 * has not enabled SME don't advertise the feature.
>  			 */
>  			rdmsrl(MSR_K8_SYSCFG, msr);
> -			if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
> +			if (msr & MSR_K8_SYSCFG_MEM_ENCRYPT)
> +				c->x86_phys_bits -= (ebx >> 6) & 0x3f;
> +			else
>  				eax &= ~0x01;

Right, as I mentioned yesterday, this should go to arch/x86/kernel/cpu/amd.c

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
