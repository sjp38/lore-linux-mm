Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3B2A6B0047
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 22:38:44 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:35:25 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v3
Message-Id: <20090421113525.29332f3d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090417171343.e848481f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<100477cfc6c3c775abc7aecd4ce8c46e.squirrel@webmail-b.css.fujitsu.com>
	<432ace3655a26d2d492a56303369a88a.squirrel@webmail-b.css.fujitsu.com>
	<20090320164520.f969907a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323104555.cb7cd059.nishimura@mxp.nes.nec.co.jp>
	<20090323114118.8b45105f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323140419.40235ce3.nishimura@mxp.nes.nec.co.jp>
	<20090323142242.f6659457.kamezawa.hiroyu@jp.fujitsu.com>
	<20090324173218.4de33b90.nishimura@mxp.nes.nec.co.jp>
	<20090325085713.6f0b7b74.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417153455.c6fe2ba6.nishimura@mxp.nes.nec.co.jp>
	<20090417155411.76901324.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417165036.bdca7163.nishimura@mxp.nes.nec.co.jp>
	<20090417165806.4ca40a08.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417171201.6c79bee5.nishimura@mxp.nes.nec.co.jp>
	<20090417171343.e848481f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Sorry for late reply.

On Fri, 17 Apr 2009 17:13:43 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 17 Apr 2009 17:12:01 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Fri, 17 Apr 2009 16:58:06 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Fri, 17 Apr 2009 16:50:36 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > On Fri, 17 Apr 2009 15:54:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > On Fri, 17 Apr 2009 15:34:55 +0900
> > > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > > I made a patch for reclaiming SwapCache from orphan LRU based on your patch,
> > > > > > and have been testing it these days.
> > > > > > 
> > > > > Good trial! 
> > > > > Honestly, I've written a patch to fix this problem in these days but seems to
> > > > > be over-kill ;)
> > > > > 
> > > > > 
> > > > > > Major changes from your version:
> > > > > > - count the number of orphan pages per zone and make the threshold per zone(4MB).
> > > > > > - As for type 2 of orphan SwapCache, they are usually set dirty by add_to_swap.
> > > > > >   But try_to_drop_swapcache(__remove_mapping) can't free dirty pages,
> > > > > >   so add a check and try_to_free_swap to the end of shrink_page_list.
> > > > > > 
> > > > > > It seems work fine, no "pseud leak" of SwapCache can be seen.
> > > > > > 
> > > > > > What do you think ?
> > > > > > If it's all right, I'll merge this with the orphan list framework patch
> > > > > > and send it to Andrew with other fixes of memcg that I have.
> > > > > > 
> > > > > I'm sorry but my answer is "please wait". The reason is..
> > > > > 
> > > > > 1. When global LRU works, the pages will be reclaimed.
> > > > > 2. Global LRU will work finally.
> > > > > 3. While testing, "stale" swap cache cannot be big amount.
> > > > > 
> > > > Hmm, I can't understand 2.
> > > > 
> > > > If (memsize on system) >> (swapsize on system), global LRU doesn't run
> > > > and all the swap space can be used up by these SwapCache.
> > > > This means setting mem.limit can use up all the swap space on the system.
> > > > I've tested with 50MB size of swap and it can be used up in less than 24h.
> > > > I think it's not small.
> > > > 
> > > 
> > > plz add hook to shrink_zone() to fix this as you did. 
> > > orphan list is overkilling at this stage.
> > > 
> > I see.
> > 
> > I'll make a patch, test it, and repost it in next week.
> > It can prevent at least type-2 of orphan SwapCache.
> > 
> BTW, type-1 still exits ?
> 
Ah, I meant adding to shrink_page_list():

@@ -785,6 +786,23 @@ activate_locked:
                SetPageActive(page);
                pgactivate++;
 keep_locked:
+               if (!scanning_global_lru(sc) && PageSwapCache(page)) {
+                       struct page_cgroup *pc;
+
+                       pc = lookup_page_cgroup(page);
+                       /*
+                        * Used bit of swapcache is solid under page lock.
+                        */
+                       if (unlikely(!PageCgroupUsed(pc)))
+                               /*
+                                * This can happen if the page is free'ed by
+                                * the owner process before it is added to
+                                * swapcache.
+                                * These swapcache cannot be managed by memcg
+                                * well, so free it here.
+                                */
+                               try_to_free_swap(page);
+               }
                unlock_page(page);
 keep:
                list_add(&page->lru, &ret_pages);

This cannot prevent type-1 orphan SwapCache(caused by the race
between exit() and swap-in readahead).
Type-1 can pressure the memsw usage(trigger OOM if memsw.limit is set, as a result)
and make struct mem_cgroup unfreeable even after rmdir(because it holds refcount
to mem_cgroup).

Do you have any ideas to solve orphan SwapCache problem by adding some hooks to shrink_zone() ?
(scan some pages from global LRU and check whether it's orphan SwapCache or not by
adding some code like above ?)

And, what do you think about adding above code to shrink_page_list() ?
I think it might be unnecessary if we can solve the problem in another way, though.


Thanks,
Daisuke Nishimura.

> > I'll revisit orphan list if needed in future.
> > 
> Thank you!.
> 
> Regards,
> -Kame
> 
> > 
> > Thanks,
> > Daisuke Nishimura.
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
