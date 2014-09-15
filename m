Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 953996B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 23:06:57 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id p10so5249090pdj.37
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 20:06:57 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id o2si19845120pdf.1.2014.09.14.20.06.55
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 20:06:56 -0700 (PDT)
Date: Mon, 15 Sep 2014 12:06:54 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC] Free the reserved memblock when free cma pages
Message-ID: <20140915030653.GE2676@js1304-P5Q-DELUXE>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
 <5412BE75.8030600@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5412BE75.8030600@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, "'mhocko@suse.cz'" <mhocko@suse.cz>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

On Fri, Sep 12, 2014 at 11:35:49AM +0200, Marek Szyprowski wrote:
> Hello,
> 
> On 2014-09-09 08:13, Wang, Yalin wrote:
> >This patch add memblock_free to also free the reserved memblock,
> >so that the cma pages are not marked as reserved memory in
> >/sys/kernel/debug/memblock/reserved debug file
> >
> >Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> 
> Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
> 
> >---
> >  mm/cma.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> >diff --git a/mm/cma.c b/mm/cma.c
> >index c17751c..f3ec756 100644
> >--- a/mm/cma.c
> >+++ b/mm/cma.c
> >@@ -114,6 +114,8 @@ static int __init cma_activate_area(struct cma *cma)
> >  				goto err;
> >  		}
> >  		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> >+		memblock_free(__pfn_to_phys(base_pfn),
> >+				pageblock_nr_pages * PAGE_SIZE);
> >  	} while (--i);
> >  	mutex_init(&cma->lock);
> 
> Right. Thanks for fixing this issue. When cma_activate_area() is
> called noone
> should use memblock to allocate memory, but it is ok to call memblock_free()
> to update memblock statistics, so users won't be confused by cma entries in
> /sys/kernel/debug/memblock/reserved file.

Maybe some comment on code would be very helpful.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
