Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A5E996B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 00:14:38 -0400 (EDT)
Date: Wed, 29 Apr 2009 21:14:39 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: Swappiness vs. mmap() and interactive response
Message-ID: <20090430041439.GA6110@eskimo.com>
References: <20090428090916.GC17038@localhost> <20090428120818.GH22104@mit.edu> <20090429130430.4B11.A69D9226@jp.fujitsu.com> <20090428233455.614dcf3a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428233455.614dcf3a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@mit.edu>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 11:34:55PM -0700, Andrew Morton wrote:
> On Wed, 29 Apr 2009 14:51:07 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Hi
> > 
> > > On Tue, Apr 28, 2009 at 05:09:16PM +0800, Wu Fengguang wrote:
> > > > The semi-drop-behind is a great idea for the desktop - to put just
> > > > accessed pages to end of LRU. However I'm still afraid it vastly
> > > > changes the caching behavior and wont work well as expected in server
> > > > workloads - shall we verify this?
> > > > 
> > > > Back to this big-cp-hurts-responsibility issue. Background write
> > > > requests can easily pass the io scheduler's obstacles and fill up
> > > > the disk queue. Now every read request will have to wait 10+ writes
> > > > - leading to 10x slow down of major page faults.
> > > > 
> > > > I reach this conclusion based on recent CFQ code reviews. Will bring up
> > > > a queue depth limiting patch for more exercises..
> > > 
> > > We can muck with the I/O scheduler, but another thing to consider is
> > > whether the VM should be more aggressively throttling writes in this
> > > case; it sounds like the big cp in this case may be dirtying pages so
> > > aggressively that it's driving other (more useful) pages out of the
> > > page cache --- if the target disk is slower than the source disk (for
> > > example, backing up a SATA primary disk to a USB-attached backup disk)
> > > no amount of drop-behind is going to help the situation.
> > > 
> > > So that leaves three areas for exploration:
> > > 
> > > * Write-throttling
> > > * Drop-behind
> > > * background writes pushing aside foreground reads
> > > 
> > > Hmm, note that although the original bug reporter is running Ubuntu
> > > Jaunty, and hence 2.6.28, this problem is going to get *worse* with
> > > 2.6.30, since we have the ext3 data=ordered latency fixes which will
> > > write out the any journal activity, and worse, any synchornous commits
> > > (i.e., caused by fsync) will force out all of the dirty pages with
> > > WRITE_SYNC priority.  So with a heavy load, I suspect this is going to
> > > be more of a VM issue, and especially figuring out how to tune more
> > > aggressive write-throttling may be key here.
> > 
> > firstly, I'd like to report my reproduce test result.
> > 
> > test environment: no lvm, copy ext3 to ext3 (not mv), no change swappiness, 
> >                   CFQ is used, userland is Fedora10, mmotm(2.6.30-rc1 + mm patch),
> >                   CPU opteronx4, mem 4G
> > 
> > mouse move lag:               not happend
> > window move lag:              not happend
> > Mapped page decrease rapidly: not happend (I guess, these page stay in 
> >                                           active list on my system)
> > page fault large latency:     happend (latencytop display >200ms)
> 
> hm.  The last two observations appear to be inconsistent.
> 
> Elladan, have you checked to see whether the Mapped: number in
> /proc/meminfo is decreasing?

Yes, Mapped decreases while a large file copy is ongoing.  It increases again
if I use the GUI.

> > Then, I don't doubt vm replacement logic now.
> > but I need more investigate.
> > I plan to try following thing today and tommorow.
> > 
> >  - XFS
> >  - LVM
> >  - another io scheduler (thanks Ted, good view point)
> >  - Rik's new patch
> 
> It's not clear that we know what's happening yet, is it?  It's such a
> gross problem that you'd think that even our testing would have found
> it by now :(
> 
> Elladan, do you know if earlier kernels (2.6.26 or thereabouts) had
> this severe a problem?

No, I don't know about older kernels.

Also, just to add a bit: I'm having some difficulty reproducing the extremely
severe latency I was seeing right off.  It's not difficult for me to reproduce
latencies that are painful, but not on the order of 10 second response.  Maybe
3 or 4 seconds at most.  I didn't have a stopwatch handy originally though, so
it's somewhat subjective, but I wonder if there's some element of the load that
I'm missing.

I had a theory about why this might be: my original repro was copying data
which I believe had been written once, but never read.  Plus, I was using
relatime.  However, on second thought this doesn't work -- there's only 8000
files, and a re-test with atime turned on isn't much different than with
relatime.

The other possibility is that there was some other background IO load spike,
which I didn't notice at the time.  I don't know what that would be though,
unless it was one of gnome's indexing jobs (I didn't see one, though).

-Elladan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
