Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B3D916B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 19:01:45 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0D01gij027757
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Jan 2010 09:01:43 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FED245DE51
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:01:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EE0245DE57
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:01:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D47C1DB8038
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:01:41 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 98CD91DB8042
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:01:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for memory free
In-Reply-To: <alpine.DEB.2.00.1001121332100.9941@chino.kir.corp.google.com>
References: <20100112175027.B3BC.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1001121332100.9941@chino.kir.corp.google.com>
Message-Id: <20100113084206.B3C8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Jan 2010 09:01:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 12 Jan 2010, KOSAKI Motohiro wrote:
> 
> > > > commit e815af95 (change all_unreclaimable zone member to flags) chage
> > > > all_unreclaimable member to bit flag. but It have undesireble side
> > > > effect.
> > > > free_one_page() is one of most hot path in linux kernel and increasing
> > > > atomic ops in it can reduce kernel performance a bit.
> > > > 
> > > 
> > > Could you please elaborate on "a bit" in the changelog with some data?  If 
> > > it's so egregious, it should be easily be quantifiable.
> > 
> > Unfortunately I can't. atomic ops is mainly the issue of large machine. but
> > I can't access such machine now. but I'm sure we shouldn't take unnecessary
> > atomic ops.
> > 
> 
> e815af95 was intended to consolidate all bit flags into a single word 
> merely for space efficiency and cleanliness.  At that time, we only had 
> one member of struct zone that could be converted, and that was 
> all_unreclaimable.  That said, it was part of a larger patchset that 
> later added another zone flag meant to serialize the oom killer by 
> zonelist.  So no consideration was given at the time concerning any 
> penalty incurred by moving all_unreclaimable to an atomic op.

I agree ZONE_OOM_LOCKED have lots worth. 


> > That's fundamental space vs performance tradeoff thing. if we talked about
> > struct page or similar lots created struct, space efficient is very important.
> > but struct zone isn't such one.
> > 
> > Or, do you have strong argue to use bitops without space efficiency?
> 
> I'd suggest using a non-atomic variation within zone->flags that may still 
> be reordered so that it does not incur any performance penalty.  In other 
> words, instead of readding zone->all_unreclaimable, we should add 
> __zone_set_flag(), __zone_test_and_set_flag(), and __zone_clear_flag() 
> variants to wrap non-atomic bitops.

No. non-atomic ops assume the flags are protected by same lock. but
all_unreclaimable and ZONE_OOM_LOCKED don't have such lock. iow,
your opinion might cause ZONE_OOM_LOCKED lost.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
