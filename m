Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 092C86B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 01:05:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2O58Djh018363
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 24 Mar 2009 14:08:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F36D545DD76
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 14:08:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D072E45DD75
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 14:08:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B2FBDE08004
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 14:08:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EB9CE08002
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 14:08:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <alpine.LFD.2.00.0903230940580.3030@localhost.localdomain>
References: <20090323162954.GB4192@elte.hu> <alpine.LFD.2.00.0903230940580.3030@localhost.localdomain>
Message-Id: <20090324140304.902C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 24 Mar 2009 14:08:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> > And your v2 is now:
> > 
> >     9 files changed, 66 insertions(+), 21 deletions(-)
> > 
> > ... and it is also speeding up fast-gup. Which is a marked 
> > improvement IMO.
> 
> Yeah, I have no problems with that patch. I'd just suggest a final 
> simplification, and getting rid of the
> 
>         mask = _PAGE_PRESENT|_PAGE_USER;
>         /* Maybe the read only pte is cow mapped page. (or not maybe)
>            So, falling back to get_user_pages() is better */
>         mask |= _PAGE_RW;
> 
> and just doing something like
> 
> 	/*
> 	 * fast-GUP only handles the simple cases where we have
> 	 * full access to the page (ie private pages are copied
> 	 * etc).
> 	 */
> 	#define GUP_MASK (_PAGE_PRESENT|_PAGE_USER|_PAGE_RW)

OK! I'll do that.
Thanks good reviewing!


> and leaving it at that.
> 
> Of course, maybe somebody does O_DIRECT writes on a fork'ed image in order 
> to create a snapshot image or something, and now the v2 thing breaks COW 
> on all the pages in order to be safe and performance sucks.
> 
> But I can't really say that _I_ could possibly care. I really seriously 
> think that O_DIRECT and its ilk were braindamaged to begin with.

Yes. I have to totally agreed ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
