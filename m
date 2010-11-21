Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4560F6B0089
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 10:26:06 -0500 (EST)
Received: by pwi6 with SMTP id 6so1274853pwi.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 07:26:04 -0800 (PST)
Date: Mon, 22 Nov 2010 00:25:56 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/4] alloc_contig_pages() allocate big chunk memory
 using migration
Message-ID: <20101121152556.GC20947@barrios-desktop>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
 <20101119171528.32674ef4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101119171528.32674ef4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 05:15:28PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Add an function to allocate contiguous memory larger than MAX_ORDER.
> The main difference between usual page allocator is that this uses
> memory offline technique (Isolate pages and migrate remaining pages.).
> 
> I think this is not 100% solution because we can't avoid fragmentation,
> but we have kernelcore= boot option and can create MOVABLE zone. That
> helps us to allow allocate a contiguous range on demand.
> 
> The new function is
> 
>   alloc_contig_pages(base, end, nr_pages, alignment)
> 
> This function will allocate contiguous pages of nr_pages from the range
> [base, end). If [base, end) is bigger than nr_pages, some pfn which
> meats alignment will be allocated. If alignment is smaller than MAX_ORDER,
> it will be raised to be MAX_ORDER.
> 
> __alloc_contig_pages() has much more arguments.
> 
> 
> Some drivers allocates contig pages by bootmem or hiding some memory
> from the kernel at boot. But if contig pages are necessary only in some
> situation, kernelcore= boot option and using page migration is a choice.
> 
> Changelog: 2010-11-19
>  - removed no_search
>  - removed some drain_ functions because they are heavy.
>  - check -ENOMEM case
> 
> Changelog: 2010-10-26
>  - support gfp_t
>  - support zonelist/nodemask
>  - support [base, end) 
>  - support alignment
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Minchan Kim <minchan.kim@gmail.com>

Trivial comment below. 

> +EXPORT_SYMBOL_GPL(alloc_contig_pages);
> +
> +struct page *alloc_contig_pages_host(unsigned long nr_pages, int align_order)
> +{
> +	return __alloc_contig_pages(0, max_pfn, nr_pages, align_order, -1,
> +				GFP_KERNEL | __GFP_MOVABLE, NULL);
> +}

We need include #include <linux/bootmem.h> for using max_pfn. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
