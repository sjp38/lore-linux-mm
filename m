Date: Tue, 15 Aug 2000 19:21:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Syncing the page cache, take 2
In-Reply-To: <3999C0C9.301BB475@innominate.de>
Message-ID: <Pine.LNX.4.21.0008151916160.2466-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <daniel.phillips@innominate.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Aug 2000, Daniel Phillips wrote:
> Rik van Riel wrote:
> > On Tue, 15 Aug 2000, Stephen C. Tweedie wrote:
> > 
> > > Correct.  We have plans to change this in 2.5, basically by
> > > removing the VM's privileged knowledge about the buffer cache
> > > and making the buffer operations (write-back, unmap etc.) into
> > > special cases of generic address-space operations.  For 2.4,
> > > it's really to late to do anything about this.
> > 
> > please take a look at my VM patch at http://www.surriel.com/patches/
> > (either the -test4 or the -test7-pre4 one).
> > 
> > If you look closely at mm/vmscan.c::page_launder(), you'll see
> > that we should be able to add the flush callback with only about
> > 5 to 10 lines of changed code ...
> > 
> > (and even more ... we just about *need* the flush callback when
> > we're running in a multi-queue VM)
> 
> OK, but what about the case where the filesystem knows it wants
> the page cache to flush *right now*?  For example, when a
> filesystem wants to be sure the page cache is synced through to
> buffers just before marking a consistent state in the journal,
> say.  How does it make that happen?

There are some ugly tricks, like pinning the buffer so that
the buffer flushing code can't flush it out. Most of these
have the potential for messing up VM and making the box run
out of memory or even making the box hang...

If the new VM makes it into 2.4, however, it should be
relatively easy to add the flush callback as a function
in page_launder(). Otherwise we could add yet another
thing to shrink_mmap() ... we could do it, but I guess
at the cost of some code readability  *grin*

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
