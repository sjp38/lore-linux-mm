Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7F7A16B004D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 21:07:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4K17lTW021449
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 May 2009 10:07:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D4F445DD79
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:07:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E398E45DE51
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:07:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C87D4E18001
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:07:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FEA1E38001
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:07:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] readahead:add blk_run_backing_dev
In-Reply-To: <6.0.0.20.2.20090518183752.0581fdc0@172.19.0.2>
References: <6.0.0.20.2.20090518183752.0581fdc0@172.19.0.2>
Message-Id: <20090520100602.7438.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 May 2009 10:07:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

(cc to Wu and linux-mm)

> Hi.
> 
> I wrote a patch that adds blk_run_backing_dev on page_cache_async_readahead
> so readahead I/O is unpluged to improve throughput.
> 
> Following is the test result with dd.
> 
> #dd if=testdir/testfile of=/dev/null bs=16384
> 
> -2.6.30-rc6
> 1048576+0 records in
> 1048576+0 records out
> 17179869184 bytes (17 GB) copied, 224.182 seconds, 76.6 MB/s
> 
> -2.6.30-rc6-patched
> 1048576+0 records in
> 1048576+0 records out
> 17179869184 bytes (17 GB) copied, 206.465 seconds, 83.2 MB/s
> 
> Sequential read performance on a big file was improved.
> Please merge my patch.

I guess the improvement depend on readahead window size.
Have you mesure random access workload?

> 
> Thanks.
> 
> Signed-off-by: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
> 
> diff -Nrup linux-2.6.30-rc6.org/mm/readahead.c linux-2.6.30-rc6.unplug/mm/readahead.c
> --- linux-2.6.30-rc6.org/mm/readahead.c	2009-05-18 10:46:15.000000000 +0900
> +++ linux-2.6.30-rc6.unplug/mm/readahead.c	2009-05-18 13:00:42.000000000 +0900
> @@ -490,5 +490,7 @@ page_cache_async_readahead(struct addres
>  
>  	/* do read-ahead */
>  	ondemand_readahead(mapping, ra, filp, true, offset, req_size);
> +
> +	blk_run_backing_dev(mapping->backing_dev_info, NULL);
>  }
>  EXPORT_SYMBOL_GPL(page_cache_async_readahead);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
