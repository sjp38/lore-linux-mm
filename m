Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B525A6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 06:06:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v109so8474177wrc.5
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 03:06:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m25sor1282454wmi.76.2017.09.25.03.06.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 03:06:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1506329174-19265-2-git-send-email-imbrenda@linux.vnet.ibm.com>
References: <1506329174-19265-1-git-send-email-imbrenda@linux.vnet.ibm.com> <1506329174-19265-2-git-send-email-imbrenda@linux.vnet.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 25 Sep 2017 12:06:28 +0200
Message-ID: <CAMuHMdUcd01J1fXeqVQdVeOGF_YqGp9uZh4MEucVdhc+XNOAsQ@mail.gmail.com>
Subject: Re: [RFC v1 1/2] VS1544 KSM generic memory comparison functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, nefelim4ag@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, zhongjiang@huawei.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, solee@os.korea.ac.kr, Andi Kleen <ak@linux.intel.com>

Hi Claudio,

On Mon, Sep 25, 2017 at 10:46 AM, Claudio Imbrenda
<imbrenda@linux.vnet.ibm.com> wrote:
> This is just a refactoring of the existing code:
>
> * Split the page checksum and page comparison functions from ksm.c into
>   a new asm-generic header (page_memops.h)

... and make them inline?

> --- /dev/null
> +++ b/include/asm-generic/page_memops.h
> @@ -0,0 +1,31 @@
> +#ifndef _ASM_GENERIC_PAGE_MEMOPS_H
> +#define _ASM_GENERIC_PAGE_MEMOPS_H
> +
> +#include <linux/mm_types.h>
> +#include <linux/highmem.h>
> +#include <linux/jhash.h>
> +
> +static inline u32 calc_page_checksum(struct page *page)
> +{
> +       void *addr = kmap_atomic(page);
> +       u32 checksum;
> +
> +       checksum = jhash2(addr, PAGE_SIZE / 4, 17);
> +       kunmap_atomic(addr);
> +       return checksum;
> +}
> +
> +static inline int memcmp_pages(struct page *page1, struct page *page2)
> +{
> +       char *addr1, *addr2;
> +       int ret;
> +
> +       addr1 = kmap_atomic(page1);
> +       addr2 = kmap_atomic(page2);
> +       ret = memcmp(addr1, addr2, PAGE_SIZE);
> +       kunmap_atomic(addr2);
> +       kunmap_atomic(addr1);
> +       return ret;
> +}

Do they really have to be inline?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
