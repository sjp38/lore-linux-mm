MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14610.29158.285011.81152@charged.uio.no>
Date: Fri, 5 May 2000 09:01:58 +0200 (CEST)
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <Pine.LNX.4.21.0005042201520.5533-100000@alpha.random>
References: <14609.53317.581465.821028@charged.uio.no>
	<Pine.LNX.4.21.0005042201520.5533-100000@alpha.random>
Reply-To: trond.myklebust@fys.uio.no
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> " " == Andrea Arcangeli <andrea@suse.de> writes:

    >> As far as NFS is concerned, that page is incorrect and should
    >> be read in again whenever we next try to access it. That is the
    >> purpose of the call to invalidate_inode_pages().  As far as I
    >> can see, your patch fundamentally breaks that concept for all
    >> files whether they are mmapped or not.

     > It breaks the concept only for mmaped files. non mmaped files
     > have page->count == 1 so their cache will be shrunk completly
     > as usual.

If there are pending asynchronous writes then this is neither true in
2.2.x nor in 2.3.x. Each pending writeback has to increment the
page->count in order to prevent the page from disappearing beneath
it. Since a writeback does not have to involve the whole page, we
cannot assume that just because the page is dirty, then it won't want
to get invalidated. Imagine the scenario:

   Process 1 (on client 1)             Process 2 (on client 2)

   Schedule asynchronous write
   on bytes 0-255 of file

                                      Write bytes 256-511 of same file.

   revalidate inode
   discover that file has changed
   try to invalidate page 0

Under your patch, the invalidation of page 0 will fail due to the
pending writeback, and hence process 1 will never see what process 2
wrote.

     > unmapping page from the pagetable means that later userspace
     > won't be anymore able to read/write to the page (only kernel
     > will have visibility on the page then and you'll read from the
     > page in each read(2) and write(2)). A page in the cache can be
     > mapped in several ptes and we have to unmap it from all them
     > before we're allowed to unlink the page from the pagecache or
     > current VM will break.

Could this be done as part of "invalidate_inode_pages" or would that
break the VM?

    >> such a page still have to be part of an inode's i_data?

     > Mapped page-cache can't be unlinked from the cache as first
     > because when you'll have to sync the dirty shard mapping
     > (because you run low on memory and you have to get rid of dirty
     > data in the VM) you won't know anymore which inode and which fs
     > the page belongs to.

You have the vma->vm_file and hence both dentry and inode.

Don't forget that on NFS, the inode is just a pretty collection of
statistics. It contains our estimates of the data, size, creation
times...  It does *not* contain sufficient information to sync a page
to storage, and if the VM assumes that it does, then it is clearly
broken.
Under NFS all read and write operations require us to use a file
handle, which is stored in the dentry, not in the inode. So you will
always be required to use the vm_file in some form or other.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
