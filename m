Subject: Re: PATCH: Rewrite of truncate_inode_pages (WIP)
References: <yttvgzwg70s.fsf@serpe.mitica> <shsd7m3w0xp.fsf@charged.uio.no>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Trond Myklebust's message of "31 May 2000 10:58:42 +0200"
Date: 31 May 2000 14:13:03 +0200
Message-ID: <ytt7lcaex4g.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "trond" == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:
>> This patch does:

>> - defines a new function: discard_buffer, it will lock the buffer
>> (waiting if needed) and remove the buffer from all the
>> queues.  It is like unmap_buffer, but makes sure that we
>> don't do any IO and that we remove the buffer from all the
>> lists.

>> - defines a new function: block_destroy_buffers: it is a mix of
>> block_flushpage and do_try_to_free_pages.  It will make all
>> the buffers in that page disappear calling discard_buffer.
>> Notice the way that we iterate through all the buffer heads.
>> I think that it is not racy, but I would like to hear
>> comments from people than know more about buffer heads
>> handling.

>> - I change invalidate_inode_pages (again).  Now block_destroy_buffers
>> can wait, then we are *civilized* citizens and drop any lock
>> that we have before call that block_destroy_buffers, and
>> reaquire later.

trond> This is a bug! invalidate_inode_pages() is not supposed to invalidate
trond> pending writes. It is only supposed to invalidate the page cache.

OK, the problem here is that __remove_inode_pages needs to be called
with page->buffers==NULL.  What do you suggest to obtain that?

We don't invalidate the pending write, we only *make sure* that the
buffers of the page are freed, i.e. We wait for the writes to finish.

trond> Also, it is pointless to add block device-specific code to that
trond> particular function since no block devices actually use it.

Ok, tell me *the* correct way of doing that.  We need to make sere
that __remove_inode_page is called with page->buffers == NULL.  It is
ok for you:
   if(page->buffers)
        BUG();

If we don't make a test like that (or the *actual* one), we left pages
in the page cache which contents are invalid, and when shrink_mmap try
to free that page, it would write that buffers (buffers that are in
the invalidated part).

Thanks a lot for the comments.

Later,Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
