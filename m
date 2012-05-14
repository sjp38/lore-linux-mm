Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 284256B0081
	for <linux-mm@kvack.org>; Mon, 14 May 2012 05:08:14 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2C1FB3EE0C0
	for <linux-mm@kvack.org>; Mon, 14 May 2012 18:08:12 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 14BDE45DE5B
	for <linux-mm@kvack.org>; Mon, 14 May 2012 18:08:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F187045DE5D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 18:08:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB4A81DB8049
	for <linux-mm@kvack.org>; Mon, 14 May 2012 18:08:11 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93032E08001
	for <linux-mm@kvack.org>; Mon, 14 May 2012 18:08:11 +0900 (JST)
Message-ID: <4FB0CAFF.6060705@jp.fujitsu.com>
Date: Mon, 14 May 2012 18:06:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/10] shmem: replace page if mapping excludes its zone
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils> <alpine.LSU.2.00.1205120453210.28861@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205120453210.28861@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <ffwll.ch@google.com>, Rob Clark <rob.clark@linaro.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/05/12 20:59), Hugh Dickins wrote:

> The GMA500 GPU driver uses GEM shmem objects, but with a new twist:
> the backing RAM has to be below 4GB.  Not a problem while the boards
> supported only 4GB: but now Intel's D2700MUD boards support 8GB, and
> their GMA3600 is managed by the GMA500 driver.
> 
> shmem/tmpfs has never pretended to support hardware restrictions on
> the backing memory, but it might have appeared to do so before v3.1,
> and even now it works fine until a page is swapped out then back in.
> When read_cache_page_gfp() supplied a freshly allocated page for copy,
> that compensated for whatever choice might have been made by earlier
> swapin readahead; but swapoff was likely to destroy the illusion.
> 
> We'd like to continue to support GMA500, so now add a new
> shmem_should_replace_page() check on the zone when about to move
> a page from swapcache to filecache (in swapin and swapoff cases),
> with shmem_replace_page() to allocate and substitute a suitable page
> (given gma500/gem.c's mapping_set_gfp_mask GFP_KERNEL | __GFP_DMA32).
> 
> This does involve a minor extension to mem_cgroup_replace_page_cache()
> (the page may or may not have already been charged); and I've removed
> a comment and call to mem_cgroup_uncharge_cache_page(), which in fact
> is always a no-op while PageSwapCache.
> 
> Also removed optimization of an unlikely path in shmem_getpage_gfp(),
> now that we need to check PageSwapCache more carefully (a racing caller
> might already have made the copy).  And at one point shmem_unuse_inode()
> needs to use the hitherto private page_swapcount(), to guard against
> racing with inode eviction.
> 
> It would make sense to extend shmem_should_replace_page(), to cover
> cpuset and NUMA mempolicy restrictions too, but set that aside for
> now: needs a cleanup of shmem mempolicy handling, and more testing,
> and ought to handle swap faults in do_swap_page() as well as shmem.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---



Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
