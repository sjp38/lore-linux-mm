Date: Mon, 9 Oct 2000 14:50:51 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <200010092144.OAA02051@pachyderm.pa.dec.com>
Message-ID: <Pine.LNX.4.10.10010091446500.1438-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jim Gettys <jg@pa.dec.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 9 Oct 2000, Jim Gettys wrote:
> 
> 
> On Date: Mon, 9 Oct 2000 14:38:10 -0700 (PDT), Linus Torvalds <torvalds@transmeta.com>
> said:
> 
> >
> > The problem is that there is no way to keep track of them afterwards.
> >
> > So the process that gave X the bitmap dies. What now? Are we going to
> > depend on X un-counting the resources?
> >
> 
> X has to uncount the resources already, to free the memory in the X server
> allocated on behalf of that client.  X has to get this right, to be a long
> lived server (properly debugged X servers last many months without problems:
> unfortunately, a fair number of DDX's are buggy).

No, but my point is that it doesn't really work.

One of the biggest bitmaps is the background bitmap. So you have a client
that uploads it to X and then goes away. There's nobody to un-count to by
the time X decides to switch to another background.

Does that memory just disappear as far as the resource handling is
concerned when the client that originated it dies?

What happens with TCP connections? They might be local. Or they might not.
In either case X doesn't know whom to blame.

Basically, the only thing _I_ think X can do is to really say "oh, please
don't count my memory, because everything I do I do for my clients, not
for myself". 

THAT is my argument. Basically there is nothing we can reliably account.

So we might as well fall back on just saying "X is more important than
some random client", and have a mm niceness level. Which right now is
obviously approximated by the IO capabilities tests etc.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
