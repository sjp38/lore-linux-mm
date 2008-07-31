Date: Thu, 31 Jul 2008 07:12:01 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
Message-ID: <20080731061201.GA7156@shareable.org>
References: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <20080731001131.GA30900@shareable.org> <20080731004214.GA32207@shareable.org> <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> > Jamie Lokier wrote:
> > > not being able to tell when a sendfile() has finished with the pages
> > > its sending.
> > 
> > (Except by the socket fully closing or a handshake from the other end,
> > obviously.)
> 
> Well, people should realize that this is pretty fundamental to zero-copy 
> scemes. It's why zero-copy is often much less useful than doing a copy in 
> the first place. How do you know how far in a splice buffer some random 
> 'struct page' has gotten? Especially with splicing to spicing to tee to 
> splice...

Having implemented an equivalent zero-copy thing in userspace, I can
confidently say it's not fundamental at all.

What is fundamental is that you either (a) treat sendfile as an async
operation, and get a notification when it's finished with the data,
just like any other async operation, or (b) while sendfile claims those
pages, they are marked COW.

(b) is *much* more useful for the things you actually want to use
sendfile for, namely a faster copy-file-to-socket with no weird
complications.  Since you're sending files which you don't *expect* to
change (but want to behave sensibly if they do), and the pages
probably aren't mapped into any process, COW would not cost anything.

Right now, sendfile is used by servers of all kinds: http, ftp, file
servers, you name it.  They all want to believe it's purely a
performance optimisation, equivalent to write.  On many operations
systems, it is.  (I count sendfile equivalents on: Windows NT, SCO
Unixware, Solaris, FreeBSD, Dragonfly, HP-UX, Tru64, AIX and S/390 in
addition to Linux :-)

> You'd have to have some kind of barrier model (which would be really 
> complex), or perhaps a "wait for this page to no longer be shared" (which 
> has issues all its own).
> 
> IOW, splice() is very closely related to a magic kind of "mmap()+write()" 
> in another thread. That's literally what it does internally (except the 
> "mmap" is just a small magic kernel buffer rather than virtual address 
> space), and exactly as with mmap, if you modify the file, the other thread 
> will see if, even though it did it long ago.

That's fine.  But if you use a thread, the thread can tell you when
it's done.  Then you know what you're sending not an infinite time in
the future :-)

> Personally, I think the right approach is to just realize that splice() is 
> _not_ a write() system call, and never will be. If you need synchronous 
> writing, you simply shouldn't use splice().

People want zero-copy, and no weirdness like sending blocks of zeros
which the file never contained, and (if you lock the file) knowing
when to release locks for someone else to edit the file.

Sync or async doesn't matter so much; that's API stuff.

The obvious mechanism for completion notifications is the AIO event
interface.  I.e. aio_sendfile that reports completion when it's safe
to modify data it was using.  aio_splice would be logical for similar
reasons.  Note it doesn't mean when the data has reached a particular
place, it means when the pages it's holding are released.  Pity AIO
still sucks ;-)

Btw, Windows had this since forever, it's called overlapped
TransmitFile with an I/O completion event.  Don't know if it's any
good though ;-)

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
