Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1293A6B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 12:26:22 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id z81so6084201oig.16
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 09:26:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 200sor3891665oic.64.2017.12.17.09.26.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Dec 2017 09:26:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-12-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-12-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 17 Dec 2017 09:26:20 -0800
Message-ID: <CAPcyv4hbezncGj16p9D2ypsPbfmJwMVbaZ36XpuCsf640O4xtA@mail.gmail.com>
Subject: Re: [PATCH 11/17] mm: move get_dev_pagemap out of line
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> This is a pretty big function, which should be out of line in general,
> and a no-op stub if CONFIG_ZONE_DEVIC=D0=95 is not set.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
[..]
> +/**
> + * get_dev_pagemap() - take a new live reference on the dev_pagemap for =
@pfn
> + * @pfn: page frame number to lookup page_map
> + * @pgmap: optional known pgmap that already has a reference
> + *
> + * @pgmap allows the overhead of a lookup to be bypassed when @pfn lands=
 in the
> + * same mapping.
> + */
> +struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
> +               struct dev_pagemap *pgmap)
> +{
> +       const struct resource *res =3D pgmap ? pgmap->res : NULL;
> +       resource_size_t phys =3D PFN_PHYS(pfn);
> +
> +       /*
> +        * In the cached case we're already holding a live reference so
> +        * we can simply do a blind increment
> +        */
> +       if (res && phys >=3D res->start && phys <=3D res->end) {
> +               percpu_ref_get(pgmap->ref);
> +               return pgmap;
> +       }

I was going to say keep the cached case in the static inline, but with
the optimization to the calling convention in the following patch I
think that makes this moot.

So,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
