Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3C50D900001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 09:47:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EF3EE3EE0BB
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:47:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D040045DE99
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:47:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AB43245DE92
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:47:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 97F51E08003
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:47:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CEB21DB8038
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:47:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 6/8] In order putback lru core
In-Reply-To: <20110428110623.GU4658@suse.de>
References: <51e7412097fa62f86656c77c1934e3eb96d5eef6.1303833417.git.minchan.kim@gmail.com> <20110428110623.GU4658@suse.de>
Message-Id: <20110501224844.75EC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  1 May 2011 22:47:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

> > +/* This structure is used for keeping LRU ordering of isolated page */
> > +struct pages_lru {
> > +        struct page *page;      /* isolated page */
> > +        struct page *prev_page; /* previous page of isolate page as LRU order */
> > +        struct page *next_page; /* next page of isolate page as LRU order */
> > +        struct list_head lru;
> > +};
> >  /*
> 
> So this thing has to be allocated from somewhere. We can't put it
> on the stack as we're already in danger there so we must be using
> kmalloc. In the reclaim paths, this should be avoided obviously.
> For compaction, we might hurt the compaction success rates if pages
> are pinned with control structures. It's something to be wary of.
> 
> At LSF/MM, I stated a preference for swapping the source and
> destination pages in the LRU. This unfortunately means that the LRU
> now contains a page in the process of being migrated to and the backout
> paths for migration failure become a lot more complex. Reclaim should
> be ok as it'll should fail to lock the page and recycle it in the list.
> This avoids allocations but I freely admit that I'm not in the position
> to implement such a thing right now :(

I like swaping to fake page. one way pointer might become dangerous. vmscan can
detect fake page and ignore it.

ie, 
is_fake_page(page)
{
	if (is_stack_addr((void*)page))
		return true;
	return false;
}

Also, I like to use stack rather than kmalloc in compaction.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
