Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 934936B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 20:56:14 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 14so255621oii.6
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:56:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w68sor2648928oiw.296.2017.10.10.17.56.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 17:56:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1507663581-37864-1-git-send-email-peng.hao2@zte.com.cn>
References: <1507663581-37864-1-git-send-email-peng.hao2@zte.com.cn>
From: Wanpeng Li <kernellwp@gmail.com>
Date: Wed, 11 Oct 2017 08:56:12 +0800
Message-ID: <CANRm+CzopYYJb2ka=iBHoXBpXTXEy4mECG3c-ovCtQHbJRk=EQ@mail.gmail.com>
Subject: Re: [PATCH] KVM: X86: clear page flags when freeing kvm mmapping page
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peng Hao <peng.hao2@zte.com.cn>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, kvm <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Cc mm community.
2017-10-11 3:26 GMT+08:00 Peng Hao <peng.hao2@zte.com.cn>:
> When freeing mmapped kvm_run several pages, the pages will have page
> flags PG_dirty and PG_referenced. It will result to bad page report
> when allocating pages.
> I just encounter once like this;
> BUG: Bad page state in process qemu-system-x86  pfn:81fc5d
> page:ffffea00207f1740 count:0 mapcount:0 mapping:          (null) index:0=
x4
> flags: 0x600000000000014(referenced|dirty)
> raw: 0600000000000014 0000000000000000 0000000000000004 00000000ffffffff
> raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
> page dumped because: PAGE_FLAGS_CHECK_AT_PREP flag set
> bad because of flags: 0x14(referenced|dirty)
> Modules linked in: kvm_intel kvm vhost_net vhost tap xt_CHECKSUM iptable_=
mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat xt_conntrack ipt_R=
EJECT xt_tcpudp ebtable_filter ebtables ip6table_filter ip6_tables iptable_=
filter openvswitch nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_i=
pv4 nf_nat intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp coretem=
p crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel aes_x86_64 =
mei_me crypto_simd input_leds cryptd led_class joydev shpchp mei wmi lpc_ic=
h glue_helper mfd_core acpi_power_meter acpi_pad irqbypass ip_tables x_tabl=
es megaraid_sas [last unloaded: kvm_intel]
> CPU: 7 PID: 37349 Comm: qemu-system-x86 Tainted: G        W       4.13.0-=
rc6nfv+ #1
> Hardware name: Dell Inc. PowerEdge R720/068CDY, BIOS 2.2.2 01/16/2014
> Call Trace:
> dump_stack+0x63/0x8c
> bad_page+0xfe/0x11a
> check_new_page_bad+0x76/0x78
> get_page_from_freelist+0x65e/0xa00
> __alloc_pages_nodemask+0xf6/0x270
> alloc_pages_vma+0x6b/0x110
> __handle_mm_fault+0x4e2/0xb20
> handle_mm_fault+0xd8/0x1f0
> __do_page_fault+0x215/0x4b0
> do_page_fault+0x32/0x90
> page_fault+0x28/0x30
> RIP: 0033:0x7f68ca7d94fc
> RSP: 002b:00007ffe911a3570 EFLAGS: 00010216
> RAX: 00005599e0240a30 RBX: 00005599e023e920 RCX: 0000000000006c41
> RDX: 00007f68cab157b8 RSI: 0000000061d00000 RDI: 0000000000000003
> RBP: 00007f68cab15760 R08: 0000000000020000 R09: 0000000000002100
> R10: 000000000000006b R11: 0000000000000000 R12: 0000000000004b30
> R13: 0000000000006c40 R14: 0000000000002110 R15: 00007f68cab157b8
>
> Signed-off-by: Peng Hao <peng.hao2@zte.com.cn>
> ---
>  arch/x86/kvm/x86.c        | 5 ++++-
>  virt/kvm/coalesced_mmio.c | 8 ++++++--
>  virt/kvm/kvm_main.c       | 5 ++++-
>  3 files changed, 14 insertions(+), 4 deletions(-)
>
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index cd17b7d..82e5ac1 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -8058,6 +8058,7 @@ int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
>  void kvm_arch_vcpu_uninit(struct kvm_vcpu *vcpu)
>  {
>         int idx;
> +       struct page *page =3D virt_to_page(vcpu->arch.pio_data);
>
>         kvm_hv_vcpu_uninit(vcpu);
>         kvm_pmu_destroy(vcpu);
> @@ -8066,7 +8067,9 @@ void kvm_arch_vcpu_uninit(struct kvm_vcpu *vcpu)
>         idx =3D srcu_read_lock(&vcpu->kvm->srcu);
>         kvm_mmu_destroy(vcpu);
>         srcu_read_unlock(&vcpu->kvm->srcu, idx);
> -       free_page((unsigned long)vcpu->arch.pio_data);
> +       ClearPageDirty(page);
> +       ClearPageReferenced(page);

These flags should be handled by core mm instead of kvm if there is a
bug in core mm.

Regards,
Wanpeng Li

> +       __free_page(page);
>         if (!lapic_in_kernel(vcpu))
>                 static_key_slow_dec(&kvm_no_apic_vcpu);
>  }
> diff --git a/virt/kvm/coalesced_mmio.c b/virt/kvm/coalesced_mmio.c
> index 571c1ce..bd834a4 100644
> --- a/virt/kvm/coalesced_mmio.c
> +++ b/virt/kvm/coalesced_mmio.c
> @@ -129,8 +129,12 @@ int kvm_coalesced_mmio_init(struct kvm *kvm)
>
>  void kvm_coalesced_mmio_free(struct kvm *kvm)
>  {
> -       if (kvm->coalesced_mmio_ring)
> -               free_page((unsigned long)kvm->coalesced_mmio_ring);
> +       if (kvm->coalesced_mmio_ring) {
> +               struct page *page =3D virt_to_page(kvm->coalesced_mmio_ri=
ng);
> +               ClearPageDirty(page);
> +               ClearPageReferenced(page);
> +               __free_page(page);
> +       }
>  }
>
>  int kvm_vm_ioctl_register_coalesced_mmio(struct kvm *kvm,
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 9deb5a2..ee65972 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -305,6 +305,7 @@ int kvm_vcpu_init(struct kvm_vcpu *vcpu, struct kvm *=
kvm, unsigned id)
>
>  void kvm_vcpu_uninit(struct kvm_vcpu *vcpu)
>  {
> +       struct page *page =3D virt_to_page(vcpu->run);
>         /*
>          * no need for rcu_read_lock as VCPU_RUN is the only place that
>          * will change the vcpu->pid pointer and on uninit all file
> @@ -312,7 +313,9 @@ void kvm_vcpu_uninit(struct kvm_vcpu *vcpu)
>          */
>         put_pid(rcu_dereference_protected(vcpu->pid, 1));
>         kvm_arch_vcpu_uninit(vcpu);
> -       free_page((unsigned long)vcpu->run);
> +       ClearPageDirty(page);
> +       ClearPageReferenced(page);
> +       __free_page(page);
>  }
>  EXPORT_SYMBOL_GPL(kvm_vcpu_uninit);
>
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
