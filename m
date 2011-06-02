Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 161D36B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 18:32:29 -0400 (EDT)
Date: Fri, 3 Jun 2011 00:32:01 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110602223201.GH2802@random.random>
References: <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
 <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
 <20110531143734.GB13418@barrios-laptop>
 <20110531143830.GC13418@barrios-laptop>
 <20110602182302.GA2802@random.random>
 <20110602202156.GA23486@barrios-laptop>
 <20110602214041.GF2802@random.random>
 <BANLkTim1WjdHWOQp7bMg5pFFKp1SSFoLKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTim1WjdHWOQp7bMg5pFFKp1SSFoLKw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 03, 2011 at 07:23:48AM +0900, Minchan Kim wrote:
> I mean we have more tail pages than head pages. So I think we are likely to
> meet tail pages. Of course, compared to all pages(page cache, anon and
> so on), compound pages would be very small percentage.

Yes that's my point, that being a small percentage it's no big deal to
break the loop early.

> > isolated the head and it's useless to insist on more tail pages (at
> > least for large page size like on x86). Plus we've compaction so
> 
> I can't understand your point. Could you elaborate it?

What I meant is that if we already isolated the head page of the THP,
we don't need to try to free the tail pages and breaking the loop
early, will still give us a chance to free a whole 2m because we
isolated the head page (it'll involve some work and swapping but if it
was a compoundtranspage we're ok to break the loop and we're not
making the logic any worse). Provided the PMD_SIZE is quite large like
2/4m...

The only way this patch makes things worse is for slub order 3 in the
process of being freed. But tail pages aren't generally free anyway so
I doubt this really makes any difference plus the tail is getting
cleared as soon as the page reaches the buddy so it's probably
unnoticeable as this then makes a difference only during a race (plus
the tail page can't be isolated, only head page can be part of lrus
and only if they're THP).

> > insisting and screwing lru ordering isn't worth it, better to be
> > permissive and abort... in fact I wouldn't dislike to remove the
> > entire lumpy logic when COMPACTION_BUILD is true, but that alters the
> > trace too...
> 
> AFAIK, it's final destination to go as compaction will not break lru
> ordering if my patch(inorder-putback) is merged.

Agreed. I like your patchset, sorry for not having reviewed it in
detail yet but there were other issues popping up in the last few
days.

> >> get_page(cursor_page)
> >> /* The page is freed already */
> >> if (1 == page_count(cursor_page)) {
> >>       put_page(cursor_page)
> >>       continue;
> >> }
> >> put_page(cursor_page);
> >
> > We can't call get_page on an tail page or we break split_huge_page,
> 
> Why don't we call get_page on tail page if tail page isn't free?
> Maybe I need investigating split_huge_page.

Yes it's split_huge_page, only gup is allowed to increase the tail
page because we're guaranteed while gup_fast does it,
split_huge_page_refcount isn't running yet, because the pmd wasn't
set as splitting and the irqs were disabled (or we'd be holding the
page_table_lock for gup slow version after checking again the pmd
wasn't splitting and so __split_huge_page_refcount will wait).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
