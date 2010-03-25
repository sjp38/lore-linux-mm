Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 19B186B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 06:17:00 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2PAGGE1026756
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 25 Mar 2010 19:16:16 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5212D45DE4E
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 19:16:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1ABD145DE4F
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 19:16:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D8D33E38002
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 19:16:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 89CA91DB804A
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 19:16:15 +0900 (JST)
Date: Thu, 25 Mar 2010 19:12:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
Message-Id: <20100325191229.8e3d2ba1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100325185200.6C8C.A69D9226@jp.fujitsu.com>
References: <20100325092131.GK2024@csn.ul.ie>
	<20100325184123.e3e3b009.kamezawa.hiroyu@jp.fujitsu.com>
	<20100325185200.6C8C.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Mar 2010 18:59:25 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > > > Kosaki-san,
> > > > > 
> > > > >  IIUC, the race in memory-hotunplug was fixed by this patch [2/11].
> > > > > 
> > > > >  But, this behavior of unmap_and_move() requires access to _freed_
> > > > >  objects (spinlock). Even if it's safe because of SLAB_DESTROY_BY_RCU,
> > > > >  it't not good habit in general.
> > > > > 
> > > > >  After direct compaction, page-migration will be one of "core" code of
> > > > >  memory management. Then, I agree to patch [1/11] as our direction for
> > > > >  keeping sanity and showing direction to more updates. Maybe adding
> > > > >  refcnt and removing RCU in futuer is good.
> > > > 
> > > > But Christoph seems oppose to remove SLAB_DESTROY_BY_RCU. then refcount
> > > > is meaningless now.
> > > 
> > > Christoph is opposed to removing it because of cache-hotness issues more
> > > so than use-after-free concerns. The refcount is needed with or without
> > > SLAB_DESTROY_BY_RCU.
> > > 
> > 
> > I wonder a code which the easiest to be read will be like following.
> > ==
> > 
> >         if (PageAnon(page)) {
> >                 struct anon_vma anon = page_lock_anon_vma(page);
> > 		/* to take this lock, this page must be mapped. */
> > 		if (!anon_vma)
> > 			goto uncharge;
> > 		increase refcnt
> > 		page_unlock_anon_vma(anon);
> >         }
> > 	....
> > ==
> 
> This seems very good and acceptable to me. This refcnt usage
> obviously reduce rcu-lock holding time.
> 
> I still think no refcount doesn't cause any disaster. but I agree
> this is forward step patch.
> 

BTW, by above change and the change in patch [2/11], 
"A page turnd to be SwapCache and free unmapped but not freed"
page will be never migrated.

Mel, could you change the check as this ??

	if (PageAnon(page)) {
		rcu_read_lock();
		if (!page_mapcount(page)) {
			rcu_read_unlock();
			if (!PageSwapCache(page))
				goto uncharge;
			/* unmapped swap cache can be migrated */
		} else {
			...
		}
	.....
	} else 


Thx,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
