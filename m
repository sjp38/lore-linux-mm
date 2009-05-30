Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 079A65F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 18:53:17 -0400 (EDT)
Date: Sat, 30 May 2009 15:51:36 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
Message-ID: <20090530225136.GN6535@oblivion.subreption.com>
References: <20090530192829.GK6535@oblivion.subreption.com> <1243722771.6645.162.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1243722771.6645.162.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@linux-foundation.org>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On 00:32 Sun 31 May     , Peter Zijlstra wrote:
> On Sat, 2009-05-30 at 12:28 -0700, Larry H. wrote:
> > [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
> > 
> > This patch changes the ZERO_SIZE_PTR address to point at top memory
> > unmapped space, instead of the original location which could be
> > mapped from userland to abuse a NULL (or offset-from-null) pointer
> > dereference scenario.
> 
> Same goes for the regular NULL pointer, we have bits to disallow
> userspace mapping the NULL page, so I'm not exactly seeing what this
> patch buys us.

mmap_min_addr has a history of being easy to bypass. Let me get this
straight: you are arguing this doesn't bring anything new because an
additional mmap() based check exists, whose purpose is blocking NULL
from being mapped in userland. But the purpose of this patch, is making
sure that any user of ZERO_SIZE_PTR doesn't set some pointer to a
NULL+16 location, but a top memory unmapped address instead. In other
words, this is orthogonal to mmap_min_addr, preventing the situation
that mmap_min_addr is _supposed_ to block, from happening.

Both can coexist, one ensuring pointers don't get set to an userland
reachable/mmap-able region, and the other prevents such a region from
being mapped from userland.

The next patch changes LIST_POISON(1|2) to point at sane addresses as
well. Explaining why this is necessary to you will require you to
understand the security risks of unlinking doubly linked lists, etc. If
you aren't familiar with those concepts, I encourage you to look for
some literature on the matter ("Once upon a free()" is a good start, an
article published in Phrack magazine). Furthermore those changes will
only be effective when list debugging is enabled, therefore it's not
even used by the entire user base.

> > The ZERO_OR_NULL_PTR macro is changed accordingly. This patch does
> > not modify its behavior nor has any performance nor functionality
> > impact.
> 
> It does generate longer asm.

3 more bytes in amd64 (gcc 4.3.3):

 198:   48 83 ff 10             cmp    $0x10,%rdi
 19c:   74 1c                   je     1ba <kzfree+0x33>
 19e:   48 85 ff                test   %rdi,%rdi
 1a1:   74 17                   je     1ba <kzfree+0x33>
 --
 198:   48 81 ff 00 fc ff ff    cmp    $0xfffffffffffffc00,%rdi
 19f:   74 1c                   je     1bd <kzfree+0x36>
 1a1:   48 85 ff                test   %rdi,%rdi
 1a4:   74 17                   je     1bd <kzfree+0x36>

How many users of this macro exist? A dozen or so? Looks like the
security benefits of this patch outweight those 3 extra bytes.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
