Date: Wed, 13 Aug 2008 23:46:50 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: pthread_create() slow for many threads; also time to revisit 64b context switch optimization?
Message-ID: <20080813214650.GS1366@one.firstfloor.org>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com> <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <87fxp8zlx3.fsf@basil.nowhere.org> <20080813135633.dcb8d602.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080813135633.dcb8d602.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, mingo@elte.hu, drepper@redhat.com, arjan@infradead.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, torvalds@linux-foundation.org, tglx@linutronix.de, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

> Yes, the free_area_cache is always going to have failure modes - I
> think we've been kind of waiting for it to explode.
> 
> I do think that we need an O(log(n)) search in there.  It could still
> be on the fallback path, so we retain the mostly-O(1) benefits of
> free_area_cache.

The standard dumb way to do that would be to have two parallel trees, one to 
index free space (similar to e.g. the free space btrees in XFS) and the 
other to index the objects (like today). That would increase the constant 
factor somewhat by bloating the VMAs, increasing cache overhead etc, and
also would be more brute force than elegant.   But it would be simple
and straight forward.

Perhaps the combined data structure experience of linux-kernel can come
up with something better and some data structure that allows to look
up both efficiently?

This would be also an opportunity to reevaluate rbtrees for the object
index. One drawback of them is that they are not really optimized to be 
cache friendly because their nodes are too small.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
