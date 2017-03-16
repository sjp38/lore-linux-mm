Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B9DA16B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 07:06:57 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id r45so31506918qte.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:06:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j35si3610613qtd.148.2017.03.16.04.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 04:06:56 -0700 (PDT)
Subject: Re: [RFC PATCH v2 16/32] x86: kvm: Provide support to create Guest
 and HV shared per-CPU variables
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846773666.2349.9492983018843773590.stgit@brijesh-build-machine>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <02c00224-6b4d-4256-ead0-854755d6d0ea@redhat.com>
Date: Thu, 16 Mar 2017 12:06:44 +0100
MIME-Version: 1.0
In-Reply-To: <148846773666.2349.9492983018843773590.stgit@brijesh-build-machine>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net



On 02/03/2017 16:15, Brijesh Singh wrote:
> Some KVM specific MSR's (steal-time, asyncpf, avic_eio) allocates per-CPU
> variable at compile time and share its physical address with hypervisor.
> It presents a challege when SEV is active in guest OS. When SEV is active,
> guest memory is encrypted with guest key and hypervisor will no longer able
> to modify the guest memory. When SEV is active, we need to clear the
> encryption attribute of shared physical addresses so that both guest and
> hypervisor can access the data.
> 
> To solve this problem, I have tried these three options:
> 
> 1) Convert the static per-CPU to dynamic per-CPU allocation. When SEV is
> detected then clear the encryption attribute. But while doing so I found
> that per-CPU dynamic allocator was not ready when kvm_guest_cpu_init was
> called.
> 
> 2) Since the encryption attributes works on PAGE_SIZE hence add some extra
> padding to 'struct kvm-steal-time' to make it PAGE_SIZE and then at runtime
> clear the encryption attribute of the full PAGE. The downside of this was
> now we need to modify structure which may break the compatibility.
> 
> 3) Define a new per-CPU section (.data..percpu.hv_shared) which will be
> used to hold the compile time shared per-CPU variables. When SEV is
> detected we map this section with encryption attribute cleared.
> 
> This patch implements #3. It introduces a new DEFINE_PER_CPU_HV_SHAHRED
> macro to create a compile time per-CPU variable. When SEV is detected we
> map the per-CPU variable as decrypted (i.e with encryption attribute cleared).
> 
> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>

Looks good to me.

Paolo

> ---
>  arch/x86/kernel/kvm.c             |   43 +++++++++++++++++++++++++++++++------
>  include/asm-generic/vmlinux.lds.h |    3 +++
>  include/linux/percpu-defs.h       |    9 ++++++++
>  3 files changed, 48 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> index 099fcba..706a08e 100644
> --- a/arch/x86/kernel/kvm.c
> +++ b/arch/x86/kernel/kvm.c
> @@ -75,8 +75,8 @@ static int parse_no_kvmclock_vsyscall(char *arg)
>  
>  early_param("no-kvmclock-vsyscall", parse_no_kvmclock_vsyscall);
>  
> -static DEFINE_PER_CPU(struct kvm_vcpu_pv_apf_data, apf_reason) __aligned(64);
> -static DEFINE_PER_CPU(struct kvm_steal_time, steal_time) __aligned(64);
> +static DEFINE_PER_CPU_HV_SHARED(struct kvm_vcpu_pv_apf_data, apf_reason) __aligned(64);
> +static DEFINE_PER_CPU_HV_SHARED(struct kvm_steal_time, steal_time) __aligned(64);
>  static int has_steal_clock = 0;
>  
>  /*
> @@ -290,6 +290,22 @@ static void __init paravirt_ops_setup(void)
>  #endif
>  }
>  
> +static int kvm_map_percpu_hv_shared(void *addr, unsigned long size)
> +{
> +	/* When SEV is active, the percpu static variables initialized
> +	 * in data section will contain the encrypted data so we first
> +	 * need to decrypt it and then map it as decrypted.
> +	 */
> +	if (sev_active()) {
> +		unsigned long pa = slow_virt_to_phys(addr);
> +
> +		sme_early_decrypt(pa, size);
> +		return early_set_memory_decrypted(addr, size);
> +	}
> +
> +	return 0;
> +}
> +
>  static void kvm_register_steal_time(void)
>  {
>  	int cpu = smp_processor_id();
> @@ -298,12 +314,17 @@ static void kvm_register_steal_time(void)
>  	if (!has_steal_clock)
>  		return;
>  
> +	if (kvm_map_percpu_hv_shared(st, sizeof(*st))) {
> +		pr_err("kvm-stealtime: failed to map hv_shared percpu\n");
> +		return;
> +	}
> +
>  	wrmsrl(MSR_KVM_STEAL_TIME, (slow_virt_to_phys(st) | KVM_MSR_ENABLED));
>  	pr_info("kvm-stealtime: cpu %d, msr %llx\n",
>  		cpu, (unsigned long long) slow_virt_to_phys(st));
>  }
>  
> -static DEFINE_PER_CPU(unsigned long, kvm_apic_eoi) = KVM_PV_EOI_DISABLED;
> +static DEFINE_PER_CPU_HV_SHARED(unsigned long, kvm_apic_eoi) = KVM_PV_EOI_DISABLED;
>  
>  static notrace void kvm_guest_apic_eoi_write(u32 reg, u32 val)
>  {
> @@ -327,25 +348,33 @@ static void kvm_guest_cpu_init(void)
>  	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF) && kvmapf) {
>  		u64 pa = slow_virt_to_phys(this_cpu_ptr(&apf_reason));
>  
> +		if (kvm_map_percpu_hv_shared(this_cpu_ptr(&apf_reason),
> +					sizeof(struct kvm_vcpu_pv_apf_data)))
> +			goto skip_asyncpf;
>  #ifdef CONFIG_PREEMPT
>  		pa |= KVM_ASYNC_PF_SEND_ALWAYS;
>  #endif
>  		wrmsrl(MSR_KVM_ASYNC_PF_EN, pa | KVM_ASYNC_PF_ENABLED);
>  		__this_cpu_write(apf_reason.enabled, 1);
> -		printk(KERN_INFO"KVM setup async PF for cpu %d\n",
> -		       smp_processor_id());
> +		printk(KERN_INFO"KVM setup async PF for cpu %d msr %llx\n",
> +		       smp_processor_id(), pa);
>  	}
> -
> +skip_asyncpf:
>  	if (kvm_para_has_feature(KVM_FEATURE_PV_EOI)) {
>  		unsigned long pa;
>  		/* Size alignment is implied but just to make it explicit. */
>  		BUILD_BUG_ON(__alignof__(kvm_apic_eoi) < 4);
> +		if (kvm_map_percpu_hv_shared(this_cpu_ptr(&kvm_apic_eoi),
> +					sizeof(unsigned long)))
> +			goto skip_pv_eoi;
>  		__this_cpu_write(kvm_apic_eoi, 0);
>  		pa = slow_virt_to_phys(this_cpu_ptr(&kvm_apic_eoi))
>  			| KVM_MSR_ENABLED;
>  		wrmsrl(MSR_KVM_PV_EOI_EN, pa);
> +		printk(KERN_INFO"KVM setup PV EOI for cpu %d msr %lx\n",
> +		       smp_processor_id(), pa);
>  	}
> -
> +skip_pv_eoi:
>  	if (has_steal_clock)
>  		kvm_register_steal_time();
>  }
> diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
> index 0968d13..8d29910 100644
> --- a/include/asm-generic/vmlinux.lds.h
> +++ b/include/asm-generic/vmlinux.lds.h
> @@ -773,6 +773,9 @@
>  	. = ALIGN(cacheline);						\
>  	*(.data..percpu)						\
>  	*(.data..percpu..shared_aligned)				\
> +	. = ALIGN(PAGE_SIZE);						\
> +	*(.data..percpu..hv_shared)					\
> +	. = ALIGN(PAGE_SIZE);						\
>  	VMLINUX_SYMBOL(__per_cpu_end) = .;
>  
>  /**
> diff --git a/include/linux/percpu-defs.h b/include/linux/percpu-defs.h
> index 8f16299..5af366e 100644
> --- a/include/linux/percpu-defs.h
> +++ b/include/linux/percpu-defs.h
> @@ -172,6 +172,15 @@
>  #define DEFINE_PER_CPU_READ_MOSTLY(type, name)				\
>  	DEFINE_PER_CPU_SECTION(type, name, "..read_mostly")
>  
> +/* Declaration/definition used for per-CPU variables that must be shared
> + * between hypervisor and guest OS.
> + */
> +#define DECLARE_PER_CPU_HV_SHARED(type, name)				\
> +	DECLARE_PER_CPU_SECTION(type, name, "..hv_shared")
> +
> +#define DEFINE_PER_CPU_HV_SHARED(type, name)				\
> +	DEFINE_PER_CPU_SECTION(type, name, "..hv_shared")
> +
>  /*
>   * Intermodule exports for per-CPU variables.  sparse forgets about
>   * address space across EXPORT_SYMBOL(), change EXPORT_SYMBOL() to
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
