Subject: Re: Estrange behaviour of pre9-1
References: <Pine.LNX.4.10.10005151651140.812-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Mon, 15 May 2000 16:59:47 -0700 (PDT)"
Date: 16 May 2000 02:20:29 +0200
Message-ID: <yttu2fzxs4y.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Hi

linus> So, how about doing something like:

linus>  - if memory is low, allocate the page anyway if you can, but increment a
linus>    "bad user" count in current->user->mmuse;
linus>  - when entering __alloc_pages(), if "current->user->mmuse > 0", do a
linus>    "try_to_free_pages()" if there are any zones that need any help
linus>    (otherwise just clear this field).

linus> Think of it as "this user can allocate a few pages, but it's on credit.
linus> They have to be paid back with the appropriate 'try_to_free_pages()'".

I was discussing with Rik an scheme similar to that. I have found that
appears that we are trying very hard to get pages without doing any
writing. I think that we need to _wait_ for the pages if we are really
low on memory.  Just now, for pathological examples like mmap002 that
dirty a lot of memory very fast, I am observing that we made the page
cache grow until it occupies all the RAM. That is OK when the RAM is
empty.  But in that moment, if all the pages are dirty, we call
shrink_mmap, and it will start the async write of all the pages (in
this case, all our memory).  In this case shrink_mmap returns fail and
we will end calling shrink_mmap again, until we start the writing of
all the pages to the disk.  I think that shrink_mmap should return an
special value just in the case that it has started a *lot* of writes
of dirty pages, then we need to wait for some IO to complete before
continuing asking for memory.  We don't want to write synchronously
pages to the disk, because we want the requests to be coalescing.  But
in the other hand, we don't want to start the witting of 100MB of
dirty pages in one only call to try_to_free_pages.  And I suspect that
this is the case with the actual code.

Comments?

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
