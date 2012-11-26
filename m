Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id DDB3C6B0073
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 15:13:16 -0500 (EST)
Date: Mon, 26 Nov 2012 15:13:08 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
Message-ID: <20121126201308.GA21050@infradead.org>
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
> Gosh, that's a very sudden new consensus.  The consensus over the past
> ten or twenty years has been that the Linux kernel enforce locking for
> consistent atomic writes, but skip that overhead on reads - hasn't it?

I'm not sure there was much of a consensus ever.  We XFS people always
ttried to push everyone down the strict rule, but there was enough
pushback that it didn't actually happen.

> Thanks, that's helpful; but I think linux-mm people would want to defer
> to linux-fsdevel maintainers on this: mm/filemap.c happens to be in mm/,
> but a fundamental change to VFS locking philosophy is not mm's call.
> 
> I don't see that page locking would have anything to do with it: if we
> are going to start guaranteeing reads atomic against concurrent writes,
> then surely it's the size requested by the user to be guaranteed,
> spanning however many pages and fs-blocks: i_mutex, or a more
> efficiently crafted alternative.

What XFS does is simply replace (or rather augment currently) i_mutex
with a rw_semaphore (i_iolock in XFS) which is used the following way:

exclusive:
 - buffer writes
 - pagecache flushing before direct I/O (then downgraded)
 - appending direct I/O writes
 - less than blocksize granularity direct I/O

shared:
 - everything else (buffered reads, "normal" direct I/O)

Doing this in the highest levels of the generic_file_ code would be
trivial, and would allow us to get rid of a fair chunk of wrappers in
XFS.

Note that we've been thinking about replacing this lock with a range
lock, but this will require more research.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
