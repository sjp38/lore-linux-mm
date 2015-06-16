Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id C92536B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 12:22:02 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so3354528wic.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:22:02 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id et1si24879772wib.116.2015.06.16.09.22.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 09:22:01 -0700 (PDT)
Date: Tue, 16 Jun 2015 17:21:47 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC v3 1/4] fs: Add generic file system event notifications
Message-ID: <20150616162147.GA17109@ZenIV.linux.org.uk>
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, greg@kroah.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On Tue, Jun 16, 2015 at 03:09:30PM +0200, Beata Michalska wrote:
> Introduce configurable generic interface for file
> system-wide event notifications, to provide file
> systems with a common way of reporting any potential
> issues as they emerge.
> 
> The notifications are to be issued through generic
> netlink interface by newly introduced multicast group.
> 
> Threshold notifications have been included, allowing
> triggering an event whenever the amount of free space drops
> below a certain level - or levels to be more precise as two
> of them are being supported: the lower and the upper range.
> The notifications work both ways: once the threshold level
> has been reached, an event shall be generated whenever
> the number of available blocks goes up again re-activating
> the threshold.
> 
> The interface has been exposed through a vfs. Once mounted,
> it serves as an entry point for the set-up where one can
> register for particular file system events.

Hmm...

1) what happens if two processes write to that file at the same time,
trying to create an entry for the same fs?  WARN_ON() and fail for one
of them if they race?

2) what happens if fs is mounted more than once (e.g. in different
namespaces, or bound at different mountpoints, or just plain mounted
several times in different places) and we add an event for each?
More specifically, what should happen when one of those gets unmounted?

3) what's the meaning of ->active?  Is that "fs_drop_trace_entry() hadn't
been called yet" flag?  Unless I'm misreading it, we can very well get
explicit removal race with umount, resulting in cleanup_mnt() returning
from fs_event_mount_dropped() before the first process (i.e. write
asking to remove that entry) gets around to its deactivate_super(),
ending up with umount(2) on a filesystem that isn't mounted anywhere
else reporting success to userland before the actual fs shutdown, which
is not a nice thing to do...

4) test in fs_event_mount_dropped() looks very odd - by that point we
are absolutely guaranteed to have ->mnt_ns == NULL.  What's that supposed
to do?


Al, trying to figure out the lifetime rules in all of that...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
