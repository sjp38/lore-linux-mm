Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 8BC206B0027
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 05:45:36 -0400 (EDT)
Date: Fri, 12 Apr 2013 10:45:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130412094532.GH11656@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130411183512.GA12298@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Thu, Apr 11, 2013 at 02:35:12PM -0400, Theodore Ts'o wrote:
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

Yeah, ok. This is not the answer I was hoping for but it's the answer I
expected.

> Could you code which checks the hold time of lock_buffer(), measuing
> from when the lock is successfully grabbed, to see if you can see if I
> missed some code path in ext4 or jbd2 where the bh is locked and then
> there is some call to some function which needs to block for some
> random reason?
>
> What I'd suggest is putting a timestamp in buffer_head
> structure, which is set by lock_buffer once it is successfully grabbed
> the lock, and then in unlock_buffer(), if it is held for more than a
> second or some such, to dump out the stack trace.
> 

I can do that but the results might lack meaning. What I could do instead
is use a variation of the page owner tracking patch (current iteration at
https://lkml.org/lkml/2012/12/7/487) to record a stack trace in lock_buffer
and dump it from jbd2/transaction.c if it stalls for too long. I'll report
if I find something useful.

> Because at this point, either I'm missing something or I'm beginning
> to suspect that your hard drive (or maybe something the block layer?)
> is simply taking a long time to service an I/O request. 

It could be because the drive is a piece of crap.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
