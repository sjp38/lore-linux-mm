Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DF3266B01CA
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 09:04:42 -0400 (EDT)
Date: Wed, 9 Jun 2010 15:04:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: Implement writeback livelock avoidance using
 page tagging
Message-ID: <20100609130418.GA8739@quack.suse.cz>
References: <1275677231-15662-1-git-send-email-jack@suse.cz>
 <1275677231-15662-3-git-send-email-jack@suse.cz>
 <20100605013802.GG26335@laptop>
 <20100607160903.GE6293@quack.scz.novell.com>
 <20100608052937.GP26335@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100608052937.GP26335@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 08-06-10 15:29:37, Nick Piggin wrote:
> On Mon, Jun 07, 2010 at 06:09:03PM +0200, Jan Kara wrote:
> > On Sat 05-06-10 11:38:02, Nick Piggin wrote:
> > > On Fri, Jun 04, 2010 at 08:47:11PM +0200, Jan Kara wrote:
> > > > +	if (wbc->sync_mode == WB_SYNC_ALL)
> > > > +		tag_pages_for_writeback(mapping, index, end);
> > > 
> > > I wonder if this is too much spinlock latency in a huge dirty file?
> > > Some kid of batching of the operation perhaps would be good?
> >   You mean like copy tags for 4096 pages, then cond_resched the spin lock
> > and continue? That should be doable but it will give tasks that try to
> > livelock us more time (i.e. if there were 4096 tasks creating dirty pages
> > than probably they would be able to livelock us, won't they? Maybe we don't
> > care?).
> 
> Not 100% sure. I think that if we've got the inode in I_SYNC state, it
> should stop cleaning and dirtiers will get throttled.
> 
> Even if writeback was able to continue on that inode, it would be a big
> achievement to dirty then clean pages as fast as we are able to tag them
> in batches of 4096 :)
  In practice, you are probably right that the writers will eventually get
throttled if they were aggressive enough to dirty lots of pages while
we cond_resched the lock...

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
