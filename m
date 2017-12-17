Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 444156B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 12:28:51 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id l74so6084952oih.10
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 09:28:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w19sor3926081otw.14.2017.12.17.09.28.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Dec 2017 09:28:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-13-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-13-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 17 Dec 2017 09:28:49 -0800
Message-ID: <CAPcyv4gTnFzT0a5Q3XrLRWjNzc5QtBq3Pypwxz2hsar5b+17hg@mail.gmail.com>
Subject: Re: [PATCH 12/17] mm: optimize dev_pagemap reference counting around get_dev_pagemap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> Change the calling convention so that get_dev_pagemap always consumes the
> previous reference instead of doing this using an explicit earlier call to
> put_dev_pagemap in the callers.
>
> The callers will still need to put the final reference after finishing the
> loop over the pages.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> ---
>  kernel/memremap.c | 17 +++++++++--------
>  mm/gup.c          |  7 +++++--
>  2 files changed, 14 insertions(+), 10 deletions(-)
>
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 43d94db97ff4..26764085785d 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -506,22 +506,23 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>   * @pfn: page frame number to lookup page_map
>   * @pgmap: optional known pgmap that already has a reference
>   *
> - * @pgmap allows the overhead of a lookup to be bypassed when @pfn lands in the
> - * same mapping.
> + * If @pgmap is non-NULL and covers @pfn it will be returned as-is.  If @pgmap
> + * is non-NULL but does not cover @pfn the reference to it while be released.

s/while/will/


Other than that you can add:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
