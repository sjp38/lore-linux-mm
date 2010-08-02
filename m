Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CC6A2600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 16:50:50 -0400 (EDT)
Date: Mon, 2 Aug 2010 22:51:52 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/5] writeback: stop periodic/background work on seeing
 sync works
Message-ID: <20100802205152.GL3278@quack.suse.cz>
References: <20100729115142.102255590@intel.com>
 <20100729121423.332557547@intel.com>
 <20100729162027.GF12690@quack.suse.cz>
 <20100730040306.GA5694@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="pWyiEgJYm5f9v55/"
Content-Disposition: inline
In-Reply-To: <20100730040306.GA5694@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>


--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri 30-07-10 12:03:06, Wu Fengguang wrote:
> On Fri, Jul 30, 2010 at 12:20:27AM +0800, Jan Kara wrote:
> > On Thu 29-07-10 19:51:44, Wu Fengguang wrote:
> > > The periodic/background writeback can run forever. So when any
> > > sync work is enqueued, increase bdi->sync_works to notify the
> > > active non-sync works to exit. Non-sync works queued after sync
> > > works won't be affected.
> >   Hmm, wouldn't it be simpler logic to just make for_kupdate and
> > for_background work always yield when there's some other work to do (as
> > they are livelockable from the definition of the target they have) and
> > make sure any other work isn't livelockable?
> 
> Good idea!
> 
> > The only downside is that
> > non-livelockable work cannot be "fair" in the sense that we cannot switch
> > inodes after writing MAX_WRITEBACK_PAGES.
> 
> Cannot switch indoes _before_ finish with the current
> MAX_WRITEBACK_PAGES batch? 
  Well, even after writing all those MAX_WRITEBACK_PAGES. Because what you
want to do in a non-livelockable work is: take inode, write it, never look at
it again for this work. Because if you later return to the inode, it can
have newer dirty pages and thus you cannot really avoid livelock. Of
course, this all assumes .nr_to_write isn't set to something small. That
avoids the livelock as well.

> >   I even had a patch for this but it's already outdated by now. But I
> > can refresh it if we decide this is the way to go.
> 
> I'm very interested in your old patch, would you post it? Let's see
> which one is easier to work with :)
  OK, attached is the patch. I've rebased it against 2.6.35.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--pWyiEgJYm5f9v55/
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-Stop-background-writeback-if-there-is-other-work-.patch"


--pWyiEgJYm5f9v55/--
