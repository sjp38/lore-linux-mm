Date: Mon, 15 May 2000 21:55:02 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Estrange behaviour of pre9-1
In-Reply-To: <yttu2fzxs4y.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0005152147490.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 16 May 2000, Juan J. Quintela wrote:

> linus> So, how about doing something like:
> 
> linus>  - if memory is low, allocate the page anyway if you can, but increment a
> linus>    "bad user" count in current->user->mmuse;
> linus>  - when entering __alloc_pages(), if "current->user->mmuse > 0", do a
> linus>    "try_to_free_pages()" if there are any zones that need any help
> linus>    (otherwise just clear this field).
> 
> linus> Think of it as "this user can allocate a few pages, but it's on credit.
> linus> They have to be paid back with the appropriate 'try_to_free_pages()'".

I don't think this will help. Imagine a user firing up 'ls', that
will need more than one page. Besides, the difference isn't that
we have to free pages, but that we have to deal with a *LOT* of
dirty pages at once, unexpectedly.

> I was discussing with Rik an scheme similar to that. I have
> found that appears that we are trying very hard to get pages
> without doing any writing. I think that we need to _wait_ for
> the pages if we are really low on memory.

Indeed. I've seen vmstat reports where the most common action
just before OOM is _pagein_. This indicates that shrink_mmap()
was very busy skipping over the dirty pages and dropping clean
pages which were needed again a few milliseconds later...

The right solution is to make sure the dirty pages are flushed
out.

> We don't want to write synchronously pages to the disk, because
> we want the requests to be coalescing.  But in the other hand,
> we don't want to start the witting of 100MB of dirty pages in
> one only call to try_to_free_pages.  And I suspect that this is
> the case with the actual code.

I think we may be able to use the 'priority' argument to
shrink_mmap() to determine the maximum amount of pages to
sync out at once (more or less, since this is pretty
arbitrary anyway we don't need to be that precise).

What we may want to do is wait on one page per shrink_mmap(),
and only "start waiting" after count has been decremented to
less than 1/2 of its original value.

This way we'll:
- make sure we won't flush too many things out at once
- allow for some IO clustering to happen
- keep latency decent
- try hard to flush out the _right_ page

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
