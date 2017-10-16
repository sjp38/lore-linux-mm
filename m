Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C64216B0253
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 13:45:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v2so13771054pfa.10
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 10:45:05 -0700 (PDT)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id bi10si4810856plb.824.2017.10.16.10.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 10:45:04 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
	<CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
	<20171009000529.GY3666@dastard> <20171009183129.GE11645@wotan.suse.de>
	<87wp442lgm.fsf@xmission.com>
	<8729041d-05e5-6bea-98db-7f265edde193@suse.de>
	<20171015130625.o5k6tk5uflm3rx65@thunk.org>
	<87efq4qcry.fsf@xmission.com> <20171015232246.GI3666@dastard>
Date: Mon, 16 Oct 2017 12:44:33 -0500
In-Reply-To: <20171015232246.GI3666@dastard> (Dave Chinner's message of "Mon,
	16 Oct 2017 10:22:46 +1100")
Message-ID: <877evvng1q.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Aleksa Sarai <asarai@suse.de>, "Luis R.
 Rodriguez" <mcgrof@kernel.org>, =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA?= =?utf-8?B?0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, Christoph Hellwig <hch@infradead.org>, Jan Blunck <jblunck@infradead.org>, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, linux-xfs@vger.kernel.org

Dave Chinner <david@fromorbit.com> writes:

> On Sun, Oct 15, 2017 at 05:14:41PM -0500, Eric W. Biederman wrote:
>> Theodore Ts'o <tytso@mit.edu> writes:
>> 
>> > On Sun, Oct 15, 2017 at 07:53:11PM +1100, Aleksa Sarai wrote:
>> >> This is the bug that I talked to you about at LPC, related to devicemapper
>> >> and it not being possible to issue DELETE and REMOVE operations on a
>> >> devicemapper device that is still mounted in $some_namespace. [Before we go
>> >> on, deferred removal and deletion can help here, but the deferral will never
>> >> kick in until the reference goes away. On SUSE systems, deferred removal
>> >> doesn't appear to work at all, but that's an issue for us to solve.]
>> >
>> > Yeah, it's not really a bug, as much as (IMHO) a profound design
>> > misfeature in the way mount namespaces work.  And the fundamental
>> > problem is that there are two distinct things that you might want to
>> > do:
>> >
>> >     * In a container, "unmount" a file system is it no longer shows up in
>> >       your mount namespace.
>> >
>> >     * As a system administrator, make a mounted file system **go** **away**
>> >       because the device is about to disapear, either because:
>> >          * The iscsi/nbd device is gone or about to disappear (maybe the server is
>> > 	   about to shut down)
>> > 	 * The user wants to yank out the USB thumb drive
>> > 	 * The system is shutting down and for whatever reason the shutdown
>> > 	   sequence wants to remove the block device driver or otherwise shutdown
>> > 	   the UFS device on the Android system.
>> >
>> > The last three examples are all real world examples where people have
>> > complained to me about, and there have been some hacky things we've
>> > done as a result.
>> >
>> > We sort of have a hacky solution which works today, at least for f2fs,
>> > ext4 and xfs file systems, which is you can use
>> > {EXT4,F2FS}_FS_IOC_SHUTDOWN / XFS_IOC_GOINGDOWN ioctls to forcibly
>> > shutdown the file system, and then recurse over all of /proc looking
>> > for /proc/*/mounts files and seeing if the file system is mounted in
>> > that namespace, and then either killing the pid or somehow entering
>> > the namespace of that process and unmounting the file system.  But
>> > it's ugly and messy, and it's not at all intuitive, and so people keep
>> > tripping against the problem.
>> >
>> > What we really need is some kind of "global shutdown and unmount"
>> > system call which safely and cleanly does this.  Instead of relying on
>> > the file system's brute force shutdown sequence, it would be better if
>> > we implemented some kind of VFS-level revoke(2) functionality (ala the
>> > *BSD revoke system call, which they've had for ages) on all file
>> > descriptors opened on the file systems, and if any processes have a
>> > CWD in the file system, it is replaced by an anonymous
>> > invalid/"deleted" directory, followed by a syncfs() on the file
>> > system, followed by a recursive search and removal of the file system
>> > from all mount namespaces.
>> >
>> > Obviously, this could only be used by someone with root privileges on
>> > the "root" container.
>> 
>> There are two practical cases here.
>> 
>> 1) What to do if someone is actively using the filesystem?
>>    AKA Is using the file system as a working directory or has a file on
>>    that filesystem open possibly mmaped.
>> 
>> 2) What to do if the filesystem is simply mounted in some set of mount
>>    namespaces.
>> 
>> For the second case we should be able to solve it easily with a
>> variation on the internal detach_mounts call that we use when the mount
>> point goes away.  All of the infrastructure exists.
>> 
>> 
>> Looking at the code it appears ext4, f2fs, and xfs shutdown path
>> implements revoking a bdev from a filesystem. 
>
> Deja vu.
>
> I raised the concept of a ->shutdown() superblock op more than
> ten years ago to deal with the problem of a block device being
> yanked out from underneath a filesystem without the fs being aware
> of it. I wanted it called from the block device invalidation code
> that is run when a device is yanked out so the filesystem has
> immediate notification that the bdev is gone an is never coming
> back....
>
> Unfortunately, like so many of the things we wanted the VFS to
> support to integrate XFS properly into Linux 10-15 years ago (e.g.
> preallocation, unwritten extents, fiemap, freeze/thaw, shutdown,
> etc) it was considered "that a silly XFS problem" and so doesn't get
> any further until years later someone else has suddenly realises
> "you know, if we had ....".
>
> That's when we've finally been able to either just lifted the XFS
> ioctl interface to the VFS or implemented a new API that end up
> being a thin wrapper around existing XFS functionality.... :P
>
>> Further if the ext4 implementation is anything to go by it looks
>> like something we could generalize into the vfs.
>
> In case you hadn't guessed by now, shutdown didn't originate in ext4.
>
> The ext4 shutdown code (EXT4_IOC_SHUTDOWN) and the f2fs code
> (F2FS_IOC_SHUTDOWN) are all copies of the XFS shutdown ioctl
> interface (that's the 'X' in the ioctl definition). They got added
> so various XFS specific filesystem and data integrity tests in
> fstests that relied on the shutdown interface could be run on f2fs,
> and then more recently ext4.
>
> Historically stuff like this only gets pulled up to the VFS until
> someone on the XFS side says "stop copy-n-pasting ioctl definitions
> and define it generically!".  Hence if we pull it up to the VFS, it
> needs to takes it's cues from the XFS semantics, not the ext4
> reimplementation. They should be the same, but copy-n-paste has a
> habit of changing subtle stuff....
>
>> Hmm.  Unless I am completely mistake we already have a super block
>> operation that pretty much does this in umount_begin (the guts behind
>> mount -f).  Which makes the set of filesystems that can support this
>> kind of operation to: 9p, ceph, cifs, fuse, nfs, ext4, f2fs, and xfs.
>
> I'm not sure that a shutdown operation is correct here.  A shutdown
> operation on a filesystem like XFS chops off all IO in flight, stops
> all modifications in flight, triggers EIO on all current and future
> IO and refuses to allow anyone to read anything from the filesystem.
> Shutdown is a nasty, hard stop for a filesystem, not a "prepare to
> unmount" operation.
>
> Indeed, shutdowns can occur during unmount (e.g. corruption occurs
> due to metadata writeback errors when flushing the journal) which
> leave us with a tricky situation if unmount is supposed to use
> shutdowns to force unmounts...
>
> It must also be said here that a shutdown of an active, valid
> filesystem *will* cause unrecoverable data loss. And if it's your
> root filesystem, shutdown will be the last thing the system is able
> to do correctly until it is forcibly rebooted by hand (because the
> reboot command won't be able to be loaded from the fs)....
>
>> If the filesystem can cut all communication with the backing store as
>> ext4, f2fs, and xfs can I don't know that we need to remove the
>> filesystem from the mount tree.  The superblock will just be useless not
>> gone.
>
> So the problem that often occurs with this is that the sb can still
> hold a reference to the block device and so the device cannot be
> remounted (will give block device EBUSY errors) even though the user
> cannot find a reference to an active mount or user of the block
> device.
>
>> So my suggestions for this case are two fold.
>> 
>> - Tweak Docker and friends to not be sloppy and hold onto extra
>>   resources that they don't need.  That is just bad form.
>> 
>> - Generalize what ext4, f2fs, xfs and possibly the network filesystems
>>   with umount_begin are doing into a general disconnect this filesystem
>>   from it's backing store operation.
>> 
>>   That operation should be enough to drop the reference to the backing
>>   device so that device mapper doesn't care.
>
> Define the semantics of a forced filesystem unmount are supposed to
> be first, then decide whether an existing shutdown operation can be
> used. It may be we just need a new flag to the existing API to
> implement slightly different semantics (e.g to silence unnecessary
> warnings), but at minimum I think we've need the ->unmount_begin op
> name to change to indicate it's function, not document the calling
> context...

Definite the expected semantics of a forced filesystem umount is the
same process as defining the semantics of a forced filesytem shutdown.
Look at the code and see what it does and document it.

That said, a quick skim through the umount_begin methods on network
filesystems (the only filesystems that implement umount_begin) it
appears they drop the network connection.  Which is pretty much the same
as dropping the connection to the bdev.  So I think there is good reason
to believe these two cases can be unified.  They may not be exactly the
same but they are close enough that the should be able to share common
infrastructure.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
