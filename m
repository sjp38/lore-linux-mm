Date: Tue, 9 Jan 2001 16:23:36 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.21.0101092011520.7500-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101091618110.2815-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 9 Jan 2001, Marcelo Tosatti wrote:
> > 
> > No, I'm saying that "the background scanning" should not do the page
> > aging.
> 
> If you age pages only when there is memory pressure/low memory, you'll
> have less knowledge about which pages were unused/used pages over time.

Hmm.. Fair enough. However, if you don't have VM pressure, you're also not
going to look at the page tables, so you are not going to get any use
information from them, either. 

The aging should really be done at roughly the same rate as the "mark
active", wouldn't you say? If you mark things active without aging, pages
end up all being marked as "new". And if you age without marking things
active, they all end up being "old". Neither is good. What you really want
to have is aging that happens at the same rate as reference marking.

So one "conditional aging" algorithm might just be something as simple as

 - every time you mark something referenced, you increment a counter
 - every time you want to age something, you check whethe rthe counter is
   positive first (and decrement it if you age something)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
