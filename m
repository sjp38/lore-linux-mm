Date: Mon, 15 May 2000 22:03:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Estrange behaviour of pre9-1
In-Reply-To: <Pine.LNX.4.10.10005151651140.812-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005152156250.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 May 2000, Linus Torvalds wrote:

> The fact that Rik's patch performs so badly is interesting in
> itself, and I thus removed it from my tree.

This may be because the different try_to_free_pages end
up waiting for each other (to complete IO?).

If VM was constructed right, we would never have the
situation where a half-dozen apps are all waiting in
try_to_free_pages() simultaneously.

The bug is, IMHO, the fact that shrink_mmap() frees the
wrong pages by skipping over buffer pages. This causes
"innocent" apps to have pagefaults they didn't deserve
==> slowdown.

> _Most_ of the time when "try_to_free_pages()" is called, the
> memory actually exists, and we call try_to_free_pages() mainly
> because we want to make sure that we don't get into a bad
> situation.

True.

> So, how about doing something like:
> 
>  - if memory is low, allocate the page anyway if you can, but increment a
>    "bad user" count in current->user->mmuse;
>  - when entering __alloc_pages(), if "current->user->mmuse > 0", do a
>    "try_to_free_pages()" if there are any zones that need any help
>    (otherwise just clear this field).
> 
> Think of it as "this user can allocate a few pages, but it's on credit.
> They have to be paid back with the appropriate 'try_to_free_pages()'".

I don't think this will work if we keep stealing the wrong pages
from innocent, small processes with lots of clean pages (ie. bash,
vi, emacs, ...).

> Rik? I think this would solve the fairness concerns without the
> need to tell the rest of the world about a process trying to
> free up memory and causing bad performance..

The main problem now seems to be bad page replacement and a
practically unbounded wait time inside try_to_free_pages().

If we fix those, I think it should be possible to move back
to a slightly more conservative (and safe) model (like what
I had in my patch ... you might argue it is too conservative,
slow or whatever, but it should be the more robust one).

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
