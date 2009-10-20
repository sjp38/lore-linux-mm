Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC61A6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 06:48:39 -0400 (EDT)
Date: Tue, 20 Oct 2009 11:48:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091020104839.GC11778@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <20091014103002.GA5027@csn.ul.ie> <200910141510.11059.elendil@planet.nl> <200910190133.33183.elendil@planet.nl> <20091019140151.GC9036@csn.ul.ie> <20091019161815.GA11487@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091019161815.GA11487@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Frans Pop <elendil@planet.nl>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 20, 2009 at 01:18:15AM +0900, Chris Mason wrote:
> On Mon, Oct 19, 2009 at 03:01:52PM +0100, Mel Gorman wrote:
> > 
> > > During the 2nd phase I see the first SKB allocation errors with a music 
> > > skip between reading commits 95.000 and 110.000.
> > > About commit 115.000 there is a very long pause during which the counter 
> > > does not increase, music stops and the desktop freezes completely. The 
> > > first 30 seconds of that freeze there is only very low disk activity (which 
> > > seems strange);
> > 
> > I'm just going to have to depend on Jens here. Jens, the congestion_wait() is
> > on BLK_RW_ASYNC after the commit. Reclaim usually writes pages asynchronously
> > but lumpy reclaim actually waits of pages to write out synchronously so
> > it's not always async.
> 
> Waiting doesn't make it synchronous from the elevator point of view ;)
> If you're using WB_SYNC_NONE, it's a async write.  WB_SYNC_ALL makes it
> a sync write.  I only see WB_SYNC_NONE in vmscan.c, so we should be
> using the async congestion wait.  (the exception is xfs which always
> does async writes).
> 

Right, reclaim always queues the pages for async IO but for lumpy reclaim,
it calls wait_on_page_writeback() but as you say, from an elevator point of
view, it's still async.

> But I'm honestly not 100% sure.  Looking back through the emails, the
> test case is doing IO on top of a whole lot of things on top of
> dm-crypt?  I just tried to figure out if dm-crypt is turning the async
> IO into sync IOs, but didn't quite make sense of it.
> 

I'm not overly sure either.

> Could you also please include which filesystems were being abused during
> the test and how?  Reading through the emails, I think you've got:
> 
> gitk being run 3 times on some FS (NFS?)
> streaming reads on NFS
> swap on dm-crypt
> 
> If other filesystems are being used, please correct me.  Also please
> include if they are on crypto or straight block device.
> 

I've attached a patch below that should allow us to cheat. When it's applied,
it outputs who called congestion_wait(), how long the timeout was and how
long it waited for. By comparing before and after sleep times, we should
be able to see which of the callers has significantly changed and if
it's something easily addressable.

> > Either way, reclaim is usually worried about writing pages but it would appear
> > after this change that a lot of read activity can also stall a process in
> > direct reclaim. What might be happening in Frans's particular case is that the
> > tasklet that allocates high-order pages for the RX buffers is getting stalled
> > by congestion caused by other processes doing reads from the filesystem.
> > While it makes sense from a congestion point of view to halt the IO, the
> > reclaim operations from direct reclaimers is getting delayed for long enough
> > to cause problems for GFP_ATOMIC.
> 
> The congestion_wait code either waits for congestion to clear or for
> a given timeout.  The part that isn't clear is if before the patch
> we waited a very short time (congestion cleared quickly) or a very long
> time (we hit the timeout or congestion cleared slowly).
> 

Using the instrumentation patch, I found with a very basic test that we
are waiting for short periods of time more often with the patch applied

      1 congestion_wait   rw=1 delay 6 timeout 25 :: before commit
      7 kswapd            congestion_wait   rw=1 delay 0 timeout 25 :: before commit
     32 kswapd            congestion_wait sync=0 delay 0 timeout 25 :: after commit
     61 kswapd            congestion_wait   rw=1 delay 1 timeout 25 :: before commit
    133 kswapd            congestion_wait sync=0 delay 1 timeout 25 :: after commit
     16 kswapd            congestion_wait   rw=1 delay 2 timeout 25 :: before commit
     70 kswapd            congestion_wait sync=0 delay 2 timeout 25 :: after commit
      1 try_to_free_pages congestion_wait sync=0 delay 2 timeout 25 :: after commit
     17 kswapd            congestion_wait   rw=1 delay 3 timeout 25 :: before commit
     28 kswapd            congestion_wait sync=0 delay 3 timeout 25 :: after commit
      1 try_to_free_pages congestion_wait sync=0 delay 3 timeout 25 :: after commit
     23 kswapd            congestion_wait   rw=1 delay 4 timeout 25 :: before commit
     16 kswapd            congestion_wait sync=0 delay 4 timeout 25 :: after commit
      5 try_to_free_pages congestion_wait sync=0 delay 4 timeout 25 :: after commit
     20 kswapd            congestion_wait   rw=1 delay 5 timeout 25 :: before commit
     18 kswapd            congestion_wait sync=0 delay 5 timeout 25 :: after commit
      3 try_to_free_pages congestion_wait sync=0 delay 5 timeout 25 :: after commit
     21 kswapd            congestion_wait   rw=1 delay 6 timeout 25 :: before commit
      8 kswapd            congestion_wait sync=0 delay 6 timeout 25 :: after commit
      2 try_to_free_pages congestion_wait sync=0 delay 6 timeout 25 :: after commit
     13 kswapd            congestion_wait   rw=1 delay 7 timeout 25 :: before commit
     12 kswapd            congestion_wait sync=0 delay 7 timeout 25 :: after commit
      2 try_to_free_pages congestion_wait sync=0 delay 7 timeout 25 :: after commit
      8 kswapd            congestion_wait   rw=1 delay 8 timeout 25 :: before commit
      7 kswapd            congestion_wait sync=0 delay 8 timeout 25 :: after commit
      9 kswapd            congestion_wait   rw=1 delay 9 timeout 25 :: before commit
      5 kswapd            congestion_wait sync=0 delay 9 timeout 25 :: after commit
      2 try_to_free_pages congestion_wait sync=0 delay 9 timeout 25 :: after commit
      4 kswapd            congestion_wait   rw=1 delay 10 timeout 25 :: before commit
      5 kswapd            congestion_wait sync=0 delay 10 timeout 25 :: after commit
      1 try_to_free_pages congestion_wait sync=0 delay 10 timeout 25 :: after commit
[... remaining output snipped ...]

The before and after commit are really 2.6.31 and 2.6.31-patch-reverted.
The first column is how many times we delayed for that length of time.
To generate the output, I just took the console log from both kernels with
a basic test, put the congestion_wait lines into two separate files and

cat congestion-*-sorted | sort -n -k5 | uniq -c

to give a count of how many times we delayed for a particular caller.

> The easiest way to tell is to just replace the congestion_wait() calls
> in direct reclaim with schedule_timeout_interruptible(10), test, then
> schedule_timeout_interruptible(HZ/20), then test again.
> 

Reclaim can also call congestion_wait() and maybe the problem isn't
within the page allocator at all but that it's indirectly affected by
timing.

> > 
> > Does this sound plausible to you? If so, what's the best way of
> > addressing this? Changing congestion_wait back to WRITE (assuming that
> > works for Frans)? Changing it to SYNC (again, assuming it actually
> > works) or a revert?
> 
> I don't think changing it to SYNC is a good plan unless we're actually
> doing sync io.  It would be better to just wait on one of the pages that
> you've sent down (or its hashed waitqueue since the page can go away).
> 

Frans, is there any chance you could apply the following patch and get
the console logs for a vanilla kernel and with the congestion patches
reverted? I'm hoping it'll be able to tell us which of the callers has
significantly changed in timing. If there is one caller that has
significantly changed, it might be enough to address just that caller.

=====
