Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BAB3D6B009A
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 04:31:42 -0500 (EST)
Date: Fri, 17 Dec 2010 17:31:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 22/35] writeback: trace global dirty page states
Message-ID: <20101217093136.GA21141@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150329.002158963@intel.com>
 <20101217021934.GA9525@localhost>
 <alpine.LSU.2.00.1012162239270.23229@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1012162239270.23229@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 17, 2010 at 02:52:50PM +0800, Hugh Dickins wrote:
> On Fri, 17 Dec 2010, Wu Fengguang wrote:
> > On Mon, Dec 13, 2010 at 10:47:08PM +0800, Wu, Fengguang wrote:
> > 
> > > +	TP_fast_assign(
> > > +		strlcpy(__entry->bdi,
> > > +			dev_name(mapping->backing_dev_info->dev), 32);
> > > +		__entry->ino			= mapping->host->i_ino;
> > 
> > I got an oops against the above line on shmem. Can be fixed by the
> > below patch, but still not 100% confident..
> > 
> > Thanks,
> > Fengguang
> > ---
> > Subject: writeback fix dereferencing NULL shmem mapping->host
> > Date: Thu Dec 16 22:22:00 CST 2010
> > 
> > The oops happens when doing "cp /proc/vmstat /dev/shm". It seems to be
> > triggered on accessing host->i_ino, since the offset of i_ino is exactly
> > 0x50. However I'm afraid the problem is not fully understand
> > 
> > 1) it's not normal that tmpfs will have mapping->host == NULL
> > 
> > 2) I tried removing the dereference as the below diff, however it
> >    didn't stop the oops. This is very weird.
> > 
> > TRACE_EVENT balance_dirty_state:
> > 
> >  	TP_fast_assign(
> >  		strlcpy(__entry->bdi,
> >  			dev_name(mapping->backing_dev_info->dev), 32);
> 
> I believe this line above is actually the problem: you can imagine that
> tmpfs leaves backing_dev_info->dev NULL, and dev_name() appears to

Ah, I didn't notice that obvious fact in shmem_backing_dev_info..

> access dev->init_name at 64-bit offset 0x50 down struct device.

And it's such a coincident that the two lines accessed different
struct members both with offset 0x50 :)

> > -		__entry->ino			= mapping->host->i_ino;
> >  		__entry->nr_dirty		= nr_dirty;
> >  		__entry->nr_writeback		= nr_writeback;
> >  		__entry->nr_unstable		= nr_unstable;
> ...
> > 
> > CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> I prefer hughd@google.com, but the tiscali address survived unexpectedly.

OK, just updated my alias db.

> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  mm/page-writeback.c |    3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > --- linux-next.orig/mm/page-writeback.c	2010-12-17 09:30:11.000000000 +0800
> > +++ linux-next/mm/page-writeback.c	2010-12-17 09:31:05.000000000 +0800
> > @@ -907,6 +907,9 @@ void balance_dirty_pages_ratelimited_nr(
> >  {
> >  	struct backing_dev_info *bdi = mapping->backing_dev_info;
> >  
> > +	if (!mapping_cap_writeback_dirty(mapping))
> > +		return;
> > +
> >  	current->nr_dirtied += nr_pages_dirtied;
> >  
> >  	if (unlikely(!current->nr_dirtied_pause))
> 
> That would not really be the right patch to fix your oops, but it

Then it will also avoid oops in another tracepoint balance_dirty_pages.
([PATCH 21/35] writeback: trace balance_dirty_pages() in this series)

I skipped the backing_dev_info->dev check partly because it's also
referenced in tracepoint balance_dirty_pages. So I did this cure-all
change that makes sense in itself :)

> or something like would be a very sensible patch in its own right:
> looking back through old patches I never got around to sending in,
> I can see I had a very similar one two years ago, to save wasting
> time on dirty page accounting here when it's inappropriate.

It's a pity you didn't submit it.

> Though mine was testing !mapping_cap_account_dirty(mapping).

Sorry I didn't check whether to use mapping_cap_writeback_dirty() or
mapping_cap_account_dirty() -- I just used a random one of them.

Some double checking shows that the end results are the same as for
now: all related parts set both flags at the same time with
BDI_CAP_NO_ACCT_AND_WRITEBACK. However it does look more sane to use
bdi_cap_account_dirty(bdi). I'll switch to it. Thank you!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
