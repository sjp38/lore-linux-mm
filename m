Date: Mon, 9 Oct 2000 15:07:53 -0700 (PDT)
From: jg@pa.dec.com (Jim Gettys)
Message-Id: <200010092207.PAA08714@pachyderm.pa.dec.com>
In-Reply-To: <Pine.LNX.4.10.10010091446500.1438-100000@penguin.transmeta.com>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Mime-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Jim Gettys <jg@pa.dec.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> From: Linus Torvalds <torvalds@transmeta.com>
> Date: Mon, 9 Oct 2000 14:50:51 -0700 (PDT)
> To: Jim Gettys <jg@pa.dec.com>
> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>,
>         Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>,
>         Rik van Riel <riel@conectiva.com.br>,
>         Byron Stanoszek <gandalf@winds.org>,
>         MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
> -----
> On Mon, 9 Oct 2000, Jim Gettys wrote:
> >
> >
> > On Date: Mon, 9 Oct 2000 14:38:10 -0700 (PDT), Linus Torvalds
> <torvalds@transmeta.com>
> > said:
> >
> > >
> > > The problem is that there is no way to keep track of them afterwards.
> > >
> > > So the process that gave X the bitmap dies. What now? Are we going to
> > > depend on X un-counting the resources?
> > >
> >
> > X has to uncount the resources already, to free the memory in the X server
> > allocated on behalf of that client.  X has to get this right, to be a long
> > lived server (properly debugged X servers last many months without problems:
> > unfortunately, a fair number of DDX's are buggy).
> 
> No, but my point is that it doesn't really work.
> 
> One of the biggest bitmaps is the background bitmap. So you have a client
> that uploads it to X and then goes away. There's nobody to un-count to by
> the time X decides to switch to another background.

Actually, the big offenders are things other than the background bitmap:
things like E do absolutely insane things, you would not believe (or maybe
you would).  The background pixmap is generally in the worst case typically
no worse than 4 megabytes (for those people who are crazy enough to put
images up as their root window on 32 bit deep displays, at 1kX1k resolution).

> 
> Does that memory just disappear as far as the resource handling is
> concerned when the client that originated it dies?

No, X recovers the memory when a connection dies, unless the client has
gone out of its way to arrange to preserve things across connection
termination.  Few, if any clients do this: it is primarily possible mostly
for debugging purposes, that (fortunately, or unfortunately, depending
on your opinion) what happens not just vanish before you can see what
happened.

So the X server does extensive bookkeeping of its memory usage, and retrieves
all memory used by clients when they terminate (with the above rare
exception).

> 
> What happens with TCP connections? They might be local. Or they might not.
> In either case X doesn't know whom to blame.

At least on BSD kernels, it was reasonably straightforward to determine
if a TCP connection was local: in that case, the code actually did an upcall
and delivered data directly to the appropriate socket.  Dunno about the
insides of Linux.

I suspect it should not be hard to find the right process for local
connections.  Distant connections are, indeed, a challenge.

> 
> Basically, the only thing _I_ think X can do is to really say "oh, please
> don't count my memory, because everything I do I do for my clients, not
> for myself".
> 
> THAT is my argument. Basically there is nothing we can reliably account.

Your argument has alot of validity, though the X server does a better job
of accounting than you might think.

BUT, I'm actually more interested in dealing with scheduling preferences, to
get really first rate interactive feel.

> 
> So we might as well fall back on just saying "X is more important than
> some random client", and have a mm niceness level. Which right now is
> obviously approximated by the IO capabilities tests etc.
> 

As I say above, the principle here may be more useful than for the memory 
example, but for controlling scheduling so we can get great interactive 
feel.  THAT is what is really worth discussing.
				- Jim


--
Jim Gettys
Technology and Corporate Development
Compaq Computer Corporation
jg@pa.dec.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
