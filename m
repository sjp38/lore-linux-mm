From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200006212110.OAA53717@google.engr.sgi.com>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Date: Wed, 21 Jun 2000 14:10:17 -0700 (PDT)
In-Reply-To: <20000621210620Z131176-21003+33@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 03:59:51 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> > Yes, this is saying that although we waste physical memory (which few
> > people care about any more), some of the unused space is never cached,
> > since it is not accessed (although hardware processor prefetches might
> > change this assumption a little bit). So, valuable cache space is not 
> > wasted that can be used to hold data/code that is actually used.
> > 
> > What I was warning you about is that if you shrink the array to the
> > exact size, there might be other data that comes on the same cacheline,
> > which might cause all kinds of interesting behavior (I think they call
> > this false cache sharing or some such thing).
> 
> Ok, I understand your explanation, but I have a hard time seeing how false
> cache sharing can be a bad thing.
> 
> If the cache sucks up a bunch of zeros that are never used, that's definitely
> wasted cache space.  How can that be any better than sucking up some real data
> that can be used?
>

Okay, I will shut up since I will have to pull out old notes and books
to convince you, but basically, here's a simple example. Say a L2 cache 
line is 128 bytes, and each array element is 16 bytes, giving 8 array 
elements per cache line. Say you decide to eliminate the last element,
maybe because it is not used. So, in that space, two global integers/
spinlocks etc are packed in after the deletion. Further assume these
two integers are frequently updated. Looking at an SMP system that uses
the exlusive write cache update protocol, the cache line will probably
bounce between the different L2 caches, which is quite bad, assuming 
that the original 8 element array was readonly, and was probably 
coresident in all the caches.

Till now, this has been a completely academic decision. I suggest if
you are serious, go ahead and make the change, then try running few
simple benchmarks (kernel compiles possibly), and if you see no 
performance regression, post the patch, and send it to Alan and Linus.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
