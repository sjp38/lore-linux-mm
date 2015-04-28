Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE506B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:09:43 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so165734977pab.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:09:42 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id pa10si29899025pdb.114.2015.04.28.07.09.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 07:09:42 -0700 (PDT)
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 133F7203EB
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:09:39 -0400 (EDT)
Date: Tue, 28 Apr 2015 16:09:36 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [RFC v2 1/4] fs: Add generic file system event notifications
Message-ID: <20150428140936.GA13406@kroah.com>
References: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
 <1430135504-24334-2-git-send-email-b.michalska@samsung.com>
 <20150427142421.GB21942@kroah.com>
 <553E50EB.3000402@samsung.com>
 <20150427153711.GA23428@kroah.com>
 <20150428135653.GD9955@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150428135653.GD9955@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Beata Michalska <b.michalska@samsung.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On Tue, Apr 28, 2015 at 03:56:53PM +0200, Jan Kara wrote:
> On Mon 27-04-15 17:37:11, Greg KH wrote:
> > On Mon, Apr 27, 2015 at 05:08:27PM +0200, Beata Michalska wrote:
> > > On 04/27/2015 04:24 PM, Greg KH wrote:
> > > > On Mon, Apr 27, 2015 at 01:51:41PM +0200, Beata Michalska wrote:
> > > >> Introduce configurable generic interface for file
> > > >> system-wide event notifications, to provide file
> > > >> systems with a common way of reporting any potential
> > > >> issues as they emerge.
> > > >>
> > > >> The notifications are to be issued through generic
> > > >> netlink interface by newly introduced multicast group.
> > > >>
> > > >> Threshold notifications have been included, allowing
> > > >> triggering an event whenever the amount of free space drops
> > > >> below a certain level - or levels to be more precise as two
> > > >> of them are being supported: the lower and the upper range.
> > > >> The notifications work both ways: once the threshold level
> > > >> has been reached, an event shall be generated whenever
> > > >> the number of available blocks goes up again re-activating
> > > >> the threshold.
> > > >>
> > > >> The interface has been exposed through a vfs. Once mounted,
> > > >> it serves as an entry point for the set-up where one can
> > > >> register for particular file system events.
> > > >>
> > > >> Signed-off-by: Beata Michalska <b.michalska@samsung.com>
> > > >> ---
> > > >>  Documentation/filesystems/events.txt |  231 ++++++++++
> > > >>  fs/Makefile                          |    1 +
> > > >>  fs/events/Makefile                   |    6 +
> > > >>  fs/events/fs_event.c                 |  770 ++++++++++++++++++++++++++++++++++
> > > >>  fs/events/fs_event.h                 |   25 ++
> > > >>  fs/events/fs_event_netlink.c         |   99 +++++
> > > >>  fs/namespace.c                       |    1 +
> > > >>  include/linux/fs.h                   |    6 +-
> > > >>  include/linux/fs_event.h             |   58 +++
> > > >>  include/uapi/linux/fs_event.h        |   54 +++
> > > >>  include/uapi/linux/genetlink.h       |    1 +
> > > >>  net/netlink/genetlink.c              |    7 +-
> > > >>  12 files changed, 1257 insertions(+), 2 deletions(-)
> > > >>  create mode 100644 Documentation/filesystems/events.txt
> > > >>  create mode 100644 fs/events/Makefile
> > > >>  create mode 100644 fs/events/fs_event.c
> > > >>  create mode 100644 fs/events/fs_event.h
> > > >>  create mode 100644 fs/events/fs_event_netlink.c
> > > >>  create mode 100644 include/linux/fs_event.h
> > > >>  create mode 100644 include/uapi/linux/fs_event.h
> > > > 
> > > > Any reason why you just don't do uevents for the block devices today,
> > > > and not create a new type of netlink message and userspace tool required
> > > > to read these?
> > > 
> > > The idea here is to have support for filesystems with no backing device as well.
> > > Parsing the message with libnl is really simple and requires few lines of code
> > > (sample application has been presented in the initial version of this RFC)
> > 
> > I'm not saying it's not "simple" to parse, just that now you are doing
> > something that requires a different tool.  If you have a block device,
> > you should be able to emit uevents for it, you don't need a backing
> > device, we handle virtual filesystems in /sys/block/ just fine :)
> > 
> > People already have tools that listen to libudev for system monitoring
> > and management, why require them to hook up to yet-another-library?  And
> > what is going to provide the ability for multiple userspace tools to
> > listen to these netlink messages in case you have more than one program
> > that wants to watch for these things (i.e. multiple desktop filesystem
> > monitoring tools, system-health checkers, etc.)?
>   As much as I understand your concerns I'm not convinced uevent interface
> is a good fit. There are filesystems that don't have underlying block
> device - think of e.g. tmpfs or filesystems working directly on top of
> flash devices.  These still want to send notification to userspace (one of
> primary motivation for this interfaces was so that tmpfs can notify about
> something). And creating some fake nodes in /sys/block for tmpfs and
> similar filesystems seems like doing more harm than good to me...

If these are "fake" block devices, what's going to be present in the
block major/minor fields of the netlink message?  For some reason I
thought it was a required field, and because of that, I thought we had a
"real" filesystem somewhere to refer to, otherwise how would userspace
know what filesystem was creating these events?

What am I missing here?

confused,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
