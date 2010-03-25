Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E46116B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 09:39:56 -0400 (EDT)
Date: Thu, 25 Mar 2010 13:39:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
Message-ID: <20100325133936.GR2024@csn.ul.ie>
References: <20100325092131.GK2024@csn.ul.ie> <20100325184123.e3e3b009.kamezawa.hiroyu@jp.fujitsu.com> <20100325185200.6C8C.A69D9226@jp.fujitsu.com> <20100325191229.8e3d2ba1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100325191229.8e3d2ba1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 25, 2010 at 07:12:29PM +0900, KAMEZAWA Hiroyuki wrote:
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

Good point.

> Mel, could you change the check as this ??
> 
> 	if (PageAnon(page)) {
> 		rcu_read_lock();
> 		if (!page_mapcount(page)) {
> 			rcu_read_unlock();
> 			if (!PageSwapCache(page))
> 				goto uncharge;
> 			/* unmapped swap cache can be migrated */
> 		} else {
> 			...
> 		}
> 	.....
> 	} else 
> 

There were minor changes in how the rcu_read_lock is taken and released
based on other comments. With your suggestion, the block now looks like;

        if (PageAnon(page)) {
                rcu_read_lock();
                rcu_locked = 1;

                /*
                 * If the page has no mappings any more, just bail. An
                 * unmapped anon page is likely to be freed soon but
                 * worse,
                 * it's possible its anon_vma disappeared between when
                 * the page was isolated and when we reached here while
                 * the RCU lock was not held
                 */
                if (!page_mapcount(page) && !PageSwapCache(page))
                        goto rcu_unlock;

                anon_vma = page_anon_vma(page);
                atomic_inc(&anon_vma->external_refcount);
        }

Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
