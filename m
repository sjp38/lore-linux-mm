Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 093356B005A
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 07:19:34 -0400 (EDT)
Date: Tue, 21 Jul 2009 13:18:02 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/4] mm: drop unneeded double negations
Message-ID: <20090721111802.GA9050@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <20090721093312.GA25383@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090721093312.GA25383@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 21, 2009 at 10:33:13AM +0100, Mel Gorman wrote:
> On Tue, Jul 21, 2009 at 10:56:31AM +0200, Johannes Weiner wrote:

> >  out_set_pte:
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 07fd8aa..46ec6a5 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -516,7 +516,7 @@ int remove_mapping(struct address_space *mapping, struct page *page)
> >  void putback_lru_page(struct page *page)
> >  {
> >  	int lru;
> > -	int active = !!TestClearPageActive(page);
> > +	int active = TestClearPageActive(page);
> >  	int was_unevictable = PageUnevictable(page);
> >  
> 
> But are you *sure* about this change?
> 
> active it used as an array offset later in this function for evictable pages
> so it needs to be 1 or 0 but IIRC, the TestClear functions are not guaranteed
> to return 0 or 1 on all architectures. They return 0 or non-zero. I'm 99.999%
> certain I've been bitten before by test_bit returning the word with the one
> bit set instead of 1. Maybe things have changed since or it's my
> imagination but can you double check please?

You are correct.  I was a bit naive there and relied on the
documentation of the generic versions of test_and_clear_bit().
However,

	- arm returns something non-zero for the atomic versions but
          uses the true boolean generic unlocked versions

	- ia64 seems to returns true boolean for everything but
          __test_and_clear_bit

Everyone else returns true booleans, so I think these two should
adjusted.

Andrew, please ignore this patch for now, I will resend it once I
fixed arm and ia64.

Thanks for pointing it out, Mel.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
