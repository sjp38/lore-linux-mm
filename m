Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 177946B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:33:38 -0400 (EDT)
Date: Thu, 11 Apr 2013 23:33:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130411213335.GE9379@quack.suse.cz>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411183512.GA12298@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Mel Gorman <mgorman@suse.de>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Thu 11-04-13 14:35:12, Ted Tso wrote:
> On Thu, Apr 11, 2013 at 06:04:02PM +0100, Mel Gorman wrote:
> > > If we're stalling on lock_buffer(), that implies that buffer was being
> > > written, and for some reason it was taking a very long time to
> > > complete.
> > > 
> > 
> > Yes.
> > 
> > > It might be worthwhile to put a timestamp in struct dm_crypt_io, and
> > > record the time when a particular I/O encryption/decryption is getting
> > > queued to the kcryptd workqueues, and when they finally squirt out.
> > > 
> > 
> > That somewhat assumes that dm_crypt was at fault which is not unreasonable
> > but I was skeptical as the workload on dm_crypt was opening a maildir
> > and mostly reads.
> 
> Hmm... well, I've reviewed all of the places in the ext4 and jbd2
> layer where we call lock_buffer(), and with one exception[1] we're not
> holding the the bh locked any longer than necessary.  There are a few
> places where we grab a spinlock or two before we can do what we need
> to do and then release the lock'ed buffer head, but the only time we
> hold the bh locked for long periods of time is when we submit metadata
> blocks for I/O.
> 
> [1] There is one exception in ext4_xattr_release_block() where I
> believe we should move the call to unlock_buffer(bh) before the call
> to ext4_free_blocks(), since we've already elevanted the bh count and
> ext4_free_blocks() does not need to have the bh locked.  It's not
> related to any of the stalls you've repored, though, as near as I can
> tell (none of the stack traces include the ext4 xattr code, and this
> would only affect external extended attribute blocks).
> 
> 
> Could you code which checks the hold time of lock_buffer(), measuing
> from when the lock is successfully grabbed, to see if you can see if I
> missed some code path in ext4 or jbd2 where the bh is locked and then
> there is some call to some function which needs to block for some
> random reason?  What I'd suggest is putting a timestamp in buffer_head
> structure, which is set by lock_buffer once it is successfully grabbed
> the lock, and then in unlock_buffer(), if it is held for more than a
> second or some such, to dump out the stack trace.
> 
> Because at this point, either I'm missing something or I'm beginning
> to suspect that your hard drive (or maybe something the block layer?)
> is simply taking a long time to service an I/O request.  Putting in
> this check should be able to very quickly determine what code path
> and/or which subsystem we should be focused upon.
  I think it might be more enlightening if Mel traced which process in
which funclion is holding the buffer lock. I suspect we'll find out that
the flusher thread has submitted the buffer for IO as an async write and
thus it takes a long time to complete in presence of reads which have
higher priority.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
