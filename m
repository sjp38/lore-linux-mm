Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C03236B011C
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 13:51:46 -0400 (EDT)
Date: Wed, 22 Jul 2009 19:50:31 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/4] mm: return boolean from page_has_private()
Message-ID: <20090722175031.GA3484@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <1248166594-8859-4-git-send-email-hannes@cmpxchg.org> <alpine.DEB.1.10.0907221220350.3588@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0907221220350.3588@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 22, 2009 at 12:49:44PM -0400, Christoph Lameter wrote:
> On Tue, 21 Jul 2009, Johannes Weiner wrote:
> 
> > Make page_has_private() return a true boolean value and remove the
> > double negations from the two callsites using it for arithmetic.
> 
> page_has_private_data()?

I am not so fond of changing that, because then we should probably
also rename page_private() and that is moot for slightly improved
source code English.

> Also note that you are adding unecessary double negation to the other
> callers. Does the compiler catch that?

Yes, callsites using it in a conditionals do not change here with gcc
4.3.3.

> > +static inline int page_has_private(struct page *page)
> > +{
> > +	return !!(page->flags & ((1 << PG_private) | (1 << PG_private_2)));
> > +}
> 
> Two private bits? How did that happen?

fscache :)

> Could we define a PAGE_FLAGS_PRIVATE in page-flags.h?

It would certainly look nicer, I will add that.

> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 6b368d3..67e2824 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -286,7 +286,7 @@ static inline int page_mapping_inuse(struct page *page)
> >
> >  static inline int is_page_cache_freeable(struct page *page)
> >  {
> > -	return page_count(page) - !!page_has_private(page) == 2;
> > +	return page_count(page) - page_has_private(page) == 2;
> 
> That looks funky and in need of comments.

Agreed, I will add one in a different patch.

	Hannes

---
