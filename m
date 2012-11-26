Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 761F46B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 16:39:13 -0500 (EST)
Date: Mon, 26 Nov 2012 16:39:01 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
Message-ID: <20121126213901.GA10587@infradead.org>
References: <bug-50981-5823@https.bugzilla.kernel.org/>
 <20121126163328.ACEB011FE9C@bugzilla.kernel.org>
 <20121126164555.GL31891@thunk.org>
 <alpine.LNX.2.00.1211261144190.1183@eggly.anvils>
 <20121126201308.GA21050@infradead.org>
 <20121126212845.GJ6434@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126212845.GJ6434@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, bugzilla-daemon@bugzilla.kernel.org, meetmehiro@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, Nov 27, 2012 at 08:28:45AM +1100, Dave Chinner wrote:
> We still need the iolock deep in the guts of the filesystem, though.

I don't think we do.  The only thing that comes close to it is
xfs_swap_extents passing the XFS_IOLOCK_EXCL to xfs_trans_ijoin so
that the transaction commit automatically unlocks it, but that can
be trivially replaced with a manual unlock.

> I suspect that if we are going to change the VFS locking, then we
> should seriously consider allowing the filesystem to provide it's
> own locking implementation and the VFS just pass the type of lock
> required. Otherwise we are still going to need all the locking
> within the filesystem to serialise all the core pieces that the VFS
> locking doesn't serialise (e.g. EOF truncation on close/evict,
> extent swaps for online defrag, etc).

The VFS currently doesn't hardcode i_mutex for any data plane
operations, only a few generic helpers do it, most notably
generic_file_aio_write (which can be bypassed by using a slightly
lower level variant) and __blockdev_direct_IO when used in DIO_LOCKING
mode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
