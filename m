Date: Mon, 2 Oct 2000 20:12:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.10.10010021559120.2206-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010022008270.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Linus Torvalds wrote:

> Basically the ordered write case will need extra logic, and we
> might as well put the effort in just one place anyway. Note that
> the page case isn't necessarily any harder in the end - the
> simple solution might be something like just adding a generation
> count to the buffer head, and having try_to_free_buffers() just
> refuse to write stuff out before that generation has come to
> pass.

That is another one of the very wrong (im)possibilities ;)

The VM is doing page aging and should, for page replacement
efficiency, only write out OLD pages. This can conflict with
the write ordering constraints in such a way that the system
will never get around to flushing out the only writable page
we have at that moment -> livelock.

Also, you cannot do try_to_free_buffers() on delayed allocation
pages, simply because these pages haven't been allocated yet
and just don't have any buffer heads attached ...

The idea Stephen and I have to solve this problem is to have
a callback into the filesystem [page->mapping->flush(page)],
so the filesystem can take care of filesystem-specific issues
and the VM subsystem takes care of VM-specific issues.

Without the need for any of the two to know much about each other.

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
