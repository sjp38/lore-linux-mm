Date: Thu, 2 Nov 2000 12:29:59 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] Re: 2.4 VM & refill_inactive_scan()
Message-ID: <20001102122959.Y1876@redhat.com>
References: <Pine.LNX.4.21.0010271643050.25174-100000@duckman.distro.conectiva> <Pine.LNX.4.10.10010271147160.1850-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10010271147160.1850-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Fri, Oct 27, 2000 at 11:52:35AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Oct 27, 2000 at 11:52:35AM -0700, Linus Torvalds wrote:
> 
> On Fri, 27 Oct 2000, Rik van Riel wrote:
> > 
> > There is one big point left though...
> > 
> > Raw IO into a page which just gets unmapped by a process.
> > For NFS we'll somehow need to get the credentials for that
> > page so we can write back the data after it is detached from
> > the process...
> 
> I really think that you should just add "struct file" to the kiobuf array,
> and expand "maplist".

OK, done.  I've broken the diff into chunks, because there are a
couple of other kiobuf fixes to go in at the same time.  The kiobuf
user-land mapping code can now map the struct file and propagate
dirty flags into it once a read operation into the memory completes.

> In fact, you should expand "maplist" anyway, because right now kiobuf's
> cannot handle the case of multiple partial pages: you can be partial only
> at the beginning or the end, which means that kiobuf's are worthless for
> stuff like "sendmsg()" that can do scatter-gather.

That's why the IO functions themselves take a kiovec, not a kiobuf, as
input, and why the iobuf.c code has utility functions for dealing with
entire kiovecs at once.  The iovec is the scatter-gather unit for IO,
but the individual kiobuf is the unit for mapping of pages.  That way,
you can take two different kiobufs, owned by different system
components, and do a single IO on them (eg. take an mmap()ed kiobuf
containing an http header that an application just wrote, and a kiobuf
mapped over the page cache containing a file, and send them over the
wire as a single network packet).

I've considered adding support for a real struct kiovec to allow
passing of kiovec structs as first-class data objects, but for now I
haven't come across anything in the implementation which can't be
handled cleanly enough by a counted vector of kiobufs.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
