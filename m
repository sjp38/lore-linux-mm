Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0E9E36B01AC
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 11:29:21 -0400 (EDT)
Received: by fxm25 with SMTP id 25so1526fxm.6
        for <linux-mm@kvack.org>; Thu, 25 Mar 2010 08:29:19 -0700 (PDT)
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100325191229.8e3d2ba1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100325092131.GK2024@csn.ul.ie>
	 <20100325184123.e3e3b009.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100325185200.6C8C.A69D9226@jp.fujitsu.com>
	 <20100325191229.8e3d2ba1.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Mar 2010 00:29:01 +0900
Message-ID: <1269530941.1814.21.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Kame. 

On Thu, 2010-03-25 at 19:12 +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 25 Mar 2010 18:59:25 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > > > > Kosaki-san,
> > > > > > 
> > > > > >  IIUC, the race in memory-hotunplug was fixed by this patch [2/11].
> > > > > > 
> > > > > >  But, this behavior of unmap_and_move() requires access to _freed_
> > > > > >  objects (spinlock). Even if it's safe because of SLAB_DESTROY_BY_RCU,
> > > > > >  it't not good habit in general.
> > > > > > 
> > > > > >  After direct compaction, page-migration will be one of "core" code of
> > > > > >  memory management. Then, I agree to patch [1/11] as our direction for
> > > > > >  keeping sanity and showing direction to more updates. Maybe adding
> > > > > >  refcnt and removing RCU in futuer is good.
> > > > > 
> > > > > But Christoph seems oppose to remove SLAB_DESTROY_BY_RCU. then refcount
> > > > > is meaningless now.
> > > > 
> > > > Christoph is opposed to removing it because of cache-hotness issues more
> > > > so than use-after-free concerns. The refcount is needed with or without
> > > > SLAB_DESTROY_BY_RCU.
> > > > 
> > > 
> > > I wonder a code which the easiest to be read will be like following.
> > > ==
> > > 
> > >         if (PageAnon(page)) {
> > >                 struct anon_vma anon = page_lock_anon_vma(page);
> > > 		/* to take this lock, this page must be mapped. */
> > > 		if (!anon_vma)
> > > 			goto uncharge;
> > > 		increase refcnt
> > > 		page_unlock_anon_vma(anon);
> > >         }
> > > 	....
> > > ==
> > 
> > This seems very good and acceptable to me. This refcnt usage
> > obviously reduce rcu-lock holding time.
> > 
> > I still think no refcount doesn't cause any disaster. but I agree
> > this is forward step patch.
> > 
> 
> BTW, by above change and the change in patch [2/11], 
> "A page turnd to be SwapCache and free unmapped but not freed"
> page will be never migrated.
> 
> Mel, could you change the check as this ??
> 
> 	if (PageAnon(page)) {
> 		rcu_read_lock();
> 		if (!page_mapcount(page)) {
> 			rcu_read_unlock();
> 			if (!PageSwapCache(page))
> 				goto uncharge;
> 			/* unmapped swap cache can be migrated */


Which case do we have PageAnon && (page_mapcount == 0) && PageSwapCache ?
With looking over code which add_to_swap_cache, I found somewhere. 

1) shrink_page_list
I think this case doesn't matter by isolate_lru_xxx.

2) shmem_swapin
It seems to be !PageAnon

3) shmem_writepage
It seems to be !PageAnon. 

4) do_swap_page
page_add_anon_rmap increases _mapcount before setting page->mapping to anon_vma. 
So It doesn't matter. 


I think following codes in unmap_and_move seems to handle 3) case. 

---
         * Corner case handling:
         * 1. When a new swap-cache page is read into, it is added to the LRU
         * and treated as swapcache but it has no rmap yet.
        ...
        if (!page->mapping) {
                if (!PageAnon(page) && page_has_private(page)) {
                ....
                }    
                goto skip_unmap;
        }    

---

Do we really check PageSwapCache in there?
Do I miss any case?



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
