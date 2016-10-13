Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 60C866B0261
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:17:08 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x23so45908269lfi.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:17:08 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id 12si7894630lfz.291.2016.10.13.03.17.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 03:17:06 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id l131so9053293lfl.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:17:06 -0700 (PDT)
Subject: Re: [RFC PATCH v1 19/28] KVM: SVM: prepare to reserve asid for SEV
 guest
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190846546.9523.8365293594479732082.stgit@brijesh-build-machine>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <ed2ef47b-9a8a-9836-c6bb-effc4872d585@redhat.com>
Date: Thu, 13 Oct 2016 12:17:00 +0200
MIME-Version: 1.0
In-Reply-To: <147190846546.9523.8365293594479732082.stgit@brijesh-build-machine>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com



On 23/08/2016 01:27, Brijesh Singh wrote:
> In current implementation, asid allocation starts from 1, this patch
> adds a min_asid variable in svm_vcpu structure to allow starting asid
> from something other than 1.
> 
> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
> ---
>  arch/x86/kvm/svm.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
> index 211be94..f010b23 100644
> --- a/arch/x86/kvm/svm.c
> +++ b/arch/x86/kvm/svm.c
> @@ -470,6 +470,7 @@ struct svm_cpu_data {
>  	u64 asid_generation;
>  	u32 max_asid;
>  	u32 next_asid;
> +	u32 min_asid;
>  	struct kvm_ldttss_desc *tss_desc;
>  
>  	struct page *save_area;
> @@ -726,6 +727,7 @@ static int svm_hardware_enable(void)
>  	sd->asid_generation = 1;
>  	sd->max_asid = cpuid_ebx(SVM_CPUID_FUNC) - 1;
>  	sd->next_asid = sd->max_asid + 1;
> +	sd->min_asid = 1;
>  
>  	native_store_gdt(&gdt_descr);
>  	gdt = (struct desc_struct *)gdt_descr.address;
> @@ -1887,7 +1889,7 @@ static void new_asid(struct vcpu_svm *svm, struct svm_cpu_data *sd)
>  {
>  	if (sd->next_asid > sd->max_asid) {
>  		++sd->asid_generation;
> -		sd->next_asid = 1;
> +		sd->next_asid = sd->min_asid;
>  		svm->vmcb->control.tlb_ctl = TLB_CONTROL_FLUSH_ALL_ASID;
>  	}
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

Reviewed-by: Paolo Bonzini <pbonzini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
