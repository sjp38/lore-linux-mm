Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id DB49E6B006C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 11:08:50 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so132225627pab.3
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 08:08:50 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id gz6si30154682pbc.252.2015.04.27.08.08.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 08:08:49 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NNH0080T0QL9E00@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Apr 2015 16:08:45 +0100 (BST)
Message-id: <553E50EB.3000402@samsung.com>
Date: Mon, 27 Apr 2015 17:08:27 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC v2 1/4] fs: Add generic file system event notifications
References: <1430135504-24334-1-git-send-email-b.michalska@samsung.com>
 <1430135504-24334-2-git-send-email-b.michalska@samsung.com>
 <20150427142421.GB21942@kroah.com>
In-reply-to: <20150427142421.GB21942@kroah.com>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On 04/27/2015 04:24 PM, Greg KH wrote:
> On Mon, Apr 27, 2015 at 01:51:41PM +0200, Beata Michalska wrote:
>> Introduce configurable generic interface for file
>> system-wide event notifications, to provide file
>> systems with a common way of reporting any potential
>> issues as they emerge.
>>
>> The notifications are to be issued through generic
>> netlink interface by newly introduced multicast group.
>>
>> Threshold notifications have been included, allowing
>> triggering an event whenever the amount of free space drops
>> below a certain level - or levels to be more precise as two
>> of them are being supported: the lower and the upper range.
>> The notifications work both ways: once the threshold level
>> has been reached, an event shall be generated whenever
>> the number of available blocks goes up again re-activating
>> the threshold.
>>
>> The interface has been exposed through a vfs. Once mounted,
>> it serves as an entry point for the set-up where one can
>> register for particular file system events.
>>
>> Signed-off-by: Beata Michalska <b.michalska@samsung.com>
>> ---
>>  Documentation/filesystems/events.txt |  231 ++++++++++
>>  fs/Makefile                          |    1 +
>>  fs/events/Makefile                   |    6 +
>>  fs/events/fs_event.c                 |  770 ++++++++++++++++++++++++++++++++++
>>  fs/events/fs_event.h                 |   25 ++
>>  fs/events/fs_event_netlink.c         |   99 +++++
>>  fs/namespace.c                       |    1 +
>>  include/linux/fs.h                   |    6 +-
>>  include/linux/fs_event.h             |   58 +++
>>  include/uapi/linux/fs_event.h        |   54 +++
>>  include/uapi/linux/genetlink.h       |    1 +
>>  net/netlink/genetlink.c              |    7 +-
>>  12 files changed, 1257 insertions(+), 2 deletions(-)
>>  create mode 100644 Documentation/filesystems/events.txt
>>  create mode 100644 fs/events/Makefile
>>  create mode 100644 fs/events/fs_event.c
>>  create mode 100644 fs/events/fs_event.h
>>  create mode 100644 fs/events/fs_event_netlink.c
>>  create mode 100644 include/linux/fs_event.h
>>  create mode 100644 include/uapi/linux/fs_event.h
> 
> Any reason why you just don't do uevents for the block devices today,
> and not create a new type of netlink message and userspace tool required
> to read these?

The idea here is to have support for filesystems with no backing device as well.
Parsing the message with libnl is really simple and requires few lines of code
(sample application has been presented in the initial version of this RFC)

> 
>> --- a/fs/Makefile
>> +++ b/fs/Makefile
>> @@ -126,3 +126,4 @@ obj-y				+= exofs/ # Multiple modules
>>  obj-$(CONFIG_CEPH_FS)		+= ceph/
>>  obj-$(CONFIG_PSTORE)		+= pstore/
>>  obj-$(CONFIG_EFIVAR_FS)		+= efivarfs/
>> +obj-y				+= events/
> 
> Always?
> 
>> diff --git a/fs/events/Makefile b/fs/events/Makefile
>> new file mode 100644
>> index 0000000..58d1454
>> --- /dev/null
>> +++ b/fs/events/Makefile
>> @@ -0,0 +1,6 @@
>> +#
>> +# Makefile for the Linux Generic File System Event Interface
>> +#
>> +
>> +obj-y := fs_event.o
> 
> Always?  Even if the option is not selected?  Why is everyone forced to
> always use this code?  Can't you disable it for the "tiny" systems that
> don't need it?
> 

I was considering making it optional and I guess it's worth getting back
to this idea.

>> +struct fs_trace_entry {
>> +	atomic_t	 count;
> 
> Why not just use a 'struct kref' for your count, which will save a bunch
> of open-coding of reference counting, and forcing us to audit your code
> to verify you got all the corner cases correct?  :)
> 
>> +	atomic_t	 active;
>> +	struct super_block *sb;

Not sure if using kref would change much here as the kref would not really
make it easier to verify those corner cases, unfortunately.

> 
> Are you properly reference counting this pointer?  I didn't see where
> that was happening, so I must have missed it.
> 
> thanks,
>

You haven't. And if I haven't missed anything, the sb is being used only
as long as the super is alive. Most of the code operates on sb only if it
was explicitly asked to, through call from filesystem. There is also
a callback notifying of mount being dropped (which proceeds the call to 
kill_super) that invalidates the object that depends on it.
Still, it should be explicitly stated that the sb is being used through
bidding up the s_count counter, though that would require taking the
sb_lock. AFAIK, one can get the reference to super block but for a particular
device. Maybe it would be worth having it more generic (?).


> greg k-h
> 


BR
Beata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
