Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D4E996B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 03:30:54 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so69935506pdb.2
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 00:30:54 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id ej13si37167258pdb.155.2015.06.26.00.30.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 00:30:53 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NQJ009CLJJCU690@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 26 Jun 2015 08:30:48 +0100 (BST)
Message-id: <558CFF9C.20700@samsung.com>
Date: Fri, 26 Jun 2015 09:30:36 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC v3 1/4] fs: Add generic file system event notifications
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
 <87oak5ebmx.fsf@openvz.org> <558ACD3A.2020508@samsung.com>
 <CAH2r5msAncF_KOxK-Wt_sZs-fOOMRh7KMqVJ80MK=KimUC7NLg@mail.gmail.com>
In-reply-to: 
 <CAH2r5msAncF_KOxK-Wt_sZs-fOOMRh7KMqVJ80MK=KimUC7NLg@mail.gmail.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve French <smfrench@gmail.com>
Cc: Dmitry Monakhov <dmonlist@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, Christoph Hellwig <hch@infradead.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kyungmin.park@samsung.com, kmpark@infradead.org

On 06/24/2015 06:26 PM, Steve French wrote:
> On Wed, Jun 24, 2015 at 10:31 AM, Beata Michalska
> <b.michalska@samsung.com> wrote:
>> On 06/24/2015 10:47 AM, Dmitry Monakhov wrote:
>>> Beata Michalska <b.michalska@samsung.com> writes:
>>>
>>>> Introduce configurable generic interface for file
>>>> system-wide event notifications, to provide file
>>>> systems with a common way of reporting any potential
>>>> issues as they emerge.
>>>>
>>>> The notifications are to be issued through generic
>>>> netlink interface by newly introduced multicast group.
>>>>
>>>> Threshold notifications have been included, allowing
>>>> triggering an event whenever the amount of free space drops
>>>> below a certain level - or levels to be more precise as two
>>>> of them are being supported: the lower and the upper range.
>>>> The notifications work both ways: once the threshold level
>>>> has been reached, an event shall be generated whenever
>>>> the number of available blocks goes up again re-activating
>>>> the threshold.
>>>>
>>>> The interface has been exposed through a vfs. Once mounted,
>>>> it serves as an entry point for the set-up where one can
>>>> register for particular file system events.
>>>>
>>>> Signed-off-by: Beata Michalska <b.michalska@samsung.com>
>>>> ---
>>>>  Documentation/filesystems/events.txt |  232 ++++++++++
>>>>  fs/Kconfig                           |    2 +
>>>>  fs/Makefile                          |    1 +
>>>>  fs/events/Kconfig                    |    7 +
>>>>  fs/events/Makefile                   |    5 +
>>>>  fs/events/fs_event.c                 |  809 ++++++++++++++++++++++++++++++++++
>>>>  fs/events/fs_event.h                 |   22 +
>>>>  fs/events/fs_event_netlink.c         |  104 +++++
>>>>  fs/namespace.c                       |    1 +
>>>>  include/linux/fs.h                   |    6 +-
>>>>  include/linux/fs_event.h             |   72 +++
>>>>  include/uapi/linux/Kbuild            |    1 +
>>>>  include/uapi/linux/fs_event.h        |   58 +++
>>>>  13 files changed, 1319 insertions(+), 1 deletion(-)
>>>>  create mode 100644 Documentation/filesystems/events.txt
>>>>  create mode 100644 fs/events/Kconfig
>>>>  create mode 100644 fs/events/Makefile
>>>>  create mode 100644 fs/events/fs_event.c
>>>>  create mode 100644 fs/events/fs_event.h
>>>>  create mode 100644 fs/events/fs_event_netlink.c
>>>>  create mode 100644 include/linux/fs_event.h
>>>>  create mode 100644 include/uapi/linux/fs_event.h
>>>>
>>>> diff --git a/Documentation/filesystems/events.txt b/Documentation/filesystems/events.txt
>>>> new file mode 100644
>>>> index 0000000..c2e6227
>>>> --- /dev/null
>>>> +++ b/Documentation/filesystems/events.txt
>>>> @@ -0,0 +1,232 @@
>>>> +
>>>> +    Generic file system event notification interface
>>>> +
>>>> +Document created 23 April 2015 by Beata Michalska <b.michalska@samsung.com>
>>>> +
>>>> +1. The reason behind:
>>>> +=====================
>>>> +
>>>> +There are many corner cases when things might get messy with the filesystems.
>>>> +And it is not always obvious what and when went wrong. Sometimes you might
>>>> +get some subtle hints that there is something going on - but by the time
>>>> +you realise it, it might be too late as you are already out-of-space
>>>> +or the filesystem has been remounted as read-only (i.e.). The generic
>>>> +interface for the filesystem events fills the gap by providing a rather
>>>> +easy way of real-time notifications triggered whenever something interesting
>>>> +happens, allowing filesystems to report events in a common way, as they occur.
>>>> +
>>>> +2. How does it work:
>>>> +====================
>>>> +
>>>> +The interface itself has been exposed as fstrace-type Virtual File System,
>>>> +primarily to ease the process of setting up the configuration for the
>>>> +notifications. So for starters, it needs to get mounted (obviously):
>>>> +
>>>> +    mount -t fstrace none /sys/fs/events
>>>> +
>>>> +This will unveil the single fstrace filesystem entry - the 'config' file,
>>>> +through which the notification are being set-up.
>>>> +
>>>> +Activating notifications for particular filesystem is as straightforward
>>>> +as writing into the 'config' file. Note that by default all events, despite
>>>> +the actual filesystem type, are being disregarded.
>>>> +
>>>> +Synopsis of config:
>>>> +------------------
>>>> +
>>>> +    MOUNT EVENT_TYPE [L1] [L2]
>>>> +
>>>> + MOUNT      : the filesystem's mount point
>>>> + EVENT_TYPE : event types - currently two of them are being supported:
>>>> +
>>>> +          * generic events ("G") covering most common warnings
>>>> +          and errors that might be reported by any filesystem;
>>>> +          this option does not take any arguments;
>>>> +
>>>> +          * threshold notifications ("T") - events sent whenever
>>>> +          the amount of available space drops below certain level;
>>>> +          it is possible to specify two threshold levels though
>>>> +          only one is required to properly setup the notifications;
>>>> +          as those refer to the number of available blocks, the lower
>>>> +          level [L1] needs to be higher than the upper one [L2]
>>>> +
>>>> +Sample request could look like the following:
>>>> +
>>>> + echo /sample/mount/point G T 710000 500000 > /sys/fs/events/config
>>>> +
>>>> +Multiple request might be specified provided they are separated with semicolon.
>>>> +
>>>> +The configuration itself might be modified at any time. One can add/remove
>>>> +particular event types for given fielsystem, modify the threshold levels,
>>>> +and remove single or all entries from the 'config' file.
>>>> +
>>>> + - Adding new event type:
>>>> +
>>>> + $ echo MOUNT EVENT_TYPE > /sys/fs/events/config
>>>> +
>>>> +(Note that is is enough to provide the event type to be enabled without
>>>> +the already set ones.)
>>>> +
>>>> + - Removing event type:
>>>> +
>>>> + $ echo '!MOUNT EVENT_TYPE' > /sys/fs/events/config
>>>> +
>>>> + - Updating threshold limits:
>>>> +
>>>> + $ echo MOUNT T L1 L2 > /sys/fs/events/config
>>>> +
>>>> + - Removing single entry:
>>>> +
>>>> + $ echo '!MOUNT' > /sys/fs/events/config
>>>> +
>>>> + - Removing all entries:
>>>> +
>>>> + $ echo > /sys/fs/events/config
>>>> +
>>>> +Reading the file will list all registered entries with their current set-up
>>>> +along with some additional info like the filesystem type and the backing device
>>>> +name if available.
>>>> +
>>>> +Final, though a very important note on the configuration: when and if the
>>>> +actual events are being triggered falls way beyond the scope of the generic
>>>> +filesystem events interface. It is up to a particular filesystem
>>>> +implementation which events are to be supported - if any at all. So if
>>>> +given filesystem does not support the event notifications, an attempt to
>>>> +enable those through 'config' file will fail.
>>>> +
>>>> +
>>>> +3. The generic netlink interface support:
>>>> +=========================================
>>>> +
>>>> +Whenever an event notification is triggered (by given filesystem) the current
>>>> +configuration is being validated to decide whether a userpsace notification
>>>> +should be launched. If there has been no request (in a mean of 'config' file
>>>> +entry) for given event, one will be silently disregarded. If, on the other
>>>> +hand, someone is 'watching' given filesystem for specific events, a generic
>>>> +netlink message will be sent. A dedicated multicast group has been provided
>>>> +solely for this purpose so in order to receive such notifications, one should
>>>> +subscribe to this new multicast group. As for now only the init network
>>>> +namespace is being supported.
>>>> +
>>>> +3.1 Message format
>>>> +
>>>> +The FS_NL_C_EVENT shall be stored within the generic netlink message header
>>>> +as the command field. The message payload will provide more detailed info:
>>>> +the backing device major and minor numbers, the event code and the id of
>>>> +the process which action led to the event occurrence. In case of threshold
>>>> +notifications, the current number of available blocks will be included
>>>> +in the payload as well.
>>>> +
>>>> +
>>>> +     0                   1                   2                   3
>>>> +     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
>>>> +    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>>>> +    |                   NETLINK MESSAGE HEADER                      |
>>>> +    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>>>> +    |               GENERIC NETLINK MESSAGE HEADER                  |
>>>> +    |          (with FS_NL_C_EVENT as genlmsghdr cdm field)         |
>>>> +    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>>>> +    |             Optional user specific message header             |
>>>> +    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>>>> +    |                  GENERIC MESSAGE PAYLOAD:                     |
>>>> +    +---------------------------------------------------------------+
>>>> +    |                 FS_NL_A_EVENT_ID  (NLA_U32)                   |
>>>> +    +---------------------------------------------------------------+
>>>> +    |                 FS_NL_A_DEV_MAJOR (NLA_U32)                   |
>>>> +    +---------------------------------------------------------------+
>>>> +    |                 FS_NL_A_DEV_MINOR (NLA_U32)                   |
>>>
>> ...
>>
>>>> +
>>>> +static int create_common_msg(struct sk_buff *skb, void *data)
>>>> +{
>>>> +    struct fs_trace_entry *en = (struct fs_trace_entry *)data;
>>>> +    struct super_block *sb = en->sb;
>>>> +
>>>> +    if (nla_put_u32(skb, FS_NL_A_DEV_MAJOR, MAJOR(sb->s_dev))
>>>> +    ||  nla_put_u32(skb, FS_NL_A_DEV_MINOR, MINOR(sb->s_dev)))
>>>> +            return -EINVAL;
>>> What about diskless(nfs,cifs,etc) filesystem? btrfs also has no
>>> valid sb->s_dev
> 
> And note that filesystem notifications and also file/directory change
> notification are particularly useful in the case of a a network file
> system (and heavily used by Windows desktop, Mac etc.) since when a
> file is shared a user may not necessarily know that a file (or file
> system as a whole) changed via another client (or on the server, or on
> the server via a different protocol  e.g.SMB3 vs NFSv4), but is more
> likely to know about local changes to the same file.   In some sense
> the users of mounts on network file systems get more benefit from
> notifications than a mount on a local file system would.
> 

As for the network file systems...
As it has been pointed out there are some serious scalability/performance
issues with the current version of the events interface. As it also has been
suggested I plan to modify the way the threshold notifications are being handled
by shuffling the responsibility for tracking the amount of available space 
through querying file systems for an update. Thus I'm wondering, if this
will not result in yet another issue in case of the network file systems, as for
them, handling such query means asking the sever for an update
(there is basically no caching on the client side).


Best Regards
Beata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
