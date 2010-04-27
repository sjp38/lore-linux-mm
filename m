Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E60026B01F1
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 20:35:31 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3R0ZWSf026808
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Apr 2010 09:35:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46B6245DE51
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:35:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 238F645DE50
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:35:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E8EF9E08001
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:35:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D2B11DB803F
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:35:31 +0900 (JST)
Date: Tue, 27 Apr 2010 09:31:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
Message-Id: <20100427093136.4de21a47.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BD63031.6050105@redhat.com>
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
	<1272321478-28481-3-git-send-email-mel@csn.ul.ie>
	<4BD63031.6050105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Apr 2010 20:30:41 -0400
Rik van Riel <riel@redhat.com> wrote:

> On 04/26/2010 06:37 PM, Mel Gorman wrote:
> 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 85f203e..bc313a6 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1368,15 +1368,31 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
> >   	 * are holding mmap_sem. Users without mmap_sem are required to
> >   	 * take a reference count to prevent the anon_vma disappearing
> >   	 */
> > +retry:
> >   	anon_vma = page_anon_vma(page);
> >   	if (!anon_vma)
> >   		return ret;
> >   	spin_lock(&anon_vma->lock);
> >   	list_for_each_entry(avc,&anon_vma->head, same_anon_vma) {
> >   		struct vm_area_struct *vma = avc->vma;
> > -		unsigned long address = vma_address(page, vma);
> > -		if (address == -EFAULT)
> > -			continue;
> > +		unsigned long address;
> > +
> > +		/*
> > +		 * Guard against deadlocks by not spinning against
> > +		 * vma->anon_vma->lock. If contention is found, release our
> > +		 * lock and try again until VMA list can be traversed without
> > +		 * contention.
> > +		 */
> > +		if (anon_vma != vma->anon_vma) {
> > +			if (!spin_trylock(&vma->anon_vma->lock)) {
> > +				spin_unlock(&anon_vma->lock);
> > +				goto retry;
> > +			}
> > +		}
> 
> If you're part way down the list, surely you'll need to
> unlock multiple anon_vmas here before going to retry?
> 
vma->anon_vma->lock is released after vma_address().

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
