Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E3E4F6B0115
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 22:32:46 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7Q2Wk12019320
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 26 Aug 2009 11:32:46 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DB54245DE58
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:32:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B278745DE4C
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:32:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 850D51DB8041
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:32:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E1191DB803F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 11:32:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
In-Reply-To: <Pine.LNX.4.64.0908250947400.2872@sister.anvils>
References: <82e12e5f0908242146uad0f314hcbb02fcc999a1d32@mail.gmail.com> <Pine.LNX.4.64.0908250947400.2872@sister.anvils>
Message-Id: <20090826113622.9A29.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 26 Aug 2009 11:32:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Hiroaki Wakabayashi <primulaelatior@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Menage <menage@google.com>, Ying Han <yinghan@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> > > Yeah, GUP_FLAGS_NOFAULT is better.
> > 
> > Me too.
> > I will change this flag name.
> >... 
> > When I try to change __get_user_pages(), I got problem.
> > If remove NULLs from pages,
> > __mlock_vma_pages_range() cannot know how long __get_user_pages() readed.
> > So, I have to get the virtual address of the page from vma and page.
> > Because __mlock_vma_pages_range() have to call
> > __get_user_pages() many times with different `start' argument.
> > 
> > I try to use page_address_in_vma(), but it failed.
> > (page_address_in_vma() returned -EFAULT)
> > I cannot find way to solve this problem.
> > Are there good ideas?
> > Please give me some ideas.
> 
> I agree that this munlock issue needs to be addressed: it's not just a
> matter of speedup, I hit it when testing what happens when mlock takes
> you to OOM - which is currently a hanging disaster because munlock'ing
> in the exiting OOM-killed process gets stuck trying to fault in all
> those pages that couldn't be locked in the first place.

I agree too.


> I had intended to fix it by being more careful about splitting/merging
> vmas, noting how far the mlock had got, and munlocking just up to there.
> However, now that I've got in there, that looks wrong to me, given the
> traditional behaviour that mlock does its best, but pretends success
> to allow for later instantiation of the pages if necessary.
> 
> You ask for ideas.  My main idea is that so far we have added
> GUP_FLAGS_IGNORE_VMA_PERMISSIONS (Kosaki-san, what was that about?
>                                   we already had the force flag),

MAY_WRITE and MAY_READ might be turned off at some special case.
but munlock should turn off PG_mlock bit. otherwise the page never be reclaimed.
This problem was explained by Lee about a year ago.

However, To use follow_page() solove this issue and we will be able to
remove this ugly flag.

> GUP_FLAGS_IGNORE_SIGKILL, and now you propose
> GUP_FLAGS_NOFAULT, all for the sole use of munlock.
> 
> How about GUP_FLAGS_MUNLOCK, or more to the point, GUP_FLAGS_DONT_BE_GUP?
> By which I mean, don't all these added flags suggest that almost
> everything __get_user_pages() does is unsuited to the munlock case?
> 
> My advice (but I sure hate giving advice before I've tried it myself)
> is to put __mlock_vma_pages_range() back to handling just the mlock
> case, and do your own follow_page() loop in munlock_vma_pages_range().

Agreed. follow_page() is better.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
