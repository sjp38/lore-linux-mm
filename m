Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 515446B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 22:47:35 -0400 (EDT)
Date: Wed, 16 May 2012 12:14:23 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Hole punching and mmap races
Message-ID: <20120516021423.GO25351@dastard>
References: <20120515224805.GA25577@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120515224805.GA25577@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, May 16, 2012 at 12:48:05AM +0200, Jan Kara wrote:
>   Hello,
> 
>   Hugh pointed me to ext4 hole punching code which is clearly missing some
> locking. But looking at the code more deeply I realized I don't see
> anything preventing the following race in XFS or ext4:
> 
> TASK1				TASK2
> 				punch_hole(file, 0, 4096)
> 				  filemap_write_and_wait()
> 				  truncate_pagecache_range()
> addr = mmap(file);
> addr[0] = 1
>   ^^ writeably fault a page
> 				  remove file blocks
> 
> 						FLUSHER
> 						write out file
> 						  ^^ interesting things can
> happen because we expect blocks under the first page to be allocated /
> reserved but they are not...
> 
> I'm pretty sure ext4 has this problem, I'm not completely sure whether
> XFS has something to protect against such race but I don't see anything.

No, it doesn't. It's a known problem due to not being able to take a
lock in .page_mkwrite() to serialise mmap() IO against truncation or
other IO such as direct IO. This has been known for, well, long
before we came up with page_mkwrite(). At the time page_mkwrite()
was introduced, locking was discusses to solve this problem but was
considered difficult on the VM side so it was ignored.

> It's not easy to protect against these races. For truncate, i_size protects
> us against similar races but for hole punching we don't have any such
> mechanism. One way to avoid the race would be to hold mmap_sem while we are
> invalidating the page cache and punching hole but that sounds a bit ugly.
> Alternatively we could just have some special lock (rwsem?) held during
> page_mkwrite() (for reading) and during whole hole punching (for writing)
> to serialize these two operations.

What really needs to happen is that .page_mkwrite() can be made to
fail with -EAGAIN and retry the entire page fault from the start an
arbitrary number of times instead of just once as the current code
does with VM_FAULT_RETRY. That would allow us to try to take the
filesystem lock that provides IO exclusion for all other types of IO
and fail with EAGAIN if we can't get it without blocking. For XFS,
that is the i_iolock rwsem, for others it is the i_mutex, and some
other filesystems might take other locks.

FWIW, I've been running at "use the IO lock in page_mkwrite" patch
for XFS for several months now, but I haven't posted it because
without the VM side being able to handle such locking failures
gracefully there's not much point in making the change. I did this
patch to reduce the incidence of mmap vs direct IO races that are
essentially identical in nature to rule them out of the cause of
stray delalloc blocks in files that fsstress has been producing on
XFS. FYI, this race condition hasn't been responsible for any of the
problems I've found recently....

> Another alternative, which doesn't really look more appealing, is to go
> page-by-page and always free corresponding blocks under page lock.

Doesn't work for regions with no pages in memory over them.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
