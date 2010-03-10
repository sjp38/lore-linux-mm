Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 23B156B00AD
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 08:09:38 -0500 (EST)
Date: Wed, 10 Mar 2010 21:09:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH] Fix Readahead stalling by plugged device queues
Message-ID: <20100310130932.GB18509@localhost>
References: <4B979104.6010907@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B979104.6010907@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ronald <intercommit@gmail.com>, Bart Van Assche <bart.vanassche@gmail.com>, Vladislav Bolkhovitin <vst@vlnb.net>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

> --- linux.orig/mm/readahead.c
> +++ linux/mm/readahead.c
> @@ -188,8 +188,11 @@ __do_page_cache_readahead(struct address
>  	 * uptodate then the caller will launch readpage again, and
>  	 * will then handle the error.
>  	 */
> -	if (ret)
> +	if (ret) {
>  		read_pages(mapping, filp, &page_pool, ret);
> +		/* unplug backing dev to avoid latencies */
> +		blk_run_address_space(mapping);
> +	}

Christian, did you notice this commit for 2.6.33?

commit 65a80b4c61f5b5f6eb0f5669c8fb120893bfb388
Author: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Date:   Thu Dec 17 15:27:26 2009 -0800

    readahead: add blk_run_backing_dev

--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -547,5 +547,17 @@ page_cache_async_readahead(struct address_space *mapping,
 
        /* do read-ahead */
        ondemand_readahead(mapping, ra, filp, true, offset, req_size);
+
+#ifdef CONFIG_BLOCK
+       /*
+        * Normally the current page is !uptodate and lock_page() will be
+        * immediately called to implicitly unplug the device. However this
+        * is not always true for RAID conifgurations, where data arrives
+        * not strictly in their submission order. In this case we need to
+        * explicitly kick off the IO.
+        */
+       if (PageUptodate(page))
+               blk_run_backing_dev(mapping->backing_dev_info, NULL);
+#endif
 }

It should at least improve performance between .32 and .33, because
once two readahead requests are merged into one single IO request,
the PageUptodate() will be true at next readahead, and hence
blk_run_backing_dev() get called to break out of the suboptimal
situation. 

Your patch does reduce the possible readahead submit latency to 0.

Is your workload a simple dd on a single disk? If so, it sounds like
something illogical hidden in the block layer.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
