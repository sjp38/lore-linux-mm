Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 412FD6B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 05:45:00 -0500 (EST)
Date: Fri, 2 Mar 2012 18:39:51 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-ID: <20120302103951.GA13378@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144747.198713792@intel.com>
 <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
 <20120301123640.GA30369@localhost>
 <20120301163837.GA13104@quack.suse.cz>
 <20120302044858.GA14802@localhost>
 <20120302095910.GB1744@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120302095910.GB1744@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 02, 2012 at 10:59:10AM +0100, Jan Kara wrote:
> On Fri 02-03-12 12:48:58, Wu Fengguang wrote:
> > On Thu, Mar 01, 2012 at 05:38:37PM +0100, Jan Kara wrote:
> > > On Thu 01-03-12 20:36:40, Wu Fengguang wrote:
> > > > > Please have a think about all of this and see if you can demonstrate
> > > > > how the iput() here is guaranteed safe.
> > > > 
> > > > There are already several __iget()/iput() calls inside fs-writeback.c.
> > > > The existing iput() calls already demonstrate its safety?
> > > > 
> > > > Basically the flusher works in this way
> > > > 
> > > > - the dirty inode list i_wb_list does not reference count the inode at all
> > > > 
> > > > - the flusher thread does something analog to igrab() and set I_SYNC
> > > >   before going off to writeout the inode
> > > > 
> > > > - evict() will wait for completion of I_SYNC
> > >   Yes, you are right that currently writeback code already holds inode
> > > references and so it can happen that flusher thread drops the last inode
> > > reference. But currently that could create problems only if someone waits
> > > for flusher thread to make progress while effectively blocking e.g.
> > > truncate from happening. Currently flusher thread handles sync(2) and
> > > background writeback and filesystems take care to not hold any locks
> > > blocking IO / truncate while possibly waiting for these.
> > > 
> > > But with your addition situation changes significantly - now anyone doing
> > > allocation can block and do allocation from all sorts of places including
> > > ones where we hold locks blocking other fs activity. The good news is that
> > > we use GFP_NOFS in such places. So if GFP_NOFS allocation cannot possibly
> > > depend on a completion of some writeback work, then I'd still be
> > > comfortable with dropping inode references from writeback code. But Andrew
> > > is right this at least needs some arguing...
> > 
> > You seem to miss the point that we don't do wait or page allocations
> > inside queue_pageout_work().
>   I didn't miss this point. I know we don't wait directly. But if the only

Ah OK.

> way to free pages from the zone where we need to do allocation is via flusher
> thread, then we effectively *are* waiting for the work to complete. And if
> the flusher thread is blocked, we have a problem.

Right. If the flusher ever deadlocks itself, page reclaim may be in trouble.

What's more, the global dirty threshold may also go exceeded
(especially when it's the only bdi in the system). Then
balance_dirty_pages() kicks in and block every writers in the system,
including the occasional writers. For example, /bin/bash will be block
when writing to .bash_history. The system effectively becomes
unusable..

> And I agree it's unlikely but given enough time and people, I
> believe someone finds a way to (inadvertedly) trigger this.

Right. The pageout works could add lots more iput() to the flusher
and turn some hidden statistical impossible bugs into real ones.

Fortunately the "flusher deadlocks itself" case is easy to detect and
prevent as illustrated in another email.

> > The final iput() will not block the
> > random tasks because the latter don't wait for completion of the work.
> > 
> >         random task                     flusher thread
> > 
> >         page allocation
> >           page reclaim
> >             queue_pageout_work()
> >               igrab()
> > 
> >                   ......  after a while  ......
> > 
> >                                         execute pageout work                
> >                                         iput()
> >                                         <work completed>
> > 
> > There will be some reclaim_wait()s if the pageout works are not
> > executed quickly, in which case vmscan will be impacted and slowed
> > down. However it's not waiting for any specific work to complete, so
> > there is no chance to form a loop of dependencies leading to deadlocks.
> > 
> > The iput() does have the theoretic possibility to deadlock the flusher
> > thread itself (but not with the other random tasks). Since the flusher
> > thread has always been doing iput() w/o running into such bugs, we can
> > reasonably expect the new iput() to be as safe in practical.
>   But so far, kswapd could do writeout itself so even if flusher thread is
> blocked in iput(), we could still do writeout from kswapd to clean zones.
> 
> Now I don't think blocking on iput() can be a problem because of reasons I
> outlined in another email yesterday (GFP_NOFS allocations and such). Just
> I don't agree with your reasoning that it cannot be a problem because it
> was not problem previously. That's just not true.

Heh the dilemma for GFP_NOFS is: vmscan only pageout() inode pages for
__GFP_FS allocations. So the only hope for this kind of allocations
is to relay pageout works to the flusher...and hope that it does not
deadlock itself.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
