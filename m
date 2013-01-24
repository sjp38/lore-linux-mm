Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 148196B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 06:26:11 -0500 (EST)
Date: Thu, 24 Jan 2013 12:26:07 +0100
From: Jan Kara <jack@suse.cz>
Subject: [LSF/MM TOPIC] Mapping range locking
Message-ID: <20130124112607.GA21818@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

  Hello,

  I'd like to discuss idea of using range locking to serialize IO to a
range of pages. I have POC patches implementing the locking and converting
ext3 to use it. They pass xfstests and I plan to post them once I gather
some basic performace data (how much does the range locking cost us).

Now to the details of the idea. There are several different motivations for
implementing mapping range locking:
a) Punch hole is currently racy wrt mmap (page can be faulted in in the
   punched range after page cache has been invalidated) leading to nasty
   results as fs corruption (we can end up writing to already freed block),
   user exposure of uninitialized data, etc. To fix this we need some new
   mechanism of serializing hole punching and page faults.
b) There is an uncomfortable number of mechanisms serializing various paths
   manipulating pagecache and data underlying it. We have i_mutex, page lock,
   checks for page beyond EOF in pagefault code, i_dio_count for direct IO.
   Different pairs of operations are serialized by different mechanisms and
   not all the cases are covered. Case (a) above is likely the worst but DIO
   vs buffered IO isn't ideal either (we provide only limited consistency).
   The range locking should somewhat simplify serialization of pagecache
   operations. So i_dio_count can be removed completely, i_mutex to certain
   extent (we still need something for things like timestamp updates,
   possibly for i_size changes although those can be dealt with I think).
c) i_mutex doesn't allow any paralellism of operations using it and some
   filesystems workaround this for specific cases (e.g. DIO reads). Using
   range locking allows for concurrent operations (e.g. writes, DIO) on
   different parts of the file. Of course, range locking itself isn't
   enough to make the parallelism possible. Filesystems still have to
   somehow deal with the concurrency when manipulating inode allocation
   data. But the range locking at least provides a common VFS mechanism for
   serialization VFS itself needs and it's upto each filesystem to
   serialize more if it needs to.

How it works:

General idea is that range lock for range x-y prevents creation of pages in
that range.

In practice this means:
All read paths adding page to page cache and grab_cache_page_write_begin()
first take range lock for the index, then insert locked page, and finally
unlock the range. See below on why buffered IO uses range locks on per-page
basis.

DIO gets range lock at the moment it submits bio for the range covering
pages in the bio. Then pagecache is truncated and bio submitted. Range lock
is unlocked once bio is completed.

Punch hole for range x-y takes range lock for the range before truncating
page cache and the lock is released after filesystem blocks for the range
are freed.

Truncate to size x is equivalent to punch hole for the range x - ~0UL.

The reason why we take the range lock for buffered IO on per-page basis and
for DIO for each bio separately is lock ordering with mmap_sem. Page faults
need to instantiate page under mmap_sem. That establishes mmap_sem > range
lock. Buffered IO takes mmap_sem when prefaulting pages so we cannot hold
range lock at that moment. Similarly get_user_pages() in DIO code takes
mmap_sem so we have be sure not to hold range lock when calling that.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
