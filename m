From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 01/20] x86: Documentation for AMD Secure Memory
 Encryption (SME)
Date: Thu, 10 Nov 2016 11:51:14 +0100
Message-ID: <20161110105114.oiwcgpb436dxrdpb@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003439.3280.82634.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161110003439.3280.82634.stgit@tlendack-t1.amdoffice.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>
List-Id: linux-mm.kvack.org

On Wed, Nov 09, 2016 at 06:34:39PM -0600, Tom Lendacky wrote:
> This patch adds a Documenation entry to decribe the AMD Secure Memory
> Encryption (SME) feature.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  Documentation/kernel-parameters.txt         |    5 +++
>  Documentation/x86/amd-memory-encryption.txt |   40 +++++++++++++++++++++++++++
>  2 files changed, 45 insertions(+)
>  create mode 100644 Documentation/x86/amd-memory-encryption.txt
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 030e9e9..4c730b0 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2282,6 +2282,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			memory contents and reserves bad memory
>  			regions that are detected.
>  
> +	mem_encrypt=	[X86-64] Enable AMD Secure Memory Encryption (SME)
> +			Memory encryption is disabled by default, using this
> +			switch, memory encryption can be enabled.

I'd say here:

			"Force-enable memory encryption if it is disabled in the
			BIOS."

> +			on: enable memory encryption
> +
>  	meye.*=		[HW] Set MotionEye Camera parameters
>  			See Documentation/video4linux/meye.txt.
>  
> diff --git a/Documentation/x86/amd-memory-encryption.txt b/Documentation/x86/amd-memory-encryption.txt
> new file mode 100644
> index 0000000..788d871
> --- /dev/null
> +++ b/Documentation/x86/amd-memory-encryption.txt
> @@ -0,0 +1,40 @@
> +Secure Memory Encryption (SME) is a feature found on AMD processors.
> +
> +SME provides the ability to mark individual pages of memory as encrypted using
> +the standard x86 page tables.  A page that is marked encrypted will be
> +automatically decrypted when read from DRAM and encrypted when written to
> +DRAM.  SME can therefore be used to protect the contents of DRAM from physical
> +attacks on the system.
> +
> +A page is encrypted when a page table entry has the encryption bit set (see
> +below how to determine the position of the bit).  The encryption bit can be
> +specified in the cr3 register, allowing the PGD table to be encrypted. Each
> +successive level of page tables can also be encrypted.
> +
> +Support for SME can be determined through the CPUID instruction. The CPUID
> +function 0x8000001f reports information related to SME:
> +
> +	0x8000001f[eax]:
> +		Bit[0] indicates support for SME
> +	0x8000001f[ebx]:
> +		Bit[5:0]  pagetable bit number used to enable memory encryption
> +		Bit[11:6] reduction in physical address space, in bits, when
> +			  memory encryption is enabled (this only affects system
> +			  physical addresses, not guest physical addresses)
> +
> +If support for SME is present, MSR 0xc00100010 (SYS_CFG) can be used to
> +determine if SME is enabled and/or to enable memory encryption:
> +
> +	0xc0010010:
> +		Bit[23]   0 = memory encryption features are disabled
> +			  1 = memory encryption features are enabled
> +
> +Linux relies on BIOS to set this bit if BIOS has determined that the reduction
> +in the physical address space as a result of enabling memory encryption (see
> +CPUID information above) will not conflict with the address space resource
> +requirements for the system.  If this bit is not set upon Linux startup then
> +Linux itself will not set it and memory encryption will not be possible.
> +
> +SME support is configurable through the AMD_MEM_ENCRYPT config option.
> +Additionally, the mem_encrypt=on command line parameter is required to activate
> +memory encryption.

So how am I to understand this? We won't have TSME or we will but it
will be off by default and users will have to enable it in the BIOS or
will have to boot with mem_encrypt=on...?

Can you please expand on all the possible options there would be
available to users?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
