Date: Thu, 31 Jul 2008 13:33:50 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
Message-ID: <20080731123350.GB16481@shareable.org>
References: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <20080731001131.GA30900@shareable.org> <20080731004214.GA32207@shareable.org> <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org> <20080731061201.GA7156@shareable.org> <20080731102612.GA29766@2ka.mipt.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080731102612.GA29766@2ka.mipt.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Evgeniy Polyakov wrote:
> On Thu, Jul 31, 2008 at 07:12:01AM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> > The obvious mechanism for completion notifications is the AIO event
> > interface.  I.e. aio_sendfile that reports completion when it's safe
> > to modify data it was using.  aio_splice would be logical for similar
> > reasons.  Note it doesn't mean when the data has reached a particular
> > place, it means when the pages it's holding are released.  Pity AIO
> > still sucks ;-)
> 
> It is not that simple: page can be held in hardware or tcp queues for
> a long time, and the only possible way to know, that system finished
> with it, is receiving ack from the remote side. There is a project to
> implement such a callback at skb destruction time (it is freed after ack
> from the other peer), but do we really need it? System which does care
> about transmit will implement own ack mechanism, so page can be unlocked
> at higher layer. Actually page can be locked during transfer and
> unlocked after rpc reply received, so underlying page invalidation will
> be postponed and will not affect sendfile/splice.

This is why marking the pages COW would be better.  Automatic!
There's no need for a notification, merely letting go of the page
references - yes, the hardware / TCP acks already do that, no locking
or anything!  :-)  The last reference is nothing special, it just means
the next file write/truncate sees the count is 1 and doesn't need to
COW the page.


Two reason for being mildly curious about sendfile page releases in an
application though:

   - Sendfile on tmpfs files: zero copy sending of calculated data.
     Only trouble is when can you reuse the pages?  Current solution
     is use a set of files, consume the pages in sequential order, delete
     files at some point, let the kernel hold the pages.  Works for
     sequentially generated and transmitted data, but not good for
     userspace caches where different parts expire separately.  Also,
     may pin a lot of page cache; not sure if that's accounted.

   - Sendfile on real large data contained in a userspace
     database-come-filesystem (the future!).  App wants to send big
     blobs, and with COW it can forget about them, but for performance
     it would rathe allocate new writes in the file to areas that are
     not sendfile-hot.  It can approximate with heuristics though.

> > Btw, Windows had this since forever, it's called overlapped
> > TransmitFile with an I/O completion event.  Don't know if it's any
> > good though ;-)
> 
> There was a linux aio_sendfile() too. Google still knows about its
> numbers, graphs and so on... :)

I vaguely remember it's performance didn't seem that good.

One of the problems is you don't really want AIO all the time, just
when a process would block because the data isn't in cache.  You
really don't want to be sending *all* ops to worker threads, even
kernel threads.  And you preferably don't want the AIO interface
overhead for ops satisfied from cache.

Syslets got some of the way there, and maybe that's why they were
faster than AIO for some things.  There are user-space hacks which are
a bit like syslets.  (Bind two processes to the same CPU, process 1
wakes process 2 just before 1 does a syscall, and puts 2 back to sleep
if 2 didn't wake and do an atomic op to prove it's awake).  I haven't
tested their performance, it could suck.

Look up LAIO, Lazy Asynchronous I/O.  Apparently FreeBSD, NetBSD,
Solaris, Tru64, and Windows, have the capability to call a synchronous
I/O op and if it's satisfied from cache, simply return a result, if
not, either queue it and return an AIO event later (Windows style (it
does some cleverer thread balancing too)), or wake another thread to
handle it (FreeBSD style).  I believe Linus suggested something like
the latter line approach some time ago.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
