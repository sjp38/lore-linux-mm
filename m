Message-ID: <3D4DB2AF.48B07053@zip.com.au>
Date: Sun, 04 Aug 2002 16:03:11 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: how not to write a search algorithm
References: <3D4CE74A.A827C9BC@zip.com.au> <20020804203804.GD4010@holomorphy.com> <3D4D9802.D1F208F0@zip.com.au> <E17bU7n-0000Yb-00@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> On Sunday 04 August 2002 23:09, Andrew Morton wrote:
> > Seems that simply changing the page_add_ramp() interface to require the
> > caller to pass in one (err, two) pte_chains would suffice.  The tricky
> > one is copy_page_range(), which is probably where -ac panics.
> 
> Hmm, seems to me my recent patch did exactly that.  Somebody called
> it 'ugly' ;-)
> 
> I did intend to move the initialization of that little pool outside
> copy_page_range, and never free the remainder.
> 
> Why two pte_chains, by the way?

Converting from a PageDirect representation to a shared-by-two
representation needs two pte_chains.

> > I suppose we could hang the pool of pte_chains off task_struct
> > and have a little "precharge the pte_chains" function.  Gack.
> 
> It's not that bad.  It's much nicer than hanging onto the rmap lock
> while kmem_cache_alloc does its thing.

The list walk is killing us now.   I think we need:

struct pte_chain {
	struct pte_chain *next;
	pte_t *ptes[L1_CACHE_BYTES/4 - 4];
};

Still poking...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
