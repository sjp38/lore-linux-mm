Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC5B86B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 12:33:34 -0500 (EST)
Date: Fri, 19 Dec 2008 09:35:14 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc][patch] unlock_page speedup
In-Reply-To: <20081218233549.cb451bc8.akpm@linux-foundation.org>
Message-ID: <alpine.LFD.2.00.0812190926000.14014@localhost.localdomain>
References: <20081219072909.GC26419@wotan.suse.de> <20081218233549.cb451bc8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Thu, 18 Dec 2008, Andrew Morton wrote:
>
> On Fri, 19 Dec 2008 08:29:09 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > Introduce a new page flag, PG_waiters
> 
> Leaving how many?  fs-cache wants to take two more.

Hmm. Do we ever use lock_page() on anything but page-cache pages and the 
buffer cache?

We _could_ decide to try to move the whole locking into the "mapping" 
field, and use a few more bits in the low bits of the pointer. Right now 
we just use one bit (PAGE_MAPPING_ANON), but if we just make the rule be 
that "struct address_space" has to be 8-byte aligned, then we'd have two 
more bits available there, and we could hide the lock bit and the 
contention bit there too.

This actually would have a _really_ nice effect, in that if we do this, 
then I suspect that we could eventually even make the bits in "flags" be 
non-atomic. The lock bit really is special. The other bits tend to be 
either pretty static over allocation, or things that should be set only 
when the page is locked.

I dunno. But it sounds like a reasonable thing to do, and it would free 
one bit from the page flags, rather than use yet another one. And because 
locking is special and because we already have to access that "mapping" 
pointer specially, I don't think the impact would be very invasive.

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
