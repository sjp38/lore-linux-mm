Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2A8BE6B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 19:55:47 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4DNtiMd014190
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 14 May 2010 08:55:44 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DA6C45DE4F
	for <linux-mm@kvack.org>; Fri, 14 May 2010 08:55:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 139C445DE4E
	for <linux-mm@kvack.org>; Fri, 14 May 2010 08:55:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F09CB1DB8015
	for <linux-mm@kvack.org>; Fri, 14 May 2010 08:55:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A49551DB8012
	for <linux-mm@kvack.org>; Fri, 14 May 2010 08:55:43 +0900 (JST)
Date: Fri, 14 May 2010 08:51:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm,migration: Avoid race between shift_arg_pages() and
 rmap_walk() during migration by not migrating temporary stacks
Message-Id: <20100514085135.cfb5ba17.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1005131219190.20037@router.home>
References: <20100511085752.GM26611@csn.ul.ie>
	<20100512092239.2120.A69D9226@jp.fujitsu.com>
	<20100512125427.d1b170ba.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1005121627020.1273@router.home>
	<20100513091930.9b42e3b8.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1005131219190.20037@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 13 May 2010 12:22:01 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 13 May 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > Would it not be possible to do something similar for the temporary stack?
> > >
> >
> > Problem here is unmap->remap. ->migratepage() function is used as
> >
> > 	unmap
> > 	   -> migratepage()
> > 	      -> failed
> > 		-> remap
> >
> > Then, migratepage() itself is no help. We need some check-callback before unmap
> > or lock to wait for an event we can make remapping progress.
> 
> We could check earlier if the migrate function points to
> fail_migrate_page()?

If you mean checking before unmap, yes. we can avoid the race.
Unmapping itself is dangerous in this case.

> Where we check for PageKsm() in unmap_and_move f.e.?
> 

I'm not sure about KSM.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
