Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3E8956B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 05:59:31 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2P9xRji016430
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Mar 2010 18:59:27 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BAD745DE4F
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:59:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E24C045DE4C
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:59:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A2CF91DB801A
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:59:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 530EA1DB8019
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:59:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped anonymous pages
In-Reply-To: <20100325184123.e3e3b009.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100325092131.GK2024@csn.ul.ie> <20100325184123.e3e3b009.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20100325185200.6C8C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Mar 2010 18:59:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > Kosaki-san,
> > > > 
> > > >  IIUC, the race in memory-hotunplug was fixed by this patch [2/11].
> > > > 
> > > >  But, this behavior of unmap_and_move() requires access to _freed_
> > > >  objects (spinlock). Even if it's safe because of SLAB_DESTROY_BY_RCU,
> > > >  it't not good habit in general.
> > > > 
> > > >  After direct compaction, page-migration will be one of "core" code of
> > > >  memory management. Then, I agree to patch [1/11] as our direction for
> > > >  keeping sanity and showing direction to more updates. Maybe adding
> > > >  refcnt and removing RCU in futuer is good.
> > > 
> > > But Christoph seems oppose to remove SLAB_DESTROY_BY_RCU. then refcount
> > > is meaningless now.
> > 
> > Christoph is opposed to removing it because of cache-hotness issues more
> > so than use-after-free concerns. The refcount is needed with or without
> > SLAB_DESTROY_BY_RCU.
> > 
> 
> I wonder a code which the easiest to be read will be like following.
> ==
> 
>         if (PageAnon(page)) {
>                 struct anon_vma anon = page_lock_anon_vma(page);
> 		/* to take this lock, this page must be mapped. */
> 		if (!anon_vma)
> 			goto uncharge;
> 		increase refcnt
> 		page_unlock_anon_vma(anon);
>         }
> 	....
> ==

This seems very good and acceptable to me. This refcnt usage
obviously reduce rcu-lock holding time.

I still think no refcount doesn't cause any disaster. but I agree
this is forward step patch.

thanks.


> and
> ==
> void anon_vma_free(struct anon_vma *anon)
> {
> 	/*
> 	 * To increase refcnt of anon-vma, anon_vma->lock should be held by
> 	 * page_lock_anon_vma(). It means anon_vma has a "mapped" page.
> 	 * If this anon is freed by unmap or exit, all pages under this anon
> 	 * must be unmapped. Then, just checking refcnt without lock is ok.
> 	 */
> 	if (check refcnt > 0)
> 		return do nothing
> 	kmem_cache_free(anon);
> }
> ==
> 
> Then, rcu_read_lock can be removed in clean way.
> 
> Thanks,
> -Kame
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
