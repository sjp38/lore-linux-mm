Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 73E306B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 21:46:21 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n891kOuq005940
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 9 Sep 2009 10:46:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A98A345DE4E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 10:46:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D1E245DE56
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 10:46:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2818C1DB8040
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 10:46:24 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D7A22E1800A
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 10:46:23 +0900 (JST)
Date: Wed, 9 Sep 2009 10:44:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/8] mm: reinstate ZERO_PAGE
Message-Id: <20090909104423.4bd23a2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0909081231480.25652@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
	<Pine.LNX.4.64.0909072238320.15430@sister.anvils>
	<20090908113734.869cdad7.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0909081231480.25652@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009 12:56:57 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Tue, 8 Sep 2009, KAMEZAWA Hiroyuki wrote:
> > 
> > A nitpick but this was a concern you shown, IIUC.
> > 
> > == __get_user_pages()..
> > 
> >                         if (pages) {
> >                                 pages[i] = page;
> > 
> >                                 flush_anon_page(vma, page, start);
> >                                 flush_dcache_page(page);
> >                         }
> > ==
> > 
> > This part will call flush_dcache_page() even when ZERO_PAGE is found.
> > 
> > Don't we need to mask this ?
> 
> No, it's okay to flush_dcache_page() on ZERO_PAGE: we always used to
> do that there, and the arches I remember offhand won't do anything
> with it anyway, once they see page->mapping NULL.
> 
> What you're remembering, that I did object to, was the way your
> FOLL_NOZERO ended up doing
> 				pages[i] = NULL;
> 				flush_anon_page(vma, NULL, start);
> 				flush_dcache_page(NULL);
> 
> which would cause an oops when those arches look at page->mapping.
> 
> I should take another look at your FOLL_NOZERO: I may have dismissed
> it too quickly, after seeing that bug, and oopsing on x86 when
> mlocking a readonly anonymous area.
> 
> Though I like that we don't _need_ to change mlock.c for reinstated
> ZERO_PAGE, this morning I'm having trouble persuading myself that
> mlocking a readonly anonymous area is too silly to optimize for.
> 
> Maybe the very people who persuaded you to bring back the anonymous
> use of ZERO_PAGE, are also doing a huge mlock of the area first?
No, as far as I know, they'll not do huge mlock.


Thanks,
-Kame

> So if two or more are starting up at the same time on the same box,
> more bouncing than is healthy (and more than they would have seen
> in the old days of ZERO_PAGE but no lock_page on it there).
> 
> I'd like to persuade myself not to bother,
> but may want to add a further patch for that later.
> 
> Hugh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
