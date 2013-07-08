Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 108216B0038
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 07:50:48 -0400 (EDT)
Subject: Re: [PATCH 2/4] PF: Move architecture specifics to the backends
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Mon, 08 Jul 2013 12:50:32 +0100
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <4a7e12c08e8973572f2bfe05cebb3dfb@www.loen.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013-07-05 21:55, Dominik Dingel wrote:
> Current common codes uses PAGE_OFFSET to indicate a bad host virtual 
> address.
> As this check won't work on architectures that don't map kernel and
> user memory
> into the same address space (e.g. s390), it is moved into architcture
> specific
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

[...]

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

Nit: This breaks arm64. I suppose the patches have been created before 
the arm64 code got merged, so I'd expect the next version of this series 
to deal with arm64 as well.

Thanks,

         M.
-- 
Fast, cheap, reliable. Pick two.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
