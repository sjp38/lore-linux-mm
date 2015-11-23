Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id B333F6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 15:50:20 -0500 (EST)
Received: by obbnk6 with SMTP id nk6so112215693obb.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:50:20 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id p3si9463606oeq.99.2015.11.23.12.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 12:50:20 -0800 (PST)
Message-ID: <1448311559.19320.2.camel@hpe.com>
Subject: Re: [PATCH] dax: Split pmd map when fallback on COW
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 23 Nov 2015 13:45:59 -0700
In-Reply-To: <CAPcyv4ibgtMJdKG19vaS_s2_eFy8ufZm92G2DH6N7brDiE+LYA@mail.gmail.com>
References: <1448309120-20911-1-git-send-email-toshi.kani@hpe.com>
	 <CAPcyv4ibgtMJdKG19vaS_s2_eFy8ufZm92G2DH6N7brDiE+LYA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, 2015-11-23 at 12:45 -0800, Dan Williams wrote:
> On Mon, Nov 23, 2015 at 12:05 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> > An infinite loop of PMD faults was observed when attempted to
> > mlock() a private read-only PMD mmap'd range of a DAX file.
> > 
> > __dax_pmd_fault() simply returns with VM_FAULT_FALLBACK when
> > falling back to PTE on COW.  However, __handle_mm_fault()
> > returns without falling back to handle_pte_fault() because
> > a PMD map is present in this case.
> > 
> > Change __dax_pmd_fault() to split the PMD map, if present,
> > before returning with VM_FAULT_FALLBACK.
> > 
> > Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Matthew Wilcox <willy@linux.intel.com>
> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> I thought the patch from Ross already addressed the infinite loop:
> 
> https://patchwork.kernel.org/patch/7653731/

This fixes a different issue.  I hit this one while testing my other patch along
with the Ross's patch.

> > ---
> >  fs/dax.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 43671b6..3405583 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -546,8 +546,10 @@ int __dax_pmd_fault(struct vm_area_struct *vma,
> > unsigned long address,
> >                 return VM_FAULT_FALLBACK;
> > 
> >         /* Fall back to PTEs if we're going to COW */
> > -       if (write && !(vma->vm_flags & VM_SHARED))
> > +       if (write && !(vma->vm_flags & VM_SHARED)) {
> > +               split_huge_page_pmd(vma, address, pmd);
> >                 return VM_FAULT_FALLBACK;
> > +       }
> >         /* If the PMD would extend outside the VMA */
> >         if (pmd_addr < vma->vm_start)
> >                 return VM_FAULT_FALLBACK;
> 
> This is a nop if CONFIG_TRANSPARENT_HUGEPAGE=n, so I don't think it's
> a complete fix.

Well, __dax_pmd_fault() itself depends on CONFIG_TRANSPARENT_HUGEPAGE.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
