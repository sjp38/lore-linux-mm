Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 233836B0360
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:15:49 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id b82so1476117wmd.5
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:15:49 -0800 (PST)
Received: from proxmox-new.maurer-it.com ([212.186.127.180])
        by mx.google.com with ESMTPS id m184si365779wmm.42.2017.12.06.00.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Dec 2017 00:15:47 -0800 (PST)
Date: Wed, 6 Dec 2017 09:15:40 +0100
From: Fabian =?iso-8859-1?Q?Gr=FCnbichler?= <f.gruenbichler@proxmox.com>
Subject: Re: [PATCH 1/2] KVM: x86: fix APIC page invalidation
Message-ID: <20171206081540.zwwznkvlyq63qhqo@nora.maurer-it.com>
References: <20171130161933.GB1606@flask>
 <20171130180546.4331-1-rkrcmar@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171130180546.4331-1-rkrcmar@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Thu, Nov 30, 2017 at 07:05:45PM +0100, Radim KrA?mA!A? wrote:
> Implementation of the unpinned APIC page didn't update the VMCS address
> cache when invalidation was done through range mmu notifiers.
> This became a problem when the page notifier was removed.
> 
> Re-introduce the arch-specific helper and call it from ...range_start.
> 
> Fixes: 38b9917350cb ("kvm: vmx: Implement set_apic_access_page_addr")
> Fixes: 369ea8242c0f ("mm/rmap: update to new mmu_notifier semantic v2")
> Signed-off-by: Radim KrA?mA!A? <rkrcmar@redhat.com>

Tested-by: Fabian GrA 1/4 nbichler <f.gruenbichler@proxmox.com>

no further issues observed with this patch applied on top of 4.13 and
4.14 - thanks!

> ---
>  arch/x86/include/asm/kvm_host.h |  3 +++
>  arch/x86/kvm/x86.c              | 14 ++++++++++++++
>  virt/kvm/kvm_main.c             |  8 ++++++++
>  3 files changed, 25 insertions(+)
> 
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index 977de5fb968b..c16c3f924863 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -1435,4 +1435,7 @@ static inline int kvm_cpu_get_apicid(int mps_cpu)
>  #define put_smstate(type, buf, offset, val)                      \
>  	*(type *)((buf) + (offset) - 0x7e00) = val
>  
> +void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +		unsigned long start, unsigned long end);
> +
>  #endif /* _ASM_X86_KVM_HOST_H */
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index eee8e7faf1af..a219974cdb89 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -6778,6 +6778,20 @@ static void kvm_vcpu_flush_tlb(struct kvm_vcpu *vcpu)
>  	kvm_x86_ops->tlb_flush(vcpu);
>  }
>  
> +void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +		unsigned long start, unsigned long end)
> +{
> +	unsigned long apic_address;
> +
> +	/*
> +	 * The physical address of apic access page is stored in the VMCS.
> +	 * Update it when it becomes invalid.
> +	 */
> +	apic_address = gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_SHIFT);
> +	if (start <= apic_address && apic_address < end)
> +		kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
> +}
> +
>  void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu)
>  {
>  	struct page *page = NULL;
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index c01cff064ec5..b7f4689e373f 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -135,6 +135,11 @@ static void kvm_uevent_notify_change(unsigned int type, struct kvm *kvm);
>  static unsigned long long kvm_createvm_count;
>  static unsigned long long kvm_active_vms;
>  
> +__weak void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +		unsigned long start, unsigned long end)
> +{
> +}
> +
>  bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
>  {
>  	if (pfn_valid(pfn))
> @@ -360,6 +365,9 @@ static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
>  		kvm_flush_remote_tlbs(kvm);
>  
>  	spin_unlock(&kvm->mmu_lock);
> +
> +	kvm_arch_mmu_notifier_invalidate_range(kvm, start, end);
> +
>  	srcu_read_unlock(&kvm->srcu, idx);
>  }
>  
> -- 
> 2.14.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
