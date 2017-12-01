Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2785C6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:15:43 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id c85so4424300oib.13
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:15:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j23si2064747oih.99.2017.12.01.07.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 07:15:42 -0800 (PST)
Subject: Re: [PATCH 2/2] TESTING! KVM: x86: add invalidate_range mmu notifier
References: <20171130161933.GB1606@flask>
 <20171130180546.4331-1-rkrcmar@redhat.com>
 <20171130180546.4331-2-rkrcmar@redhat.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <4e0b6e81-b987-487e-b582-4d61aec9252d@redhat.com>
Date: Fri, 1 Dec 2017 16:15:37 +0100
MIME-Version: 1.0
In-Reply-To: <20171130180546.4331-2-rkrcmar@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, =?UTF-8?Q?Fabian_Gr=c3=bcnbichler?= <f.gruenbichler@proxmox.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 30/11/2017 19:05, Radim KrA?mA!A? wrote:
> Does roughly what kvm_mmu_notifier_invalidate_page did before.
> 
> I am not certain why this would be needed.  It might mean that we have
> another bug with start/end or just that I missed something.

I don't think this is needed, because we don't have shared page tables.
My understanding is that without shared page tables, you can assume that
all page modifications go through invalidate_range_start/end.  With
shared page tables, there are additional TLB flushes to take care of,
which require invalidate_range.

Thanks,

Paolo

> Please try just [1/2] first and apply this one only if [1/2] still bugs,
> thanks!
> ---
>  virt/kvm/kvm_main.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index b7f4689e373f..0825ea624f16 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -342,6 +342,29 @@ static void kvm_mmu_notifier_change_pte(struct mmu_notifier *mn,
>  	srcu_read_unlock(&kvm->srcu, idx);
>  }
>  
> +static void kvm_mmu_notifier_invalidate_range(struct mmu_notifier *mn,
> +						    struct mm_struct *mm,
> +						    unsigned long start,
> +						    unsigned long end)
> +{
> +	struct kvm *kvm = mmu_notifier_to_kvm(mn);
> +	int need_tlb_flush = 0, idx;
> +
> +	idx = srcu_read_lock(&kvm->srcu);
> +	spin_lock(&kvm->mmu_lock);
> +	kvm->mmu_notifier_seq++;
> +	need_tlb_flush = kvm_unmap_hva_range(kvm, start, end);
> +	need_tlb_flush |= kvm->tlbs_dirty;
> +	if (need_tlb_flush)
> +		kvm_flush_remote_tlbs(kvm);
> +
> +	spin_unlock(&kvm->mmu_lock);
> +
> +	kvm_arch_mmu_notifier_invalidate_range(kvm, start, end);
> +
> +	srcu_read_unlock(&kvm->srcu, idx);
> +}
> +
>  static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
>  						    struct mm_struct *mm,
>  						    unsigned long start,
> @@ -476,6 +499,7 @@ static void kvm_mmu_notifier_release(struct mmu_notifier *mn,
>  }
>  
>  static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
> +	.invalidate_range	= kvm_mmu_notifier_invalidate_range,
>  	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
>  	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
>  	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
