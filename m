Date: Tue, 16 May 2000 06:53:22 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Estrange behaviour of pre9-1
In-Reply-To: <yttog67xqjq.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005160642440.1398-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 16 May 2000, Juan J. Quintela wrote:
> Hi
> 
> linus> That is indeed what my shink_mmap() suggested change does (ie make
> linus> "sync_page_buffers()" wait for old locked buffers). 
> 
> But your change wait for *all* locked buffers, I want to start several
> writes asynchronously and then wait for one of them.

This is pretty much exactly what my change does - no need to be
excessively clever.

Remember, we walk the LRU list from the "old" end, and whenever we hita
dirty buffer we will write it out asynchronously. AND WE WILL MOVE IT TO
THE TOP OF THE LRU QUEUE!

Which means that we will only see actual locked buffers if we have gotten
through the whole LRU queue without giving our write-outs time to
complete: which is exactly the situation where we do want to wait for
them.

So normally, we will write out a ton of buffers, and then wait for the
oldest one. You're obviously right that we may end up waiting for more
than one buffer, but when that happens it will be the right thing to do:
whenever we're waiting for the oldest buffer to flush, the others are also
likely to have flushed (remember - we started them pretty much at the same
time because we've tried hard to delay the 'run_task(&tq_disk)' too).

>						 This makes the
> system sure that we don't try to write *all* the memory in one simple
> call to try_to_free_pages.

Well, right now we cannot avoid doing that. The reason is simply that the
current MM layerdoes not know how many pages are dirty. THAT is a problem,
but it's not a problem we're going to solve for 2.4.x. 

If you actually were to use "write()", or if the load on the machine was
more balanced than just one large "mmap002", you wouldn't see the
everything-at-once behaviour, but ..

> Yes, I agree here, but this program is based in one application that
> gets Ooops in pre6 and previous kernels.  I made the test to know that
> the code works, I know that the thing that does mmap002 is very rare,
> but not one reason to begin doing Oops/killing innocent processes.
> That is all the point of that test, not optimise performance for it.

Absolutely. We apparently do not get the oopses any more, but the
out-of-memory behaviour should be fixed. And never fear, we'llget it
fixed.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
