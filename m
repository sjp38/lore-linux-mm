Date: Mon, 28 May 2001 15:07:07 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] modified memory_pressure calculation
In-Reply-To: <3B12A515.B8B207EA@colorfullife.com>
Message-ID: <Pine.LNX.4.21.0105281448570.1261-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 May 2001, Manfred Spraul wrote:

> Marcelo Tosatti wrote:
> > 
> > I disagree with the second hunk.
> > 
> > memory_pressure is used to calculate the size of _both_ the inactive dirty
> > and clean lists.
> > 
> > Since you're adding the page back to the inactive dirty list, you should
> > not increase memory_pressure.
> >
> 
> Correct. And page_launder should increase memory_pressure fore each page
> it moves back into the active list.

With the current VM code we can reach a high deactivation rate under most
heavy losts. Way too high, actually.

With a lot of heavy allocator(s), the deactivation target will become high
pretty fast, and tasks will have their pages freed way too fast.

Allocators which try to free pages themselves by calling try_to_free_pages
(in __alloc_pages()) are aging the active pages, and if we have lots of
them doing that, we have a problem.

It looks correct to make page_launder() increase memory_pressure for each
page moved to the active list, but then the problem I described above will
become even worse. 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
