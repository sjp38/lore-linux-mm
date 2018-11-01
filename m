Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB94F6B026F
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 06:49:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v88-v6so16208807pfk.19
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 03:49:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o34-v6sor30068824pgm.39.2018.11.01.03.49.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Nov 2018 03:49:30 -0700 (PDT)
Date: Thu, 1 Nov 2018 21:49:26 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [RFC PATCH v1 3/4] kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE
 hcalls
Message-ID: <20181101104926.GF16399@350D>
References: <20181022051837.1165-1-bharata@linux.ibm.com>
 <20181022051837.1165-4-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022051837.1165-4-bharata@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com

On Mon, Oct 22, 2018 at 10:48:36AM +0530, Bharata B Rao wrote:
> H_SVM_INIT_START: Initiate securing a VM
> H_SVM_INIT_DONE: Conclude securing a VM
> 
> During early guest init, these hcalls will be issued by UV.
> As part of these hcalls, [un]register memslots with UV.
> 
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/hvcall.h    |  4 ++-
>  arch/powerpc/include/asm/kvm_host.h  |  1 +
>  arch/powerpc/include/asm/ucall-api.h |  6 ++++
>  arch/powerpc/kvm/book3s_hv.c         | 54 ++++++++++++++++++++++++++++
>  4 files changed, 64 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm/hvcall.h
> index 89e6b70c1857..6091276fef07 100644
> --- a/arch/powerpc/include/asm/hvcall.h
> +++ b/arch/powerpc/include/asm/hvcall.h
> @@ -300,7 +300,9 @@
>  #define H_INT_RESET             0x3D0
>  #define H_SVM_PAGE_IN		0x3D4
>  #define H_SVM_PAGE_OUT		0x3D8
> -#define MAX_HCALL_OPCODE	H_SVM_PAGE_OUT
> +#define H_SVM_INIT_START	0x3DC
> +#define H_SVM_INIT_DONE		0x3E0
> +#define MAX_HCALL_OPCODE	H_SVM_INIT_DONE
>  
>  /* H_VIOCTL functions */
>  #define H_GET_VIOA_DUMP_SIZE	0x01
> diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
> index 194e6e0ff239..267f8c568bc3 100644
> --- a/arch/powerpc/include/asm/kvm_host.h
> +++ b/arch/powerpc/include/asm/kvm_host.h
> @@ -292,6 +292,7 @@ struct kvm_arch {
>  	struct dentry *debugfs_dir;
>  	struct dentry *htab_dentry;
>  	struct kvm_resize_hpt *resize_hpt; /* protected by kvm->lock */
> +	bool svm_init_start; /* Indicates H_SVM_INIT_START has been called */
>  #endif /* CONFIG_KVM_BOOK3S_HV_POSSIBLE */
>  #ifdef CONFIG_KVM_BOOK3S_PR_POSSIBLE
>  	struct mutex hpt_mutex;
> diff --git a/arch/powerpc/include/asm/ucall-api.h b/arch/powerpc/include/asm/ucall-api.h
> index 2c12f514f8ab..9ddfcf541211 100644
> --- a/arch/powerpc/include/asm/ucall-api.h
> +++ b/arch/powerpc/include/asm/ucall-api.h
> @@ -17,4 +17,10 @@ static inline int uv_page_out(u64 lpid, u64 dw0, u64 dw1, u64 dw2, u64 dw3)
>  	return U_SUCCESS;
>  }
>  
> +static inline int uv_register_mem_slot(u64 lpid, u64 dw0, u64 dw1, u64 dw2,
> +				       u64 dw3)
> +{
> +	return 0;
> +}
> +
>  #endif	/* _ASM_POWERPC_UCALL_API_H */
> diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
> index 05084eb8aadd..47f366f634fd 100644
> --- a/arch/powerpc/kvm/book3s_hv.c
> +++ b/arch/powerpc/kvm/book3s_hv.c
> @@ -819,6 +819,50 @@ static int kvmppc_get_yield_count(struct kvm_vcpu *vcpu)
>  	return yield_count;
>  }
>  
> +#ifdef CONFIG_PPC_SVM
> +#include <asm/ucall-api.h>
> +/*
> + * TODO: Check if memslots related calls here need to be called
> + * under any lock.
> + */
> +static unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
> +{
> +	struct kvm_memslots *slots;
> +	struct kvm_memory_slot *memslot;
> +	int ret;
> +
> +	slots = kvm_memslots(kvm);
> +	kvm_for_each_memslot(memslot, slots) {
> +		ret = uv_register_mem_slot(kvm->arch.lpid,
> +					   memslot->base_gfn << PAGE_SHIFT,
> +					   memslot->npages * PAGE_SIZE,
> +					   0, memslot->id);

For every memslot their is a corresponding registration in the ultravisor?
Is there a corresponding teardown?

> +		if (ret < 0)
> +			return H_PARAMETER;
> +	}
> +	kvm->arch.svm_init_start = true;
> +	return H_SUCCESS;
> +}
> +
> +static unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
> +{
> +	if (kvm->arch.svm_init_start)
> +		return H_SUCCESS;
> +	else
> +		return H_UNSUPPORTED;
> +}
> +#else
> +static unsigned long kvmppc_h_svm_init_start(struct kvm *kvm)
> +{
> +	return H_UNSUPPORTED;
> +}
> +
> +static unsigned long kvmppc_h_svm_init_done(struct kvm *kvm)
> +{
> +	return H_UNSUPPORTED;
> +}
> +#endif
> +
>  int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
>  {
>  	unsigned long req = kvmppc_get_gpr(vcpu, 3);
> @@ -950,6 +994,12 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
>  					    kvmppc_get_gpr(vcpu, 6),
>  					    kvmppc_get_gpr(vcpu, 7));
>  		break;
> +	case H_SVM_INIT_START:
> +		ret = kvmppc_h_svm_init_start(vcpu->kvm);
> +		break;
> +	case H_SVM_INIT_DONE:
> +		ret = kvmppc_h_svm_init_done(vcpu->kvm);
> +		break;
>  	default:
>  		return RESUME_HOST;
>  	}
> @@ -978,6 +1028,8 @@ static int kvmppc_hcall_impl_hv(unsigned long cmd)
>  #endif
>  	case H_SVM_PAGE_IN:
>  	case H_SVM_PAGE_OUT:
> +	case H_SVM_INIT_START:
> +	case H_SVM_INIT_DONE:
>  		return 1;
>  	}
>  
> @@ -4413,6 +4465,8 @@ static unsigned int default_hcall_list[] = {
>  #endif
>  	H_SVM_PAGE_IN,
>  	H_SVM_PAGE_OUT,
> +	H_SVM_INIT_START,
> +	H_SVM_INIT_DONE,
>  	0
>  };
>  
> -- 
> 2.17.1
> 
