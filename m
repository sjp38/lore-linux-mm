Date: Mon, 25 Sep 2000 13:33:07 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: refill_inactive()
In-Reply-To: <Pine.LNX.4.10.10009250914100.1666-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0009251332510.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Linus Torvalds wrote:
> On Mon, 25 Sep 2000, Rik van Riel wrote:
> > 
> > Hmmm, doesn't GFP_BUFFER simply imply that we cannot
> > allocate new buffer heads to do IO with??
> 
> No.
> 
> New buffer heads would be ok - recursion is fine in theory, as long as it
> is bounded, and we might bound it some other way (I don't think we
> _should_ do recursion here due to the stack limit, but at least it's not
> a fundamental problem).
> 
> The fundamental problem is that GFP_BUFFER allocations are often done with
> some critical filesystem lock held. Which means that we cannot call down
> to the filesystem to free up memory.
> 
> The name is a misnomer, partly due to historical reasons (the buffer cache
> used to be fragile, and if you free'd buffer cache pages while you were
> trying to allocate new ones you could cause BadThings(tm) to happen), but
> partly just because the only _user_ of it is the buffer cache. 
> 
> In theory, filesystems could use it for any other allocations that they
> do, but in practice they don't, and the only allocations they do in
> critical regions is the buffer allocation. And as this thread has
> discussed, even that is really more of a bug than a feature.

Good thing to have this documented ;)

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
