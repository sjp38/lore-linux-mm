Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id CFE866B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 08:41:09 -0400 (EDT)
Date: Mon, 2 Jul 2012 13:41:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: setup pageblock_order before it's used by sparse
Message-ID: <20120702124103.GP14154@suse.de>
References: <1341047274-5616-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1341047274-5616-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Yinghai Lu <yinghai@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On Sat, Jun 30, 2012 at 05:07:54PM +0800, Jiang Liu wrote:
> From: Xishi Qiu <qiuxishi@huawei.com>
> 
> On architectures with CONFIG_HUGETLB_PAGE_SIZE_VARIABLE set, such as Itanium,
> pageblock_order is a variable with default value of 0. It's set to the right
> value by set_pageblock_order() in function free_area_init_core().
> 
> But pageblock_order may be used by sparse_init() before free_area_init_core()
> is called along path:
> sparse_init()
>     ->sparse_early_usemaps_alloc_node()
> 	->usemap_size()
> 	    ->SECTION_BLOCKFLAGS_BITS
> 		->((1UL << (PFN_SECTION_SHIFT - pageblock_order)) *
> NR_PAGEBLOCK_BITS)
> 
> The uninitialized pageblock_size will cause memory wasting because usemap_size()
> returns a much bigger value then it's really needed.
> 
> For example, on an Itanium platform,
> sparse_init() pageblock_order=0 usemap_size=24576
> free_area_init_core() before pageblock_order=0, usemap_size=24576
> free_area_init_core() after pageblock_order=12, usemap_size=8
> 
> That means 24K memory has been wasted for each section, so fix it by calling
> set_pageblock_order() from sparse_init().
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Signed-off-by: Jiang Liu <liuj97@gmail.com>

Looks all right.

Acked-by: Mel Gorman <mgorman@suse.de>

This should be considered a stable candidate. Add

Cc: stable <stable@vger.kernel.org>

above your Signed-off-by and it'll get picked up if the patch is merged
to mainline.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
