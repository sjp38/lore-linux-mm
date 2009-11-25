Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C7CCA6B0044
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 08:09:47 -0500 (EST)
Message-ID: <4B0D2C90.2060200@redhat.com>
Date: Wed, 25 Nov 2009 15:09:36 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 09/12] Retry fault before vmentry
References: <1258985167-29178-1-git-send-email-gleb@redhat.com> <1258985167-29178-10-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-10-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 11/23/2009 04:06 PM, Gleb Natapov wrote:
> When page is swapped in it is mapped into guest memory only after guest
> tries to access it again and generate another fault. To save this fault
> we can map it immediately since we know that guest is going to access
> the page.
>
>
> -static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
> +static int tdp_page_fault(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t gpa,
>   				u32 error_code)
>   {
>   	pfn_t pfn;
> @@ -2230,7 +2233,7 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa,
>   	mmu_seq = vcpu->kvm->mmu_notifier_seq;
>   	smp_rmb();
>
> -	if (can_do_async_pf(vcpu)) {
> +	if (cr3 == vcpu->arch.cr3&&  can_do_async_pf(vcpu)) {
>    

Why check cr3 here?

> -static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
> +static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t addr,
>   			       u32 error_code)
>    

I'd be slightly happier if we had a page_fault_other_cr3() op that 
switched cr3, called the original, then switched back (the tdp version 
need not change anything).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
