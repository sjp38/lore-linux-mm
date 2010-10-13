Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 19CD56B00ED
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 01:05:54 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D55o3w012235
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Oct 2010 14:05:50 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 58FF445DE4E
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:05:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 342F145DD71
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:05:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 204E01DB8013
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:05:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CC0EA1DB8012
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:05:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
In-Reply-To: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20101013140546.ADB7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Oct 2010 14:05:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> 
> No big change since the previous version but divided into 3 patches.
> This patch is based onto mmotm-1008 and just works, IOW, mot tested in
> very-bad-situation.
> 
> What this wants to do: 
>   allocates a contiguous chunk of pages larger than MAX_ORDER.
>   for device drivers (camera? etc..)
>   My intention is not for allocating HUGEPAGE(> MAX_ORDER).
>   
> What this does:
>   allocates a contiguous chunk of page with page migration,
>   based on memory hotplug codes. (memory unplug is for isolating
>   a chunk of page from buddy allocator.)
> 
> Consideration:
>   Maybe more codes can be shared with other functions
>   (memory hotplug, compaction..)
> 
> Status:
>   Maybe still needs more updates, works on small test.
>   [1/3] ... move some codes from memory hotplug. (no functional changes)
>   [2/3] ... a code for searching contiguous pages.
>   [3/3] ... a code for allocating contig memory.
> 
> Thanks,
> -Kame
> ==
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Memory hotplug is a logic for making pages unused in the specified range
> of pfn. So, some of core logics can be used for other purpose as
> allocating a very large contigous memory block.
> 
> This patch moves some functions from mm/memory_hotplug.c to
> mm/page_isolation.c. This helps adding a function for large-alloc in
> page_isolation.c with memory-unplug technique.
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page-isolation.h |    7 ++
>  mm/memory_hotplug.c            |  109 ---------------------------------------
>  mm/page_isolation.c            |  114 +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 121 insertions(+), 109 deletions(-)
> 
> Index: mmotm-1008/include/linux/page-isolation.h
> ===================================================================
> --- mmotm-1008.orig/include/linux/page-isolation.h
> +++ mmotm-1008/include/linux/page-isolation.h
> @@ -33,5 +33,12 @@ test_pages_isolated(unsigned long start_
>  extern int set_migratetype_isolate(struct page *page);
>  extern void unset_migratetype_isolate(struct page *page);
>  
> +/*
> + * For migration.
> + */
> +
> +int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn);
> +int scan_lru_pages(unsigned long start, unsigned long end);

offtopic: scan_lru_pages() return type should be unsined long. it return
pfn.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
