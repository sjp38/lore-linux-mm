Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4964F6B0069
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 23:03:33 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id n64so5151420ota.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 20:03:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f79sor2392990oih.250.2017.12.07.20.03.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 20:03:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171207150840.28409-11-hch@lst.de>
References: <20171207150840.28409-1-hch@lst.de> <20171207150840.28409-11-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 7 Dec 2017 20:03:30 -0800
Message-ID: <CAPcyv4hK8R2Ki09odb9e5Quf_e3ux7oRND+-Ymgo1Ay3FU7oxg@mail.gmail.com>
Subject: Re: [PATCH 10/14] memremap: change devm_memremap_pages interface to
 use struct dev_pagemap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, kbuild test robot <lkp@intel.com>

On Thu, Dec 7, 2017 at 7:08 AM, Christoph Hellwig <hch@lst.de> wrote:
> From: Logan Gunthorpe <logang@deltatee.com>
>
> This new interface is similar to how struct device (and many others)
> work. The caller initializes a 'struct dev_pagemap' as required
> and calls 'devm_memremap_pages'. This allows the pagemap structure to
> be embedded in another structure and thus container_of can be used. In
> this way application specific members can be stored in a containing
> struct.
>
> This will be used by the P2P infrastructure and HMM could probably
> be cleaned up to use it as well (instead of having it's own, similar
> 'hmm_devmem_pages_create' function).
>
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
[..]
> diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
> index e1f75a1914a1..9631993b6ee0 100644
> --- a/tools/testing/nvdimm/test/iomap.c
> +++ b/tools/testing/nvdimm/test/iomap.c
> @@ -104,15 +104,14 @@ void *__wrap_devm_memremap(struct device *dev, resource_size_t offset,
>  }
>  EXPORT_SYMBOL(__wrap_devm_memremap);
>
> -void *__wrap_devm_memremap_pages(struct device *dev, struct resource *res,
> -               struct percpu_ref *ref, struct vmem_altmap *altmap)
> +void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  {
> -       resource_size_t offset = res->start;
> +       resource_size_t offset = pgmap->res.start;
>         struct nfit_test_resource *nfit_res = get_nfit_res(offset);
>
>         if (nfit_res)
>                 return nfit_res->buf + offset - nfit_res->res.start;
> -       return devm_memremap_pages(dev, res, ref, altmap);
> +       return devm_memremap_pages(dev, pgmap)

Missed semicolon...

I need to follow up with the kbuild robot about including
tools/testing/nvdimm in its build tests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
