Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id DFFF56B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 06:32:40 -0400 (EDT)
Received: by widdi4 with SMTP id di4so85911656wid.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 03:32:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lc7si31420982wjc.124.2015.04.20.03.32.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 03:32:38 -0700 (PDT)
Date: Mon, 20 Apr 2015 12:32:32 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
Message-ID: <20150420103232.GE3117@quack.suse.cz>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <20150417113110.GD3116@quack.suse.cz>
 <067F429D-5480-4449-9141-87B5D9BD1309@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <067F429D-5480-4449-9141-87B5D9BD1309@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Jan Kara <jack@suse.cz>, Beata Michalska <b.michalska@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Hugh Dickins <hughd@google.com>, =?utf-8?B?THVrw6HFoQ==?= Czerner <lczerner@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ext4 <linux-ext4@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kyungmin.park@samsung.com, kmpark@infradead.org

On Fri 17-04-15 16:44:16, Andreas Dilger wrote:
> On Apr 17, 2015, at 5:31 AM, Jan Kara <jack@suse.cz> wrote:
> > On Wed 15-04-15 09:15:44, Beata Michalska wrote:
> >> Introduce configurable generic interface for file
> >> system-wide event notifications to provide file
> >> systems with a common way of reporting any potential
> >> issues as they emerge.
> >> 
> >> The notifications are to be issued through generic
> >> netlink interface, by a dedicated, for file system
> >> events, multicast group. The file systems might as
> >> well use this group to send their own custom messages.
> >> 
> >> The events have been split into four base categories:
> >> information, warnings, errors and threshold notifications,
> >> with some very basic event types like running out of space
> >> or file system being remounted as read-only.
> >> 
> >> Threshold notifications have been included to allow
> >> triggering an event whenever the amount of free space
> >> drops below a certain level - or levels to be more precise
> >> as two of them are being supported: the lower and the upper
> >> range. The notifications work both ways: once the threshold
> >> level has been reached, an event shall be generated whenever
> >> the number of available blocks goes up again re-activating
> >> the threshold.
> >> 
> >> The interface has been exposed through a vfs. Once mounted,
> >> it serves as an entry point for the set-up where one can
> >> register for particular file system events.
> >> 
> >> Signed-off-by: Beata Michalska <b.michalska@samsung.com>
> >  Thanks for the patches! Some comments are below.
> > 
> >> ---
> >> Documentation/filesystems/events.txt |  254 +++++++++++
> >> fs/Makefile                          |    1 +
> >> fs/events/Makefile                   |    6 +
> >> fs/events/fs_event.c                 |  775 ++++++++++++++++++++++++++++++++++
> >> fs/events/fs_event.h                 |   27 ++
> >> fs/events/fs_event_netlink.c         |   94 +++++
> >> fs/namespace.c                       |    1 +
> >> include/linux/fs.h                   |    6 +-
> >> include/linux/fs_event.h             |   69 +++
> >> include/uapi/linux/fs_event.h        |   62 +++
> >> include/uapi/linux/genetlink.h       |    1 +
> >> net/netlink/genetlink.c              |    7 +-
> >> 12 files changed, 1301 insertions(+), 2 deletions(-)
> >> create mode 100644 Documentation/filesystems/events.txt
> >> create mode 100644 fs/events/Makefile
> >> create mode 100644 fs/events/fs_event.c
> >> create mode 100644 fs/events/fs_event.h
> >> create mode 100644 fs/events/fs_event_netlink.c
> >> create mode 100644 include/linux/fs_event.h
> >> create mode 100644 include/uapi/linux/fs_event.h
> >> 
> >> diff --git a/Documentation/filesystems/events.txt b/Documentation/filesystems/events.txt
> >> new file mode 100644
> >> index 0000000..c85dd88
> >> --- /dev/null
> >> +++ b/Documentation/filesystems/events.txt
> >> @@ -0,0 +1,254 @@
> >> +
> >> +	Generic file system event notification interface
> >> +
> >> +Document created 09 April 2015 by Beata Michalska <b.michalska@samsung.com>
> >> +
> >> +1. The reason behind:
> >> +=====================
> >> +
> >> +There are many corner cases when things might get messy with the filesystems.
> >> +And it is not always obvious what and when went wrong. Sometimes you might
> >> +get some subtle hints that there is something going on - but by the time
> >> +you realise it, it might be too late as you are already out-of-space
> >> +or the filesystem has been remounted as read-only (i.e.). The generic
> >> +interface for the filesystem events fills the gap by providing a rather
> >> +easy way of real-time notifications triggered whenever something intreseting
> >> +happens, allowing filesystems to report events in a common way, as they occur.
> >> +
> >> +2. How does it work:
> >> +====================
> >> +
> >> +The interface itself has been exposed as fstrace-type Virtual File System,
> >> +primarily to ease the process of setting up the configuration for the file
> >> +system notifications. So for starters it needs to get mounted (obviously):
> >> +
> >> +	mount -t fstrace none /sys/fs/events
> >> +
> >> +This will unveil the single fstrace filesystem entry - the 'config' file,
> >> +through which the notification are being set-up.
> >> +
> >> +Activating notifications for particular filesystem is as straightforward
> >> +as writing into the 'config' file. Note that by default all events despite
> >> +the actual filesystem type are being disregarded.
> >  Is there a reason to have a special filesystem for this? Do you expect
> > extending it by (many) more files? Why not just creating a file in sysfs or
> > something like that?
> > 
> >> +Synopsis of config:
> >> +------------------
> >> +
> >> +	MOUNT EVENT_TYPE [L1] [L2]
> >> +
> >> + MOUNT      : the filesystem's mount point
> >  I'm not quite decided but is mountpoint really the right thing to pass
> > via the interface? They aren't unique (filesystem can be mounted in
> > multiple places) and more importantly can change over time. So won't it be
> > better to pass major:minor over the interface? These are stable, unique to
> > the filesystem, and userspace can easily get them by calling stat(2) on the
> > desired path (or directly from /proc/self/mountinfo). That could be also
> > used as an fs identifier instead of assigned ID (and thus we won't need
> > those events about creation of new trace which look somewhat strange to
> > me).
> > 
> > OTOH using major:minor may have issues in container world where processes
> > could watch events from filesystems inaccessible to the container if they
> > guess the device number. So maybe we could use 'path' when creating new
> > trace but I'd still like to use the device number internally and for all
> > outgoing communication because of above mentioned problems with
> > mountpoints.
> 
> Please don't make major:minor part of the interface.  That doesn't make
> sense for network filesystems.  Using the mountpoint to set this up is
> fine, and really what is expected by userspace tools to monitor a specific
> mountpoint.  We could use sb->s_id to identify the events.
  So for setup I agree that mountpoint is probably the easiest. For
reporting back from kernel, sb->s_id isn't enough because as Beata noted,
this isn't unique. You are right that for network filesystems (or
in-memory filesystem for that matter) device number doesn't make any
particular sense but each fs (even e.g. procfs) is assigned a "virtual"
device number which uniquely identifies that filesystem. You can see that
device number in /proc/self/mountinfo and you will also see it in st_dev
from stat(2). So using that is IMHO better than devising own unique number.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
