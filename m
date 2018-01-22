Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE2D0800D8
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 20:22:24 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y200so8762472itc.7
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 17:22:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g38si12676123ioj.81.2018.01.21.17.22.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 21 Jan 2018 17:22:23 -0800 (PST)
Date: Sun, 21 Jan 2018 17:21:56 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 1/1] mm: page_alloc: skip over regions of invalid pfns
 on UMA
Message-ID: <20180122012156.GA10428@bombadil.infradead.org>
References: <20180121144753.3109-1-erosca@de.adit-jv.com>
 <20180121144753.3109-2-erosca@de.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180121144753.3109-2-erosca@de.adit-jv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugeniu Rosca <erosca@de.adit-jv.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steven Sistare <steven.sistare@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Paul Burton <paul.burton@mips.com>, James Hartley <james.hartley@mips.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


I like the patch.  I think it could be better.

> +++ b/mm/page_alloc.c
> @@ -5344,7 +5344,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  			goto not_early;
>  
>  		if (!early_pfn_valid(pfn)) {
> -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +#ifdef CONFIG_HAVE_MEMBLOCK
>  			/*
>  			 * Skip to the pfn preceding the next valid one (or
>  			 * end_pfn), such that we hit a valid pfn (or end_pfn)

This ifdef makes me sad.  Here's more of the context:

                if (!early_pfn_valid(pfn)) {
#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
                        /*
                         * Skip to the pfn preceding the next valid one (or
                         * end_pfn), such that we hit a valid pfn (or end_pfn)
                         * on our next iteration of the loop.
                         */
                        pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
#endif
                        continue;
                }

This is crying out for:

#ifdef CONFIG_HAVE_MEMBLOCK
unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
#else
static inline unsigned long memblock_next_valid_pfn(unsigned long pfn,
		unsigned long max_pfn)
{
	return pfn + 1;
}
#endif

in a header file somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
