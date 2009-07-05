Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BC8446B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:58:28 -0400 (EDT)
Date: Sun, 5 Jul 2009 19:21:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] add buffer cache information to show_free_areas()
Message-ID: <20090705112159.GB1898@localhost>
References: <20090705181400.08F1.A69D9226@jp.fujitsu.com> <20090705182337.08F9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090705182337.08F9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 05, 2009 at 05:24:07PM +0800, KOSAKI Motohiro wrote:
> Subject: [PATCH] add buffer cache information to show_free_areas()
> 
> When administrator analysis memory shortage reason from OOM log, They
> often need to know rest number of cache like pages.

nr_blockdev_pages() pages are also accounted in NR_FILE_PAGES.

> Then, show_free_areas() shouldn't only display page cache, but also it
> should display buffer cache.

So if we are to add this, I'd suggest to put it close to the total
pagecache line:

        printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
+       printk("%ld blkdev pagecache pages\n", nr_blockdev_pages());

Thanks,
Fengguang

> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/page_alloc.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2118,7 +2118,7 @@ void show_free_areas(void)
>  	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
>  		" inactive_file:%lu"
>  		" unevictable:%lu"
> -		" dirty:%lu writeback:%lu unstable:%lu\n"
> +		" dirty:%lu writeback:%lu buffer:%lu unstable:%lu\n"
>  		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>  		" mapped:%lu pagetables:%lu bounce:%lu\n",
>  		global_page_state(NR_ACTIVE_ANON),
> @@ -2128,6 +2128,7 @@ void show_free_areas(void)
>  		global_page_state(NR_UNEVICTABLE),
>  		global_page_state(NR_FILE_DIRTY),
>  		global_page_state(NR_WRITEBACK),
> +		K(nr_blockdev_pages()),
>  		global_page_state(NR_UNSTABLE_NFS),
>  		global_page_state(NR_FREE_PAGES),
>  		global_page_state(NR_SLAB_RECLAIMABLE),
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
