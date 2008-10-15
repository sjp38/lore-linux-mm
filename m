From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] SLOB memory ordering issue
Date: Thu, 16 Oct 2008 03:46:58 +1100
References: <200810160334.13082.nickpiggin@yahoo.com.au>
In-Reply-To: <200810160334.13082.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810160346.59166.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 16 October 2008 03:34, Nick Piggin wrote:
> I think I see a possible memory ordering problem with SLOB:
> In slab caches with constructors, the constructor is run
> before returning the object to caller, with no memory barrier
> afterwards.
>
> Now there is nothing that indicates the _exact_ behaviour
> required here. Is it at all reasonable to expect ->ctor() to
> be visible to all CPUs and not just the allocating CPU?
>
> SLAB and SLUB don't appear to have this problem. Of course,
> they have per-CPU fastpath queues, so _can_ have effectively
> exactly the same ordering issue if the object was brought
> back into the "initialized" state before being freed, rather
> than by ->ctor(). However in that case, it is at least
> kind of visible to the caller.

Although I guess it's just as much of a SLAB implementation
detail as the lack of ->ctor() barrier... And I really doubt
_any_ of the callers would have ever thought about either
possible problem.

I'd really hate to add a branch to the slab fastpath for this
though. Maybe we just have to document it, assume there are
no problems, and maybe take a look at some of the core users
of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
