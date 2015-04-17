Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id AB1576B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:04:45 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so124992222pab.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 06:04:45 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id gm2si16671244pbc.22.2015.04.17.06.04.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 06:04:44 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NMY00CSMCIDD740@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 17 Apr 2015 14:08:37 +0100 (BST)
Message-id: <553104E5.2040704@samsung.com>
Date: Fri, 17 Apr 2015 15:04:37 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <20150417113110.GD3116@quack.suse.cz>
In-reply-to: <20150417113110.GD3116@quack.suse.cz>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

On 04/17/2015 01:31 PM, Jan Kara wrote:
> On Wed 15-04-15 09:15:44, Beata Michalska wrote:
>> Introduce configurable generic interface for file
>> system-wide event notifications to provide file
>> systems with a common way of reporting any potential
>> issues as they emerge.
>>
>> The notifications are to be issued through generic
>> netlink interface, by a dedicated, for file system
>> events, multicast group. The file systems might as
>> well use this group to send their own custom messages.
>>
>> The events have been split into four base categories:
>> information, warnings, errors and threshold notifications,
>> with some very basic event types like running out of space
>> or file system being remounted as read-only.
>>
>> Threshold notifications have been included to allow
>> triggering an event whenever the amount of free space
>> drops below a certain level - or levels to be more precise
>> as two of them are being supported: the lower and the upper
>> range. The notifications work both ways: once the threshold
>> level has been reached, an event shall be generated whenever
>> the number of available blocks goes up again re-activating
>> the threshold.
>>
>> The interface has been exposed through a vfs. Once mounted,
>> it serves as an entry point for the set-up where one can
>> register for particular file system events.
>>
>> Signed-off-by: Beata Michalska <b.michalska@samsung.com>
>   Thanks for the patches! Some comments are below.
> 
>> ---
>>  Documentation/filesystems/events.txt |  254 +++++++++++
>>  fs/Makefile                          |    1 +
>>  fs/events/Makefile                   |    6 +
>>  fs/events/fs_event.c                 |  775 ++++++++++++++++++++++++++++++++++
>>  fs/events/fs_event.h                 |   27 ++
>>  fs/events/fs_event_netlink.c         |   94 +++++
>>  fs/namespace.c                       |    1 +
>>  include/linux/fs.h                   |    6 +-
>>  include/linux/fs_event.h             |   69 +++
>>  include/uapi/linux/fs_event.h        |   62 +++
>>  include/uapi/linux/genetlink.h       |    1 +
>>  net/netlink/genetlink.c              |    7 +-
>>  12 files changed, 1301 insertions(+), 2 deletions(-)
>>  create mode 100644 Documentation/filesystems/events.txt
>>  create mode 100644 fs/events/Makefile
>>  create mode 100644 fs/events/fs_event.c
>>  create mode 100644 fs/events/fs_event.h
>>  create mode 100644 fs/events/fs_event_netlink.c
>>  create mode 100644 include/linux/fs_event.h
>>  create mode 100644 include/uapi/linux/fs_event.h
>>
>> diff --git a/Documentation/filesystems/events.txt b/Documentation/filesystems/events.txt
>> new file mode 100644
>> index 0000000..c85dd88
>> --- /dev/null
>> +++ b/Documentation/filesystems/events.txt
>> @@ -0,0 +1,254 @@
>> +
>> +	Generic file system event notification interface
>> +
>> +Document created 09 April 2015 by Beata Michalska <b.michalska@samsung.com>
>> +
>> +1. The reason behind:
>> +=====================
>> +
>> +There are many corner cases when things might get messy with the filesystems.
>> +And it is not always obvious what and when went wrong. Sometimes you might
>> +get some subtle hints that there is something going on - but by the time
>> +you realise it, it might be too late as you are already out-of-space
>> +or the filesystem has been remounted as read-only (i.e.). The generic
>> +interface for the filesystem events fills the gap by providing a rather
>> +easy way of real-time notifications triggered whenever something intreseting
>> +happens, allowing filesystems to report events in a common way, as they occur.
>> +
>> +2. How does it work:
>> +====================
>> +
>> +The interface itself has been exposed as fstrace-type Virtual File System,
>> +primarily to ease the process of setting up the configuration for the file
>> +system notifications. So for starters it needs to get mounted (obviously):
>> +
>> +	mount -t fstrace none /sys/fs/events
>> +
>> +This will unveil the single fstrace filesystem entry - the 'config' file,
>> +through which the notification are being set-up.
>> +
>> +Activating notifications for particular filesystem is as straightforward
>> +as writing into the 'config' file. Note that by default all events despite
>> +the actual filesystem type are being disregarded.
>   Is there a reason to have a special filesystem for this? Do you expect
> extending it by (many) more files? Why not just creating a file in sysfs or
> something like that?

No particular reason here - just for possible future extension if needed.
I'm totally fine with having a single sysfs entry.

> 
>> +Synopsis of config:
>> +------------------
>> +
>> +	MOUNT EVENT_TYPE [L1] [L2]
>> +
>> + MOUNT      : the filesystem's mount point
>   I'm not quite decided but is mountpoint really the right thing to pass
> via the interface? They aren't unique (filesystem can be mounted in
> multiple places) and more importantly can change over time. So won't it be
> better to pass major:minor over the interface? These are stable, unique to
> the filesystem, and userspace can easily get them by calling stat(2) on the
> desired path (or directly from /proc/self/mountinfo). That could be also
> used as an fs identifier instead of assigned ID (and thus we won't need
> those events about creation of new trace which look somewhat strange to
> me).
> 
Even if a given filesystem is being mounted in many places this will come
down to single super_block - the interface will add trace for the first mount
point. This is just to ease the usage: internally a particular trace is 
associated with a super_block. 

> OTOH using major:minor may have issues in container world where processes
> could watch events from filesystems inaccessible to the container if they
> guess the device number. So maybe we could use 'path' when creating new
> trace but I'd still like to use the device number internally and for all
> outgoing communication because of above mentioned problems with
> mountpoints.

Alright then, so dropping the idea of announcing new trace (with assigned id)
and switching to using the major:minor numbers. Sounds OK to me.

> 
>> + EVENT_TYPE : type of events to be enabled: info,warn,err,thr;
>> +              at least one type needs to be specified;
>> +              note the comma delimiter and lack of spaces between
>> +	      those options
>> + L1         : the threshold limit - lower range
>> + L2         : the threshold limit - upper range
>> + 	      case enabling threshold notifications the lower level is
>> +	      mandatory, whereas the upper one remains optional;
>> +	      note though, that as those refer to the number of available
>> +	      blocks, the lower level needs to be higher than the upper one
>> +
>> +Sample request could look like the follwoing:
>> +
>> + echo /sample/mount/point warn,err,thr 710000 500000 > /sys/fs/events/config
>> +
>> +Multiple request might be specified provided they are separated with semicolon.
>   Is this necessary? It somewhat complicates syntax and parsing in kernel
> and I don't see a need for that. I'd prefer to keep the interface as simple
> as possible.
> 

This is not necessary but could ease the usage - i.e. through scripting: to specify
multiple traces and register them in one go. 

> Also I think that we should make it clear that each event type has
> different set of arguments. For threshold events they'll be L1 & L2, for
> other events there may be no arguments, for other events maybe something
> else...
> 

Currently only the threshold events use arguments -  not sure what arguments
could be used for the remaining notifications. But any suggestions are welcomed.

> ...
>> +static const match_table_t fs_etypes = {
>> +	{ FS_EVENT_INFO,    "info"  },
>> +	{ FS_EVENT_WARN,    "warn"  },
>> +	{ FS_EVENT_THRESH,  "thr"   },
>> +	{ FS_EVENT_ERR,     "err"   },
>> +	{ 0, NULL },
>> +};
>   Why are there these generic message types? Threshold messages make good
> sense to me. But not so much the rest. If they don't have a clear meaning,
> it will be a mess. So I also agree with a message like - "filesystem has
> trouble, you should probably unmount and run fsck" - that's fine. But
> generic "info" or "warning" doesn't really carry any meaning on its own and
> thus seems pretty useless to me. To explain a bit more, AFAIU this
> shouldn't be a generic logging interface where something like severity
> makes sense but rather a relatively specific interface notifying about
> events in filesystem userspace should know about so I expect relatively low
> number of types of events, not tens or even hundreds...
> 
> 								Honza

Getting rid of those would simplify the configuration part, indeed.
So we would be left with 'generic' and threshold events.
I guess I've overdone this part.

Thanks for Your comments so far.

BR
Beata





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
