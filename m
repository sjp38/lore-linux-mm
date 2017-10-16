Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E81D46B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 13:54:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j3so7615129pga.5
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 10:54:23 -0700 (PDT)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id b9si4779721pls.832.2017.10.16.10.54.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 10:54:22 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
	<CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
	<20171009000529.GY3666@dastard> <20171009183129.GE11645@wotan.suse.de>
	<87wp442lgm.fsf@xmission.com>
	<8729041d-05e5-6bea-98db-7f265edde193@suse.de>
	<20171015130625.o5k6tk5uflm3rx65@thunk.org>
	<87efq4qcry.fsf@xmission.com>
	<20171016011301.dcam44qylno7rm6a@thunk.org>
Date: Mon, 16 Oct 2017 12:53:53 -0500
In-Reply-To: <20171016011301.dcam44qylno7rm6a@thunk.org> (Theodore Ts'o's
	message of "Sun, 15 Oct 2017 21:13:01 -0400")
Message-ID: <87zi8rkmha.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Aleksa Sarai <asarai@suse.de>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Dave Chinner <david@fromorbit.com>, =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LA=?= =?utf-8?B?0LLRgNC40LvQvtCy?= <mikhail.v.gavrilov@gmail.com>, Christoph Hellwig <hch@infradead.org>, Jan Blunck <jblunck@infradead.org>, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, linux-xfs@vger.kernel.org

Theodore Ts'o <tytso@mit.edu> writes:

> On Sun, Oct 15, 2017 at 05:14:41PM -0500, Eric W. Biederman wrote:
>> 
>> Looking at the code it appears ext4, f2fs, and xfs shutdown path
>> implements revoking a bdev from a filesystem.  Further if the ext4
>> implementation is anything to go by it looks like something we could
>> generalize into the vfs.
>
> There are two things which the current file system shutdown paths do.
> The first is that they prevent the file system from attempting to
> write to the bdev.  That's all very file system specific, and can't be
> generalized into the VFS.
>
> The second thing they do is they cause system calls which might modify
> the file system to return an error.  Currently operations that might
> result in _reads_ are not shutdown, so it's not a true revoke(2)
> functionality ala *BSD.  I assume that's what you are talking about
> generalizing into the VFS.  Personally, I would prefer to see us
> generalize something like vhangup() but which works on a file
> descriptor, not just a TTY.  That it is, it disconnects the file
> descriptor entirely from the hardware / file system so in the case of
> the tty, it can be used by other login session, and in the case of the
> file descriptor belonging to a file system, it stops the file system
> from being unmounted.
>
> The reason why I want to see something which actually does disconnect
> the file descriptor and replaces the CWD for processes is because the
> shutdown path is inherently a fairly violent procedure.  It forcibly
> disconnects the file system from the block device, which means we
> can't do a clean unmount.  If the block device has disappeared, we
> don't have a choice, and that's the only thing we can do.
>
> But if the USB thumb drive hasn't been yanked out yet, it would be
> nice to simply disconnect everything at the file descriptor level,
> then do a normal umount in all of the namespaces.  This will allow the
> file system to be cleanly unmounted, which means it will work for
> those file systems which don't have journals.  (The ext4/btrfs/xfs
> shutdown paths rely on the file system's journalling capability
> because it causes the block device to look like the system had been
> powered off, and so you have to replay the journal when file system is
> remounted.  That's fine, but it's not going to work on file systems
> like VFAT, or worse, on NTFS, where we don't correctly support the
> native file system's logging capability, so power-fail or a forced
> shutdown may end up corrupting the file system enough that you have
> boot into Windows to run CHKDSK.EXE in order clean it up.)
>
>> I won't call this a security regression with user namespaces, or a mount
>> namespace specific issue as it appears any process that can open a file
>> has always been able to trigger this.  That said it does appear this has
>> gone from a theoretical issue to an actuall problem so it is most
>> definitely time to address and fix this.
>
> The reason why this has started become a really painful issue is that
> mount namespaces are extremely painful to debug.  You can't iterate
> over all of the possible namespaces, without having to iterate over
> every process and every thread's /proc/*/mounts.  So if there are 10
> mount namespaces, but 10,000 threads, that's 10,000 /proc/*/mounts
> file that you have to examine individually, just to *find* that needle
> in the haystack which is keeping the mount pinned.
>
> And there is at least one system daemon where when it starts, it opens
> a new mount namespace.  Which means if you happen to have a USB
> thumbdrive mounted when you restart that system daemon, it is not at
> all obvious what you need to do to unmount the USB thumb drive.  And
> yes, any process can open a file, but people at least knew how to find
> it by using lsof.  So perhaps this could be solved partially by better
> tooling, but I would argue that having userspace do a brute force
> search through all of /proc/*/fd/* actually wasn't particularly clean,
> either.  We've lived with it, true.  But perhaps it's time to do
> something better?
>
> And in the case where the system daemon only accidentally captured the
> USB thumb drive by forking a mount namespace, it would be *definitely*
> nice if we could simply make the mount disappear, instead of what we
> have to today, which is kill the system daemon, unmount the USB thumb
> drive, and then restart the system daemon.  (Once, that is, you have
> figured what is going on first.  Often, you end up reporting an ext4
> bug to the ext4 maintainer first, because you think it's an ext4 bug
> that ext4 is refusing to unmount the file system.  After all, you are
> an experienced system administrator, so you *know* that *nothing*
> could *possibly* be keeping the file system busy.  lsof said so.  :-)

I would prefer that we start with what we can do easily.  There is a
danger in working on revoke like actions that a high cost will be paid
to get nice semantics for a rare case.

We can easily set a flag on the superblock and disconnect from the
backing store.  A generic shutdown derived from the existiong ioctls.

We can easily before that request that the filesystem be remounted
read-only.  We may not succeed (as someone may have something open for
write) but that code path exists and it is easy to use.

Tracking down all instances of struct file and all instances of struct
path that reference a filesystem is expensive today, and expensive to
add a list to do.  So I don't know that we want to do that.


So the best option that I see right now is remount the superblock
read-only, followed by disconnect the superblock from the backing store.
With a filesystem sync in there before we disconnect the backing store
to ensure all of the changes if possible are flushed to disk.

>> Ted, Aleksa would either of you be interested in generalizing what ext4,
>> f2fs, and xfs does now and working to put a good interface on it?  I can
>> help especially with review but for the short term I am rather booked.
>
> Unfortunately, I have way too much travel coming up in the short term,
> so I probably won't have to take on a new project until at least
> mid-to-late-November at the earliest.  Aleska, do you have time?  I
> can consult on a design, but I have zero coding time for the next
> couple of weeks.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
