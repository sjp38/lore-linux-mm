Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7F08A6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 21:39:25 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o311dNtX023378
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 1 Apr 2010 10:39:24 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 974F845DE6E
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 10:39:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 77BF845DE4D
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 10:39:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B66FE18002
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 10:39:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E740B1DB803B
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 10:39:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] __isolate_lru_page: skip unneeded mode check
In-Reply-To: <w2gcf18f8341003311830pb0d697efi721641050c88a254@mail.gmail.com>
References: <2f11576a1003310717y1fe1aa66p8f92135d5eec29e6@mail.gmail.com> <w2gcf18f8341003311830pb0d697efi721641050c88a254@mail.gmail.com>
Message-Id: <20100401103210.12C0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu,  1 Apr 2010 10:39:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> @@ -862,15 +862,10 @@ int __isolate_lru_page(struct page *page, int mode,
> >> int file)
> >>        if (!PageLRU(page))
> >>                return ret;
> >>
> >> -       /*
> >> -        * When checking the active state, we need to be sure we are
> >> -        * dealing with comparible boolean values.  Take the logical not
> >> -        * of each.
> >> -        */
> >> -       if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
> >> +       if (mode != ISOLATE_BOTH && (PageActive(page) != mode))
> >>                return ret;
> >
> > no. please read the comment.
> >
> 
> Hm,. I have read it, but still miss it :-).
> PageActive(page) will return an int 0 or 1, mode is also int 0 or 1(
> already != ISOLATE_BOTH).
> There are comparible and why must to be sure to boolean values?

hm, ok. you are right.
please resend this part as individual patch.


> >> -       if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
> >> +       if (page_is_file_cache(page) != file)
> >>                return ret;
> >
> > no. please consider lumpy reclaim.
> 
> During lumpy reclaim mode is ISOLATE_BOTH, that case we don't check
> page_is_file_cache() ?  Would you please explain it a little more ,i
> am still unclear about it.
> Thanks a lot.

ISOLATE_BOTH is for to help allocate high order memory. then,
it ignore both PageActive() and page_is_file_cache(). otherwise,
we fail to allocate high order memory.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
