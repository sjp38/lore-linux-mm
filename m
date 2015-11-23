Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id DE9F46B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 15:53:03 -0500 (EST)
Received: by wmvv187 with SMTP id v187so179988060wmv.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:53:03 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id bt17si21541531wjb.137.2015.11.23.12.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 12:53:02 -0800 (PST)
Received: by wmec201 with SMTP id c201so179731099wme.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:53:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
Date: Mon, 23 Nov 2015 12:53:02 -0800
Message-ID: <CAPcyv4gOrc_heKtBRZiiKeywo6Dn2JSTtfKgvse_1siyvd7kTg@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix mmap MAP_POPULATE for DAX pmd mapping
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, mauricio.porto@hpe.com, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Nov 23, 2015 at 12:04 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> The following oops was observed when mmap() with MAP_POPULATE
> pre-faulted pmd mappings of a DAX file.  follow_trans_huge_pmd()
> expects that a target address has a struct page.
>
>   BUG: unable to handle kernel paging request at ffffea0012220000
>   follow_trans_huge_pmd+0xba/0x390
>   follow_page_mask+0x33d/0x420
>   __get_user_pages+0xdc/0x800
>   populate_vma_page_range+0xb5/0xe0
>   __mm_populate+0xc5/0x150
>   vm_mmap_pgoff+0xd5/0xe0
>   SyS_mmap_pgoff+0x1c1/0x290
>   SyS_mmap+0x1b/0x30
>
> Fix it by making the PMD pre-fault handling consistent with PTE.
> After pre-faulted in faultin_page(), follow_page_mask() calls
> follow_trans_huge_pmd(), which is changed to call follow_pfn_pmd()
> for VM_PFNMAP or VM_MIXEDMAP.  follow_pfn_pmd() handles FOLL_TOUCH
> and returns with -EEXIST.

As of 4.4.-rc2 DAX pmd mappings are disabled.  So we have time to do
something more comprehensive in 4.5.

>
> Reported-by: Mauricio Porto <mauricio.porto@hpe.com>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Matthew Wilcox <willy@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  mm/huge_memory.c |   34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index d5b8920..f56e034 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
[..]
> @@ -1288,6 +1315,13 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>         if ((flags & FOLL_NUMA) && pmd_protnone(*pmd))
>                 goto out;
>
> +       /* pfn map does not have a struct page */
> +       if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)) {
> +               ret = follow_pfn_pmd(vma, addr, pmd, flags);
> +               page = ERR_PTR(ret);
> +               goto out;
> +       }
> +
>         page = pmd_page(*pmd);
>         VM_BUG_ON_PAGE(!PageHead(page), page);
>         if (flags & FOLL_TOUCH) {

I think it is already problematic that dax pmd mappings are getting
confused with transparent huge pages.  They're more closely related to
a hugetlbfs pmd mappings in that they are mapping an explicit
allocation.  I have some pending patches to address this dax-pmd vs
hugetlb-pmd vs thp-pmd classification that I will post shortly.

By the way, I'm collecting DAX pmd regression tests [1], is this just
a simple crash upon using MAP_POPULATE?

[1]: https://github.com/pmem/ndctl/blob/master/lib/test-dax-pmd.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
