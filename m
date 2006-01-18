Date: Wed, 18 Jan 2006 08:38:44 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch 0/4] mm: de-skew page refcount
In-Reply-To: <20060118024106.10241.69438.sendpatchset@linux.site>
Message-ID: <Pine.LNX.4.64.0601180830520.3240@g5.osdl.org>
References: <20060118024106.10241.69438.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>


On Wed, 18 Jan 2006, Nick Piggin wrote:
>
> The following patchset (against 2.6.16-rc1 + migrate race fixes) uses the new
> atomic ops to do away with the offset page refcounting, and simplify the race
> that it was designed to cover.
> 
> This allows some nice optimisations

Why?

The real downside is that "atomic_inc_nonzero()" is a lot more expensive 
than checking for zero on x86 (and x86-64).

The reason it's offset is that on architectures that automatically test 
the _result_ of an atomic op (ie x86[-64]), it's easy to see when 
something _becomes_ negative or _becomes_ zero, and that's what

	atomic_add_negative
	atomic_inc_and_test

are optimized for (there's also "atomic_dec_and_test()" which reacts on 
the count becoming zero, but that doesn't have a pairing: there's no way 
to react to the count becoming one for the increment operation, so the 
"atomic_dec_and_test()" is used for things where zero means "free it").

Nothing else can be done that fast on x86. Everything else requires an 
insane "load, update, cmpxchg" sequence.

So I disagree with this patch series. It has real downsides. There's a 
reason we have the offset.

I suspect that whatever "nice optimizations" you have are quite doable 
without doing this count pessimization.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
