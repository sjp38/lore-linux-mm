Date: Fri, 25 Jan 2008 08:27:10 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -v8 4/4] The design document for memory-mapped file
 times update
Message-Id: <20080125082710.09f321c1.randy.dunlap@oracle.com>
In-Reply-To: <1201044083554-git-send-email-salikhmetov@gmail.com>
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
	<1201044083554-git-send-email-salikhmetov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008 02:21:20 +0300 Anton Salikhmetov wrote:

> Add a document, which describes how the POSIX requirements on updating
> memory-mapped file times are addressed in Linux.

Hi Anton,

Just a few small comments below...

> Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>
> ---
>  Documentation/vm/00-INDEX  |    2 +
>  Documentation/vm/msync.txt |  117 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 119 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
> index 2131b00..2726c8d 100644
> --- a/Documentation/vm/00-INDEX
> +++ b/Documentation/vm/00-INDEX
> @@ -6,6 +6,8 @@ hugetlbpage.txt
>  	- a brief summary of hugetlbpage support in the Linux kernel.
>  locking
>  	- info on how locking and synchronization is done in the Linux vm code.
> +msync.txt
> +	- the design document for memory-mapped file times update
>  numa
>  	- information about NUMA specific code in the Linux vm.
>  numa_memory_policy.txt
> diff --git a/Documentation/vm/msync.txt b/Documentation/vm/msync.txt
> new file mode 100644
> index 0000000..571a766
> --- /dev/null
> +++ b/Documentation/vm/msync.txt
> @@ -0,0 +1,117 @@
> +
> +	The msync() system call and memory-mapped file times
> +
> +	Copyright (C) 2008 Anton Salikhmetov
> +
> +The POSIX standard requires that any write reference to memory-mapped file
> +data should result in updating the ctime and mtime for that file. Moreover,
> +the standard mandates that updated file times should become visible to the
> +world no later than at the next call to msync().
> +
> +Failure to meet this requirement creates difficulties for certain classes
> +of important applications. For instance, database backup systems fail to
> +pick up the files modified via the mmap() interface. Also, this is a
> +security hole, which allows forging file data in such a manner that proving
> +the fact that file data was modified is not possible.
> +
> +Briefly put, this requirement can be stated as follows:
> +
> +	once the file data has changed, the operating system
> +	should acknowledge this fact by updating file metadata.
> +
> +This document describes how this POSIX requirement is addressed in Linux.
> +
> +1. Requirements
> +
> +1.1) the POSIX standard requires updating ctime and mtime not later
> +than at the call to msync() with MS_SYNC or MS_ASYNC flags;
> +
> +1.2) in existing POSIX implementations, ctime and mtime
> +get updated not later than at the call to fsync();
> +
> +1.3) in existing POSIX implementation, ctime and mtime
> +get updated not later than at the call to sync(), the "auto-update" feature;
> +
> +1.4) the customers require and the common sense suggests that
> +ctime and mtime should be updated not later than at the call to munmap()
> +or exit(), the latter function implying an implicit call to munmap();
> +
> +1.5) the (1.1) item should be satisfied if the file is a block device
> +special file;
> +
> +1.6) the (1.1) item should be satisfied for files residing on
> +memory-backed filesystems such as tmpfs, too.
> +
> +The following operating systems were used as the reference platforms
> +and are referred to as the "existing implementations" above:
> +HP-UX B.11.31 and FreeBSD 6.2-RELEASE.
> +
> +2. Lazy update
> +
> +Many attempts before the current version implemented the "lazy update" approach
> +to satisfying the requirements given above. Within the latter approach, ctime
> +and mtime get updated at last moment allowable.
> +
> +Since we don't update the file times immediately, some Flag has to be
> +used. When up, this Flag means that the file data was modified and
> +the file times need to be updated as soon as possible.

I would s/up/set/ above and below.

> +Any existing "dirty" flag which, when up, mean that a page has been written to,

s/mean/means/

> +is not suitable for this purpose. Indeed, msync() called with MS_ASYNC
> +would have to reset this "dirty" flag after updating ctime and mtime.
> +The sys_msync() function itself is basically a no-op in the MS_ASYNC case.
> +Thereby, the synchronization routines relying upon this "dirty" flag
> +would lose data. Therefore, a new Flag has to be introduced.
> +
> +The (1.5) item coupled with (1.3) requirement leads to hard work with
> +the block device inodes. Specifically, during writeback it is impossible to
> +tell which block device file was originally mapped. Therefore, we need to
> +traverse the list of "active" devices associated with the block device inode.
> +This would lead to updating file times for block device files, which were not
> +taking part in the data transfer.
> +
> +Also all versions prior to version 6 failed to correctly process ctime and
> +mtime for files on the memory-backed filesystems such as tmpfs. So the (1.6)
> +requirement was not satisfied.
> +
> +If a write reference has occurred between two consecutive calls to msync()
> +with MS_ASYNC, the second call to the latter function should take into
> +account the last write reference. The last write reference can not be caught

s/can not/cannot/

> +if no pagefault occurs. Hence a pagefault needs to be forced. This can be done
> +using two different approaches. The first one is to synchronize data even when
> +msync() was called with MS_ASYNC. This is not acceptable because the current
> +design of the sys_msync() routine forbids starting I/O for the MS_ASYNC case.
> +The second approach is to write protect the page for triggering a pagefault

s/write protect/write-protect/

> +at the next write reference. Note that the dirty flag for the page should not
> +be cleared thereby.
> +
> +In the "lazy update" approach, the requirements (1.1), (1.2), (1.3), and (1.4)
> +taken together result in adding code at least to the following kernel routines:
> +sys_msync(), do_fsync(), some routine in the unmap() call path, some routine
> +in the sync() call path.
> +
> +Finally, a file_update_time()-like function would have to be created for
> +processing the inode objects, not file objects. This is due to the fact that
> +during the sync() operation, the file object may not exist any more, only
> +the inode is known.
> +
> +To sum up: this "lazy" approach leads to massive changes, incurs overhead in
> +the block device case, and requires complicated design decisions.
> +
> +3. Immediate update
> +
> +OK, still reading? There's a better way.
> +
> +In a fashion analogous to what happens at write(2), react to the fact
> +that the page gets dirtied by updating the file times immediately.
> +Thereby any page writeback happens when the write reference has already
> +been accounted for from the view point of file times.

Probably s/view point/viewpoint/.

> +
> +The only problem which remains is to force refreshing file times at the write
> +reference following a call to msync() with MS_ASYNC. As mentioned above, all
> +that is needed here is to force a pagefault.
> +
> +The vma_wrprotect() routine introduced in this patch series is called
> +from sys_msync() in the MS_ASYNC case. The former routine is essentially
> +a version of existing page_mkclean_one() function from mm/rmap.c. Unlike
> +the latter function, the vma_wrprotect() does not touch the dirty bit.
> -- 

Thanks for the design document.
---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
