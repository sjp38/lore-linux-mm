Date: Wed, 13 Aug 2008 13:56:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: pthread_create() slow for many threads; also time to revisit
 64b context switch optimization?
Message-Id: <20080813135633.dcb8d602.akpm@linux-foundation.org>
In-Reply-To: <87fxp8zlx3.fsf@basil.nowhere.org>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com>
	<af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com>
	<20080813104445.GA24632@elte.hu>
	<20080813063533.444c650d@infradead.org>
	<48A2EE07.3040003@redhat.com>
	<20080813142529.GB21129@elte.hu>
	<48A2F157.7000303@redhat.com>
	<20080813151007.GA8780@elte.hu>
	<87fxp8zlx3.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: mingo@elte.hu, drepper@redhat.com, arjan@infradead.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, torvalds@linux-foundation.org, tglx@linutronix.de, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

On Wed, 13 Aug 2008 22:42:48 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> Ingo Molnar <mingo@elte.hu> writes:
> >
> > i find it pretty unacceptable these days that we limit any aspect of 
> > pure 64-bit apps in any way to 4GB (or any other 32-bit-ish limit). 
> 
> It's not limited to 2GB, there's a fallback to >4GB of course. Ok
> admittedly the fallback is slow, but it's there.
> 
> I would prefer to not slow down the P4s. There are **lots** of them in
> field. And they ran 64bit still quite well. Also back then I
> benchmarked on early K8 and it also made a difference there (but I
> admit I forgot the numbers)
> 
> I think it would be better to fix the VM because there are
> other use cases of applications who prefer to allocate in a lower area.
> For example Java JVMs now widely use a technique called pointer
> compression where they dynamically adjust the pointer size based
> on how much memory the process uses. For that you have to get
> low memory in the 47bit VM too. The VM should deal with that gracefully.
> 
> To be honest I always thought the linear search in the VMA list
> was a little dumb. I'm sure there are other cases where it hurts
> too. Perhaps this would be really an opportunity  to do something about it :)
> 

Yes, the free_area_cache is always going to have failure modes - I
think we've been kind of waiting for it to explode.

I do think that we need an O(log(n)) search in there.  It could still
be on the fallback path, so we retain the mostly-O(1) benefits of
free_area_cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
