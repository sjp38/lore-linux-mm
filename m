Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9DC6B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 12:34:13 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 105so7802873oth.22
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 09:34:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u198sor3791484oif.274.2017.12.17.09.34.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Dec 2017 09:34:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-15-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-15-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 17 Dec 2017 09:34:11 -0800
Message-ID: <CAPcyv4i2naLJjWzm+q0ORRfyHkT0f5dFBFKutuaXE3OgPcHX5g@mail.gmail.com>
Subject: Re: [PATCH 14/17] memremap: simplify duplicate region handling in devm_memremap_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> __radix_tree_insert already checks for duplicates and returns -EEXIST in
> that case, so remove the duplicate (and racy) duplicates check.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> ---
>  kernel/memremap.c | 11 -----------
>  1 file changed, 11 deletions(-)
>
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 891491ddccdb..901404094df1 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -395,17 +395,6 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>         align_end = align_start + align_size - 1;
>
>         foreach_order_pgoff(res, order, pgoff) {
> -               struct dev_pagemap *dup;
> -
> -               rcu_read_lock();
> -               dup = find_dev_pagemap(res->start + PFN_PHYS(pgoff));
> -               rcu_read_unlock();
> -               if (dup) {
> -                       dev_err(dev, "%s: %pr collides with mapping for %s\n",
> -                                       __func__, res, dev_name(dup->dev));
> -                       error = -EBUSY;
> -                       break;
> -               }
>                 error = __radix_tree_insert(&pgmap_radix,
>                                 PHYS_PFN(res->start) + pgoff, order, page_map);
>                 if (error) {


This is not racy, we'll catch the error on insert, and I think the
extra debug information is useful for debugging a broken memory map or
alignment math.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
