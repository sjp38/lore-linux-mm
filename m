Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8165B6B0254
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:08:54 -0500 (EST)
Received: by ykdv3 with SMTP id v3so202009354ykd.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:08:54 -0800 (PST)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id c5si27264954ywf.184.2015.11.30.14.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 14:08:53 -0800 (PST)
Received: by ykdv3 with SMTP id v3so202008934ykd.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:08:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
References: <1448309082-20851-1-git-send-email-toshi.kani@hpe.com>
Date: Mon, 30 Nov 2015 14:08:53 -0800
Message-ID: <CAPcyv4gY2SZZwiv9DtjRk4js3gS=vf4YLJvmsMJ196aps4ZHcQ@mail.gmail.com>
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
>
> Reported-by: Mauricio Porto <mauricio.porto@hpe.com>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Matthew Wilcox <willy@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---

Hey Toshi,

I ended up fixing this differently with follow_pmd_devmap() introduced
in this series:

https://lists.01.org/pipermail/linux-nvdimm/2015-November/003033.html

Does the latest libnvdimm-pending branch [1] pass your test case?

[1]: git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm libnvdimm-pending

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
