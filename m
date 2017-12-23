Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB276B026F
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 20:54:35 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id l74so13164558oih.10
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 17:54:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v31sor5063664otf.145.2017.12.22.17.54.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Dec 2017 17:54:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-5-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-5-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Dec 2017 17:54:33 -0800
Message-ID: <CAPcyv4i-TWnQ-fRVLB9kaSxJ+2QwZUEEixkTSwYGF-73fmemvw@mail.gmail.com>
Subject: Re: [PATCH 04/17] mm: pass the vmem_altmap to arch_add_memory and __add_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> We can just pass this on instead of having to do a radix tree lookup
> without proper locking 2 levels into the callchain.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
[..]
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 8acdc35c2dfa..e26ade50ae18 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -772,12 +772,12 @@ static void update_end_of_memory_vars(u64 start, u64 size)
>         }
>  }
>
> -int add_pages(int nid, unsigned long start_pfn,
> -             unsigned long nr_pages, bool want_memblock)
> +int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
> +               struct vmem_altmap *altmap, bool want_memblock)
>  {
>         int ret;
>
> -       ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
> +       ret = __add_pages(nid, start_pfn, nr_pages, NULL, want_memblock);
>         WARN_ON_ONCE(ret);

Should be 'altmap' instead of NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
