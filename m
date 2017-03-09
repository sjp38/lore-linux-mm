Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47F966B03E2
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 14:29:46 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g10so22677385wrg.5
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 11:29:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l2si9858839wrb.253.2017.03.09.11.29.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 11:29:45 -0800 (PST)
Date: Thu, 9 Mar 2017 20:29:19 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 13/32] KVM: SVM: Enable SEV by setting the
 SEV_ENABLE CPU feature
Message-ID: <20170309192919.lt3gfqeuhlsoylu7@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846770159.2349.16863375000963463500.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <148846770159.2349.16863375000963463500.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Mar 02, 2017 at 10:15:01AM -0500, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> 
> Modify the SVM cpuid update function to indicate if Secure Encrypted
> Virtualization (SEV) is active in the guest by setting the SEV KVM CPU
> features bit. SEV is active if Secure Memory Encryption is enabled in
> the host and the SEV_ENABLE bit of the VMCB is set.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kvm/cpuid.c |    4 +++-
>  arch/x86/kvm/svm.c   |   18 ++++++++++++++++++
>  2 files changed, 21 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/kvm/cpuid.c b/arch/x86/kvm/cpuid.c
> index 1639de8..e0c40a8 100644
> --- a/arch/x86/kvm/cpuid.c
> +++ b/arch/x86/kvm/cpuid.c
> @@ -601,7 +601,7 @@ static inline int __do_cpuid_ent(struct kvm_cpuid_entry2 *entry, u32 function,
>  		entry->edx = 0;
>  		break;
>  	case 0x80000000:
> -		entry->eax = min(entry->eax, 0x8000001a);
> +		entry->eax = min(entry->eax, 0x8000001f);
>  		break;
>  	case 0x80000001:
>  		entry->edx &= kvm_cpuid_8000_0001_edx_x86_features;
> @@ -634,6 +634,8 @@ static inline int __do_cpuid_ent(struct kvm_cpuid_entry2 *entry, u32 function,
>  		break;
>  	case 0x8000001d:
>  		break;
> +	case 0x8000001f:
> +		break;

I guess those three case's can be unified:

        case 0x8000001a:
        case 0x8000001d:
        case 0x8000001f:
                break;

...

> +	sev_info = kvm_find_cpuid_entry(vcpu, 0x8000001f, 0);
> +	if (!sev_info)
> +		return;
> +
> +	if (ca->nested_ctl & SVM_NESTED_CTL_SEV_ENABLE) {
> +		features->eax |= (1 << KVM_FEATURE_SEV);
> +		cpuid(0x8000001f, &sev_info->eax, &sev_info->ebx,
> +		      &sev_info->ecx, &sev_info->edx);
> +	}

Right, as already mentioned in the previous mail: can we communicate SEV
status to the guest solely through the 0x8000001f leaf? Then we won't
need KVM_FEATURE_SEV and this way we'll be hypervisor-agnostic, as Paolo
suggested.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
