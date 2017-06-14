Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B48426B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:42:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q97so2019487wrb.14
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:42:17 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id u74si711991wrb.292.2017.06.14.10.42.16
        for <linux-mm@kvack.org>;
        Wed, 14 Jun 2017 10:42:16 -0700 (PDT)
Date: Wed, 14 Jun 2017 19:42:08 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 26/34] iommu/amd: Allow the AMD IOMMU to work with
 memory encryption
Message-ID: <20170614174208.p2yr5exs4b6pjxhf@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191745.28645.81756.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191745.28645.81756.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:17:45PM -0500, Tom Lendacky wrote:
> The IOMMU is programmed with physical addresses for the various tables
> and buffers that are used to communicate between the device and the
> driver. When the driver allocates this memory it is encrypted. In order
> for the IOMMU to access the memory as encrypted the encryption mask needs
> to be included in these physical addresses during configuration.
> 
> The PTE entries created by the IOMMU should also include the encryption
> mask so that when the device behind the IOMMU performs a DMA, the DMA
> will be performed to encrypted memory.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |    7 +++++++
>  arch/x86/mm/mem_encrypt.c          |   30 ++++++++++++++++++++++++++++++
>  drivers/iommu/amd_iommu.c          |   36 +++++++++++++++++++-----------------
>  drivers/iommu/amd_iommu_init.c     |   18 ++++++++++++------
>  drivers/iommu/amd_iommu_proto.h    |   10 ++++++++++
>  drivers/iommu/amd_iommu_types.h    |    2 +-
>  include/asm-generic/mem_encrypt.h  |    5 +++++
>  7 files changed, 84 insertions(+), 24 deletions(-)
> 
> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
> index c7a2525..d86e544 100644
> --- a/arch/x86/include/asm/mem_encrypt.h
> +++ b/arch/x86/include/asm/mem_encrypt.h
> @@ -31,6 +31,8 @@ void __init sme_early_decrypt(resource_size_t paddr,
>  
>  void __init sme_early_init(void);
>  
> +bool sme_iommu_supported(void);
> +
>  /* Architecture __weak replacement functions */
>  void __init mem_encrypt_init(void);
>  
> @@ -62,6 +64,11 @@ static inline void __init sme_early_init(void)
>  {
>  }
>  
> +static inline bool sme_iommu_supported(void)
> +{
> +	return true;
> +}

Some more file real-estate saving:

static inline bool sme_iommu_supported(void) 	{ return true; }

> +
>  #endif	/* CONFIG_AMD_MEM_ENCRYPT */
>  
>  static inline bool sme_active(void)
> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index 5d7c51d..018b58a 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -197,6 +197,36 @@ void __init sme_early_init(void)
>  		protection_map[i] = pgprot_encrypted(protection_map[i]);
>  }
>  
> +bool sme_iommu_supported(void)

Why is this one exported with all the header file declarations if it is
going to be used in the iommu code only? IOW, you can make it a static
function there and save yourself all the exporting.

> +{
> +	struct cpuinfo_x86 *c = &boot_cpu_data;
> +
> +	if (!sme_me_mask || (c->x86 != 0x17))

me_mask or sme_active()?

Or is the IOMMU "disabled" in a way the moment the BIOS decides that SME
can be enabled?

Also, family checks are always a bad idea for enablement. Why do we need
the family check? Because future families will work with the IOMMU? :-)

> +		return true;
> +
> +	/* For Fam17h, a specific level of support is required */
> +	switch (c->microcode & 0xf000) {

Also, you said in another mail on this subthread that c->microcode
is not yet set. Are you saying, that the iommu init gunk runs before
init_amd(), where we do set c->microcode?

If so, we can move the setting to early_init_amd() or so.

> +	case 0x0000:
> +		return false;
> +	case 0x1000:
> +		switch (c->microcode & 0x0f00) {
> +		case 0x0000:
> +			return false;
> +		case 0x0100:
> +			if ((c->microcode & 0xff) < 0x26)
> +				return false;
> +			break;
> +		case 0x0200:
> +			if ((c->microcode & 0xff) < 0x05)
> +				return false;
> +			break;
> +		}

So this is the microcode revision, why those complex compares? Can't you
simply check a range of values?

> +		break;
> +	}
> +
> +	return true;
> +}
> +
>  /* Architecture __weak replacement functions */
>  void __init mem_encrypt_init(void)
>  {
> diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
> index 63cacf5..94eb130 100644
> --- a/drivers/iommu/amd_iommu.c
> +++ b/drivers/iommu/amd_iommu.c
> @@ -544,7 +544,7 @@ static void dump_dte_entry(u16 devid)
>  
>  static void dump_command(unsigned long phys_addr)
>  {
> -	struct iommu_cmd *cmd = phys_to_virt(phys_addr);
> +	struct iommu_cmd *cmd = iommu_phys_to_virt(phys_addr);
>  	int i;
>  
>  	for (i = 0; i < 4; ++i)
> @@ -863,13 +863,15 @@ static void copy_cmd_to_buffer(struct amd_iommu *iommu,
>  	writel(tail, iommu->mmio_base + MMIO_CMD_TAIL_OFFSET);
>  }
>  
> -static void build_completion_wait(struct iommu_cmd *cmd, u64 address)
> +static void build_completion_wait(struct iommu_cmd *cmd, volatile u64 *sem)

WARNING: Use of volatile is usually wrong: see Documentation/process/volatile-considered-harmful.rst
#134: FILE: drivers/iommu/amd_iommu.c:866:
+static void build_completion_wait(struct iommu_cmd *cmd, volatile u64 *sem)

>  {
> +	u64 address = iommu_virt_to_phys((void *)sem);
> +
>  	WARN_ON(address & 0x7ULL);
>  
>  	memset(cmd, 0, sizeof(*cmd));
> -	cmd->data[0] = lower_32_bits(__pa(address)) | CMD_COMPL_WAIT_STORE_MASK;
> -	cmd->data[1] = upper_32_bits(__pa(address));
> +	cmd->data[0] = lower_32_bits(address) | CMD_COMPL_WAIT_STORE_MASK;
> +	cmd->data[1] = upper_32_bits(address);
>  	cmd->data[2] = 1;
>  	CMD_SET_TYPE(cmd, CMD_COMPL_WAIT);

<... snip stuff which Joerg needs to review... >

> diff --git a/include/asm-generic/mem_encrypt.h b/include/asm-generic/mem_encrypt.h
> index fb02ff0..bbc49e1 100644
> --- a/include/asm-generic/mem_encrypt.h
> +++ b/include/asm-generic/mem_encrypt.h
> @@ -27,6 +27,11 @@ static inline u64 sme_dma_mask(void)
>  	return 0ULL;
>  }
>  
> +static inline bool sme_iommu_supported(void)
> +{
> +	return true;
> +}

Save some more file real-estate... you get the idea by now, I'm sure.

:-)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
