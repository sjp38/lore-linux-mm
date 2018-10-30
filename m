Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80F936B04BD
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 01:31:15 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id be11-v6so8400559plb.2
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 22:31:15 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id v7-v6si22783738plp.420.2018.10.29.22.31.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Oct 2018 22:31:14 -0700 (PDT)
Date: Tue, 30 Oct 2018 16:26:46 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [RFC PATCH v1 2/4] kvmppc: Add support for shared pages in HMM
 driver
Message-ID: <20181030052646.GB11072@blackberry>
References: <20181022051837.1165-1-bharata@linux.ibm.com>
 <20181022051837.1165-3-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022051837.1165-3-bharata@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com

On Mon, Oct 22, 2018 at 10:48:35AM +0530, Bharata B Rao wrote:
> A secure guest will share some of its pages with hypervisor (Eg. virtio
> bounce buffers etc). Support shared pages in HMM driver.
> 
> Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>

Comments below...

> ---
>  arch/powerpc/kvm/book3s_hv_hmm.c | 69 ++++++++++++++++++++++++++++++--
>  1 file changed, 65 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
> index a2ee3163a312..09b8e19b7605 100644
> --- a/arch/powerpc/kvm/book3s_hv_hmm.c
> +++ b/arch/powerpc/kvm/book3s_hv_hmm.c
> @@ -50,6 +50,7 @@ struct kvmppc_hmm_page_pvt {
>  	struct hlist_head *hmm_hash;
>  	unsigned int lpid;
>  	unsigned long gpa;
> +	bool skip_page_out;
>  };
>  
>  struct kvmppc_hmm_migrate_args {
> @@ -278,6 +279,65 @@ static unsigned long kvmppc_gpa_to_hva(struct kvm *kvm, unsigned long gpa,
>  	return hva;
>  }
>  
> +/*
> + * Shares the page with HV, thus making it a normal page.
> + *
> + * - If the page is already secure, then provision a new page and share
> + * - If the page is a normal page, share the existing page
> + *
> + * In the former case, uses the HMM fault handler to release the HMM page.
> + */
> +static unsigned long
> +kvmppc_share_page(struct kvm *kvm, unsigned long gpa,
> +		  unsigned long addr, unsigned long page_shift)
> +{
> +
> +	int ret;
> +	struct hlist_head *list, *hmm_hash;
> +	unsigned int lpid = kvm->arch.lpid;
> +	unsigned long flags;
> +	struct kvmppc_hmm_pfn_entry *p;
> +	struct page *hmm_page, *page;
> +	struct kvmppc_hmm_page_pvt *pvt;
> +	unsigned long pfn;
> +
> +	/*
> +	 * First check if the requested page has already been given to
> +	 * UV as a secure page. If so, ensure that we don't issue a
> +	 * UV_PAGE_OUT but instead directly send the page
> +	 */
> +	spin_lock_irqsave(&kvmppc_hmm_lock, flags);
> +	hmm_hash = kvm->arch.hmm_hash;
> +	list = &hmm_hash[kvmppc_hmm_pfn_hash_fn(gpa)];
> +	hlist_for_each_entry(p, list, hlist) {
> +		if (p->addr == gpa) {
> +			hmm_page = pfn_to_page(p->hmm_pfn);
> +			get_page(hmm_page); /* TODO: Necessary ? */
> +			pvt = (struct kvmppc_hmm_page_pvt *)
> +				hmm_devmem_page_get_drvdata(hmm_page);
> +			pvt->skip_page_out = true;
> +			put_page(hmm_page);
> +			break;
> +		}
> +	}
> +	spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
> +
> +	ret = get_user_pages_fast(addr, 1, 0, &page);

Why are we calling this with write==0?  Surely in general the secure
guest will expect to be able to write to the shared page?

Also, in general get_user_pages_fast isn't sufficient to translate a
host virtual address (derived from a guest real address) into a pfn.
See for example hva_to_pfn() in virt/kvm/kvm_main.c and the things it
does to cope with the various cases that one can hit.  I can imagine
in future that the secure guest might want to establish a shared
mapping to a PCI device, for instance.

> +	if (ret != 1)
> +		return H_PARAMETER;
> +
> +	pfn = page_to_pfn(page);
> +	if (is_zero_pfn(pfn)) {
> +		put_page(page);
> +		return H_SUCCESS;
> +	}

The ultravisor still needs a page to map into the guest in this case,
doesn't it?  What's the point of returning without giving the
ultravisor a page to use?

> +
> +	ret = uv_page_in(lpid, pfn << page_shift, gpa, 0, page_shift);
> +	put_page(page);
> +
> +	return (ret == U_SUCCESS) ? H_SUCCESS : H_PARAMETER;
> +}
> +
>  /*
>   * Move page from normal memory to secure memory.
>   */
> @@ -300,8 +360,8 @@ kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
>  		return H_PARAMETER;
>  	end = addr + (1UL << page_shift);
>  
> -	if (flags)
> -		return H_P2;
> +	if (flags & H_PAGE_IN_SHARED)
> +		return kvmppc_share_page(kvm, gpa, addr, page_shift);

Would be best to fail if any unknown flags are set, I would think.

>  
>  	args.hmm_hash = kvm->arch.hmm_hash;
>  	args.lpid = kvm->arch.lpid;
> @@ -349,8 +409,9 @@ kvmppc_hmm_fault_migrate_alloc_and_copy(struct vm_area_struct *vma,
>  	       hmm_devmem_page_get_drvdata(spage);
>  
>  	pfn = page_to_pfn(dpage);
> -	ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
> -			  pvt->gpa, 0, PAGE_SHIFT);
> +	if (!pvt->skip_page_out)
> +		ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
> +				  pvt->gpa, 0, PAGE_SHIFT);
>  	if (ret == U_SUCCESS)
>  		*dst_pfn = migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
>  }
> -- 
> 2.17.1

Paul.
