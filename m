Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BC9FC6B0025
	for <linux-mm@kvack.org>; Sun,  8 May 2011 23:21:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E1BF33EE0C1
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:21:13 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C372545DE5E
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:21:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E06E45DE5C
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:21:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0988FE08002
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:21:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B98CA1DB8043
	for <linux-mm@kvack.org>; Mon,  9 May 2011 12:21:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 6/8] In order putback lru core
In-Reply-To: <BANLkTikHf+3vhnXFu3ubWXOXkCkD4j206Q@mail.gmail.com>
References: <20110501224844.75EC.A69D9226@jp.fujitsu.com> <BANLkTikHf+3vhnXFu3ubWXOXkCkD4j206Q@mail.gmail.com>
Message-Id: <20110509122255.3AD5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon,  9 May 2011 12:21:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

> On Sun, May 1, 2011 at 10:47 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> > +/* This structure is used for keeping LRU ordering of isolated page */
> >> > +struct pages_lru {
> >> > + A  A  A  A struct page *page; A  A  A /* isolated page */
> >> > + A  A  A  A struct page *prev_page; /* previous page of isolate page as LRU order */
> >> > + A  A  A  A struct page *next_page; /* next page of isolate page as LRU order */
> >> > + A  A  A  A struct list_head lru;
> >> > +};
> >> > A /*
> >>
> >> So this thing has to be allocated from somewhere. We can't put it
> >> on the stack as we're already in danger there so we must be using
> >> kmalloc. In the reclaim paths, this should be avoided obviously.
> >> For compaction, we might hurt the compaction success rates if pages
> >> are pinned with control structures. It's something to be wary of.
> >>
> >> At LSF/MM, I stated a preference for swapping the source and
> >> destination pages in the LRU. This unfortunately means that the LRU
> >> now contains a page in the process of being migrated to and the backout
> >> paths for migration failure become a lot more complex. Reclaim should
> >> be ok as it'll should fail to lock the page and recycle it in the list.
> >> This avoids allocations but I freely admit that I'm not in the position
> >> to implement such a thing right now :(
> >
> > I like swaping to fake page. one way pointer might become dangerous. vmscan can
> > detect fake page and ignore it.
> 
> 
> I guess it means swapping between migrated-from page and migrated-to page.
> Right? 

no. I was intend to use fake struct page. but this idea is also good to me.

> If so, migrated-from page is already removed from LRU list and
> migrated-to page isn't LRU as it's page allocated newly so they don't
> have any LRU information. How can we swap them? We need space keeps
> LRU information before removing the page from LRU list. :(

pure fake struct page or preallocation migrated-to page?



> 
> Could you explain in detail about swapping if I miss something?
> 
> About one way pointer, I think it's no problem. Worst case I imagine
> is to put the page in head of LRU list. It means it's same issue now.
> So it doesn't make worse than now.
> 
> >
> > ie,
> > is_fake_page(page)
> > {
> > A  A  A  A if (is_stack_addr((void*)page))
> > A  A  A  A  A  A  A  A return true;
> > A  A  A  A return false;
> > }
> >
> > Also, I like to use stack rather than kmalloc in compaction.
> >
> 
> Compaction is a procedure of reclaim. As you know, we had a problem
> about using of stack during reclaim path.
> I admit kmalloc-thing isn't good.
> I will try to solve the issue as TODO.

It depend on stack consumption size. because we don't call pageout()
from compaction path. It's big different from regular reclaim path.

> 
> Thanks for the review, KOSAKI.

Yeah, thank you for making very good patch!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
