Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id BF3E26B0073
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 10:01:22 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so985172wiv.8
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:01:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bf4si1876056wib.53.2014.10.22.07.01.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 07:01:20 -0700 (PDT)
Message-ID: <5447B874.5060206@redhat.com>
Date: Wed, 22 Oct 2014 16:00:20 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] s390/mm: disable KSM for storage key enabled pages
References: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com> <1413976170-42501-5-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413976170-42501-5-git-send-email-dingel@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

Reviewed-by: Paolo Bonzini <pbonzini@redhat.com>

(missing R-b on patch 1 is _not_ a mistake :))

Paolo

On 10/22/2014 01:09 PM, Dominik Dingel wrote:
> When storage keys are enabled unmerge already merged pages and prevent
> new pages from being merged.
> 
> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
> ---
>  arch/s390/include/asm/pgtable.h |  2 +-
>  arch/s390/kvm/priv.c            | 17 ++++++++++++-----
>  arch/s390/mm/pgtable.c          | 16 +++++++++++++++-
>  3 files changed, 28 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> index 0da98d6..dfb38af 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -1754,7 +1754,7 @@ static inline pte_t mk_swap_pte(unsigned long type, unsigned long offset)
>  extern int vmem_add_mapping(unsigned long start, unsigned long size);
>  extern int vmem_remove_mapping(unsigned long start, unsigned long size);
>  extern int s390_enable_sie(void);
> -extern void s390_enable_skey(void);
> +extern int s390_enable_skey(void);
>  extern void s390_reset_cmma(struct mm_struct *mm);
>  
>  /*
> diff --git a/arch/s390/kvm/priv.c b/arch/s390/kvm/priv.c
> index f89c1cd..e0967fd 100644
> --- a/arch/s390/kvm/priv.c
> +++ b/arch/s390/kvm/priv.c
> @@ -156,21 +156,25 @@ static int handle_store_cpu_address(struct kvm_vcpu *vcpu)
>  	return 0;
>  }
>  
> -static void __skey_check_enable(struct kvm_vcpu *vcpu)
> +static int __skey_check_enable(struct kvm_vcpu *vcpu)
>  {
> +	int rc = 0;
>  	if (!(vcpu->arch.sie_block->ictl & (ICTL_ISKE | ICTL_SSKE | ICTL_RRBE)))
> -		return;
> +		return rc;
>  
> -	s390_enable_skey();
> +	rc = s390_enable_skey();
>  	trace_kvm_s390_skey_related_inst(vcpu);
>  	vcpu->arch.sie_block->ictl &= ~(ICTL_ISKE | ICTL_SSKE | ICTL_RRBE);
> +	return rc;
>  }
>  
>  
>  static int handle_skey(struct kvm_vcpu *vcpu)
>  {
> -	__skey_check_enable(vcpu);
> +	int rc = __skey_check_enable(vcpu);
>  
> +	if (rc)
> +		return rc;
>  	vcpu->stat.instruction_storage_key++;
>  
>  	if (vcpu->arch.sie_block->gpsw.mask & PSW_MASK_PSTATE)
> @@ -692,7 +696,10 @@ static int handle_pfmf(struct kvm_vcpu *vcpu)
>  		}
>  
>  		if (vcpu->run->s.regs.gprs[reg1] & PFMF_SK) {
> -			__skey_check_enable(vcpu);
> +			int rc = __skey_check_enable(vcpu);
> +
> +			if (rc)
> +				return rc;
>  			if (set_guest_storage_key(current->mm, useraddr,
>  					vcpu->run->s.regs.gprs[reg1] & PFMF_KEY,
>  					vcpu->run->s.regs.gprs[reg1] & PFMF_NQ))
> diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
> index 58d7eb2..82aa528 100644
> --- a/arch/s390/mm/pgtable.c
> +++ b/arch/s390/mm/pgtable.c
> @@ -18,6 +18,8 @@
>  #include <linux/rcupdate.h>
>  #include <linux/slab.h>
>  #include <linux/swapops.h>
> +#include <linux/ksm.h>
> +#include <linux/mman.h>
>  
>  #include <asm/pgtable.h>
>  #include <asm/pgalloc.h>
> @@ -1328,22 +1330,34 @@ static int __s390_enable_skey(pte_t *pte, unsigned long addr,
>  	return 0;
>  }
>  
> -void s390_enable_skey(void)
> +int s390_enable_skey(void)
>  {
>  	struct mm_walk walk = { .pte_entry = __s390_enable_skey };
>  	struct mm_struct *mm = current->mm;
> +	struct vm_area_struct *vma;
> +	int rc = 0;
>  
>  	down_write(&mm->mmap_sem);
>  	if (mm_use_skey(mm))
>  		goto out_up;
>  
>  	mm->context.use_skey = 1;
> +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +		if (ksm_madvise(vma, vma->vm_start, vma->vm_end,
> +				MADV_UNMERGEABLE, &vma->vm_flags)) {
> +			mm->context.use_skey = 0;
> +			rc = -ENOMEM;
> +			goto out_up;
> +		}
> +	}
> +	mm->def_flags &= ~VM_MERGEABLE;
>  
>  	walk.mm = mm;
>  	walk_page_range(0, TASK_SIZE, &walk);
>  
>  out_up:
>  	up_write(&mm->mmap_sem);
> +	return rc;
>  }
>  EXPORT_SYMBOL_GPL(s390_enable_skey);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
