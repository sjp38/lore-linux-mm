Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A8FFC6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 18:02:01 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so6237452pdj.9
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:02:01 -0800 (PST)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [2001:4b98:c:538::195])
        by mx.google.com with ESMTPS id nj1si5835048pbc.249.2015.01.20.15.01.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 15:02:00 -0800 (PST)
Date: Tue, 20 Jan 2015 15:01:50 -0800
From: josh@joshtriplett.org
Subject: Re: [PATCH 2/2] mm: fix undefined reference to `.kernel_map_pages'
 on PPC builds
Message-ID: <20150120230150.GA14475@cloud>
References: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150120140200.aa7ba0eb28d95e456972e178@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kim Phillips <kim.phillips@freescale.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jan 20, 2015 at 02:02:00PM -0600, Kim Phillips wrote:
> It's possible to configure DEBUG_PAGEALLOC without PAGE_POISONING on
> ppc.  Fix building the generic kernel_map_pages() implementation in
> this case:
> 
>   LD      init/built-in.o
> mm/built-in.o: In function `free_pages_prepare':
> mm/page_alloc.c:770: undefined reference to `.kernel_map_pages'
> mm/built-in.o: In function `prep_new_page':
> mm/page_alloc.c:933: undefined reference to `.kernel_map_pages'
> mm/built-in.o: In function `map_pages':
> mm/compaction.c:61: undefined reference to `.kernel_map_pages'
> make: *** [vmlinux] Error 1
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
>  mm/Makefile | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/Makefile b/mm/Makefile
> index 4bf586e..2956467 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -46,6 +46,7 @@ obj-$(CONFIG_SLOB) += slob.o
>  obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
>  obj-$(CONFIG_KSM) += ksm.o
>  obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
> +obj-$(CONFIG_DEBUG_PAGEALLOC) += debug-pagealloc.o

Does it work correctly to list the same object file twice?  Doesn't seem
like it would.  Shouldn't this do something like the following instead:

ifneq ($(CONFIG_DEBUG_PAGEALLOC)$(CONFIG_PAGE_POISONING),)
obj-y += debug-pagealloc.o
endif

?

>  obj-$(CONFIG_SLAB) += slab.o
>  obj-$(CONFIG_SLUB) += slub.o
>  obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
> -- 
> 2.2.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
