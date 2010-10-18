Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E27376B00B3
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 01:57:42 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I5venP003196
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 18 Oct 2010 14:57:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CDC9945DE54
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:57:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8367545DE51
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:57:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 552651DB805F
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:57:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CDBB91DB8040
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:57:38 +0900 (JST)
Date: Mon, 18 Oct 2010 14:52:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] alloc contig pages with migration.
Message-Id: <20101018145217.38ba8ffc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTimpVWwH=znGkG8zEPBcYxq-+UR+7mN29f-RK7d=@mail.gmail.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<20101013121829.c3320944.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTingNmxT6ww_VB_K=rjsgR+dHANLnyNkwV1Myvnk@mail.gmail.com>
	<20101018093533.abd4c8ee.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikt+kq2LHZNSJAN3EQwYALdYtGuOAXfVghN-7oY@mail.gmail.com>
	<20101018143108.4e0e5299.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimpVWwH=znGkG8zEPBcYxq-+UR+7mN29f-RK7d=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Oct 2010 14:52:19 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Mon, Oct 18, 2010 at 2:31 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 18 Oct 2010 14:18:52 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >> >
> >> >> > + *
> >> >> > + * Search an area of @size in the physical memory map and checks wheter
> >> >>
> >> >> Typo
> >> >> whether
> >> >>
> >> >> > + * we can create a contigous free space. If it seems possible, try to
> >> >> > + * create contigous space with page migration. If no_search==true, we just try
> >> >> > + * to allocate [hint, hint+size) range of pages as contigous block.
> >> >> > + *
> >> >> > + * Returns a page of the beginning of contiguous block. At failure, NULL
> >> >> > + * is returned. Each page in the area is set to page_count() = 1. Because
> >> >>
> >> >> Why do you mention page_count() = 1?
> >> >> Do users of this function have to know it?
> >> >
> >> > A user can free any page within the range for his purpose.
> >>
> >> I think it's not a good idea if we allow handling of page by page, not
> >> for page-chunk requested by user.
> >> By mistake, free_contig_pages could have a trouble to free pages.
> >> Why do you support the feature? A Do you have any motivation?
> >>
> > No big motivation.
> >
> > Usual pages are set up by prep_compund_page(page, order), but it is pages smaller
> > than MAX_ORDER. A Then, I called prep_new_page() one by one.
> > And I don't think some new prep_xxxx_page() is required.
> >
> > If you requests, ok, I'll add one.
> 
> Maybe we are talking another thing.
> 
> My question is why you noticed "page_count() == 1" in function description.
> So your answer was for user to free some pages within big contiguous page.
> Then, my concern is that if you didn't mentioned page_count() == 1 in
> description, anonymous user will use just alloc_contig_pages and
> free_contig_pages. That's enough for current our requirement. But
> since you mentioned page_count() == 1 and you want for user to free
> some pages within big contiguous page, anonymous user who isn't expert
> in mm or careless people can free pages _freely_. It could make BUG
> easily(free_contig_pages can free the page which is freed by user's
> put_page).
> 
> So if there isn't strong cause, I hope removing the mention for
> preventing careless API usage.
> 

Ah, ok. I see. I'll update that parts as "use free_contig_page() to free a chunk".

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
