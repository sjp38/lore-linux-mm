Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22DA76B0302
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 07:02:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id m1-v6so392838plb.13
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 04:02:23 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id a8-v6si10478503plz.94.2018.10.26.04.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 04:02:21 -0700 (PDT)
Date: Fri, 26 Oct 2018 04:02:20 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: Re: [kvm PATCH v4 1/2] kvm: vmx: refactor vmx_msrs struct for vmalloc
Message-ID: <20181026110220.GA17600@linux.intel.com>
References: <20181026075900.111462-1-marcorr@google.com>
 <20181026075900.111462-2-marcorr@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026075900.111462-2-marcorr@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>
Cc: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org

On Fri, Oct 26, 2018 at 12:58:59AM -0700, Marc Orr wrote:
> Previously, the vmx_msrs struct relied being aligned within a struct
> that is backed by the direct map (e.g., memory allocated with kalloc()).
> Specifically, this enabled the virtual addresses associated with the
> struct to be translated to physical addresses. However, we'd like to
> refactor the host struct, vcpu_vmx, to be allocated with vmalloc(), so
> that allocation will succeed when contiguous physical memory is scarce.

IMO the changelog should call out that he MSR load/store lists are
referenced in the VMCS by their physical address and therefore must be
contiguous in physical memory.  Without that knowledge it may not be
obvious as to why we care about keeping the address contigous.

> Thus, this patch refactors how vmx_msrs is declared and allocated, to
> ensure that it can be mapped to the physical address space, even when
> vmx_msrs resides within in a vmalloc()'d struct.
> 
> Signed-off-by: Marc Orr <marcorr@google.com>
> ---
>  arch/x86/kvm/vmx.c | 57 ++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 55 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> index abeeb45d1c33..3c0303cc101d 100644
> --- a/arch/x86/kvm/vmx.c
> +++ b/arch/x86/kvm/vmx.c
> @@ -970,8 +970,25 @@ static inline int pi_test_sn(struct pi_desc *pi_desc)
>  
>  struct vmx_msrs {
>  	unsigned int		nr;
> -	struct vmx_msr_entry	val[NR_AUTOLOAD_MSRS];
> +	struct vmx_msr_entry	*val;
>  };
> +struct kmem_cache *vmx_msr_entry_cache;
> +
> +/*
> + * To prevent vmx_msr_entry array from crossing a page boundary, require:
> + * sizeof(*vmx_msrs.vmx_msr_entry.val) to be a power of two. This is guaranteed
> + * through compile-time asserts that:
> + *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) is a power of two
> + *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) <= PAGE_SIZE
> + *   - The allocation of vmx_msrs.vmx_msr_entry.val is aligned to its size.
> + */

Nit: the alignment isn't an assertion, it's simply "the code".  It'd
     also be nice to fold in the requirement about the lists being
     physically contigous.

Maybe:

	/*
	 * The VMCS references the MSR load/store lists by their physical
	 * address, i.e. the vmx_msr_entry structs must be contigous in
	 * physical memory.  Ensure this by aligning allocations to the max
	 * size of the lists and asserting that the max size is a power of
	 * two and less than PAGE_SIZE.
	 */

> +#define CHECK_POWER_OF_TWO(val) \
> +	BUILD_BUG_ON_MSG(!((val) && !((val) & ((val) - 1))), \
> +	#val " is not a power of two.")
> +#define CHECK_INTRA_PAGE(val) do { \
> +		CHECK_POWER_OF_TWO(val); \
> +		BUILD_BUG_ON(!(val <= PAGE_SIZE)); \
> +	} while (0)

You can use is_power_of_2(), no need to define your own.  And I think
it'd be better to use BUILD_BUG_ON directly in vmx_init() given that
the big comment is all about vmx_msrs, i.e. it's probably not worth
defining CHECK_INTRA_PAGE at this time.

>  struct vcpu_vmx {
>  	struct kvm_vcpu       vcpu;
> @@ -11489,6 +11506,19 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
>  	if (!vmx)
>  		return ERR_PTR(-ENOMEM);
>  
> +	vmx->msr_autoload.guest.val =
> +		kmem_cache_zalloc(vmx_msr_entry_cache, GFP_KERNEL);

Technically this doesn't need GFP_ZERO, we should never read an MSR
entry that hasn't been explicitly written, i.e. we always check
vmx_msrs.nr before dereferencing vmx_msrs.val.

> +	if (!vmx->msr_autoload.guest.val) {
> +		err = -ENOMEM;
> +		goto free_vmx;
> +	}
> +	vmx->msr_autoload.host.val =
> +		kmem_cache_zalloc(vmx_msr_entry_cache, GFP_KERNEL);
> +	if (!vmx->msr_autoload.host.val) {
> +		err = -ENOMEM;
> +		goto free_msr_autoload_guest;
> +	}
> +
>  	vmx->vpid = allocate_vpid();
>  
>  	err = kvm_vcpu_init(&vmx->vcpu, kvm, id);
> @@ -11576,6 +11606,10 @@ static struct kvm_vcpu *vmx_create_vcpu(struct kvm *kvm, unsigned int id)
>  	kvm_vcpu_uninit(&vmx->vcpu);
>  free_vcpu:
>  	free_vpid(vmx->vpid);
> +	kmem_cache_free(vmx_msr_entry_cache, vmx->msr_autoload.host.val);
> +free_msr_autoload_guest:
> +	kmem_cache_free(vmx_msr_entry_cache, vmx->msr_autoload.guest.val);
> +free_vmx:
>  	kmem_cache_free(kvm_vcpu_cache, vmx);
>  	return ERR_PTR(err);
>  }
> @@ -15153,6 +15187,10 @@ module_exit(vmx_exit);
>  static int __init vmx_init(void)
>  {
>  	int r;
> +	size_t vmx_msr_entry_size =
> +		sizeof(struct vmx_msr_entry) * NR_AUTOLOAD_MSRS;
> +
> +	CHECK_INTRA_PAGE(vmx_msr_entry_size);
>  
>  #if IS_ENABLED(CONFIG_HYPERV)
>  	/*
> @@ -15184,9 +15222,21 @@ static int __init vmx_init(void)
>  #endif
>  
>  	r = kvm_init(&vmx_x86_ops, sizeof(struct vcpu_vmx),
> -		     __alignof__(struct vcpu_vmx), THIS_MODULE);
> +		__alignof__(struct vcpu_vmx), THIS_MODULE);

Unrelated whitespace change.

>  	if (r)
>  		return r;
> +	/*
> +	 * A vmx_msr_entry array resides exclusively within the kernel. Thus,
> +	 * use kmem_cache_create_usercopy(), with the usersize argument set to
> +	 * ZERO, to blacklist copying vmx_msr_entry to/from user space.
> +	 */
> +	vmx_msr_entry_cache =
> +		kmem_cache_create_usercopy("vmx_msr_entry", vmx_msr_entry_size,
> +				  vmx_msr_entry_size, SLAB_ACCOUNT, 0, 0, NULL);
> +	if (!vmx_msr_entry_cache) {
> +		r = -ENOMEM;
> +		goto out;
> +	}
>  
>  	/*
>  	 * Must be called after kvm_init() so enable_ept is properly set
> @@ -15210,5 +15260,8 @@ static int __init vmx_init(void)
>  	vmx_check_vmcs12_offsets();
>  
>  	return 0;
> +out:
> +	kvm_exit();
> +	return r;

Three things:
  - This needs to be vmx_exit(), e.g. to undo the eVMCS stuff.
  - The cache needs to be destroyed in vmx_exit().
  - Either remove the label/goto or convert the vmx_setup_l1d_flush()
    failure path to use "goto out".

>  }
>  module_init(vmx_init);
> -- 
> 2.19.1.568.g152ad8e336-goog
> 
