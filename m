Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 145166B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 19:52:43 -0400 (EDT)
Received: by iofh134 with SMTP id h134so215511706iof.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 16:52:42 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id 75si15487643iol.1.2015.09.15.16.52.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 16:52:42 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so24509437igb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 16:52:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1438948423-128882-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1438948423-128882-1-git-send-email-kirill.shutemov@linux.intel.com>
Date: Tue, 15 Sep 2015 16:52:42 -0700
Message-ID: <CAA9_cmd9D=7YgZrCf+w3HcckoqcfmCLEHhhm9j+kv+V0ijUnqw@mail.gmail.com>
Subject: Re: [PATCH] mm: take i_mmap_lock in unmap_mapping_range() for DAX
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, ross.zwisler@linux.intel.com

Hi Kirill,

On Fri, Aug 7, 2015 at 4:53 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> DAX is not so special: we need i_mmap_lock to protect mapping->i_mmap.
>
> __dax_pmd_fault() uses unmap_mapping_range() shoot out zero page from
> all mappings. We need to drop i_mmap_lock there to avoid lock deadlock.
>
> Re-aquiring the lock should be fine since we check i_size after the
> point.
>
> Not-yet-signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  fs/dax.c    | 35 +++++++++++++++++++----------------
>  mm/memory.c | 11 ++---------
>  2 files changed, 21 insertions(+), 25 deletions(-)
>
> diff --git a/fs/dax.c b/fs/dax.c
> index 9ef9b80cc132..ed54efedade6 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -554,6 +554,25 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>         if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
>                 goto fallback;
>
> +       if (buffer_unwritten(&bh) || buffer_new(&bh)) {
> +               int i;
> +               for (i = 0; i < PTRS_PER_PMD; i++)
> +                       clear_page(kaddr + i * PAGE_SIZE);

This patch, now upstream as commit 46c043ede471, moves the call to
clear_page() earlier in __dax_pmd_fault().  However, 'kaddr' is not
set at this point, so I'm not sure this path was ever tested.  I'm
also not sure why the compiler is not complaining about an
uninitialized variable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
