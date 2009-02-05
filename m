Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A0E9D6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 21:17:50 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n152Hl0e020827
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Feb 2009 11:17:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 68E1F45DD74
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 11:17:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49A0445DD72
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 11:17:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 431BE1DB803C
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 11:17:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E4EBD1DB803A
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 11:17:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] fix mlocked page counter mistmatch
In-Reply-To: <20090204233543.GA26159@barrios-desktop>
References: <20090204171639.ECCE.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090204233543.GA26159@barrios-desktop>
Message-Id: <20090205111507.803B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Feb 2009 11:17:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> > and, I think current try_to_mlock_page() is correct. no need change.
> > Why?
> > 
> > 1. Generally, mmap_sem holding is necessary when vma->vm_flags accessed.
> >    that's vma's basic rule.
> > 2. However, try_to_unmap_one() doesn't held mamp_sem. but that's ok.
> >    it often get incorrect result. but caller consider incorrect value safe.
> > 3. try_to_mlock_page() need mmap_sem because it obey rule (1).
> > 4. in try_to_mlock_page(), if down_read_trylock() is failure, 
> >    we can't move the page to unevictable list. but that's ok.
> >    the page in evictable list is periodically try to reclaim. and
> >    be called try_to_unmap().
> >    try_to_unmap() (and its caller) also move the unevictable page to unevictable list.
> >    Therefore, in long term view, the page leak is not happend.
> 
> Thanks for clarification.
> In long term view, you're right.
> 
> but My concern is that munlock[all] pathes always hold down of mmap_sem. 
> After all, down_read_trylock always wil fail for such cases.
> 
> So, current task's mlocked pages only can be reclaimed 
> by background or direct reclaim path if the task don't exit.
> 
> I think it can increase reclaim overhead unnecessary 
> if there are lots of such tasks.
> 
> What's your opinion ?

I have 2 comment.

1. typical application never munlock()ed at all.
   and exit() path is already efficient.
   then, I don't like hacky apploach.
2. I think we should drop mmap_sem holding in munlock path in the future.
   at that time, this issue disappear automatically.
   it's clean way more.

What do you think it?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
