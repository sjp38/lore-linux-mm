Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5A48D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 13:46:49 -0500 (EST)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: Oops while rebalancing, now unmountable.
In-reply-to: <20101115182314.GA2493@infradead.org>
References: <1289236257.3611.3.camel@mars> <1289310046-sup-839@think> <1289326892.4231.2.camel@mars> <1289764507.4303.9.camel@mars> <20101114204206.GV6809@random.random> <20101114220018.GA4512@infradead.org> <20101114221222.GX6809@random.random> <20101115182314.GA2493@infradead.org>
Date: Mon, 15 Nov 2010 13:46:02 -0500
Message-Id: <1289845457-sup-9432@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Shane Shrybman <shrybman@teksavvy.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Excerpts from Christoph Hellwig's message of 2010-11-15 13:23:14 -0500:
> On Sun, Nov 14, 2010 at 11:12:22PM +0100, Andrea Arcangeli wrote:
> > I just wrote above that it can happen upstream without THP. It's not
> > THP related at all. THP is the consumer, this is a problem in migrate
> > that will trigger as well with migrate_pages or all other possible
> > migration APIs.
> > 
> > If more people would be using hugetlbfs they would have noticed
> > without THP.
> 
> Okay, it seems THP is really just the messenger for bad VM practices
> here.
> 
> > +static int btree_migratepage(struct address_space *mapping,
> > +                       struct page *newpage, struct page *page)
> > +{
> > +       /*
> > +        * we can't safely write a btree page from here,
> > +        * we haven't done the locking hook
> > +        */
> > +       if (PageDirty(page))
> > +               return -EAGAIN;
> > 
> > fallback_migrate_page would call writeout() which is apparently not
> > ok in btrfs for locking issues leading to corruption.
> 
> Hmm, it seems the issue for that particular problem is indeedin btrfs.
> If it needs external locking for writing out data it should not
> implement ->writepage to start with.  Chris, can you explain what's
> going on with the btree code? It's pretty funny both in the
> btree_writepage which goes directly into extent_write_full_page
> if PF_MEMALLOC is not set, but otherwise does much more complicated
> work, and also in btree_writepages which skips various WB_SYNC_NONE,
> including the very weird check for for_kupdate.

So, I had THP + a patched btrfs running all weekend and I can safely say
I've fixed this one now. 

> 
> What's the story behing all this and the corruption that Andrea found?

For the metadata blocks, btrfs gets into a problematic lock inversion
where it needs to record that a block has been written so that it will
be properly recowed when someone tries to change it again.

Basically the rule for btree_writepage:

1) lock the extent buffer (different from the page)
2) mark the metadata block as written
3) lock the page
4) call writepage

Btrfs does this correctly everywhere it uses writepage, and everyone
else either uses writepages or is PF_MEMALLOC, except for the page
migration code, which just jumps to step 4.

So, my current fix adds a migrate page hook and adds a warning into the
code to make sure we protest loudly when the block isn't marked as
written.  Since this shakedown worked well, I'm changing the warning to
a BUG().

The check for kupdate in btree_writepages is different.  Once we write
something, we have to do a good amount of work in order to modify it
again.  The btrfs log commits make sure that we write metadata from time
to time, so we don't really need help from the flusher threads unless.

We also don't want to waste time writing metadata from
balance_dirty_pages.  It'll just make more allocations later as we
wander around and recow things, and it is much more likely to be seeky
than the file IO.  So we setup a threshold where we don't bother doing
metadata IO unless there is a good amount pending.

I'm fine with removing the metadata writepage entirely, it didn't use to
have this many rules and it seems like a better idea to have it not
there at all.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
