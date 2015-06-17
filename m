Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 353CB6B0075
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 05:23:09 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so35036206pdb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 02:23:08 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id ko5si5385911pdb.135.2015.06.17.02.23.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 02:23:08 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NQ300D360QF5700@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 17 Jun 2015 10:23:04 +0100 (BST)
Message-id: <55813C69.2040401@samsung.com>
Date: Wed, 17 Jun 2015 11:22:49 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC v3 1/4] fs: Add generic file system event notifications
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
 <20150616162147.GA17109@ZenIV.linux.org.uk>
In-reply-to: <20150616162147.GA17109@ZenIV.linux.org.uk>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, greg@kroah.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Hi,

On 06/16/2015 06:21 PM, Al Viro wrote:
> On Tue, Jun 16, 2015 at 03:09:30PM +0200, Beata Michalska wrote:
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
> 
> Hmm...
> 
> 1) what happens if two processes write to that file at the same time,
> trying to create an entry for the same fs?  WARN_ON() and fail for one
> of them if they race?
>

There are some limits here - I admit. The entries in the config file

might be overwritten at any time - there is no support for multiple 

config entries for the same mounted fs. This is mainly due to the threshold

notifications: handling potentially numerous threshold limits each time

the number of available blocks changes didn't seem like a good idea.

So this is more like a global config, resembling sysfs fs-related tune options.


> 2) what happens if fs is mounted more than once (e.g. in different
> namespaces, or bound at different mountpoints, or just plain mounted
> several times in different places) and we add an event for each?
> More specifically, what should happen when one of those gets unmounted?
> 

Each write to that file is being handled within the current namespace.
Setting up an entry for a mount point from a different mnt namespace
needs switching to that ns. As for bound mounts: the entry exists

until the mount point it has been registered with is detached. 
The events can only be registered for one of the mount points,
as they are tied with the super
 block - so one cannot have a separate
config entry for each bound mounts.


> 3) what's the meaning of ->active?  Is that "fs_drop_trace_entry() hadn't
> been called yet" flag?  Unless I'm misreading it, we can very well get
> explicit removal race with umount, resulting in cleanup_mnt() returning
> from fs_event_mount_dropped() before the first process (i.e. write
> asking to remove that entry) gets around to its deactivate_super(),
> ending up with umount(2) on a filesystem that isn't mounted anywhere
> else reporting success to userland before the actual fs shutdown, which
> is not a nice thing to do...
> 

The 'active' means simply that the entry for a given mounted fs
is still
 valid in a way that the events are still required: the entry
in the config file
 has not been removed. When the trace is
 being removed
- it's 'active' filed gets invalidated to mark that the events for related
fs are no longer needed. deactivate_super() should get called only once,
dropping the
 reference acquired while creating the entry (fs_new_trace_entry).

While in fs_drop_trace_entry, lock is being held (in both cases: unmount and
explicit 
entry removal). The fs_drop_trace_entry will silently skip all
the clean-up if the 
entry is inactive. I might be missing smth here - though.
If so,I would really appreciate some more of your comments.

> 4) test in fs_event_mount_dropped() looks very odd - by that point we
> are absolutely guaranteed to have ->mnt_ns == NULL.  What's that supposed
> to do?
>

I have totally missed the fact that the mnt namespace pointer is invalidated

during unmount_tree - cannot really explain why that did happen. So thank You

for pointing that out. 
	This should be simply checking if it's still valid.
 This verification is
needed in case the mount that is being detached is not
 the one the events have
been registered with as they refer to fs not a particular
 mount point. This is
the case with the mnt namespaces: let's assume one registers
 for events for
particular mounted fs in an init mnt namespace, then the new mnt
 namespace is
being created with shared moutn points being cloned: so the same
 mount point
exists in both namespaces. Now if this mnt point gets detached:
 either through
umount or during the mnt namespace being swept out - the entry
 in the init mnt
namespace should remain untouched - same applies the other way round.
 
> 
> Al, trying to figure out the lifetime rules in all of that...
> 

Best Regards
Beata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
