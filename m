Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD1A6B0038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 07:58:44 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so110957971wgy.2
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 04:58:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u7si18609944wjz.206.2015.04.17.04.58.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 04:58:42 -0700 (PDT)
Date: Fri, 17 Apr 2015 13:58:39 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
Message-ID: <20150417115839.GE3116@quack.suse.cz>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <55302FFB.4010108@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55302FFB.4010108@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Cc: Beata Michalska <b.michalska@samsung.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Jan Kara <jack@suse.cz>

On Thu 16-04-15 23:56:11, Heinrich Schuchardt wrote:
> On 15.04.2015 09:15, Beata Michalska wrote:
> > Introduce configurable generic interface for file
> > system-wide event notifications to provide file
> > systems with a common way of reporting any potential
> > issues as they emerge.
> > 
> > The notifications are to be issued through generic
> > netlink interface, by a dedicated, for file system
> > events, multicast group. The file systems might as
> > well use this group to send their own custom messages.
> > 
> > The events have been split into four base categories:
> > information, warnings, errors and threshold notifications,
> > with some very basic event types like running out of space
> > or file system being remounted as read-only.
> > 
> > Threshold notifications have been included to allow
> > triggering an event whenever the amount of free space
> > drops below a certain level - or levels to be more precise
> > as two of them are being supported: the lower and the upper
> > range. The notifications work both ways: once the threshold
> > level has been reached, an event shall be generated whenever
> > the number of available blocks goes up again re-activating
> > the threshold.
> > 
> > The interface has been exposed through a vfs. Once mounted,
> > it serves as an entry point for the set-up where one can
> > register for particular file system events.
> 
> Having a framework for notification for file systems is a great idea.
> Your solution covers an important part of the possible application scope.
> 
> Before moving forward I suggest we should analyze if this scope should
> be enlarged.
> 
> Many filesystems are remote (e.g. CIFS/Samba) or distributed over many
> network nodes (e.g. Lustre). How should file system notification work here?
  IMO server <-> client notification is fully within the responsibility of
a particular protocol. The client can then translate the notification via
this interface just fine. So IMHO there's nothing to do in this regard.

> How will fuse file systems be served?
  I similar answer as previously. It's resposibility of each filesystem to
provide the notification. You would need some way for userspace to notify
the FUSE in kernel which can then relay the information via this interface.
So doable but I don't think we have to do it now...

> The current point of reference is a single mount point.
> Every time I insert an USB stick several file system may be automounted.
> I would like to receive events for these automounted file systems.
  So you'll receive udev / DBus events for the mounts, you can catch these
in a userspace daemon and add appropriate rules to receive events (you
could even make it part of the mounting procedure of your desktop). I don't
think we should magically insert new rules for mounted filesystems since
that's a decision that belongs to userspace.

> A similar case arises when starting new virtual machines. How will I
> receive events on the host system for the file systems of the virtual
> machines?
  IMHO that belongs in userspace and is out of scope for this proposal.

> In your implementation events are received via Netlink.
> Using Netlink for marking mounts for notification would create a much
> more homogenous interface. So why should we use a virtual file system here?
  Hum, that's an interesting idea. Yes, e.g. networking uses netlink to
configure e.g. routing in kernel and in case of this interface, it really
might make the interface nicer.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
