Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 855886B0083
	for <linux-mm@kvack.org>; Wed, 27 May 2009 00:06:12 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4R46FoU026167
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 27 May 2009 13:06:16 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AF0F445DD72
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:06:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 83F3645DE52
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:06:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BA15E38002
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:06:14 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E572E38011
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:06:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] readahead:add blk_run_backing_dev
In-Reply-To: <20090527035505.GA16916@localhost>
References: <20090526193601.b825af5f.akpm@linux-foundation.org> <20090527035505.GA16916@localhost>
Message-Id: <20090527130358.689C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 27 May 2009 13:06:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

> > Ah.  So it's likely to be some strange interaction with the RAID setup.
> 
> The normal case is, if page N become uptodate at time T(N), then
> T(N) <= T(N+1) holds. But for RAID, the data arrival time depends on
> runtime status of individual disks, which breaks that formula. So
> in do_generic_file_read(), just after submitting the async readahead IO
> request, the current page may well be uptodate, so the page won't be locked,
> and the block device won't be implicitly unplugged:

Hifumi-san, Can you get blktrace data and confirm Wu's assumption?


> 
>                if (PageReadahead(page))
>                         page_cache_async_readahead()
>                 if (!PageUptodate(page))
>                                 goto page_not_up_to_date;
>                 //...
> page_not_up_to_date:
>                 lock_page_killable(page);
> 
> 
> Therefore explicit unplugging can help, so
> 
>         Acked-by: Wu Fengguang <fengguang.wu@intel.com> 
> 
> The only question is, shall we avoid the double unplug by doing this?
> 
> ---
>  mm/readahead.c |   10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> --- linux.orig/mm/readahead.c
> +++ linux/mm/readahead.c
> @@ -490,5 +490,15 @@ page_cache_async_readahead(struct addres
>  
>  	/* do read-ahead */
>  	ondemand_readahead(mapping, ra, filp, true, offset, req_size);
> +
> +	/*
> +	 * Normally the current page is !uptodate and lock_page() will be
> +	 * immediately called to implicitly unplug the device. However this
> +	 * is not always true for RAID conifgurations, where data arrives
> +	 * not strictly in their submission order. In this case we need to
> +	 * explicitly kick off the IO.
> +	 */
> +	if (PageUptodate(page))
> +		blk_run_backing_dev(mapping->backing_dev_info, NULL);
>  }
>  EXPORT_SYMBOL_GPL(page_cache_async_readahead);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
