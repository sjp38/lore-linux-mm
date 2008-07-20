Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m6KNhtTF024389
	for <linux-mm@kvack.org>; Mon, 21 Jul 2008 09:43:55 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6KNiqnu280292
	for <linux-mm@kvack.org>; Mon, 21 Jul 2008 09:44:52 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6KNipAQ012908
	for <linux-mm@kvack.org>; Mon, 21 Jul 2008 09:44:51 +1000
Message-ID: <4883CDEB.2030403@linux.vnet.ibm.com>
Date: Sun, 20 Jul 2008 19:44:43 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mmtom] please drop memcg-handle-swap-cache set (memcg handle
 swap cache rework).
References: <20080717124556.3e4b6e20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080717124556.3e4b6e20.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Now, SwapCache is handled by memcg (in -mm) but it became complicated than I thought of.
> 
> followings are queued in -mm now.
>   memcg-handle-swap-cache.patch
>   memcg-handle-swap-cache-fix.patch
>   memcg-handle-swap-cache-fix-shmem-page-migration-incorrectness-on-memcgroup.patch
> 
> And I have memcg-handle-shmem-swap-cache-fix.patch....
> 
> Balbir argued that "This is too complicated!", ok, let's rework.
> 

Thanks, it was complicated and simplification is always welcome!

> Andrew, could you drop above 3 patches ? I'd like to retry with clear logic.
> 
> I'm testing this new version now. Basic logic is not changed but corner case
> handling is clearer than previous one. If there is something unclear, 
> please tell me.  I'd like to write easy-to-understand one.
> 
> ==
> This patch tries to catch SwapCache usage by memcg in following Rule.
> 
> 1. just ignore add_to_swap_cache()
> 2. if a page is uncharged,
> 	(a) don't uncharge when PageSwapCache(page)
> 	(b) don't uncharge when the page is mapped.
> 	(c) don't uncharge when the page is still on radix-tree.
>             This can be checked by (page->mapping && !PageAnon(page))
> 
> 3. __delete_from_swap_cache() calles uncharge after clearing PageSwapCache flag.
> 4. mem_cgroup_uncharge_cache() is called only after page->mapping is cleared.
> 5. migration has some corner case and handled.
> 

My understanding of this patchset now is that

If the page was ever mapped or cached, we don't tweak add_to_swap_cache(),
instead, we keep the page around in the memcg, till it is removed from swap
cache. Is my understanding of your intent correct?

[snip]

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
