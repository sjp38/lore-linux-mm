Date: Thu, 4 Jul 2002 21:47:48 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: vm lock contention reduction
In-Reply-To: <Pine.LNX.4.44L.0207042315560.6047-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.44.0207042135270.7343-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Thu, 4 Jul 2002, Rik van Riel wrote:
>
> We want something smarter anyway.  It just doesn't make
> sense to throttle on one page in one memory zone while
> the pages in another zone could have already become
> freeable by now.

That's a load of bull, and a backed up by zero amount of arguments. It
only sounds correct, while being absolute crap.

We need to throttle. Full stop. Anybody who says that "it makes no sense
to throttle on X because of Y" had better back up that statement with
_facts_, not some handwaving.

In the end, somebody needs to wait. There is no free lunch. And the fact
is, the _reason_ for the waiting doesn't much matter, it only needs to be
related to the act of freeing pages by some likely metric. And it should
wait for _more_ than the one page we absolutely need.

OF COURSE you can always end up avoiding to wait for reason Y. That only
means that you end up having to wait on reason Z at some later date.

The particular example Rik brought up is particularly stupid, since it's
obviously crap and not true. The fact is, that when you allocate memory
and you're low on memory, you _have_ to wait "more" than necessary. You
want to try to get away from the bad situation, so when you start waiting,
you should wait a bit "extra", so that you might not need to wait
immediately for the very next allocation.

And Rik's argument (and I saw people go "nod nod" like marionettes on a
string without even thinking about it) is exactly the wrong way around and
basically says that you should wait the _minimal_ amount possible. Yet
that is NOT correct, because that will absolutely guarantee that
_everybody_ ends up always waiting.

I saw this argument at the kernel summit too, thinking that waiting the
minimal amount of time is somehow "better". It's not. It's much better to
try to maek processes wait slightly _longer_ times, and get into a nice
balanced setup where you do intensive work for a while, then wait for a
while, then do work again, then wait.. Instead of waiting a bit all the
time.

Think batching. It's _more_ efficient to batch stuff than it is to try to
switch back and forth between working and waiting as quickly as you can.

So don't just nod your heads when you see something that sounds sane.
Think critically. And the critical thinking says:

 - you should wait the _maximum_ amount that
   (a) is fair
   (b) doesn't introduce bad latency issues
   (c) still allows overlap of IO and processing

Get away from this "minimum wait" thing, because it is WRONG.

Try to shoot me down, but do so with real logic and real arguments, not
some fuzzy feeling about "we shouldn't wait unless we have to". We _do_
have to wait.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
