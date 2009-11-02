Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 17EDB6B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 08:03:40 -0500 (EST)
Message-ID: <4AEED8A8.9030606@redhat.com>
Date: Mon, 02 Nov 2009 15:03:36 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/11] Retry fault before vmentry
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-8-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-8-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 11/01/2009 01:56 PM, Gleb Natapov wrote:
> When page is swapped in it is mapped into guest memory only after guest
> tries to access it again and generate another fault. To save this fault
> we can map it immediately since we know that guest is going to access
> the page.
>
>    
>
> diff --git a/arch/x86/kvm/paging_tmpl.h b/arch/x86/kvm/paging_tmpl.h
> index 9fe2ecd..b1fe61f 100644
> --- a/arch/x86/kvm/paging_tmpl.h
> +++ b/arch/x86/kvm/paging_tmpl.h
> @@ -375,7 +375,7 @@ static u64 *FNAME(fetch)(struct kvm_vcpu *vcpu, gva_t addr,
>    *  Returns: 1 if we need to emulate the instruction, 0 otherwise, or
>    *           a negative value on error.
>    */
> -static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
> +static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gpa_t cr3, gva_t addr,
>   			       u32 error_code)
>   {
>   	int write_fault = error_code&  PFERR_WRITE_MASK;
> @@ -388,6 +388,7 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
>   	pfn_t pfn;
>   	int level = PT_PAGE_TABLE_LEVEL;
>   	unsigned long mmu_seq;
> +	gpa_t curr_cr3 = vcpu->arch.cr3;
>
>   	pgprintk("%s: addr %lx err %x\n", __func__, addr, error_code);
>   	kvm_mmu_audit(vcpu, "pre page fault");
> @@ -396,6 +397,13 @@ static int FNAME(page_fault)(struct kvm_vcpu *vcpu, gva_t addr,
>   	if (r)
>   		return r;
>
> +	if (curr_cr3 != cr3) {
> +		vcpu->arch.cr3 = cr3;
> +		paging_new_cr3(vcpu);
> +		if (kvm_mmu_reload(vcpu))
> +			goto switch_cr3;
> +	}
> +
>    

This is a little frightening.  I can't put my finger on anything 
though.  But playing with cr3 under the guest's feet worries me.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
