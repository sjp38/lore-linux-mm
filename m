Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 60BBC6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 02:44:01 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LYL00HTEPHB8S10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 30 Jan 2012 07:43:59 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LYL002M6PHB1L@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 30 Jan 2012 07:43:59 +0000 (GMT)
Date: Mon, 30 Jan 2012 08:43:55 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [Linaro-mm-sig] [PATCH 12/15] drivers: add Contiguous Memory
 Allocator
In-reply-to: 
 <CAK=WgbY3L7u0AC1c=iNvoMXX+LSJoz1W-xb=S6gmhqcse5CKaA@mail.gmail.com>
Message-id: <014101ccdf22$eb610d30$c2232790$%szyprowski@samsung.com>
Content-language: pl
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-13-git-send-email-m.szyprowski@samsung.com>
 <CADMYwHw1B4RNV_9BqAg_M70da=g69Z3kyo5Cr6izCMwJ9LAtvA@mail.gmail.com>
 <00de01ccdce1$e7c8a360$b759ea20$%szyprowski@samsung.com>
 <CAO8GWqnQg-W=TEc+CUc8hs=GrdCa9XCCWcedQx34cqURhNwNwA@mail.gmail.com>
 <010301ccdd03$1ad15ab0$50741010$%szyprowski@samsung.com>
 <CAK=WgbZWHBKNQwcoY9OiXXH-r1n3XxB=ZODZJN-3vZopU2yhJA@mail.gmail.com>
 <010501ccdd06$b9844f20$2c8ced60$%szyprowski@samsung.com>
 <CAK=WgbY3L7u0AC1c=iNvoMXX+LSJoz1W-xb=S6gmhqcse5CKaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Ohad Ben-Cohen' <ohad@wizery.com>
Cc: "'Clark, Rob'" <rob@ti.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, 'Dave Hansen' <dave@linux.vnet.ibm.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

Hello,

On Saturday, January 28, 2012 7:57 PM Ohad Ben-Cohen wrote:

> On Fri, Jan 27, 2012 at 5:17 PM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
> > There have been some vmalloc layout changes merged to v3.3-rc1.
> 
> That was dead-on, thanks a lot!

Did you managed to fix this issue?

> 
> I did then bump into a different allocation failure which happened
> because dma_alloc_from_contiguous() computes 'mask' before capping the
> 'align' argument.
> 
> The early 'mask' computation was added in v18 (and therefore exists in
> v19 too) and I was actually testing v17 previously, so I didn't notice
> it before.

Right, thanks for spotting it, I will squash it to the next release.

> You may want to squash something like this:
> 
> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> index f41e699..8455cb7 100644
> --- a/drivers/base/dma-contiguous.c
> +++ b/drivers/base/dma-contiguous.c
> @@ -319,8 +319,7 @@ struct page *dma_alloc_from_contiguous(struct device *dev, i
>                                        unsigned int align)
>  {
>         struct cma *cma = dev_get_cma_area(dev);
> -       unsigned long pfn, pageno, start = 0;
> -       unsigned long mask = (1 << align) - 1;
> +       unsigned long mask, pfn, pageno, start = 0;
>         int ret;
> 
>         if (!cma || !cma->count)
> @@ -329,6 +328,8 @@ struct page *dma_alloc_from_contiguous(struct device *dev, i
>         if (align > CONFIG_CMA_ALIGNMENT)
>                 align = CONFIG_CMA_ALIGNMENT;
> 
> +       mask = (1 << align) - 1;
> +
>         pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
>                  count, align);
> 

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
