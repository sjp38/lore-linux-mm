Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8636B0085
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 20:05:27 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so77203798pdj.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 17:05:27 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id rl7si13378929pab.173.2015.06.18.17.05.24
        for <linux-mm@kvack.org>;
        Thu, 18 Jun 2015 17:05:26 -0700 (PDT)
Date: Fri, 19 Jun 2015 10:03:41 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC v3 1/4] fs: Add generic file system event notifications
Message-ID: <20150619000341.GM10224@dastard>
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
 <20150617230605.GK10224@dastard>
 <55828064.5040301@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55828064.5040301@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, greg@kroah.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On Thu, Jun 18, 2015 at 10:25:08AM +0200, Beata Michalska wrote:
> On 06/18/2015 01:06 AM, Dave Chinner wrote:
> > On Tue, Jun 16, 2015 at 03:09:30PM +0200, Beata Michalska wrote:
> >> Introduce configurable generic interface for file
> >> system-wide event notifications, to provide file
> >> systems with a common way of reporting any potential
> >> issues as they emerge.
> >>
> >> The notifications are to be issued through generic
> >> netlink interface by newly introduced multicast group.
> >>
> >> Threshold notifications have been included, allowing
> >> triggering an event whenever the amount of free space drops
> >> below a certain level - or levels to be more precise as two
> >> of them are being supported: the lower and the upper range.
> >> The notifications work both ways: once the threshold level
> >> has been reached, an event shall be generated whenever
> >> the number of available blocks goes up again re-activating
> >> the threshold.
> >>
> >> The interface has been exposed through a vfs. Once mounted,
> >> it serves as an entry point for the set-up where one can
> >> register for particular file system events.
> >>
> >> Signed-off-by: Beata Michalska <b.michalska@samsung.com>
> > 
> > This has massive scalability problems:
....
> > Have you noticed that the filesystems have percpu counters for
> > tracking global space usage? There's good reason for that - taking a
> > spinlock in such a hot accounting path causes severe contention.
....
> > Then puts the entire netlink send path inside this spinlock, which
> > includes memory allocation and all sorts of non-filesystem code
> > paths. And it may be inside critical filesystem locks as well....
> > 
> > Apart from the serialisation problem of the locking, adding
> > memory allocation and the network send path to filesystem code
> > that is effectively considered "innermost" filesystem code is going
> > to have all sorts of problems for various filesystems. In the XFS
> > case, we simply cannot execute this sort of function in the places
> > where we update global space accounting.
> > 
> > As it is, I think the basic concept of separate tracking of free
> > space if fundamentally flawed. What I think needs to be done is that
> > filesystems need access to the thresholds for events, and then the
> > filesystems call fs_event_send_thresh() themselves from appropriate
> > contexts (ie. without compromising locking, scalability, memory
> > allocation recursion constraints, etc).
> > 
> > e.g. instead of tracking every change in free space, a filesystem
> > might execute this once every few seconds from a workqueue:
> > 
> > 	event = fs_event_need_space_warning(sb, <fs_free_space>)
> > 	if (event)
> > 		fs_event_send_thresh(sb, event);
> > 
> > User still gets warnings about space usage, but there's no runtime
> > overhead or problems with lock/memory allocation contexts, etc.
> 
> Having fs to keep a firm hand on thresholds limits would indeed be
> far more sane approach though that would require each fs to
> add support for that and handle most of it on their own. Avoiding
>> this was the main rationale behind this rfc.
> If fs people agree to that, I'll be more than willing to drop this
> in favour of the per-fs tracking solution. 
> Personally, I hope they will.

I was hoping that you'd think a little more about my suggestion and
work out how to do background threshold event detection generically.
I kind of left it as "an exercise for the reader" because it seems
obvious to me.

Hint: ->statfs allows you to get the total, free and used space
from filesystems in a generic manner.

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
