Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9B5D36B004D
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 23:25:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5B3QBGZ025045
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 12:26:12 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 80DB545DE57
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 12:26:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 42F0045DE50
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 12:26:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 40AED1DB8043
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 12:26:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E144C1DB803F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 12:26:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Properly account for the number of page cache pages zone_reclaim() can reclaim
In-Reply-To: <20090610115944.GB5657@localhost>
References: <20090610103152.GG25943@csn.ul.ie> <20090610115944.GB5657@localhost>
Message-Id: <20090611122206.591B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 12:26:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


> We are not talking about NR_TMPFS_PAGES, but NR_TMPFS_MAPPED :)
> 
> We only need to account it in page_add_file_rmap() and page_remove_rmap(),
> I don't think they are too hot paths. And the relative cost is low enough.
> 
> It will look like this.
> 
> ---
>  include/linux/mmzone.h |    1 +
>  mm/rmap.c              |    4 ++++
>  2 files changed, 5 insertions(+)
> 
> --- linux.orig/include/linux/mmzone.h
> +++ linux/include/linux/mmzone.h
> @@ -99,6 +99,7 @@ enum zone_stat_item {
>  	NR_VMSCAN_WRITE,
>  	/* Second 128 byte cacheline */
>  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
> +	NR_TMPFS_MAPPED,
>  #ifdef CONFIG_NUMA
>  	NUMA_HIT,		/* allocated in intended node */
>  	NUMA_MISS,		/* allocated in non intended node */
> --- linux.orig/mm/rmap.c
> +++ linux/mm/rmap.c
> @@ -844,6 +844,8 @@ void page_add_file_rmap(struct page *pag
>  {
>  	if (atomic_inc_and_test(&page->_mapcount)) {
>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> +		if (PageSwapBacked(page))
> +			__inc_zone_page_state(page, NR_TMPFS_MAPPED);
>  		mem_cgroup_update_mapped_file_stat(page, 1);
>  	}
>  }
> @@ -894,6 +896,8 @@ void page_remove_rmap(struct page *page)
>  			mem_cgroup_uncharge_page(page);
>  		__dec_zone_page_state(page,
>  			PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
> +		if (!PageAnon(page) && PageSwapBacked(page))
> +			__dec_zone_page_state(page, NR_TMPFS_MAPPED);
>  		mem_cgroup_update_mapped_file_stat(page, -1);
>  		/*
>  		 * It would be tidy to reset the PageAnon mapping here,

I think this patch looks good. thanks :)

but I have one request. 
Could you please rename NR_FILE_MAPPED to NR_SWAP_BACKED_FILE_MAPPED?

I mean, mm/shmem isn't only used for tmpfs, but also be used ipc/shm and
/dev/zero.
NR_TMPFS_MAPPED seems a bit misleading.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
