Subject: Re: PATCH: Rewrite of truncate_inode_pages (WIP)
References: <yttvgzwg70s.fsf@serpe.mitica>
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: 31 May 2000 10:58:42 +0200
In-Reply-To: "Juan J. Quintela"'s message of "30 May 2000 03:29:23 +0200"
Message-ID: <shsd7m3w0xp.fsf@charged.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:

     > This patch does:

     > - defines a new function: discard_buffer, it will lock the buffer
     >   (waiting if needed) and remove the buffer from all the
     >   queues.  It is like unmap_buffer, but makes sure that we
     >   don't do any IO and that we remove the buffer from all the
     >   lists.

     > - defines a new function: block_destroy_buffers: it is a mix of
     >   block_flushpage and do_try_to_free_pages.  It will make all
     >   the buffers in that page disappear calling discard_buffer.
     >   Notice the way that we iterate through all the buffer heads.
     >   I think that it is not racy, but I would like to hear
     >   comments from people than know more about buffer heads
     >   handling.

     > - I change invalidate_inode_pages (again).  Now block_destroy_buffers
     >   can wait, then we are *civilized* citizens and drop any lock
     >   that we have before call that block_destroy_buffers, and
     >   reaquire later.

This is a bug! invalidate_inode_pages() is not supposed to invalidate
pending writes. It is only supposed to invalidate the page cache.

Also, it is pointless to add block device-specific code to that
particular function since no block devices actually use it.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
