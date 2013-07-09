Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 128CB6B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 11:38:35 -0400 (EDT)
Date: Tue, 9 Jul 2013 18:38:19 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 2/4] PF: Make KVM_HVA_ERR_BAD usable on s390
Message-ID: <20130709153819.GH24941@redhat.com>
References: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com>
 <1373378207-10451-3-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373378207-10451-3-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 09, 2013 at 03:56:45PM +0200, Dominik Dingel wrote:
> Current common code uses PAGE_OFFSET to indicate a bad host virtual address.
> As this check won't work on architectures that don't map kernel and user memory
> into the same address space (e.g. s390), an additional implementation is made
> available in the case that PAGE_OFFSET == 0.
> 
> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> ---
>  include/linux/kvm_host.h | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
> index a63d83e..f3c04e7 100644
> --- a/include/linux/kvm_host.h
> +++ b/include/linux/kvm_host.h
> @@ -85,6 +85,18 @@ static inline bool is_noslot_pfn(pfn_t pfn)
>  	return pfn == KVM_PFN_NOSLOT;
>  }
>  
> +#if (PAGE_OFFSET == 0)
> +
Please do it like I described it in the previous review. Lets not
rely on arch low level mmu details like that here.

> +#define KVM_HVA_ERR_BAD		(-1UL)
> +#define KVM_HVA_ERR_RO_BAD	(-1UL)
> +
> +static inline bool kvm_is_error_hva(unsigned long addr)
> +{
> +	return addr == KVM_HVA_ERR_BAD;
> +}
> +
> +#else
> +
>  #define KVM_HVA_ERR_BAD		(PAGE_OFFSET)
>  #define KVM_HVA_ERR_RO_BAD	(PAGE_OFFSET + PAGE_SIZE)
>  
> @@ -93,6 +105,8 @@ static inline bool kvm_is_error_hva(unsigned long addr)
>  	return addr >= PAGE_OFFSET;
>  }
>  
> +#endif
> +
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
