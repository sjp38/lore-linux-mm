Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A0DF26B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 10:40:45 -0500 (EST)
Date: Tue, 23 Feb 2010 16:40:16 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] vmscan: factor out page reference checks
Message-ID: <20100223154016.GC29762@cmpxchg.org>
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org> <1266868150-25984-2-git-send-email-hannes@cmpxchg.org> <1266932303.2723.13.camel@barrios-desktop> <20100223142158.GA29762@cmpxchg.org> <1266936254.2723.33.camel@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1266936254.2723.33.camel@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello Minchan,

On Tue, Feb 23, 2010 at 11:44:14PM +0900, Minchan Kim wrote:
> On Tue, 2010-02-23 at 15:21 +0100, Johannes Weiner wrote:
> > Hello Minchan,
> > 
> > On Tue, Feb 23, 2010 at 10:38:23PM +0900, Minchan Kim wrote:
> 
> <snip>
> 
> > > >  
> > > >  		if (PageDirty(page)) {
> > > > -			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
> > > > +			if (references == PAGEREF_RECLAIM_CLEAN)
> > > 
> > > How equal PAGEREF_RECLAIM_CLEAN and sc->order <= PAGE_ALLOC_COSTLY_ORDER
> > > && referenced by semantic?
> > 
> > It is encoded in page_check_references().  When
> > 	sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced
> > it returns PAGEREF_RECLAIM_CLEAN.
> > 
> > So
> > 
> > 	- PageDirty() && order < COSTLY && referenced
> > 	+ PageDirty() && references == PAGEREF_RECLAIM_CLEAN
> > 
> > is an equivalent transformation.  Does this answer your question?
> 
> Hmm. I knew it. My point was PAGEREF_RECLAIM_CLEAN seems to be a little
> awkward. I thought PAGEREF_RECLAIM_CLEAN means if the page was clean, it
> can be reclaimed.

But you were thinking right, it is exactly what it means!  If
the state is PAGEREF_RECLAIM_CLEAN, reclaim the page if it is clean:

	if (PageDirty(page)) {
		if (references == PAGEREF_RECLAIM_CLEAN)
			goto keep_locked;	/* do not reclaim */
		...
	}

> I think it would be better to rename it with represent "Although it's
> referenced page recently, we can reclaim it if VM try to reclaim high
> order page".

I changed it to PAGEREF_RECLAIM_LUMPY and PAGEREF_RECLAIM, but I felt
it made it worse.  It's awkward that we have to communicate that state
at all, maybe it would be better to do

        if (PageDirty(page) && referenced_page)
                return PAGEREF_KEEP;

in page_check_references()?  But doing PageDirty() twice is also kinda
lame.

I don't know.  Can we leave it like that for now?

        Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
