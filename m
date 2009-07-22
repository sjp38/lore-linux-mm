Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 936836B0128
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 18:12:14 -0400 (EDT)
Date: Thu, 23 Jul 2009 00:10:23 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 5/4] mm: document is_page_cache_freeable()
Message-ID: <20090722221022.GA8667@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <1248166594-8859-4-git-send-email-hannes@cmpxchg.org> <alpine.DEB.1.10.0907221220350.3588@gentwo.org> <20090722175031.GA3484@cmpxchg.org> <20090722175417.GA7059@cmpxchg.org> <alpine.DEB.1.10.0907221500440.29748@gentwo.org> <alpine.DEB.1.00.0907221447190.24706@mail.selltech.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0907221447190.24706@mail.selltech.ca>
Sender: owner-linux-mm@kvack.org
To: "Li, Ming Chun" <macli@brc.ubc.ca>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 22, 2009 at 02:55:12PM -0700, Li, Ming Chun wrote:
> On Wed, 22 Jul 2009, Christoph Lameter wrote:
> 
> > 
> > >  static inline int is_page_cache_freeable(struct page *page)
> > >  {
> > > +	/*
> > > +	 * A freeable page cache page is referenced only by the caller
> > > +	 * that isolated the page, the page cache itself and
> > 
> > The page cache "itself"? This is the radix tree reference right?
> > 
> 
> I think you are right. I had trouble understanding this function, So I 
> looked into it and found out the call path:
> 
>  add_to_page_cache_locked 
>    -> page_cache_get
>     -> atomic_inc(&page->_count) 
> 
> Please correct me if I am wrong.

This is correct.  But this is the purpose of reference counters - you
increase it when you reference the object so that it doesn't get freed
under you.

That's why everybody holding a reference to the page must have its
usage counter increased.  And this includes the page/swap cache, the
LRU lists, the page tables etc.

And I think in that context my comment should be obvious.  Do you need
to know that the page cache is actually managed with radix trees at
this point?

You need to know that the page cache is something holding a reference
to the page so you can meet the requirements that are written above
remove_from_page_cache() - which you are about to call.

I added the comment to document that magic `compare with 2' in there.
If more is needed, I am glad to help - but right now I don't really
think I know what the issue is with this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
