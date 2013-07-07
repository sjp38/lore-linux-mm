Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 90ED56B0033
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 05:20:45 -0400 (EDT)
Date: Sun, 7 Jul 2013 12:20:31 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 2/4] PF: Move architecture specifics to the backends
Message-ID: <20130707092031.GT5113@redhat.com>
References: <1373057754-59225-1-git-send-email-dingel@linux.vnet.ibm.com>
 <1373057754-59225-3-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373057754-59225-3-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 05, 2013 at 10:55:52PM +0200, Dominik Dingel wrote:
> Current common codes uses PAGE_OFFSET to indicate a bad host virtual address.
> As this check won't work on architectures that don't map kernel and user memory
> into the same address space (e.g. s390), it is moved into architcture specific
> code.
> 
> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> ---
>  arch/arm/include/asm/kvm_host.h     |  8 ++++++++
>  arch/ia64/include/asm/kvm_host.h    |  3 +++
>  arch/mips/include/asm/kvm_host.h    |  6 ++++++
>  arch/powerpc/include/asm/kvm_host.h |  8 ++++++++
>  arch/s390/include/asm/kvm_host.h    | 12 ++++++++++++
>  arch/x86/include/asm/kvm_host.h     |  8 ++++++++
>  include/linux/kvm_host.h            |  8 --------
>  7 files changed, 45 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/arm/include/asm/kvm_host.h b/arch/arm/include/asm/kvm_host.h
> index 7d22517..557c2a1 100644
> --- a/arch/arm/include/asm/kvm_host.h
> +++ b/arch/arm/include/asm/kvm_host.h
> @@ -74,6 +74,14 @@ struct kvm_arch {
>  	struct vgic_dist	vgic;
>  };
>  
> +#define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
> +#define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
> +
> +static inline bool kvm_is_error_hva(unsigned long addr)
> +{
> +	return addr >= PAGE_OFFSET;
> +}
> +
Instead of changing every arch I prefer to add
#ifndef KVM_HVA_ERR_BAD
#dndif
around this code in the common header and define different version for
s390 only.

A question bellow.

>  #define KVM_NR_MEM_OBJS     40
>  
>  /*
> diff --git a/arch/ia64/include/asm/kvm_host.h b/arch/ia64/include/asm/kvm_host.h
> index 989dd3f..d3afa6f 100644
> --- a/arch/ia64/include/asm/kvm_host.h
> +++ b/arch/ia64/include/asm/kvm_host.h
> @@ -486,6 +486,9 @@ struct kvm_arch {
>  	unsigned long irq_states[KVM_IOAPIC_NUM_PINS];
>  };
>  
> +#define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
> +#define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
> +
>  union cpuid3_t {
>  	u64 value;
>  	struct {
> diff --git a/arch/mips/include/asm/kvm_host.h b/arch/mips/include/asm/kvm_host.h
> index 4d6fa0b..3a0a3f7 100644
> --- a/arch/mips/include/asm/kvm_host.h
> +++ b/arch/mips/include/asm/kvm_host.h
> @@ -34,7 +34,13 @@
>  #define KVM_NR_PAGE_SIZES	1
>  #define KVM_PAGES_PER_HPAGE(x)	1
>  
> +#define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
> +#define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
>  
> +static inline bool kvm_is_error_hva(unsigned long addr)
> +{
> +	return addr >= PAGE_OFFSET;
> +}
>  
>  /* Special address that contains the comm page, used for reducing # of traps */
>  #define KVM_GUEST_COMMPAGE_ADDR     0x0
> diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
> index af326cd..be5d7f4 100644
> --- a/arch/powerpc/include/asm/kvm_host.h
> +++ b/arch/powerpc/include/asm/kvm_host.h
> @@ -273,6 +273,14 @@ struct kvm_arch {
>  #endif
>  };
>  
> +#define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
> +#define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
> +
> +static inline bool kvm_is_error_hva(unsigned long addr)
> +{
> +	return addr >= PAGE_OFFSET;
> +}
> +
>  /*
>   * Struct for a virtual core.
>   * Note: entry_exit_count combines an entry count in the bottom 8 bits
> diff --git a/arch/s390/include/asm/kvm_host.h b/arch/s390/include/asm/kvm_host.h
> index 3238d40..1588882 100644
> --- a/arch/s390/include/asm/kvm_host.h
> +++ b/arch/s390/include/asm/kvm_host.h
> @@ -274,6 +274,18 @@ struct kvm_arch{
>  	int css_support;
>  };
>  
> +#define KVM_HVA_ERR_BAD		(-1UL)
> +#define KVM_HVA_ERR_RO_BAD	(-1UL)
> +
> +static inline bool kvm_is_error_hva(unsigned long addr)
> +{
> +	/*
> +	 * on s390, this check is not needed as kernel and user memory
> +	 * is not mapped into the same address space
> +	 */
> +	return false;
> +}
> +
Can gfn_to_hva() ever return error hva on S390? Currently error hva is
returned if gfn is outside of any slot or slot is invalid.

>  extern int sie64a(struct kvm_s390_sie_block *, u64 *);
>  extern char sie_exit;
>  #endif
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index f87f7fc..07e8570 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -96,6 +96,14 @@
>  
>  #define ASYNC_PF_PER_VCPU 64
>  
> +#define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
> +#define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
> +
> +static inline bool kvm_is_error_hva(unsigned long addr)
> +{
> +	return addr >= PAGE_OFFSET;
> +}
> +
>  struct kvm_vcpu;
>  struct kvm;
>  struct kvm_async_pf;
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index a63d83e..210f493 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -85,14 +85,6 @@ static inline bool is_noslot_pfn(pfn_t pfn)
>  	return pfn == KVM_PFN_NOSLOT;
>  }
>  
> -#define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
> -#define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
> -
> -static inline bool kvm_is_error_hva(unsigned long addr)
> -{
> -	return addr >= PAGE_OFFSET;
> -}
> -
>  #define KVM_ERR_PTR_BAD_PAGE	(ERR_PTR(-ENOENT))
>  
>  static inline bool is_error_page(struct page *page)
> -- 
> 1.8.2.2

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
