Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 326136B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:51:06 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so42008899wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:51:05 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id i9si4763222wjf.92.2015.09.22.13.51.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 13:51:04 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so177970416wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:51:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1442950582-10140-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1442950582-10140-1-git-send-email-ross.zwisler@linux.intel.com>
Date: Tue, 22 Sep 2015 13:51:04 -0700
Message-ID: <CAPcyv4hubJDhWResqaG_aQLSLUVEOujk=EEDVQ1BF+sAdK45LA@mail.gmail.com>
Subject: Re: [PATCH v2] dax: fix NULL pointer in __dax_pmd_fault()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>

[ adding Andrew ]

On Tue, Sep 22, 2015 at 12:36 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> The following commit:
>
> commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for
>         DAX")
>
> moved some code in __dax_pmd_fault() that was responsible for zeroing
> newly allocated PMD pages.  The new location didn't properly set up
> 'kaddr', though, so when run this code resulted in a NULL pointer BUG.
>
> Fix this by getting the correct 'kaddr' via bdev_direct_access().
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reported-by: Dan Williams <dan.j.williams@intel.com>

Taking into account the comment below,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

> ---
>  fs/dax.c | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
>
> diff --git a/fs/dax.c b/fs/dax.c
> index 7ae6df7..bcfb14b 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -569,8 +569,20 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>         if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
>                 goto fallback;
>
> +       sector = bh.b_blocknr << (blkbits - 9);
> +
>         if (buffer_unwritten(&bh) || buffer_new(&bh)) {
>                 int i;
> +
> +               length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
> +                                               bh.b_size);
> +               if (length < 0) {
> +                       result = VM_FAULT_SIGBUS;
> +                       goto out;
> +               }
> +               if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
> +                       goto fallback;
> +

Hmm, we don't need the PG_PMD_COLOUR check since we aren't using the
pfn in this path, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
