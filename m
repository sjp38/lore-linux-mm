Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 226276B0068
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 15:05:57 -0500 (EST)
Received: by mail-gh0-f169.google.com with SMTP id r11so1438663ghr.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 12:05:56 -0800 (PST)
Date: Mon, 26 Nov 2012 12:05:57 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
In-Reply-To: <20121126164555.GL31891@thunk.org>
Message-ID: <alpine.LNX.2.00.1211261144190.1183@eggly.anvils>
References: <bug-50981-5823@https.bugzilla.kernel.org/> <20121126163328.ACEB011FE9C@bugzilla.kernel.org> <20121126164555.GL31891@thunk.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, bugzilla-daemon@bugzilla.kernel.org, meetmehiro@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 26 Nov 2012, Theodore Ts'o wrote:
> On Mon, Nov 26, 2012 at 04:33:28PM +0000, bugzilla-daemon@bugzilla.kernel.org wrote:
> > https://bugzilla.kernel.org/show_bug.cgi?id=50981
> >
> > as this is working properly with XFS, so in ext4/ext3...etc also we shouldn't
> > require synchronization at the Application level,., FS should take care of
> > locking... will we expecting the fix for the same ???
> 
> Meetmehiro,
> 
> At this point, there seems to be consensus that the kernel should take
> care of the locking, and that this is not something that needs be a
> worry for the application.

Gosh, that's a very sudden new consensus.  The consensus over the past
ten or twenty years has been that the Linux kernel enforce locking for
consistent atomic writes, but skip that overhead on reads - hasn't it?

> Whether this should be done in the file
> system layer or in the mm layer is the current question at hand ---
> since this is a bug that also affects btrfs and other non-XFS file
> systems.
> 
> So the question is whether every file system which supports AIO should
> add its own locking, or whether it should be done at the mm layer, and
> at which point the lock in the XFS layer could be removed as no longer
> necessary.
> 
> I've added linux-mm and linux-fsdevel to make sure all of the relevant
> kernel developers are aware of this question/issue.

Thanks, that's helpful; but I think linux-mm people would want to defer
to linux-fsdevel maintainers on this: mm/filemap.c happens to be in mm/,
but a fundamental change to VFS locking philosophy is not mm's call.

I don't see that page locking would have anything to do with it: if we
are going to start guaranteeing reads atomic against concurrent writes,
then surely it's the size requested by the user to be guaranteed,
spanning however many pages and fs-blocks: i_mutex, or a more
efficiently crafted alternative.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
