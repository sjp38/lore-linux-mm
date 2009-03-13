Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 264626B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 01:34:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D5YBxC005529
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Mar 2009 14:34:11 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EA1F45DD7E
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 14:34:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 43D7845DD7D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 14:34:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 16AD91DB8048
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 14:34:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BE5ED1DB8043
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 14:34:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention (v5)
In-Reply-To: <20090313052653.GG16897@balbir.in.ibm.com>
References: <20090313134548.AF50.A69D9226@jp.fujitsu.com> <20090313052653.GG16897@balbir.in.ibm.com>
Message-Id: <20090313142814.AF4A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Mar 2009 14:34:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-13 13:50:26]:
> 
> > > > > I have two objection to this.
> > > > > 
> > > > > - "if (!order || !did_some_progress)" mean no call try_to_free_pages()
> > > > >   in order>0 and did_some_progress>0 case.
> > > > >   but mem_cgroup_soft_limit_reclaim() don't have lumpy reclaim.
> > > > >   then, it break high order reclaim.
> > > > 
> > > > I am sending a fix for this right away. Thanks, the check should be
> > > > if (order || !did_some_progress)
> > > 
> > > No.
> > > 
> > > it isn't enough.
> > > after is does, order-1 allocation case twrice reclaim (soft limit shrinking
> > > and normal try_to_free_pages()).
> > > then, order-1 reclaim makes slower about 2 times.
> > > 
> > > unfortunately, order-1 allocation is very frequent. it is used for
> > > kernel stack.
> > 
> > in normal order-1 reclaim is:
> > 
> > 1. try_to_free_pages()
> > 2. get_page_from_freelist()
> > 3. retry if order-1 page don't exist
> > 
> > Coundn't you use the same logic?
> 
> Sorry, forgot to answer this question earlier.
> 
> I assume that by order-1 you mean 2 pages (2^1).

Yes, almost architecutre's kernel stack use 2 pages.


> Are you suggesting that if soft limit reclaim fails, we retry? Not
> sure if I understand your suggestion completely.

sorry. my last explanation is too poor.

if we need only 2pages, soft_limit_shrink() typically success
reclaim it.
then

1. mem_cgroup_soft_limit_reclaim()
2. get_page_from_freelist() if mem_cgroup_soft_limit_reclaim() return >0.
3. goto got_pg if if get_page_from_freelist() is successed.
4. try_to_free_pages()
5. get_page_from_freelist() if try_to_free_pages() return >0.
6. goto 1 if order-1 page don't exist

obiously, this logic make slower more higher order because
(2) is often fail in higher order.
but that's ok. higher order reclaim is very slow. additional
overhead don't observe (maybe).

What do you think?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
