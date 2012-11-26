Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 3AD456B0075
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 15:15:08 -0500 (EST)
Date: Mon, 26 Nov 2012 12:15:06 -0800
From: Zach Brown <zab@zabbo.net>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
Message-ID: <20121126201506.GG23854@lenny.home.zabbo.net>
References: <bug-50981-5823@https.bugzilla.kernel.org/>
 <20121126163328.ACEB011FE9C@bugzilla.kernel.org>
 <20121126164555.GL31891@thunk.org>
 <alpine.LNX.2.00.1211261144190.1183@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211261144190.1183@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, bugzilla-daemon@bugzilla.kernel.org, meetmehiro@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Nov 26, 2012 at 12:05:57PM -0800, Hugh Dickins wrote:
> On Mon, 26 Nov 2012, Theodore Ts'o wrote:
> > On Mon, Nov 26, 2012 at 04:33:28PM +0000, bugzilla-daemon@bugzilla.kernel.org wrote:
> > > https://bugzilla.kernel.org/show_bug.cgi?id=50981
> > >
> > > as this is working properly with XFS, so in ext4/ext3...etc also we shouldn't
> > > require synchronization at the Application level,., FS should take care of
> > > locking... will we expecting the fix for the same ???
> > 
> > Meetmehiro,
> > 
> > At this point, there seems to be consensus that the kernel should take
> > care of the locking, and that this is not something that needs be a
> > worry for the application.
> 
> Gosh, that's a very sudden new consensus.  The consensus over the past
> ten or twenty years has been that the Linux kernel enforce locking for
> consistent atomic writes, but skip that overhead on reads - hasn't it?

I was wondering exactly the same thing.

> > So the question is whether every file system which supports AIO should
> > add its own locking, or whether it should be done at the mm layer, and
> > at which point the lock in the XFS layer could be removed as no longer
> > necessary.

(This has nothing to do with AIO.  Buffered reads have been copied from
unlocked pages.. basically forever, right?)

> Thanks, that's helpful; but I think linux-mm people would want to defer
> to linux-fsdevel maintainers on this: mm/filemap.c happens to be in mm/,
> but a fundamental change to VFS locking philosophy is not mm's call.
> 
> I don't see that page locking would have anything to do with it: if we
> are going to start guaranteeing reads atomic against concurrent writes,
> then surely it's the size requested by the user to be guaranteed,
> spanning however many pages and fs-blocks: i_mutex, or a more
> efficiently crafted alternative.

Agreed.  While this little racing test might be fixed, those baked in
page_size == 4k == atomic granularity assumptions are pretty sketchy.

So we're talking about holding multiple page locks?  Or i_mutex?  Or
some fancy range locking?

There's consensus on serializing overlapping buffered reads and writes? 

- z
*readying the read(, mmap(), ) fault deadlock toy*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
