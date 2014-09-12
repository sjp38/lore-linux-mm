Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 27E696B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 05:35:56 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so879920pab.4
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 02:35:55 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id gx11si6622787pbd.148.2014.09.12.02.35.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 12 Sep 2014 02:35:55 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBS00HL484HED80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 12 Sep 2014 10:38:41 +0100 (BST)
Message-id: <5412BE75.8030600@samsung.com>
Date: Fri, 12 Sep 2014 11:35:49 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC] Free the reserved memblock when free cma pages
References: 
 <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
In-reply-to: 
 <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, "'mhocko@suse.cz'" <mhocko@suse.cz>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

Hello,

On 2014-09-09 08:13, Wang, Yalin wrote:
> This patch add memblock_free to also free the reserved memblock,
> so that the cma pages are not marked as reserved memory in
> /sys/kernel/debug/memblock/reserved debug file
>
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>

Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>

> ---
>   mm/cma.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/mm/cma.c b/mm/cma.c
> index c17751c..f3ec756 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -114,6 +114,8 @@ static int __init cma_activate_area(struct cma *cma)
>   				goto err;
>   		}
>   		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> +		memblock_free(__pfn_to_phys(base_pfn),
> +				pageblock_nr_pages * PAGE_SIZE);
>   	} while (--i);
>   
>   	mutex_init(&cma->lock);

Right. Thanks for fixing this issue. When cma_activate_area() is called 
noone
should use memblock to allocate memory, but it is ok to call memblock_free()
to update memblock statistics, so users won't be confused by cma entries in
/sys/kernel/debug/memblock/reserved file.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
