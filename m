Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0C26B0033
	for <linux-mm@kvack.org>; Sun, 15 Oct 2017 09:06:39 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id f199so7301118qke.6
        for <linux-mm@kvack.org>; Sun, 15 Oct 2017 06:06:39 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id u188si936779ybf.277.2017.10.15.06.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 15 Oct 2017 06:06:37 -0700 (PDT)
Date: Sun, 15 Oct 2017 09:06:25 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Message-ID: <20171015130625.o5k6tk5uflm3rx65@thunk.org>
References: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
 <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
 <20171009000529.GY3666@dastard>
 <20171009183129.GE11645@wotan.suse.de>
 <87wp442lgm.fsf@xmission.com>
 <8729041d-05e5-6bea-98db-7f265edde193@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8729041d-05e5-6bea-98db-7f265edde193@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aleksa Sarai <asarai@suse.de>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Dave Chinner <david@fromorbit.com>, =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, Christoph Hellwig <hch@infradead.org>, Jan Blunck <jblunck@infradead.org>, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, linux-xfs@vger.kernel.org

On Sun, Oct 15, 2017 at 07:53:11PM +1100, Aleksa Sarai wrote:
> This is the bug that I talked to you about at LPC, related to devicemapper
> and it not being possible to issue DELETE and REMOVE operations on a
> devicemapper device that is still mounted in $some_namespace. [Before we go
> on, deferred removal and deletion can help here, but the deferral will never
> kick in until the reference goes away. On SUSE systems, deferred removal
> doesn't appear to work at all, but that's an issue for us to solve.]

Yeah, it's not really a bug, as much as (IMHO) a profound design
misfeature in the way mount namespaces work.  And the fundamental
problem is that there are two distinct things that you might want to
do:

    * In a container, "unmount" a file system is it no longer shows up in
      your mount namespace.

    * As a system administrator, make a mounted file system **go** **away**
      because the device is about to disapear, either because:
         * The iscsi/nbd device is gone or about to disappear (maybe the server is
	   about to shut down)
	 * The user wants to yank out the USB thumb drive
	 * The system is shutting down and for whatever reason the shutdown
	   sequence wants to remove the block device driver or otherwise shutdown
	   the UFS device on the Android system.

The last three examples are all real world examples where people have
complained to me about, and there have been some hacky things we've
done as a result.

We sort of have a hacky solution which works today, at least for f2fs,
ext4 and xfs file systems, which is you can use
{EXT4,F2FS}_FS_IOC_SHUTDOWN / XFS_IOC_GOINGDOWN ioctls to forcibly
shutdown the file system, and then recurse over all of /proc looking
for /proc/*/mounts files and seeing if the file system is mounted in
that namespace, and then either killing the pid or somehow entering
the namespace of that process and unmounting the file system.  But
it's ugly and messy, and it's not at all intuitive, and so people keep
tripping against the problem.

What we really need is some kind of "global shutdown and unmount"
system call which safely and cleanly does this.  Instead of relying on
the file system's brute force shutdown sequence, it would be better if
we implemented some kind of VFS-level revoke(2) functionality (ala the
*BSD revoke system call, which they've had for ages) on all file
descriptors opened on the file systems, and if any processes have a
CWD in the file system, it is replaced by an anonymous
invalid/"deleted" directory, followed by a syncfs() on the file
system, followed by a recursive search and removal of the file system
from all mount namespaces.

Obviously, this could only be used by someone with root privileges on
the "root" container.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
