Date: Mon, 2 Oct 2000 17:24:44 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <20001002221718.B21995@athlon.random>
Message-ID: <Pine.LNX.4.21.0010021722440.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Andrea Arcangeli wrote:
> On Mon, Oct 02, 2000 at 04:59:57PM -0300, Rik van Riel wrote:
> > Linus, I remember you saying some time ago that you would
> > like to keep the buffer heads on a page around so we'd
> > have them at the point where we need to swap out again.
> 
> That's one of the basic differences between the 2.2.x and 2.4.x
> page cache design. We don't reclaim the buffers at I/O completion
> time anymore in 2.4.x but we reclaim them only later when we run
> low on memory.
> 
> Forbidding the bh to be reclaimed when we run low on memory is a
> bug and I don't think Linus ever suggested that.

*nod*

How about having the following code in refill_inactive_scan() ?

	if (page->buffers && page->mapping)
		try_to_free_buffers(page, 0);

(this will strip the buffer heads of any clean page cache
page ... we don't want to strip buffer head pages because
that would mean throwing away the data from that page)

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
