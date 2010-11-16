Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AB5848D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 16:48:55 -0500 (EST)
Subject: Re: Oops while rebalancing, now unmountable.
From: Shane Shrybman <shrybman@teksavvy.com>
In-Reply-To: <1289845457-sup-9432@think>
References: <1289236257.3611.3.camel@mars> <1289310046-sup-839@think>
	 <1289326892.4231.2.camel@mars> <1289764507.4303.9.camel@mars>
	 <20101114204206.GV6809@random.random> <20101114220018.GA4512@infradead.org>
	 <20101114221222.GX6809@random.random> <20101115182314.GA2493@infradead.org>
	 <1289845457-sup-9432@think>
Content-Type: text/plain
Date: Tue, 16 Nov 2010 16:48:48 -0500
Message-Id: <1289944128.4118.3.camel@mars>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-15 at 13:46 -0500, Chris Mason wrote:
> Excerpts from Christoph Hellwig's message of 2010-11-15 13:23:14 -0500:
> > On Sun, Nov 14, 2010 at 11:12:22PM +0100, Andrea Arcangeli wrote:
> > > I just wrote above that it can happen upstream without THP. It's not
> > > THP related at all. THP is the consumer, this is a problem in migrate
> > > that will trigger as well with migrate_pages or all other possible
> > > migration APIs.
> > > 
> > > If more people would be using hugetlbfs they would have noticed
> > > without THP.
> > 
> > Okay, it seems THP is really just the messenger for bad VM practices
> > here.
> > 
> > > +static int btree_migratepage(struct address_space *mapping,
> > > +                       struct page *newpage, struct page *page)
> > > +{
> > > +       /*
> > > +        * we can't safely write a btree page from here,
> > > +        * we haven't done the locking hook
> > > +        */
> > > +       if (PageDirty(page))
> > > +               return -EAGAIN;
> > > 
> > > fallback_migrate_page would call writeout() which is apparently not
> > > ok in btrfs for locking issues leading to corruption.
> > 
> > Hmm, it seems the issue for that particular problem is indeedin btrfs.
> > If it needs external locking for writing out data it should not
> > implement ->writepage to start with.  Chris, can you explain what's
> > going on with the btree code? It's pretty funny both in the
> > btree_writepage which goes directly into extent_write_full_page
> > if PF_MEMALLOC is not set, but otherwise does much more complicated
> > work, and also in btree_writepages which skips various WB_SYNC_NONE,
> > including the very weird check for for_kupdate.
> 
> So, I had THP + a patched btrfs running all weekend and I can safely say
> I've fixed this one now. 
> 

That seems like good news!

Is that btrfs patch available somewhere?

Where does this leave the existing corrupted btrfs'?

Thanks guys,

Shane

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
