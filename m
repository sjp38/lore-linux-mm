Date: Mon, 9 Apr 2001 13:32:41 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <200104091816.f39IGxD16018@devserv.devel.redhat.com>
Message-ID: <Pine.LNX.4.31.0104091316500.9383-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 9 Apr 2001, Alan Cox wrote:
>
> Given that strict address space management is not that hard would you
> accept patches to allow optional non-overcommit in 2.5

I really doubt anybody wants to use a truly non-overcommit system.

It would basically imply counting every single vma that is privately
writable, and assuming it becomes totally non-shared.

Try this on your system as root:

	cat /proc/*/maps | grep ' .w.p '

and see how much memory that is.

On my machine, running X, that's about 53M with just a few windows open if
I did my script right. It grew to 159M when starting StarOffice.

(I'm oldfashioned, and not a perl person, so:

	cat /proc/*/maps |
		grep 'w.p ' |
		cut -d' ' -f1 |
		tr '-' ' ' |
		while read i  j; do export k=$(($k + 0x$j-0x$i)) ; echo $k; done

I haven't verified that it gets it right. And that's not counting the
really hardwired pages at all, only th epages that might be pageable).

It would disallow a lot of stuff that actually _does_ work in practice.

But maybe some people do want this. I agree that it shouldn't be
fundamentally hard to do accounting at the vma level.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
