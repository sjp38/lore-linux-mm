Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97B2B6B031E
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:32:11 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id h12so1209749oti.8
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:32:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor538838oie.95.2017.12.05.18.32.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 18:32:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171130180546.4331-1-rkrcmar@redhat.com>
References: <20171130161933.GB1606@flask> <20171130180546.4331-1-rkrcmar@redhat.com>
From: Wanpeng Li <kernellwp@gmail.com>
Date: Wed, 6 Dec 2017 10:32:09 +0800
Message-ID: <CANRm+Cw0OfoReDHBUDeCJ5KufumNcigQvnrgCjNc5ueZW=whxQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] KVM: x86: fix APIC page invalidation
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>
Cc: =?UTF-8?Q?Fabian_Gr=C3=BCnbichler?= <f.gruenbichler@proxmox.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kvm <kvm@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

2017-12-01 2:05 GMT+08:00 Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>:
> Implementation of the unpinned APIC page didn't update the VMCS address
> cache when invalidation was done through range mmu notifiers.
> This became a problem when the page notifier was removed.
>
> Re-introduce the arch-specific helper and call it from ...range_start.
>
> Fixes: 38b9917350cb ("kvm: vmx: Implement set_apic_access_page_addr")
> Fixes: 369ea8242c0f ("mm/rmap: update to new mmu_notifier semantic v2")
> Signed-off-by: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>

Tested-by: Wanpeng Li <wanpeng.li@hotmail.com>

I observe the windows 2016 guest hang during boot on a heavy memory
overcommit host, and this commit fixes it.

Regards,
Wanpeng Li

> ---
>  arch/x86/include/asm/kvm_host.h |  3 +++
>  arch/x86/kvm/x86.c              | 14 ++++++++++++++
>  virt/kvm/kvm_main.c             |  8 ++++++++
>  3 files changed, 25 insertions(+)
>
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_h=
ost.h
> index 977de5fb968b..c16c3f924863 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -1435,4 +1435,7 @@ static inline int kvm_cpu_get_apicid(int mps_cpu)
>  #define put_smstate(type, buf, offset, val)                      \
>         *(type *)((buf) + (offset) - 0x7e00) =3D val
>
> +void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +               unsigned long start, unsigned long end);
> +
>  #endif /* _ASM_X86_KVM_HOST_H */
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index eee8e7faf1af..a219974cdb89 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -6778,6 +6778,20 @@ static void kvm_vcpu_flush_tlb(struct kvm_vcpu *vc=
pu)
>         kvm_x86_ops->tlb_flush(vcpu);
>  }
>
> +void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +               unsigned long start, unsigned long end)
> +{
> +       unsigned long apic_address;
> +
> +       /*
> +        * The physical address of apic access page is stored in the VMCS=
.
> +        * Update it when it becomes invalid.
> +        */
> +       apic_address =3D gfn_to_hva(kvm, APIC_DEFAULT_PHYS_BASE >> PAGE_S=
HIFT);
> +       if (start <=3D apic_address && apic_address < end)
> +               kvm_make_all_cpus_request(kvm, KVM_REQ_APIC_PAGE_RELOAD);
> +}
> +
>  void kvm_vcpu_reload_apic_access_page(struct kvm_vcpu *vcpu)
>  {
>         struct page *page =3D NULL;
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index c01cff064ec5..b7f4689e373f 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -135,6 +135,11 @@ static void kvm_uevent_notify_change(unsigned int ty=
pe, struct kvm *kvm);
>  static unsigned long long kvm_createvm_count;
>  static unsigned long long kvm_active_vms;
>
> +__weak void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
> +               unsigned long start, unsigned long end)
> +{
> +}
> +
>  bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
>  {
>         if (pfn_valid(pfn))
> @@ -360,6 +365,9 @@ static void kvm_mmu_notifier_invalidate_range_start(s=
truct mmu_notifier *mn,
>                 kvm_flush_remote_tlbs(kvm);
>
>         spin_unlock(&kvm->mmu_lock);
> +
> +       kvm_arch_mmu_notifier_invalidate_range(kvm, start, end);
> +
>         srcu_read_unlock(&kvm->srcu, idx);
>  }
>
> --
> 2.14.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
