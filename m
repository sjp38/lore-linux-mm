Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB5B6B009C
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 19:21:23 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so47935792pab.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 16:21:23 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id hz6si18459600pbc.59.2015.06.19.16.21.20
        for <linux-mm@kvack.org>;
        Fri, 19 Jun 2015 16:21:22 -0700 (PDT)
Date: Sat, 20 Jun 2015 09:21:17 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC v3 1/4] fs: Add generic file system event notifications
Message-ID: <20150619232117.GN10224@dastard>
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
 <20150617230605.GK10224@dastard>
 <55828064.5040301@samsung.com>
 <20150619000341.GM10224@dastard>
 <5584512B.5020301@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5584512B.5020301@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, greg@kroah.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On Fri, Jun 19, 2015 at 07:28:11PM +0200, Beata Michalska wrote:
> On 06/19/2015 02:03 AM, Dave Chinner wrote:
> > On Thu, Jun 18, 2015 at 10:25:08AM +0200, Beata Michalska wrote:
> >> On 06/18/2015 01:06 AM, Dave Chinner wrote:
> >>> On Tue, Jun 16, 2015 at 03:09:30PM +0200, Beata Michalska wrote:
> >>>> Introduce configurable generic interface for file
> >>>> system-wide event notifications, to provide file
> >>>> systems with a common way of reporting any potential
> >>>> issues as they emerge.
> >>>>
> >>>> The notifications are to be issued through generic
> >>>> netlink interface by newly introduced multicast group.
> >>>>
> >>>> Threshold notifications have been included, allowing
> >>>> triggering an event whenever the amount of free space drops
> >>>> below a certain level - or levels to be more precise as two
> >>>> of them are being supported: the lower and the upper range.
> >>>> The notifications work both ways: once the threshold level
> >>>> has been reached, an event shall be generated whenever
> >>>> the number of available blocks goes up again re-activating
> >>>> the threshold.
> >>>>
> >>>> The interface has been exposed through a vfs. Once mounted,
> >>>> it serves as an entry point for the set-up where one can
> >>>> register for particular file system events.
> >>>>
> >>>> Signed-off-by: Beata Michalska <b.michalska@samsung.com>
> >>>
> >>> This has massive scalability problems:
> > ....
> >>> Have you noticed that the filesystems have percpu counters for
> >>> tracking global space usage? There's good reason for that - taking a
> >>> spinlock in such a hot accounting path causes severe contention.
> > ....
> >>> Then puts the entire netlink send path inside this spinlock, which
> >>> includes memory allocation and all sorts of non-filesystem code
> >>> paths. And it may be inside critical filesystem locks as well....
> >>>
> >>> Apart from the serialisation problem of the locking, adding
> >>> memory allocation and the network send path to filesystem code
> >>> that is effectively considered "innermost" filesystem code is going
> >>> to have all sorts of problems for various filesystems. In the XFS
> >>> case, we simply cannot execute this sort of function in the places
> >>> where we update global space accounting.
> >>>
> >>> As it is, I think the basic concept of separate tracking of free
> >>> space if fundamentally flawed. What I think needs to be done is that
> >>> filesystems need access to the thresholds for events, and then the
> >>> filesystems call fs_event_send_thresh() themselves from appropriate
> >>> contexts (ie. without compromising locking, scalability, memory
> >>> allocation recursion constraints, etc).
> >>>
> >>> e.g. instead of tracking every change in free space, a filesystem
> >>> might execute this once every few seconds from a workqueue:
> >>>
> >>> 	event = fs_event_need_space_warning(sb, <fs_free_space>)
> >>> 	if (event)
> >>> 		fs_event_send_thresh(sb, event);
> >>>
> >>> User still gets warnings about space usage, but there's no runtime
> >>> overhead or problems with lock/memory allocation contexts, etc.
> >>
> >> Having fs to keep a firm hand on thresholds limits would indeed be
> >> far more sane approach though that would require each fs to
> >> add support for that and handle most of it on their own. Avoiding
> >>> this was the main rationale behind this rfc.
> >> If fs people agree to that, I'll be more than willing to drop this
> >> in favour of the per-fs tracking solution. 
> >> Personally, I hope they will.
> > 
> > I was hoping that you'd think a little more about my suggestion and
> > work out how to do background threshold event detection generically.
> > I kind of left it as "an exercise for the reader" because it seems
> > obvious to me.
> > 
> > Hint: ->statfs allows you to get the total, free and used space
> > from filesystems in a generic manner.
> > 
> > Cheers,
> > 
> > Dave.
> > 
> 
> I haven't given up on that, so yes, I'm still working on a more suitable
> generic solution.
> Background detection is one of the options, though it needs some more thoughts.
> Giving up the sync approach means less accuracy for the threshold notifications,
> but I guess this could be fine-tuned to get an acceptable level.

Accuracy really doesn't matter for threshold notifications - by the
time the event is delivered to userspace it can already be wrong.

> Another bump:
> how this tuning is supposed to be done (additional config option maybe)? 

Why would you need to tune it at all? You can't *stop* the operation
that is triggering the threshold, so a few seconds delay on delivery
isn't going to make any difference to anyone....

You're overthinking this massively. All this needs is a work item
per superblock, and when the thresholds are turned on it queues a
self-repeating delayed work that calls ->statfs, checks against the
configured threshold, issues an event if necessary, and then queues
itself again to run next period. When the threshold is turned off,
the work is cancelled.

Another option: a kernel thread that runs periodically and just
calls iterate_supers() with a function that checks the sb for
threshold events, and if configured runs ->statfs and does the work,
otherwise skips the sb. That avoids all the lifetime issues with
using workqueues, you don't need a struct work, etc.

> There is also an idea of using an interface resembling the stackable fs:

No. Just .... No.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
