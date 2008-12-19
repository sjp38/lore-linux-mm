Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C92636B0047
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 00:04:59 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBJ574vZ012794
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Dec 2008 14:07:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A0BDD45DD77
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 14:07:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8136F45DD76
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 14:07:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 199641DB803A
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 14:07:04 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C87D71DB803C
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 14:07:03 +0900 (JST)
Date: Fri, 19 Dec 2008 14:06:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Message-Id: <20081219140606.35a2f34b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081219112125.75bbda2b.kamezawa.hiroyu@jp.fujitsu.com>
References: <491DAF8E.4080506@quantum.com>
	<200811191526.00036.nickpiggin@yahoo.com.au>
	<20081119165819.GE19209@random.random>
	<20081218152952.GW24856@random.random>
	<20081219112125.75bbda2b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Dec 2008 11:21:25 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 18 Dec 2008 16:29:52 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > @@ -484,11 +476,34 @@
> >  	if (page) {
> >  		get_page(page);
> >  		page_dup_rmap(page);
> > +		if (is_cow_mapping(vm_flags) && PageAnon(page)) {
> > +			if (unlikely(TestSetPageLocked(page)))
> > +				forcecow = 1;
> > +			else {
> > +				if (unlikely(page_count(page) !=
> > +					     page_mapcount(page)
> > +					     + !!PageSwapCache(page)))
> > +					forcecow = 1;
> > +				unlock_page(page);
> > +			}
> > +		}
> >  		rss[!!PageAnon(page)]++;
> >  	}
>  - Why do you check only Anon rather than all MAP_PRIVATE mappings ?
> 
Sorry, ignore this quesiton.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
