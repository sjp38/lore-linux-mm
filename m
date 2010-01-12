Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6926B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 16:39:37 -0500 (EST)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id o0CLdUVx016795
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 21:39:30 GMT
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by spaceape8.eur.corp.google.com with ESMTP id o0CLcumK024831
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 13:39:29 -0800
Received: by pzk37 with SMTP id 37so13612392pzk.10
        for <linux-mm@kvack.org>; Tue, 12 Jan 2010 13:39:29 -0800 (PST)
Date: Tue, 12 Jan 2010 13:39:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
In-Reply-To: <20100112175027.B3BC.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1001121332100.9941@chino.kir.corp.google.com>
References: <20100112140923.B3A4.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1001112335001.12808@chino.kir.corp.google.com> <20100112175027.B3BC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010, KOSAKI Motohiro wrote:

> > > commit e815af95 (change all_unreclaimable zone member to flags) chage
> > > all_unreclaimable member to bit flag. but It have undesireble side
> > > effect.
> > > free_one_page() is one of most hot path in linux kernel and increasing
> > > atomic ops in it can reduce kernel performance a bit.
> > > 
> > 
> > Could you please elaborate on "a bit" in the changelog with some data?  If 
> > it's so egregious, it should be easily be quantifiable.
> 
> Unfortunately I can't. atomic ops is mainly the issue of large machine. but
> I can't access such machine now. but I'm sure we shouldn't take unnecessary
> atomic ops.
> 

e815af95 was intended to consolidate all bit flags into a single word 
merely for space efficiency and cleanliness.  At that time, we only had 
one member of struct zone that could be converted, and that was 
all_unreclaimable.  That said, it was part of a larger patchset that 
later added another zone flag meant to serialize the oom killer by 
zonelist.  So no consideration was given at the time concerning any 
penalty incurred by moving all_unreclaimable to an atomic op.

> That's fundamental space vs performance tradeoff thing. if we talked about
> struct page or similar lots created struct, space efficient is very important.
> but struct zone isn't such one.
> 
> Or, do you have strong argue to use bitops without space efficiency?
> 

I'd suggest using a non-atomic variation within zone->flags that may still 
be reordered so that it does not incur any performance penalty.  In other 
words, instead of readding zone->all_unreclaimable, we should add 
__zone_set_flag(), __zone_test_and_set_flag(), and __zone_clear_flag() 
variants to wrap non-atomic bitops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
