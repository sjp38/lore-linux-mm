Date: Wed, 22 Dec 1999 10:58:33 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: [patch] mmap<->write deadlock fix, plus bug in block_write_zero_range
In-Reply-To: <Pine.LNX.3.96.991222103000.22064A-100000@kanga.kvack.org>
Message-ID: <Pine.BSO.4.10.9912221046420.20066-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 1999, Benjamin C.R. LaHaise wrote:
> On Wed, 22 Dec 1999, Chuck Lever wrote:
> > i've tried this before several times.  i could never get the system to
> > perform as well under benchmark load using find_page_nolock as when using
> > find_get_page. the throughput difference was about 5%, if i recall.  i
> > haven't explained this to myself yet.
> > 
> > perhaps a better fix would be to take out some of the page lock complexity
> > from filemap_nopage?  dunno.
> 
> Well, there certainly is a lot of code in page_cache_read /
> do_generic_file_read / filemap_nopage that is duplicate, and our policies
> across them are inconsistent.

when i started looking at mmap read-ahead and madvise, i noticed that
there was a lot of inconsistent code duplication, and thought it would be
a good thing to fold this stuff together.  that's one reason i created the
"read_cluster_nonblocking" and "page_cache_read" functions.  for example,
you can remove 20-40 lines of do_generic_file_read by replacing them with
one call to page_cache_read.  or you could easily try clustered reads
there.

but notice you want to do something slightly different in
generic_file_write, so that code will probably need to stay.

> Here's my hypothesis about why find_page_nolock vs find_get_page makes a
> difference: using find_page_nolock means that we'll never do a
> run_task_queue(&tq_disk); to get our async readahead requests run.  So, in
> theory, doing that in filemap_nopage will restore performance.

sounds like a reasonable explanation to me, and easy enough to test, even.
i'll give that a shot later today.

> Isn't
> there a way that the choice of when to run tq_disk could be made a bit
> less arbitrary?

i suppose there's a more *efficient* way of doing it, but i think running
the queue while waiting for a page is probably a good idea.  in other
words, running the queue in find_get_page seems like a good idea to me.
what did you have in mind?

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
