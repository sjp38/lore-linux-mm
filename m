Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 4F9F36B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 18:09:28 -0400 (EDT)
Date: Mon, 20 May 2013 15:09:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] mm: Activate !PageLRU pages on mark_page_accessed
 if page is on local pagevec
Message-Id: <20130520150926.9c374888290246f683272330@linux-foundation.org>
In-Reply-To: <20130516134104.GH11497@suse.de>
References: <1368440482-27909-1-git-send-email-mgorman@suse.de>
	<1368440482-27909-4-git-send-email-mgorman@suse.de>
	<20130515155500.ffe53764d9018c80572544cc@linux-foundation.org>
	<20130516134104.GH11497@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Thu, 16 May 2013 14:41:04 +0100 Mel Gorman <mgorman@suse.de> wrote:

> On Wed, May 15, 2013 at 03:55:00PM -0700, Andrew Morton wrote:
> > > @@ -441,8 +462,17 @@ void activate_page(struct page *page)
> > >  void mark_page_accessed(struct page *page)
> > >  {
> > >  	if (!PageActive(page) && !PageUnevictable(page) &&
> > > -			PageReferenced(page) && PageLRU(page)) {
> > > -		activate_page(page);
> > > +			PageReferenced(page)) {
> > > +
> > > +		/*
> > > +		 * If the page is on the LRU, promote immediately. Otherwise,
> > > +		 * assume the page is on a pagevec, mark it active and it'll
> > > +		 * be moved to the active LRU on the next drain
> > > +		 */
> > > +		if (PageLRU(page))
> > > +			activate_page(page);
> > > +		else
> > > +			__lru_cache_activate_page(page);
> > >  		ClearPageReferenced(page);
> > >  	} else if (!PageReferenced(page)) {
> > >  		SetPageReferenced(page);
> > 
> > For starters, activate_page() doesn't "promote immediately".  It sticks
> > the page into yet another pagevec for deferred activation.
> > 
> 
> True, comment updated.
> 
> > Also, I really worry about the fact that
> > activate_page()->drain->__activate_page() will simply skip over the
> > page if it has PageActive set!  So PageActive does something useful if
> > the page is in the add-to-lru pagevec but nothing useful if the page is
> > in the activate-it-soon pagevec.  This is a confusing, unobvious bug
> > attractant.
> > 
> 
> >From mark_page_accessed, we only call activate_page() for !PageActive
> and PageLRU. The PageLRU is key, if it's set, the pages *must* be on the
> inactive list or they'd trigger BUG_ON(PageActive) checks within
> vmscan.c. Am I missing your point?

I've forgotten what my point was.  I'll ramp back up when looking at
v2.  But this code is at the stage where it needs a state transition
diagram, or table.  Which makes on wonder if it's too damn complex.

Testing PageLRU while not holding lru_lock is always ... interesting.

> ...
>
> > Secondly, I really don't see how this code avoids the races.  Suppose
> > the page gets spilled from the to-add-to-lru pagevec and onto the real
> > LRU while mark_page_accessed() is concurrently executing. 
> 
> Good question. The key here is that __lru_cache_activate_page only
> searches the pagevec for the local CPU. If the current CPU is draining the
> to_add_to_lru pagevec, it cannot also be simultaneously setting PageActive
> in mark_page_accessed. It was discussed in the changelog here.
> 
> "Note that only pages on the local pagevec are considered on purpose. A
> !PageLRU page could be in the process of being released, reclaimed,
> migrated or on a remote pagevec that is currently being drained. Marking
> it PageActive is vunerable to races where PageLRU and Active bits are
> checked at the wrong time."
> 
> Subtle comments on the code belong in the changelog, right?

Not if you want anyone to read them ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
