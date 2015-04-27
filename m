Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AD1776B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 10:24:30 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so130116219pdb.0
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 07:24:30 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id x1si30148870pdk.54.2015.04.27.07.24.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 07:24:29 -0700 (PDT)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 66BDD20B70
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 10:24:26 -0400 (EDT)
Date: Mon, 27 Apr 2015 16:24:21 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [RFC v2 1/4] fs: Add generic file system event notifications
Message-ID: <20150427142421.GB21942@kroah.com>
References: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
 <1430135504-24334-2-git-send-email-b.michalska@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430135504-24334-2-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On Mon, Apr 27, 2015 at 01:51:41PM +0200, Beata Michalska wrote:
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
> 
> Signed-off-by: Beata Michalska <b.michalska@samsung.com>
> ---
>  Documentation/filesystems/events.txt |  231 ++++++++++
>  fs/Makefile                          |    1 +
>  fs/events/Makefile                   |    6 +
>  fs/events/fs_event.c                 |  770 ++++++++++++++++++++++++++++++++++
>  fs/events/fs_event.h                 |   25 ++
>  fs/events/fs_event_netlink.c         |   99 +++++
>  fs/namespace.c                       |    1 +
>  include/linux/fs.h                   |    6 +-
>  include/linux/fs_event.h             |   58 +++
>  include/uapi/linux/fs_event.h        |   54 +++
>  include/uapi/linux/genetlink.h       |    1 +
>  net/netlink/genetlink.c              |    7 +-
>  12 files changed, 1257 insertions(+), 2 deletions(-)
>  create mode 100644 Documentation/filesystems/events.txt
>  create mode 100644 fs/events/Makefile
>  create mode 100644 fs/events/fs_event.c
>  create mode 100644 fs/events/fs_event.h
>  create mode 100644 fs/events/fs_event_netlink.c
>  create mode 100644 include/linux/fs_event.h
>  create mode 100644 include/uapi/linux/fs_event.h

Any reason why you just don't do uevents for the block devices today,
and not create a new type of netlink message and userspace tool required
to read these?

> --- a/fs/Makefile
> +++ b/fs/Makefile
> @@ -126,3 +126,4 @@ obj-y				+= exofs/ # Multiple modules
>  obj-$(CONFIG_CEPH_FS)		+= ceph/
>  obj-$(CONFIG_PSTORE)		+= pstore/
>  obj-$(CONFIG_EFIVAR_FS)		+= efivarfs/
> +obj-y				+= events/

Always?

> diff --git a/fs/events/Makefile b/fs/events/Makefile
> new file mode 100644
> index 0000000..58d1454
> --- /dev/null
> +++ b/fs/events/Makefile
> @@ -0,0 +1,6 @@
> +#
> +# Makefile for the Linux Generic File System Event Interface
> +#
> +
> +obj-y := fs_event.o

Always?  Even if the option is not selected?  Why is everyone forced to
always use this code?  Can't you disable it for the "tiny" systems that
don't need it?

> +struct fs_trace_entry {
> +	atomic_t	 count;

Why not just use a 'struct kref' for your count, which will save a bunch
of open-coding of reference counting, and forcing us to audit your code
to verify you got all the corner cases correct?  :)

> +	atomic_t	 active;
> +	struct super_block *sb;

Are you properly reference counting this pointer?  I didn't see where
that was happening, so I must have missed it.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
