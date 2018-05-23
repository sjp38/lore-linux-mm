Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8646B0272
	for <linux-mm@kvack.org>; Wed, 23 May 2018 05:03:13 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p7-v6so16988372wrj.4
        for <linux-mm@kvack.org>; Wed, 23 May 2018 02:03:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 92-v6si2086978edy.384.2018.05.23.02.03.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 02:03:12 -0700 (PDT)
Date: Wed, 23 May 2018 11:03:11 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 03/11] device-dax: enable page_mapping()
Message-ID: <20180523090311.ozyfigjbhy4npkkl@quack2.suse.cz>
References: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152699998750.24093.5270058390086110946.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152699998750.24093.5270058390086110946.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, tony.luck@intel.com

On Tue 22-05-18 07:39:47, Dan Williams wrote:
> In support of enabling memory_failure() handling for device-dax
> mappings, set the ->mapping association of pages backing device-dax
> mappings. The rmap implementation requires page_mapping() to return the
> address_space hosting the vmas that map the page.
> 
> The ->mapping pointer is never cleared. There is no possibility for the
> page to become associated with another address_space while the device is
> enabled. When the device is disabled the 'struct page' array for the
> device is destroyed / later reinitialized to zero.
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
...
> @@ -402,17 +401,33 @@ static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
>  	id = dax_read_lock();
>  	switch (pe_size) {
>  	case PE_SIZE_PTE:
> -		rc = __dev_dax_pte_fault(dev_dax, vmf);
> +		fault_size = PAGE_SIZE;
> +		rc = __dev_dax_pte_fault(dev_dax, vmf, &pfn);
>  		break;
>  	case PE_SIZE_PMD:
> -		rc = __dev_dax_pmd_fault(dev_dax, vmf);
> +		fault_size = PMD_SIZE;
> +		rc = __dev_dax_pmd_fault(dev_dax, vmf, &pfn);
>  		break;
>  	case PE_SIZE_PUD:
> -		rc = __dev_dax_pud_fault(dev_dax, vmf);
> +		fault_size = PUD_SIZE;
> +		rc = __dev_dax_pud_fault(dev_dax, vmf, &pfn);
>  		break;
>  	default:
>  		rc = VM_FAULT_SIGBUS;
>  	}
> +
> +	if (rc == VM_FAULT_NOPAGE) {
> +		unsigned long i;
> +
> +		for (i = 0; i < fault_size / PAGE_SIZE; i++) {
> +			struct page *page;
> +
> +			page = pfn_to_page(pfn_t_to_pfn(pfn) + i);
> +			if (page->mapping)
> +				continue;
> +			page->mapping = filp->f_mapping;
> +		}
> +	}
>  	dax_read_unlock(id);

Careful here. Page fault can return VM_FAULT_NOPAGE even if we raced with
somebody modifying the PTE or if we installed a zero page. With shared DAX
mappings (and device dax does not allow anything else if I'm right) this
does not matter as given file offset is guaranteed to always map to the
same page but I think it deserves a comment.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
