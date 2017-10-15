Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC54E6B0253
	for <linux-mm@kvack.org>; Sun, 15 Oct 2017 18:15:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t10so5398333pgo.20
        for <linux-mm@kvack.org>; Sun, 15 Oct 2017 15:15:11 -0700 (PDT)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id h132si3522449pfe.87.2017.10.15.15.15.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Oct 2017 15:15:10 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
	<CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
	<20171009000529.GY3666@dastard> <20171009183129.GE11645@wotan.suse.de>
	<87wp442lgm.fsf@xmission.com>
	<8729041d-05e5-6bea-98db-7f265edde193@suse.de>
	<20171015130625.o5k6tk5uflm3rx65@thunk.org>
Date: Sun, 15 Oct 2017 17:14:41 -0500
In-Reply-To: <20171015130625.o5k6tk5uflm3rx65@thunk.org> (Theodore Ts'o's
	message of "Sun, 15 Oct 2017 09:06:25 -0400")
Message-ID: <87efq4qcry.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Aleksa Sarai <asarai@suse.de>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Dave Chinner <david@fromorbit.com>, =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LA=?= =?utf-8?B?0LLRgNC40LvQvtCy?= <mikhail.v.gavrilov@gmail.com>, Christoph Hellwig <hch@infradead.org>, Jan Blunck <jblunck@infradead.org>, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, linux-xfs@vger.kernel.org

Theodore Ts'o <tytso@mit.edu> writes:

> On Sun, Oct 15, 2017 at 07:53:11PM +1100, Aleksa Sarai wrote:
>> This is the bug that I talked to you about at LPC, related to devicemapper
>> and it not being possible to issue DELETE and REMOVE operations on a
>> devicemapper device that is still mounted in $some_namespace. [Before we go
>> on, deferred removal and deletion can help here, but the deferral will never
>> kick in until the reference goes away. On SUSE systems, deferred removal
>> doesn't appear to work at all, but that's an issue for us to solve.]
>
> Yeah, it's not really a bug, as much as (IMHO) a profound design
> misfeature in the way mount namespaces work.  And the fundamental
> problem is that there are two distinct things that you might want to
> do:
>
>     * In a container, "unmount" a file system is it no longer shows up in
>       your mount namespace.
>
>     * As a system administrator, make a mounted file system **go** **away**
>       because the device is about to disapear, either because:
>          * The iscsi/nbd device is gone or about to disappear (maybe the server is
> 	   about to shut down)
> 	 * The user wants to yank out the USB thumb drive
> 	 * The system is shutting down and for whatever reason the shutdown
> 	   sequence wants to remove the block device driver or otherwise shutdown
> 	   the UFS device on the Android system.
>
> The last three examples are all real world examples where people have
> complained to me about, and there have been some hacky things we've
> done as a result.
>
> We sort of have a hacky solution which works today, at least for f2fs,
> ext4 and xfs file systems, which is you can use
> {EXT4,F2FS}_FS_IOC_SHUTDOWN / XFS_IOC_GOINGDOWN ioctls to forcibly
> shutdown the file system, and then recurse over all of /proc looking
> for /proc/*/mounts files and seeing if the file system is mounted in
> that namespace, and then either killing the pid or somehow entering
> the namespace of that process and unmounting the file system.  But
> it's ugly and messy, and it's not at all intuitive, and so people keep
> tripping against the problem.
>
> What we really need is some kind of "global shutdown and unmount"
> system call which safely and cleanly does this.  Instead of relying on
> the file system's brute force shutdown sequence, it would be better if
> we implemented some kind of VFS-level revoke(2) functionality (ala the
> *BSD revoke system call, which they've had for ages) on all file
> descriptors opened on the file systems, and if any processes have a
> CWD in the file system, it is replaced by an anonymous
> invalid/"deleted" directory, followed by a syncfs() on the file
> system, followed by a recursive search and removal of the file system
> from all mount namespaces.
>
> Obviously, this could only be used by someone with root privileges on
> the "root" container.

There are two practical cases here.

1) What to do if someone is actively using the filesystem?
   AKA Is using the file system as a working directory or has a file on
   that filesystem open possibly mmaped.

2) What to do if the filesystem is simply mounted in some set of mount
   namespaces.

For the second case we should be able to solve it easily with a
variation on the internal detach_mounts call that we use when the mount
point goes away.  All of the infrastructure exists.


Looking at the code it appears ext4, f2fs, and xfs shutdown path
implements revoking a bdev from a filesystem.  Further if the ext4
implementation is anything to go by it looks like something we could
generalize into the vfs.

Hmm.  Unless I am completely mistake we already have a super block
operation that pretty much does this in umount_begin (the guts behind
mount -f).  Which makes the set of filesystems that can support this
kind of operation to: 9p, ceph, cifs, fuse, nfs, ext4, f2fs, and xfs.

Hmm...

If the filesystem can cut all communication with the backing store as
ext4, f2fs, and xfs can I don't know that we need to remove the
filesystem from the mount tree.  The superblock will just be useless not
gone.

Which means we will just have a few extra resources consumed by vfsmount
structs and a superblock but nothing important going on.  (Especially if
we can move that operation up to the vfs from the individual
filesystems).

Just letting the vfsmount structures sit nicely avoids the problem of
what happens if the revoked filesystem is mounted on top of something
sensitive in the mount tree, that should not be revealed.



So my suggestions for this case are two fold.

- Tweak Docker and friends to not be sloppy and hold onto extra
  resources that they don't need.  That is just bad form.

- Generalize what ext4, f2fs, xfs and possibly the network filesystems
  with umount_begin are doing into a general disconnect this filesystem
  from it's backing store operation.

  That operation should be enough to drop the reference to the backing
  device so that device mapper doesn't care.

A nice to have would be remove mounts from the mount trees, that are not
problematic to remove.


I won't call this a security regression with user namespaces, or a mount
namespace specific issue as it appears any process that can open a file
has always been able to trigger this.  That said it does appear this has
gone from a theoretical issue to an actuall problem so it is most
definitely time to address and fix this.

Further I agree Dave Chinners comment about the hung task timeout.  That
appears to be a separate issue.  As no number of idle references to a
super block should trigger that.

Ted, Aleksa would either of you be interested in generalizing what ext4,
f2fs, and xfs does now and working to put a good interface on it?  I can
help especially with review but for the short term I am rather booked.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
