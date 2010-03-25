Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DD51D6B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 05:45:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2P9j923022020
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 25 Mar 2010 18:45:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6275045DE7D
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:45:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 343D445DE7A
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:45:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AD01E1800D
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:45:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 98D73E18006
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:45:08 +0900 (JST)
Date: Thu, 25 Mar 2010 18:41:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
Message-Id: <20100325184123.e3e3b009.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100325092131.GK2024@csn.ul.ie>
References: <20100325083235.GF2024@csn.ul.ie>
	<20100325180221.e1d9bae7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100325180726.6C89.A69D9226@jp.fujitsu.com>
	<20100325092131.GK2024@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Mar 2010 09:21:32 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> On Thu, Mar 25, 2010 at 06:09:34PM +0900, KOSAKI Motohiro wrote:
> > > On Thu, 25 Mar 2010 08:32:35 +0000
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > On Thu, Mar 25, 2010 at 11:49:23AM +0900, KOSAKI Motohiro wrote:
> > > > > > On Fri, Mar 19, 2010 at 03:21:41PM +0900, KOSAKI Motohiro wrote: 
> > > > > Hmmm...
> > > > > I haven't understand your mention because I guess I was wrong.
> > > > > 
> > > > > probably my last question was unclear. I mean,
> > > > > 
> > > > > 1) If we still need SLAB_DESTROY_BY_RCU, why do we need to add refcount?
> > > > >     Which difference is exist between normal page migration and compaction?
> > > > 
> > > > The processes typically calling migration today own the page they are moving
> > > > and is not going to exit unexpectedly during migration.
> > > > 
> > > > > 2) If we added refcount, which race will solve?
> > > > > 
> > > > 
> > > > The process exiting and the last anon_vma being dropped while compaction
> > > > is running. This can be reliably triggered with compaction.
> > > > 
> > > > > IOW, Is this patch fix old issue or compaction specific issue?
> > > > > 
> > > > 
> > > > Strictly speaking, it's an old issue but in practice it's impossible to
> > > > trigger because the process migrating always owns the page. Compaction
> > > > moves pages belonging to arbitrary processes.
> > > > 
> > > Kosaki-san,
> > > 
> > >  IIUC, the race in memory-hotunplug was fixed by this patch [2/11].
> > > 
> > >  But, this behavior of unmap_and_move() requires access to _freed_
> > >  objects (spinlock). Even if it's safe because of SLAB_DESTROY_BY_RCU,
> > >  it't not good habit in general.
> > > 
> > >  After direct compaction, page-migration will be one of "core" code of
> > >  memory management. Then, I agree to patch [1/11] as our direction for
> > >  keeping sanity and showing direction to more updates. Maybe adding
> > >  refcnt and removing RCU in futuer is good.
> > 
> > But Christoph seems oppose to remove SLAB_DESTROY_BY_RCU. then refcount
> > is meaningless now.
> 
> Christoph is opposed to removing it because of cache-hotness issues more
> so than use-after-free concerns. The refcount is needed with or without
> SLAB_DESTROY_BY_RCU.
> 

I wonder a code which the easiest to be read will be like following.
==

        if (PageAnon(page)) {
                struct anon_vma anon = page_lock_anon_vma(page);
		/* to take this lock, this page must be mapped. */
		if (!anon_vma)
			goto uncharge;
		increase refcnt
		page_unlock_anon_vma(anon);
        }
	....
==
and
==
void anon_vma_free(struct anon_vma *anon)
{
	/*
	 * To increase refcnt of anon-vma, anon_vma->lock should be held by
	 * page_lock_anon_vma(). It means anon_vma has a "mapped" page.
	 * If this anon is freed by unmap or exit, all pages under this anon
	 * must be unmapped. Then, just checking refcnt without lock is ok.
	 */
	if (check refcnt > 0)
		return do nothing
	kmem_cache_free(anon);
}
==

Then, rcu_read_lock can be removed in clean way.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
