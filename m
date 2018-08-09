Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA296B0010
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 04:32:08 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d18-v6so3954189qtj.20
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 01:32:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i46-v6si6663022qta.379.2018.08.09.01.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 01:32:07 -0700 (PDT)
Date: Thu, 9 Aug 2018 04:32:06 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <2130082365.883434.1533803526182.JavaMail.zimbra@redhat.com>
In-Reply-To: <0cc6cba7020f80168695fba731b8fd72fd649dc8.1533811181.git.yi.z.zhang@linux.intel.com>
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com> <0cc6cba7020f80168695fba731b8fd72fd649dc8.1533811181.git.yi.z.zhang@linux.intel.com>
Subject: Re: [PATCH V3 4/4] kvm: add a check if pfn is from NVDIMM pmem.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, jack@suse.cz, hch@lst.de, yu c zhang <yu.c.zhang@intel.com>, linux-mm@kvack.org, rkrcmar@redhat.com, yi z zhang <yi.z.zhang@intel.com>


> 
> For device specific memory space, when we move these area of pfn to
> memory zone, we will set the page reserved flag at that time, some of
> these reserved for device mmio, and some of these are not, such as
> NVDIMM pmem.
> 
> Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
> backend, since these pages are reserved. the check of
> kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
> introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
> to indentify these pages are from NVDIMM pmem. and let kvm treat these

s/indentify/identify & remove '.'

> as normal pages.
> 
> Without this patch, Many operations will be missed due to this
> mistreatment to pmem pages. For example, a page may not have chance to
> be unpinned for KVM guest(in kvm_release_pfn_clean); not able to be
> marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc
> 
> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
> ---
>  virt/kvm/kvm_main.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index c44c406..969b6ca 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -147,8 +147,12 @@ __weak void
> kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
>  
>  bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
>  {
> -        if (pfn_valid(pfn))
> -                return PageReserved(pfn_to_page(pfn));
> +        struct page *page;
> +
> +        if (pfn_valid(pfn)) {
> +                page = pfn_to_page(pfn);
> +                return PageReserved(page) && !is_dax_page(page);
> +        }
>  
>          return true;
>  }
> --
> 2.7.4
> 
> 
