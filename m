Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8516B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 17:56:34 -0400 (EDT)
Received: by wiax7 with SMTP id x7so21187575wia.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 14:56:33 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id rx3si16061232wjb.64.2015.04.16.14.56.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 14:56:32 -0700 (PDT)
Message-ID: <55302FFB.4010108@gmx.de>
Date: Thu, 16 Apr 2015 23:56:11 +0200
From: Heinrich Schuchardt <xypron.glpk@gmx.de>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com> <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
In-Reply-To: <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>, linux-kernel@vger.kernel.org
Cc: tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Jan Kara <jack@suse.cz>

On 15.04.2015 09:15, Beata Michalska wrote:
> Introduce configurable generic interface for file
> system-wide event notifications to provide file
> systems with a common way of reporting any potential
> issues as they emerge.
> 
> The notifications are to be issued through generic
> netlink interface, by a dedicated, for file system
> events, multicast group. The file systems might as
> well use this group to send their own custom messages.
> 
> The events have been split into four base categories:
> information, warnings, errors and threshold notifications,
> with some very basic event types like running out of space
> or file system being remounted as read-only.
> 
> Threshold notifications have been included to allow
> triggering an event whenever the amount of free space
> drops below a certain level - or levels to be more precise
> as two of them are being supported: the lower and the upper
> range. The notifications work both ways: once the threshold
> level has been reached, an event shall be generated whenever
> the number of available blocks goes up again re-activating
> the threshold.
> 
> The interface has been exposed through a vfs. Once mounted,
> it serves as an entry point for the set-up where one can
> register for particular file system events.

Having a framework for notification for file systems is a great idea.
Your solution covers an important part of the possible application scope.

Before moving forward I suggest we should analyze if this scope should
be enlarged.

Many filesystems are remote (e.g. CIFS/Samba) or distributed over many
network nodes (e.g. Lustre). How should file system notification work here?

How will fuse file systems be served?

The current point of reference is a single mount point.
Every time I insert an USB stick several file system may be automounted.
I would like to receive events for these automounted file systems.

A similar case arises when starting new virtual machines. How will I
receive events on the host system for the file systems of the virtual
machines?

In your implementation events are received via Netlink.
Using Netlink for marking mounts for notification would create a much
more homogenous interface. So why should we use a virtual file system here?

Best regards

Heinrich Schuchardt


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
